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
