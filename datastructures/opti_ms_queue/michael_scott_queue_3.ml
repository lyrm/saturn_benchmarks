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

type ('a, _) node =
  | Nil : ('a, [> `Nil ]) node
  | Next : {
      next : ('a, [ `Nil | `Next ]) node Atomic.t;
      mutable value : 'a option;
    }
      -> ('a, [> `Next ]) node

let[@inline] make_node value = Next { next = Atomic.make Nil; value }

type 'a t = {
  head : ('a, [ `Next ]) node Atomic.t;
  tail : ('a, [ `Next ]) node Atomic.t;
}

let create () =
  let node = make_node None in
  let head = Atomic.make_contended node in
  let tail = Atomic.make_contended node in
  { head; tail }

let is_empty t =
  let (Next node) = Atomic.get t.head in
  Atomic.get node.next == Nil

exception Empty

type ('a, _) poly = Option : ('a, 'a option) poly | Value : ('a, 'a) poly

let rec pop_as :
    type a r. (a, [ `Next ]) node Atomic.t -> Backoff.t -> (a, r) poly -> r =
 fun head backoff poly ->
  let (Next node as old_head) = Atomic.get head in
  match Atomic.get node.next with
  | Nil -> begin match poly with Value -> raise Empty | Option -> None end
  | Next r as new_head ->
      if Atomic.compare_and_set head old_head new_head then begin
        match poly with
        | Value ->
            let value = Option.get r.value in
            r.value <- None;
            value
        | Option ->
            let value = r.value in
            r.value <- None;
            value
      end
      else
        let backoff = Backoff.once backoff in
        pop_as head backoff poly

let pop t = pop_as t.head Backoff.default Value
let pop_opt t = pop_as t.head Backoff.default Option

let peek_as : type a r. (a, [ `Next ]) node Atomic.t -> (a, r) poly -> r =
 fun head poly ->
  let (Next node) = Atomic.get head in
  match Atomic.get node.next with
  | Nil -> begin
      match poly with Value -> raise Empty | Option -> raise Empty
    end
  | Next r -> (
      match poly with Value -> Option.get r.value | Option -> r.value)

let peek_opt t = peek_as t.head Option
let peek_exn t = peek_as t.head Value

let rec fix_tail (tail : ('a, [ `Next ]) node Atomic.t)
    (Next node as new_tail : ('a, [ `Next ]) node) backoff =
  let old_tail = Atomic.get tail in
  if
    Atomic.get node.next == Nil
    && not (Atomic.compare_and_set tail old_tail new_tail)
  then fix_tail tail new_tail (Backoff.once backoff)

let rec push tail link (Next _ as new_node : (_, [ `Next ]) node) backoff =
  match Atomic.get link with
  | Nil ->
      if Atomic.compare_and_set link Nil new_node then begin
        fix_tail tail new_node Backoff.default
      end
      else
        let backoff = Backoff.once backoff in
        push tail link new_node backoff
  | Next r -> push tail r.next new_node backoff

let push_exn t value =
  let (Next _ as new_node : (_, [ `Next ]) node) = make_node (Some value) in
  let (Next node as old_tail) = Atomic.get t.tail in
  let link = node.next in
  if Atomic.compare_and_set link Nil new_node then
    Atomic.compare_and_set t.tail old_tail new_node |> ignore
  else
    let backoff = Backoff.once Backoff.default in
    push t.tail link new_node backoff
