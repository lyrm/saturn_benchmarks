all:
	dune build
spsc:
	dune exec -- ./src/saturn_benchmarks.exe -budget 1 Spsc
queue:
	dune exec -- ./src/saturn_benchmarks.exe -budget 1 Queue
stack:
	dune exec -- ./src/saturn_benchmarks.exe -budget 1 Stack
spscb:
	dune exec -- ./src/saturn_benchmarks.exe -brief -budget 1 Spsc
queueb:
	dune exec -- ./src/saturn_benchmarks.exe -brief -budget 1 Queue
stackb:
	dune exec -- ./src/saturn_benchmarks.exe -brief -budget 1 Stack