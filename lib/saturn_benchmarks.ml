open Data_intf

let benchmarks_seq =
  let name benchname = "One_domain_" ^ benchname in
  [
    ( name "Stdlib.Queue",
      let module Bench = Seq_bench.Make ((Stdlib_ds.Queue : QUEUE)) in
      Bench.run_suite );
    ( name "protected_Stdlib.Queue",
      let module Bench = Seq_bench.Make ((Stdlib_ds.Locked_queue : QUEUE)) in
      Bench.run_suite );
    ( name "Saturn_lockfree.Queue",
      let module Bench = Seq_bench.Make ((Saturn_lockfree.Queue : QUEUE)) in
      Bench.run_suite );
    ( name "Optimized_MS_queue",
      let module Bench = Seq_bench.Make ((Michael_scott_queue : QUEUE)) in
      Bench.run_suite );
    ( name "Saturn_lockfree_Two-stack_Queue",
      let module Bench = Seq_bench.Make ((Two_stack_queue : QUEUE)) in
      Bench.run_suite );
    ( name "Stdlib_Stack",
      let module Bench = Seq_bench.Make ((Stdlib_ds.Stack : QUEUE)) in
      Bench.run_suite );
    ( name "protected_Stdlib.Stack",
      let module Bench = Seq_bench.Make ((Stdlib_ds.Locked_stack : QUEUE)) in
      Bench.run_suite );
    ( name "Atomic_list",
      let module Bench = Seq_bench.Make ((Basic_stack.Not_opti : QUEUE)) in
      Bench.run_suite );
    ( name "Optimed_Atomic_list",
      let module Bench = Seq_bench.Make ((Basic_stack : QUEUE)) in
      Bench.run_suite );
    ( name "Saturn_lockfree.Stack",
      let module Bench = Seq_bench.Make ((Saturn_lockfree.Stack : QUEUE)) in
      Bench.run_suite );
  ]

let benchmarks_par =
  let name benchname = "Parallel_" ^ benchname in
  [
    ( name "Stdlib_Queue_with_mutex",
      let module Bench = Par_bench.Make ((Stdlib_ds.Locked_queue : QUEUE)) in
      Bench.run_suite );
    ( name "Saturn_lockfree_Queue",
      let module Bench = Par_bench.Make ((Saturn_lockfree.Queue : QUEUE)) in
      Bench.run_suite );
    ( name "Optimized_MS_queue",
      let module Bench = Par_bench.Make ((Michael_scott_queue : QUEUE)) in
      Bench.run_suite );
    ( name "Saturn_lockfree_Two-stack_Queue",
      let module Bench = Par_bench.Make ((Two_stack_queue : QUEUE)) in
      Bench.run_suite );
    ( name "Stdlib_Stack_with_mutex",
      let module Bench = Par_bench.Make ((Stdlib_ds.Locked_stack : QUEUE)) in
      Bench.run_suite );
    ( name "Atomic_list",
      let module Bench = Par_bench.Make ((Basic_stack.Not_opti : QUEUE)) in
      Bench.run_suite );
    ( name "Optized_Atomic_list",
      let module Bench = Par_bench.Make ((Basic_stack : QUEUE)) in
      Bench.run_suite );
    ( name "Saturn_lockfree_Stack",
      let module Bench = Par_bench.Make ((Saturn_lockfree.Stack : QUEUE)) in
      Bench.run_suite );
  ]

let () =
  Multicore_bench.Cmd.run ~benchmarks:(benchmarks_seq @ benchmarks_par) ()
