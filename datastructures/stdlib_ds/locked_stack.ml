open Stdlib.Stack

type 'a t = { stack : 'a Stdlib.Stack.t; lock : Mutex.t }

let create () = { stack = create (); lock = Mutex.create () }

let pop_opt q =
  Mutex.lock q.lock;
  let res = pop_opt q.stack in
  Mutex.unlock q.lock;
  res

let push q a =
  Mutex.lock q.lock;
  push a q.stack;
  Mutex.unlock q.lock
