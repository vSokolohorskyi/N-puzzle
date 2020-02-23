import nake, unittest, strformat

const
  ExeName = "npuzzle.nim"
  PyExe = "p-gen.py"

task defaultTask, "Compiles binary":
  discard shell(nimExe, "c", "-d:release", ExeName)

task "verbose", "Compile execubale with verbose flag":
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
    var fileName = ""
    for i in 1..iters:
      for j in 3..sizes:
        fileName = $i & "_" & $j
        discard shell("python", PyExe, "-u", "-i " & $i, $j, ">", "u/"&fileName)
    for i in 1..iters:
      for j in 3..sizes:
        fileName = $i & "_" & $j
        discard shell("./npuzzle", "u/"&fileName, ">", "u/sol/"&filename)

  block solvable:
    echo "--> SOLVABLE: "
    var iters = 10
    var sizes = 7
    var fileName = ""
    for i in 1..iters:
      for j in 3..sizes:
        fileName = $i & "_" & $j
        discard shell("python", PyExe, "-s", "-i " & $i, $j, ">", "s/"&fileName)
    for i in 1..iters:
      for j in 3..sizes:
        fileName = $i & "_" & $j
        discard shell("./npuzzle", "s/"&fileName, ">", "s/sol/"&filename)

