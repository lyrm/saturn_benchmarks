open Multicore_bench
open Data_intf

module Make (Queue : QUEUE) = struct
  let run_suite ~budgetf =
    let n_msgs = 50 * Util.iter_factor in
    let t = Queue.create () in

    let op push =
      if push then Queue.push_exn t 101 else Queue.pop_opt t |> ignore
    in

    let init _ = Util.generate_push_and_pop_sequence n_msgs in
    let work _ bits = Util.Bits.iter op bits in

    Times.record ~budgetf ~n_domains:1 ~init ~work ()
    |> Times.to_thruput_metrics ~n:n_msgs ~singular:"message"
         ~config:"one domain"
end
