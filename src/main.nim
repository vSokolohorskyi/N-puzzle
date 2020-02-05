import os

import input_parser
import npuzzle / [parser, solver, types]

template helpMsg: string = "Help msg"
template invalidMsg: string = "Invalid puzzle"
template unsolvableMsg: string = "Unsolvable puzzle"

proc main() =
  try:
    let (ss, f, h) = parseInput[NPuzzleSettings] commandLineParams()
    if h:
      quit helpMsg(), QuitSuccess # TODO: maybe change on QuitFailure
    let p = parseNPuzzle f
    if not p.isValid:
      quit invalidMsg(), QuitSuccess
    if not p.isSolvable:
      quit unsolvableMsg(), QuitSuccess # TODO: maybe change on QuitFailure

    echo p
    var i: NPuzzleInfo
    solve(p, ss, i)
    #i.show()

  except Exception as e:
    echo e.msg

when isMainModule:
  main()
