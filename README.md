# Benchmarks for Saturn library.
This repository put together benchmarks for [Saturn's](https://github.com/ocaml-multicore/saturn/) data structures. 

## Running the benchmarks

The benchmarks can be run with 
```
dune exec -- ./lib/saturn_benchmarks.exe -budget 1
```

You can print the help with `-help`
```
dune exec -- ./lib/saturn_benchmarks.exe -help
```

It will also print the names of all available benchmarks. You can filter the run benchmarks by adding some parts of their name at the end of the command line:
```
dune exec -- ./lib/saturn_benchmarks.exe -bugdet 1 Parallel Stdlib
```
will run all the benchmarks with *either* `Parallel` or `Stdlib` in their names.


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
