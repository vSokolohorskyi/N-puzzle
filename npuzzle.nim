import os

import src / [input_parser, parser, solver, types]

template helpMsg: string =
  """Usage: ./npuzzle -a:[a|g|u](-algorithm:type) -h:[m|h|lcm|e](-heuristic:type) file
Where:
     Algorithms:
      a: A-star
      g: Greedy-best-first
      u: Uniform-cost-search/Dijkstra

     Heuristics:
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
    let s = parseNPuzzle f
    if not s.isValid:
      quit invalidMsg()

    let g = getGoal s
    if not s.isSolvable(g):
      quit unsolvableMsg()

    var i: NPuzzleInfo
    solve(s, g, ss, i)
    i.show()

  except Exception as e:
    echo e.msg

when isMainModule:
  main()
