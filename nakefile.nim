import nake, unittest, strformat

const
  ExeName = "npuzzle.nim"
  PyExe = "p-gen.py"

task defaultTask, "Compiles binary":
  discard shell(nimExe, "c", "-d:release", ExeName)

task "run-tests", "Builds and executes test":
    block solvable:
      var size = 3
      var maxFiles = 10
      var fileName = ""
      for i in 0..maxFiles:
        fileName = "s_" & $i & "_" & $size
        discard shell("python", PyExe, "-s", "-i " & $2, $size, ">", "s/"&fileName)
        inc size

    block unsolvable:
      var size = 3
      var maxFiles = 10
      var fileName = ""
      for i in 0..maxFiles:
        fileName = "u_" & $i & "_" & $size
        discard shell("python", PyExe, "-u", "-i " & $i, $size, ">", "u/"&fileName)
        inc size

    block testS:
      var size = 3
      var maxFiles = 10
      var fileName = ""
      for i in 0..maxFiles:
        fileName = "s_" & $i & "_" & $size
        discard shell("./npuzzle", fileName)
        inc size

