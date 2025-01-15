(lang dune 3.15)

(name saturn_benchmarks)

(generate_opam_files true)

(implicit_transitive_deps false)

(source
 (github lyrm/saturn_benchmarks))

(authors "Carine Morel")

(maintainers "Carine Morel")

(license ISC)

(documentation https://github.com/lyrm/saturn_benchmarks/blob/master/README.md)

(package
 (name saturn_benchmarks)
 (synopsis "Benchmarks for Saturn")
 (description "Benchmarks suite for Saturn to compare performance between different implementations of a given data structures. Currently, it only contains benchmarks for the queue and stack implementations.")
 (depends 
  (ocaml (>= 5.2.0))
  (dune (>= 3.15))
  (saturn (>= 1.0.0))
  (backoff (and (>= 0.1.0)))
  (qcheck-stm (and (>= 0.3) :with-test))
  (multicore-magic (and (>= 2.1.0)))
  (multicore-bench (and (>= 0.1.2)))
 )
)
