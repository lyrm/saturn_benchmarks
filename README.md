# Benchmarks for Saturn library.
This repository put together benchmarks for [Saturn's](https://github.com/ocaml-multicore/saturn/) data structures. 


## Running the Benchmarks

To run the benchmarks, use the following command:
```
dune exec -- ./src/saturn_benchmarks.exe -budget 1
```

To print the help information, use the `-help` option:
```
dune exec -- ./src/saturn_benchmarks.exe -help
```

This command will also display the names of all available benchmarks. You can filter the benchmarks to run by including part of their name at the end of the command line:
```
dune exec -- ./src/saturn_benchmarks.exe -budget 1 Parallel Stdlib
```

This will run all benchmarks with either `Parallel` or `Stdlib` in their names.


## Queue implementations 
Here is a list of queue implementations that can be compared  :
- the `Stdlib` queue (with one domain only),
- the `Stdlib` queue protected with a mutex,
- the lock-free Michael-Scott queue from `Saturn`,
- a Michael-Scott two-stack-based queue (currently in this [PR](https://github.com/ocaml-multicore/saturn/pull/112) in `Saturn`).


## Stacks implementations
The stack implementations benchmarked are
- the `Stdlib` stack (with one domain only),
- the `Stdlib` stack protected with a mutex,
- a concurrent stack implemented with an atomic list (with and without padding and backoff mechanism)
- a lock-free Treiber stack from `Saturn`.


## Single-consumer single-producer queues : different optimizations
The following command line runs benchmarks for a single-consumer single-producer queue with different optimizations. 
```
dune exec -- ./src/saturn_benchmarks.exe -budget 1 Spsc
```
The different benchmarked optimizations are (with results on Intel computer 12th Gen Intel® Core™ i7-1270P × 16):
| Implementations                                             | Notes                                                                                                                                       | Results on intel (Millons message/s) |
| ----------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------- |
| Spsc_queue Original                                         | Original spsc implementation with no optimzation                                                                                            | 14 M/s                 |
| Spsc_queue Original + padding                               | Same than previous with padding to avoid false sharing                                                                                      | 14 M/s                 |
| Spsc_queue Saturn spsc queue - padding                      | Differences from original : add caches tail and head (but no padding). Differences from `Saturn.Single_cons_single_prod_queue` : no padding | 18 M/s                 |
| Spsc_queue Saturn                                           | `Saturn.Single_cons_single_prod_queue`                                                                                                      | 60 M/s                 |
| Spsc_queue Saturn + padding                                 | `Saturn.Single_cons_single_prod_queue` with full padding using `Multicore_magic.copy_as_padded`                                             | 63 M/s                 |
| Spsc_queue Saturn + padding + relaxed read                  | Same than previous with relaxed atomic read.                                                                                                | 56 M/s                 |
| Spsc_queue Saturn + padding + relaxed read + no indirection | Same than previous with no option in array (using `Obj.magic`) to avoid `Option` indirection.                                               | 93 M/s                 |
| Spsc_queue Saturn_unsafe                                    | `Saturn.Single_cons_single_prod_queue_unsafe`. Differences from previous line : avoid float array optimisation.                             | 102 M/s                |


## Skiplist
Two skiplists implementations are benchmarked here: 
- one that is the current Saturn implementation ;
- one that uses `Atomic_array` from `Multicore_magic`. 

To run specifically these benchmarks :
```
dune exec -- ./src/saturn_benchmarks.exe -budget 1 -brief Skiplist
```