open Data_intf

let benchmarks_seq =
  [
    ( "One domain Stdlib Queue",
      let module Bench = Seq_bench.Make ((Stdlib_ds.Queue : QUEUE)) in
      Bench.run_suite );
    ( "One domain Stdlib Queue with mutex ",
      let module Bench = Seq_bench.Make ((Stdlib_ds.Locked_queue : QUEUE)) in
      Bench.run_suite );
    ( "One domain Saturn_lockfree Queue",
      let module Bench = Seq_bench.Make ((Saturn_lockfree.Queue : QUEUE)) in
      Bench.run_suite );
    ( "One domain Optimized MS queue",
      let module Bench = Seq_bench.Make ((Michael_scott_queue : QUEUE)) in
      Bench.run_suite );
    ( "One domain Saturn_lockfree Two-stack Queue",
      let module Bench = Seq_bench.Make ((Two_stack_queue : QUEUE)) in
      Bench.run_suite );
    ( "One domain Stdlib Stack",
      let module Bench = Seq_bench.Make ((Stdlib_ds.Stack : QUEUE)) in
      Bench.run_suite );
    ( "One domain Stdlib Stack with mutex ",
      let module Bench = Seq_bench.Make ((Stdlib_ds.Locked_stack : QUEUE)) in
      Bench.run_suite );
    ( "One domain Atomic list ",
      let module Bench = Seq_bench.Make ((Basic_stack : QUEUE)) in
      Bench.run_suite );
    ( "One domain Saturn_lockfree Stack",
      let module Bench = Seq_bench.Make ((Saturn_lockfree.Stack : QUEUE)) in
      Bench.run_suite );
  ]

let benchmarks_par =
  [
    ( "Parallel Stdlib Queue with mutex ",
      let module Bench = Par_bench.Make ((Stdlib_ds.Locked_queue : QUEUE)) in
      Bench.run_suite );
    ( "Parallel Saturn_lockfree Queue",
      let module Bench = Par_bench.Make ((Saturn_lockfree.Queue : QUEUE)) in
      Bench.run_suite );
    ( "Parallel Optimized MS queue",
      let module Bench = Par_bench.Make ((Michael_scott_queue : QUEUE)) in
      Bench.run_suite );
    ( "Parallel Saturn_lockfree Two-stack Queue",
      let module Bench = Par_bench.Make ((Two_stack_queue : QUEUE)) in
      Bench.run_suite );
    ( "Parallel Stdlib Stack with mutex ",
      let module Bench = Par_bench.Make ((Stdlib_ds.Locked_stack : QUEUE)) in
      Bench.run_suite );
    ( "Parallel Atomic list ",
      let module Bench = Par_bench.Make ((Basic_stack : QUEUE)) in
      Bench.run_suite );
    ( "Parallel Saturn_lockfree Stack",
      let module Bench = Par_bench.Make ((Saturn_lockfree.Stack : QUEUE)) in
      Bench.run_suite );
  ]

let () =
  Multicore_bench.Cmd.run ~benchmarks:(benchmarks_seq @ benchmarks_par) ()
