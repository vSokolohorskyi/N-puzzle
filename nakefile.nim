import nake, unittest, strformat

const
  ExeName = "npuzzle.nim"
  PyExe = "p-gen.py"

task defaultTask, "Compiles binary":
  discard shell(nimExe, "c", "-d:release", ExeName)

task "verbose", "Compile executable with verbose flag":
  discard shell(nimExe, "c", "-d:release", "-d:verbose", ExeName)

task "clean", "Deletes all exec and res files":
  let files = ["s", "u", "npuzzle", "nakefile", "solution.txt"]
  for f in files:
    discard shell("rm -rf " & f)

task "run-tests", "Builds and executes test":
  discard shell "mkdir u s u/sol s/sol"

  block unsolvable:
    echo "--> UNSOLVABLE: "
    var iters = 10
    var sizes = 7
    var file = ""
    for i in 1..iters:
      for j in 3..sizes:
        file = $i & "_" & $j
        discard shell("python", PyExe, "-u", "-i " & $i, $j, ">", "u/"&file)
    for i in 1..iters:
      for j in 3..sizes:
        file = $i & "_" & $j
        discard shell("./npuzzle", "u/"&file, ">", "u/sol/"&file)

  block solvable:
    echo "--> SOLVABLE: "
    var iters = 10
    var sizes = 7
    var file = ""
    for i in 1..iters:
      for j in 3..sizes:
        file = $i & "_" & $j
        discard shell("python", PyExe, "-s", "-i " & $i, $j, ">", "s/"&file)
    for i in 1..iters:
      for j in 3..sizes:
        file = $i & "_" & $j
        discard shell("./npuzzle", "s/"&file, ">", "s/sol/"&file)

