[@@@ocaml.warning "-32"]

open Data_intf

module Saturn_queue : QUEUE = struct
  include Saturn_lockfree.Queue

  let push_exn = push
end

module Saturn_stack : QUEUE = struct
  include Saturn_lockfree.Stack

  let push_exn = push
end

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
      let module Bench = Seq_bench.Make ((Saturn_queue : QUEUE)) in
      Bench.run_suite );
    ( name "Safe_Michael_Scott_Queue_raw",
      let module Bench = Seq_bench.Make ((
        Ms_queues.Safe_michael_scott_queue : QUEUE)) in
      Bench.run_suite );
    ( name "Optimized_Michael_Scott_Queue",
      let module Bench = Seq_bench.Make ((
        Ms_queues.Opti_michael_scott_queue : QUEUE)) in
      Bench.run_suite );
    ( name "Michael_Scott_Queue_raw+pop_as",
      let module Bench = Seq_bench.Make ((
        Ms_queues.Michael_scott_queue_1 : QUEUE)) in
      Bench.run_suite );
    ( name "Michael_Scott_Queue_raw+pop_as+gadt+push_backoff",
      let module Bench = Seq_bench.Make ((
        Ms_queues.Michael_scott_queue_3 : QUEUE)) in
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
    ( name "Atomic_list_Stack",
      let module Bench = Seq_bench.Make ((Basic_stack.Not_opti : QUEUE)) in
      Bench.run_suite );
    ( name "Optimed_Atomic_list_Stack",
      let module Bench = Seq_bench.Make ((Basic_stack : QUEUE)) in
      Bench.run_suite );
    ( name "Saturn_lockfree.Stack",
      let module Bench = Seq_bench.Make ((Saturn_stack : QUEUE)) in
      Bench.run_suite );
  ]

let benchmarks_par =
  let name benchname = "Parallel_" ^ benchname in
  [
    ( name "Stdlib_Queue_with_mutex",
      let module Bench = Par_bench.Make ((Stdlib_ds.Locked_queue : QUEUE)) in
      Bench.run_suite );
    ( name "Saturn_lockfree_Queue",
      let module Bench = Par_bench.Make ((Saturn_queue : QUEUE)) in
      Bench.run_suite );
    ( name "Safe_Michael_Scott_Queue_version_raw",
      let module Bench = Par_bench.Make ((
        Ms_queues.Safe_michael_scott_queue : QUEUE)) in
      Bench.run_suite );
    ( name "Optimized_Michael_Scott_Queue",
      let module Bench = Par_bench.Make ((
        Ms_queues.Opti_michael_scott_queue : QUEUE)) in
      Bench.run_suite );
    ( name "Michael_Scott_Queue_raw+pop_as",
      let module Bench = Par_bench.Make ((
        Ms_queues.Michael_scott_queue_1 : QUEUE)) in
      Bench.run_suite );
    ( name "Michael_Scott_Queue_raw+pop_as+inlined_push",
      let module Bench = Par_bench.Make ((
        Ms_queues.Michael_scott_queue_2 : QUEUE)) in
      Bench.run_suite );
    ( name "Michael_Scott_Queue_raw+pop_as+inlined_push+backoff",
      let module Bench = Par_bench.Make ((
        Ms_queues.Michael_scott_queue_2b : QUEUE)) in
      Bench.run_suite );
    ( name "Michael_Scott_Queue_raw+pop_as+gadt+push_backoff",
      let module Bench = Par_bench.Make ((
        Ms_queues.Michael_scott_queue_3 : QUEUE)) in
      Bench.run_suite );
    ( name "Saturn_lockfree_Two-stack_Queue",
      let module Bench = Par_bench.Make ((Two_stack_queue : QUEUE)) in
      Bench.run_suite );
    ( name "Stdlib_Stack_with_mutex",
      let module Bench = Par_bench.Make ((Stdlib_ds.Locked_stack : QUEUE)) in
      Bench.run_suite );
    ( name "Atomic_list_Stack",
      let module Bench = Par_bench.Make ((Basic_stack.Not_opti : QUEUE)) in
      Bench.run_suite );
    ( name "Optized_Atomic_list_Stack",
      let module Bench = Par_bench.Make ((Basic_stack : QUEUE)) in
      Bench.run_suite );
    ( name "Saturn_lockfree_Stack",
      let module Bench = Par_bench.Make ((Saturn_stack : QUEUE)) in
      Bench.run_suite );
  ]

let benchmarks_spsc =
  let open Spsc_queues in
  let name benchname = "Spsc_queue " ^ benchname in
  [
    ( name "Original (no optimization)",
      let module Bench = Spsc_queue_bench.Make ((
        Spsc_queue_original : SPSC_QUEUE)) in
      Bench.run_suite );
    ( name "Original + padding",
      let module Bench = Spsc_queue_bench.Make ((
        Spsc_queue_with_padding : SPSC_QUEUE)) in
      Bench.run_suite );
    (* ( name "Saturn - padding",
       let module Bench = Spsc_queue_bench.Make ((
         Saturn_spsc_queue_no_padding : SPSC_QUEUE)) in
       Bench.run_suite ); *)
    ( name "Saturn",
      let module Bench = Spsc_queue_bench.Make ((Saturn_spsc_queue : SPSC_queue)) in
      Bench.run_suite );
    (* ( name "Saturn + padding",
       let module Bench = Spsc_queue_bench.Make ((
         Saturn_spsc_queue_with_full_padding : SPSC_QUEUE)) in
       Bench.run_suite ); *)
    (* ( name "Saturn + padding + relaxed read",
         let module Bench = Spsc_queue_bench.Make ((
           Saturn_spsc_queue_with_padding_relaxed_read : SPSC_QUEUE)) in
         Bench.run_suite );
       ( name "Saturn + padding + relaxed read + no indirection",
         let module Bench = Spsc_queue_bench.Make ((
           Saturn_spsc_with_padding_relaxed_option : SPSC_QUEUE)) in
         Bench.run_suite ); *)
    ( name "Saturn_unsafe",
      let module Bench = Spsc_queue_bench.Make ((
        Saturn_spsc_queue_unsafe : SPSC_QUEUE)) in
      Bench.run_suite );
  ]

let () =
  Multicore_bench.Cmd.run
    ~benchmarks:(benchmarks_seq @ benchmarks_par (* @ benchmarks_spsc *))
    ()
