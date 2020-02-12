import os

import src / [input_parser, parser, solver, types]

template helpMsg: string =
  """Usage: ./npuzzle -h:[m|h|lcm|e](-heuristic:type) file
Where:
     m: Manhattan
     h: Hemming
     lcm: Linear conflicts + Manhattan
     e: Euclidean
  """

template invalidMsg: string = "Invalid puzzle"
template unsolvableMsg: string = "Unsolvable puzzle"

proc main() =
  try:
    let clp = commandLineParams()
    if clp.len == 0:
      quit helpMsg(), QuitSuccess

    let (ss, f) = parseInput[NPuzzleSettings] clp
    let p = parseNPuzzle f
    if not p.isValid:
      quit invalidMsg()
    if not p.isSolvable:
      quit unsolvableMsg()

    var i: NPuzzleInfo
    solve(p, ss, i)
    i.show()

  except Exception as e:
    echo e.msg

when isMainModule:
  main()
