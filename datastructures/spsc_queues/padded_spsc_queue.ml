(*
 * Copyright (c) 2022, Bartosz Modelski
 * Copyright (c) 2024, Vesa Karvonen
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *)

(* Single producer single consumer queue
 *
 * The algorithms here are inspired by:

 * https://dl.acm.org/doi/pdf/10.1145/3437801.3441583
 *)

type 'a t = {
  array : 'a Option.t Array.t;
  tail : int Atomic.t;
  tail_cache : int ref;
  head : int Atomic.t;
  head_cache : int ref;
}

exception Full

let create ~size_exponent =
  if size_exponent < 0 || Sys.int_size - 2 < size_exponent then
    invalid_arg "size_exponent out of range";
  let size = 1 lsl size_exponent in
  let array = Array.make size (Obj.magic ()) in
  let tail = Atomic.make_contended 0 in
  let tail_cache = ref 0 |> Multicore_magic.copy_as_padded in
  let head = Atomic.make_contended 0 in
  let head_cache = ref 0 |> Multicore_magic.copy_as_padded in
  { array; tail; tail_cache; head; head_cache }
  |> Multicore_magic.copy_as_padded

let push_exn { array; head; tail; _ } element =
  let head_val = Atomic.get head in
  let tail_val = Atomic.get tail in
  let size = Array.length array in
  if head_val + size == tail_val then raise Full
  else (
    Array.set array (tail_val land (size - 1)) (Some element);
    Atomic.set tail (tail_val + 1))

let try_push { array; head; tail; _ } element =
  let head_val = Atomic.get head in
  let tail_val = Atomic.get tail in
  let size = Array.length array in
  if head_val + size == tail_val then false
  else (
    Array.set array (tail_val land (size - 1)) (Some element);
    Atomic.set tail (tail_val + 1);
    true)

exception Empty

let pop_exn { array; head; tail; _ } =
  let head_val = Atomic.get head in
  let tail_val = Atomic.get tail in
  if head_val == tail_val then raise Empty
  else
    let index = head_val land (Array.length array - 1) in
    let v = Array.get array index in
    (* allow gc to collect it *)
    Array.set array index None;
    Atomic.set head (head_val + 1);
    match v with None -> assert false | Some v -> v

let pop_opt { array; head; tail; _ } =
  let head_val = Atomic.get head in
  let tail_val = Atomic.get tail in
  if head_val == tail_val then None
  else
    let index = head_val land (Array.length array - 1) in
    let v = Array.get array index in
    (* allow gc to collect it *)
    Array.set array index None;
    Atomic.set head (head_val + 1);
    assert (Option.is_some v);
    v

let peek_opt { array; head; tail; _ } =
  let head_val = Atomic.get head in
  let tail_val = Atomic.get tail in
  if head_val == tail_val then None
  else
    let v = Array.get array @@ (head_val land (Array.length array - 1)) in
    assert (Option.is_some v);
    v

let peek_exn { array; head; tail; _ } =
  let head_val = Atomic.get head in
  let tail_val = Atomic.get tail in
  if head_val == tail_val then raise Empty
  else
    let v = Array.get array @@ (head_val land (Array.length array - 1)) in
    match v with None -> assert false | Some v -> v

let size { head; tail; _ } = Atomic.get tail - Atomic.get head
