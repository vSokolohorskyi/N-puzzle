import deques
type
  Gfunc* {.pure.} = enum
    Astar = "a"
    Greedy = "g"
    Uniform = "u"

  Hfunc* {.pure.} = enum
    Manhattan = "m"
    Hamming = "h"
    LcManhattan = "lcm"
    Euclidean = "e"

  NPuzzleSettings* = tuple
    g: Gfunc
    h: Hfunc

  TailPos* = tuple[row, col: int]
  Tails* = seq[int]

  NPuzzle* = tuple
    width: int
    tails: Tails
    priority: int

  NPuzzleInfo* = tuple
    width: int
    totalStates: int
    maxStates: int
    path: Deque[NPuzzle]

