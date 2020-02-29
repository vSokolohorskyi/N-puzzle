import deques, hashes, tables, heapqueue, math, streams
import types

when defined(verbose):
  proc showPuzzle(p: NPuzzle) =
    var line = ""
    for i, t in p.tails:
      line &= $t & " "
      if (i + 1) mod p.width == 0:
        echo line
        line = ""

proc blankPos(p: NPuzzle): TailPos =
  var row, col = 0
  for i, t in p.tails:
    if t == 0:
      return (row, col)

    if (i + 1) mod p.width == 0:
      inc row
      col = 0
    else:
      inc col

proc invs(p: NPuzzle): int =
  # https://www.cs.bham.ac.uk/~mdr/teaching/modules04/java2/TilesSolvability.html
  var i = 0
  while i < p.tails.len:
    var inv = 0
    var j = i + 1
    if p.tails[i] != 0:
      while j < p.tails.len:
        if p.tails[i] > p.tails[j] and p.tails[j] != 0:
          inc inv
        inc j
    inc i
    result += inv

proc isSolvable*(start, goal: NPuzzle): bool =
  when defined(verbose):
    echo "Parity(s, g) => ", start.invs mod 2 == goal.invs mod 2
    echo "s.blank == g.blank: ", start.blankPos.row mod 2 == goal.blankPos.row mod 2
  result = if start.width mod 2 != 0:
             start.invs mod 2 == goal.invs mod 2
           else:
             if start.blankPos.row mod 2 == goal.blankPos.row mod 2:
               start.invs mod 2 == goal.invs mod 2
             else:
               start.invs mod 2 != goal.invs mod 2

proc getGoal*(p: Npuzzle): NPuzzle =
  var
    t = 1
    col, row, minCol, minRow = 0
    maxCol, maxRow = p.width - 1
    w = p.width
  result.tails.setLen(w^2)
  result.width = w
  while t < w^2:
    while t < w^2 and col < maxCol: # right
      result.tails[w*row + col] = t;
      inc t; inc col
    while t < w^2 and row < maxRow: # down
      result.tails[w*row + col] = t; inc t; inc row
    while t < w^2 and col > minCol: # left
      result.tails[w*row + col] = t; inc t; dec col
    while t < w^2 and row > minRow: # up
      result.tails[w*row + col] = t; inc t; dec row
    dec maxCol
    dec maxRow
    inc minCol
    inc minRow
    col = minCol
    row = minRow

proc inRange(p: NPuzzle, t: TailPos): bool =
  t.row != -1 and t.row < p.tails.len div p.width and t.col != -1 and t.col < p.width

proc swap(p: var NPuzzle, a, b: TailPos): bool =
  if p.inRange(a) and p.inRange(b):
    swap(p.tails[a.row * p.width + a.col], p.tails[b.row * p.width + b.col])
    result = true

proc left(b: TailPos): TailPos = (b.row, b.col - 1)
proc right(b: TailPos): TailPos = (b.row, b.col + 1)
proc down(b: TailPos): TailPos = (b.row + 1, b.col)
proc up(b: TailPos): TailPos = (b.row - 1, b.col)

iterator neighbors(p: NPuzzle): NPuzzle =
  let b = p.blankPos
  let sides = [('l', b.left), ('r', b.right), ('d', b.down), ('u', b.up)]

  for i in 0..3:
    var cp = p
    cp.side = sides[i][0]
    if cp.swap(sides[i][1], b):
      yield cp

proc `==`(a,b: NPuzzle): bool = a.tails == b.tails
proc `!=`(a,b: NPuzzle): bool = not (a == b)
proc `<`(a,b: NPuzzle): bool = a.priority < b.priority
proc hash(n: Npuzzle): Hash =
  result = n.tails.hash !& n.tails.hash
  result = !$result

proc getCol(x, w: int): int = (x - 1) mod w
proc getRow(x, w: int): int = (x - 1) div w

proc getTailPos(g: NPuzzle, x: int): TailPos =
  var row, col = 0
  for i, t in g.tails:
    if t == x:
      return (row, col)

    if (i + 1) mod g.width == 0:
      inc row
      col = 0
    else:
      inc col

