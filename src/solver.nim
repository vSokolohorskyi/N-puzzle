import deques, hashes, tables, heapqueue, algorithm, math, streams
import types

proc even(n: int): bool = n mod 2 == 0
proc odd(n: int): bool = not even(n)

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
  echo "start inversions: ", start.invs
  echo "goal inversions: ", goal.invs
  if start.width.odd:
    return start.invs mod 2 == goal.invs mod 2
  else:
    # TO DO:
    #return start.blankPos.row.odd xor start.invs.even

proc getGoal*(p: Npuzzle): NPuzzle =
  var
    t = 1
    col, row, minCol, minRow = 0
    maxCol, maxRow = p.width - 1
    w = p.width
    g: NPuzzle
  g.tails.setLen(w^2)
  g.width = w
  while t < w^2:
    while t < w^2 and col < maxCol: # right
      g.tails[w*row + col] = t; inc t; inc col
    while t < w^2 and row < maxRow: # down
      g.tails[w*row + col] = t; inc t; inc row
    while t < w^2 and col > minCol: # left
      g.tails[w*row + col] = t; inc t; dec col
    while t < w^2 and row > minRow: # up
      g.tails[w*row + col] = t; inc t; dec row
    dec maxCol
    dec maxRow
    inc minCol
    inc minRow
    col = minCol
    row = minRow
  result = g

#[
proc getGoal(p: NPuzzle): NPuzzle =
  var cp = p
  cp.tails.sort do(x, y: int) -> int:
    cmp(x, y)

  var i = 0
  while i < cp.tails.len - 1:
    cp.tails[i] = cp.tails[i + 1]
    inc i
  cp.tails[^1] = 0

  result = cp
]#

proc inRange(p: NPuzzle, t: TailPos): bool =
  t.row != -1 and t.row < p.tails.len div p.width and
  t.col != -1 and t.col < p.width

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
  let sides = [b.left, b.right, b.down, b.up]

  for i in 0..3:
    var cp = p
    if cp.swap(sides[i], b):
      yield cp

proc `==`(a,b: NPuzzle): bool = a.tails == b.tails
proc `!=`(a,b: NPuzzle): bool = not (a == b)
proc `<`(a,b: NPuzzle): bool = a.priority < b.priority
proc hash(n: Npuzzle): Hash =
  result = n.tails.hash !& n.tails.hash
  result = !$result

proc getCol(x, w: int): int = (x - 1) mod w
proc getRow(x, w: int): int = (x - 1) div w

proc manhattan(n: NPuzzle, t,r,c,w: int): int =
  abs(r - getRow(t, w)) + abs(c - getCol(t, w))

proc lcAux(n: NPuzzle, t,r,c,w: int): int =
  var rr = 0
  var cc = 0
  let tr = getRow(t, w)
  let tc = getCol(t, w)
  for i, tt in n.tails:
    if tt != 0 and t != tt:
      if c == cc or r == rr:
        if tr == getRow(tt, w) or tc == getCol(tt, w):
          if r * w + c > rr * w + cc and
             tr * w + tc < getRow(tt,w) * w + getCol(tt,w):
            inc result

proc lcmanhattan(n: NPuzzle, t,r,c,w: int): int =
  manhattan(n, t, r, c, w) + 2 * lcAux(n, t, r, c, w)

proc euclidean(n: NPuzzle, t,r,c,w: int): int =
  (r - getRow(t, w))^2 + (c - getCol(t, w))^2

proc hamming(n: NPuzzle, t,r,c,w: int): int  = 1

proc core(n: NPuzzle, p: proc(n: NPuzzle, t, r, c, w: int): int): int =
  var r, c = 0
  for i, t in n.tails:
    if i + 1 != t and t != 0:
      result += p(n, t, r, c, n.width)

    if (i + 1) mod n.width == 0:
      inc r; c = 0
    else:
      inc c

proc hScore(n: NPuzzle, h: Hfunc): int {.inline.} =
  let hs = [($Manhattan, manhattan), ($LcManhattan, lcmanhattan),
            ($Euclidean, euclidean), ($Hamming, hamming)]
  for (k, p) in hs:
    if k == $h:
      return core(n, p)

proc show*(info: NPuzzleInfo) =
  var strm = newFileStream("solution.txt", fmWrite)
  strm.write("Complexity in time: ", info.totalStates, "\n")
  strm.write("Complexity in size: ", info.maxStates, "\n")
  strm.write("Moves: ", info.path.len - 1, "\n")
  strm.write("Path:\n")
  for p in info.path:
    var line = ""
    for i, t in p.tails:
      line &= $t & " "
      if (i + 1) mod p.width == 0:
        strm.write(line,"\n")
        line = ""
    strm.write("\n")

import os
proc pp(p: NPuzzle) =
  echo p
  var line = ""
  for i, t in p.tails:
    line &= $t & " "
    if (i + 1) mod p.width == 0:
      echo line
      line = ""
  #sleep(3000)
  #discard execShellCmd("clear")

const
  nodesLimit = 600_000
  depthLimit = 100

proc solve*(start, goal: NPuzzle, ss: NPuzzleSettings, i: var NPuzzleInfo) =
  pp goal
  var opened = initHeapQueue[NPuzzle]()
  opened.push start
  var closed = initTable[NPuzzle, tuple[parent: NPuzzle, cost: int]]()
  closed[start] = ((0, @[], 0), 0)
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
#    echo "Current: "
#    echo "Depth: ", closed[c].cost
#    pp c
    for next in c.neighbors:
      var n = next
      let gScore = closed[c].cost + 1
      if not closed.hasKey(n) or gScore < closed[n].cost:
        case ss.g:
        of Astar:   n.priority = gScore + hScore(n, ss.h)
        of Greedy:  n.priority = hScore(n, ss.h)
        of Uniform: n.priority = gScore
        closed[n] = (c, gScore)
        opened.push n
#        echo "Child: "
#        echo "Depth: ", gScore
#        pp n

# Create path
  i.path = initDeque[NPuzzle]()
  while c != start:
    i.path.addFirst c
    c = closed[c].parent
  #i.path.addLast goal
