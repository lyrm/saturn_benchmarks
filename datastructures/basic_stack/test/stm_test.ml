open QCheck
open STM
module Stack = Basic_stack

module Spec = struct
  type cmd = Push of int | Pop

  let show_cmd c =
    match c with Push i -> "Push " ^ string_of_int i | Pop -> "Pop"

  type state = int list
  type sut = int Stack.t

  let arb_cmd _s =
    let int_gen = Gen.nat in
    QCheck.make ~print:show_cmd
      (Gen.oneof [ Gen.map (fun i -> Push i) int_gen; Gen.return Pop ])

  let init_state = []
  let init_sut () = Stack.create ()
  let cleanup _ = ()

  let next_state c s =
    match c with
    | Push i -> i :: s
    | Pop -> ( match s with [] -> s | _ :: s' -> s')

  let precond _ _ = true

  let run c d =
    match c with
    | Push i -> Res (unit, Stack.push_exn d i)
    | Pop -> Res (option int, Stack.pop_opt d)

  let postcond c (s : state) res =
    match (c, res) with
    | Push _, Res ((Unit, _), _) -> true
    | Pop, Res ((Option Int, _), res) -> (
        match s with [] -> res = None | j :: _ -> res = Some j)
    | _, _ -> false
end

let () =
  Stm_run.run ~count:500 ~verbose:true ~name:"Saturn_lockfree.Treiber_stack"
    (module Spec)
  |> exit
