import nake

const
  ExeName = "npuzzle.nim"

task defaultTask, "Compiles binary":
  discard shell(nimExe, "c", "-d:release", ExeName)

