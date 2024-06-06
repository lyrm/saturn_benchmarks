open Stdlib.Queue

type 'a t = { queue : 'a Stdlib.Queue.t; lock : Mutex.t }

let create () = { queue = create (); lock = Mutex.create () }

let pop_opt q =
  Mutex.lock q.lock;
  let res = take_opt q.queue in
  Mutex.unlock q.lock;
  res

let push_exn q a =
  Mutex.lock q.lock;
  push a q.queue;
  Mutex.unlock q.lock