proc manhattan(n,g: NPuzzle, t,r,c,w: int): int =
  let (gr, gc) = g.getTailPos t
  abs(r - gr + abs(c - gc))

proc lcAux(n,g: NPuzzle, t,r,c,w: int): int =
  var rr = 0
  var cc = 0
  let (tr, tc) = g.getTailPos t
  for i, tt in n.tails:
    if tt != 0 and t != tt:
      if c == cc or r == rr:
        let (ttr, ttc) = g.getTailPos tt
        if tr == ttr or tc == ttc:
          if r * w + c > rr * w + cc and
             tr * w + tc < ttr * w + ttc:
            inc result

proc lcmanhattan(n,g: NPuzzle, t,r,c,w: int): int =
  manhattan(n, g, t, r, c, w) + 2 * lcAux(n, g, t, r, c, w)

proc euclidean(n,g: NPuzzle, t,r,c,w: int): int =
  let (gr, gc) = g.getTailPos t
  (r - gr)^2 + (c - gc)^2

proc hamming(n,g: NPuzzle, t,r,c,w: int): int = 1

proc score(n,g: NPuzzle, p: proc(n,g: NPuzzle, t, r, c, w: int): int): int =
  var r, c = 0
  for i, t in n.tails:
    if i + 1 != t and t != 0:
      result += p(n, g, t, r, c, n.width)

    if (i + 1) mod n.width == 0:
      inc r; c = 0
    else:
      inc c

proc hScore(n,g: NPuzzle, h: Heuristic): int {.inline.} =
  let hs = [($Manhattan, manhattan), ($LcManhattan, lcmanhattan),
            ($Euclidean, euclidean), ($Hamming, hamming)]
  for (k, p) in hs:
    if k == $h:
      return score(n, g, p)

proc show*(info: NPuzzleInfo) =
  var strm = newFileStream("solution.txt", fmWrite)
  echo "Complexity in time: ", info.totalStates
  echo "Complexity in size: ", info.maxStates
  echo "Moves: ", info.path.len - 1
  echo "Path to the goal written to \"solution.txt\""
  strm.write("Path:\n")
  strm.write("[")
  var i = 0
  while i < info.path.len:
    let s = info.path[i].side
    if s == '\0':
      inc i
      continue
    if i + 1 == info.path.len:
      strm.write(s)
    else:
      strm.write(s&"->")
    inc i
  strm.write("]\n")
  for p in info.path:
    var line = ""
    for i, t in p.tails:
      line &= $t & " "
      if (i + 1) mod p.width == 0:
        strm.write(line,"\n")
        line = ""
    strm.write("\n")

const
  nodesLimit = 1_000_000
  depthLimit = 1000

proc solve*(start, goal: NPuzzle, ss: NPuzzleSettings, i: var NPuzzleInfo) =
  var opened = initHeapQueue[NPuzzle]()
  opened.push start
  var closed = initTable[NPuzzle, tuple[parent: NPuzzle, cost: int]]()
  closed[start] = ((0, @[], 0, '0'), 0)
  var c: Npuzzle
  while opened.len > 0:
    inc i.totalStates
    if i.maxStates < opened.len:
      i.maxStates = opened.len
    c = opened.pop
    if c == goal:
      break
    if closed[c].cost > depthLimit:
      quit "Over depth limit!"
    if opened.len > nodesLimit:
      quit "Over nodes limit!"
    for next in c.neighbors:
      var n = next
      let gScore = closed[c].cost + 1
      if not closed.hasKey(n) or gScore < closed[n].cost:
        case ss.a:
        of Astar:   n.priority = gScore + hScore(n, goal, ss.h)
        of Greedy:  n.priority = hScore(n, goal, ss.h)
        of Uniform: n.priority = gScore
        closed[n] = (c, gScore)
        opened.push n

# Create path
  i.path = initDeque[NPuzzle]()
  while c != start:
    i.path.addFirst c
    c = closed[c].parent
  i.path.addFirst c
