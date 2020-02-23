import deques
type
  Algorithm* {.pure.} = enum
    Astar = "a"
    Greedy = "g"
    Uniform = "u"

  Heuristic* {.pure.} = enum
    Manhattan = "m"
    Hamming = "h"
    LcManhattan = "lcm"
    Euclidean = "e"

  NPuzzleSettings* = tuple
    a: Algorithm
    h: Heuristic

  TailPos* = tuple[row, col: int]
  Tails* = seq[int]

  NPuzzle* = tuple
    width: int
    tails: Tails
    priority: int
    side: char

  NPuzzleInfo* = tuple
    width: int
    totalStates: int
    maxStates: int
    path: Deque[NPuzzle]

