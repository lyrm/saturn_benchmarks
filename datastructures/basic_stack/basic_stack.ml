type 'a t = 'a list Atomic.t

let create () = Atomic.make_contended []

let push_exn q a =
  let old = Atomic.get q in
  if Atomic.compare_and_set q old (a :: old) then ()
  else
    let rec push ~backoff q a =
      let old = Atomic.get q in
      if Atomic.compare_and_set q old (a :: old) then ()
      else
        let backoff = Backoff.once backoff in
        push ~backoff q a
    in
    push ~backoff:Backoff.default q a

let pop_opt q =
  let old = Atomic.get q in
  match old with
  | [] -> None
  | x :: xs ->
      if Atomic.compare_and_set q old xs then Some x
      else
        let rec pop ~backoff q =
          let old = Atomic.get q in
          match old with
          | [] -> None
          | x :: xs ->
              if Atomic.compare_and_set q old xs then Some x
              else
                let backoff = Backoff.once backoff in
                pop ~backoff q
        in
        pop ~backoff:Backoff.default q

module Not_opti = struct
  type 'a t = 'a list Atomic.t

  let create () = Atomic.make []

  let rec push_exn q a =
    let old = Atomic.get q in
    if Atomic.compare_and_set q old (a :: old) then () else push_exn q a

  let rec pop_opt q =
    let old = Atomic.get q in
    match old with
    | [] -> None
    | x :: xs -> if Atomic.compare_and_set q old xs then Some x else pop_opt q
end
