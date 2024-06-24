(*
 * Copyright (c) 2015, Théo Laurent <theo.laurent@ens.fr>
 * Copyright (c) 2015, KC Sivaramakrishnan <sk826@cl.cam.ac.uk>
 * Copyright (c) 2023, Vesa Karvonen <vesa.a.j.k@gmail.com>
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

(* Michael-Scott queue *)

(* type 'a node = Nil | Next of 'a * 'a node Atomic.t

   type 'a t = {
     head : 'a node Atomic.t Atomic.t;
     tail : 'a node Atomic.t Atomic.t;
   } *)

type ('a, _) node =
  | Nil : ('a, [> `Nil ]) node
  | Next : {
      next : ('a, [ `Nil | `Next ]) node Atomic.t;
      mutable value : 'a;
    }
      -> ('a, [> `Next ]) node

type 'a t = {
  head : ('a, [ `Next ]) node Atomic.t;
  tail : ('a, [ `Next ]) node Atomic.t;
}

let create () =
  let node = Next { value = Obj.magic (); next = Atomic.make Nil } in
  let head = Atomic.make_contended node in
  let tail = Atomic.make_contended node in
  { head; tail }

let[@inline] get_first_node (head : (_, [ `Next ]) node Atomic.t) =
  let (Next { next; _ }) = Atomic.get head in
  next

let is_empty { head; _ } =
  match Atomic.get (get_first_node head) with Nil -> true | _ -> false

exception Empty

type ('a, _) poly = Option : ('a, 'a option) poly | Value : ('a, 'a) poly

let rec pop_as :
    type a r. (a, [ `Next ]) node Atomic.t -> Backoff.t -> (a, r) poly -> r =
 fun head backoff poly ->
  let old_head = Atomic.get head head in
  match Atomic.get old_head with
  | Nil -> begin match poly with Option -> None | Value -> raise Empty end
  | Next r as new_head ->
      if Atomic.compare_and_set head old_head new_head then begin
        match poly with Value -> r | Option -> Some r
      end
      else
        let backoff = Backoff.once backoff in
        pop_as head backoff poly

let pop_opt t = pop_as t.head Backoff.default Option
let pop_exn t = pop_as t.head Backoff.default Value

let rec peek_as : type a r. a node Atomic.t Atomic.t -> (a, r) poly -> r =
 fun head poly ->
  let old_head = Atomic.get head in
  match Atomic.get old_head with
  | Nil -> begin match poly with Option -> None | Value -> raise Empty end
  | Next (r, _) -> ( match poly with Value -> r | Option -> Some r)

let peek_opt t = peek_as t.head Option
let peek_exn t = peek_as t.head Value

let rec fix_tail tail new_tail backoff =
  let old_tail = Atomic.get tail in
  if
    Atomic.get new_tail == Nil
    && not (Atomic.compare_and_set tail old_tail new_tail)
  then fix_tail tail new_tail (Backoff.once backoff)

let push_exn { tail; _ } value =
  let rec find_tail_and_enq curr_end node =
    if not (Atomic.compare_and_set curr_end Nil node) then
      match Atomic.get curr_end with
      | Nil -> find_tail_and_enq curr_end node
      | Next (_, n) -> find_tail_and_enq n node
  in
  let new_tail = Atomic.make Nil in
  let newnode = Next (value, new_tail) in
  let old_tail = Atomic.get tail in
  find_tail_and_enq old_tail newnode;
  if not (Atomic.compare_and_set tail old_tail new_tail) then
    let backoff = Backoff.once Backoff.default in
    fix_tail tail new_tail backoff


    (*
type 'a node = Nil | Next of 'a * 'a node Atomic.t
type 'a t = { head : 'a node Atomic.t; tail : 'a node Atomic.t }

let pop q =
  let b = Backoff.create () in
  let rec loop () =
    let s = Atomic.get q.head in
    let nhead =
      match s with
      | Nil -> failwith "MSQueue.pop: impossible"
      | Next (_, x) -> Atomic.get x
    in
    match nhead with
    | Nil -> None
    | Next (v, _) when Atomic.compare_and_set q.head s nhead -> Some v
    | _ ->
        Backoff.once b;
        loop ()
  in
  loop ()

type 'a t = {
  head : 'a node Atomic.t Atomic.t;
  tail : 'a node Atomic.t Atomic.t;
}

let pop { head; _ } =
  let b = Backoff.create () in
  let rec loop () =
    let old_head = Atomic.get head in
    match Atomic.get old_head with
    | Nil -> None
    | Next (value, next) when Atomic.compare_and_set head old_head next ->
        Some value
    | _ ->
        Backoff.once b;
        loop ()
  in
  loop ()
*)