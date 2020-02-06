type
  Gfunc* {.pure.} = enum
    Astar = "a"
    Greedy = "g"
    Uniform = "u" # Dijkstra's Algorithm

  Hfunc* {.pure.} = enum
    Manhattan = "m"

  NPuzzleSettings* = tuple
    g: Gfunc
    hs: set[Hfunc]

  Tails = seq[int]

  NPuzzle* = tuple
    width: int
    tails: Tails

  NPuzzleInfo* = tuple
    totalStates: int # complexity in time
    maxStates: int # complexity in size(taken memory)
    numOfMoves: int
    solutionPath: seq[Tails]

  TailPos* = tuple[row, col: int]