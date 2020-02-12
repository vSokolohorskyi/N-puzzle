import deques, hashes, tables, heapqueue, algorithm, math
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

proc isSolvable*(p: NPuzzle): bool =
  if p.width.odd and p.invs.even:
    return true
  return p.width.even and not (p.blankPos.row.odd xor p.invs.even)

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

proc getCol(x, w: int): int = (x - 1) mod w
proc getRow(x, w: int): int = (x - 1) div w

proc manhattan(n: NPuzzle, t,r,c,w: int): int =
  abs(r - getRow(t, w)) + abs(c - getCol(t, w))

proc lcAux(n: NPuzzle, t,r,c,w: int): int =
  var rr = 0
  var cc = 0
  for i, tt in n.tails:
    if tt != 0 and t != tt:
      if c == cc or r == rr:
        if getRow(t, w) == getRow(tt, w) or getCol(t, w) == getCol(tt, w):
          if r * w + c > rr * w + cc and
             getRow(t,w) * w + getCol(t,w) < getRow(tt,w) * w + getCol(tt,w):
            inc result

proc lcmanhattan(n: NPuzzle, t,r,c,w: int): int =
  manhattan(n, t, r, c, w) + 2 * lcAux(n, t, r, c, w)

proc euclidean(n: NPuzzle, t,r,c,w: int): int =
  (r - getRow(t, w))^2 + (c - getCol(t, w))^2

proc hamming(n: NPuzzle, t,r,c,w: int): int = 1

proc core(n: NPuzzle, p: proc(n: NPuzzle, t, r, c, w: int): int): int =
  var r, c = 0
  for i, t in n.tails:
    if i + 1 != t and t != 0:
      result += p(n, t, r, c, n.width)

    if (i + 1) mod n.width == 0:
      inc r; c = 0
    else:
      inc c

proc heuristic(n: NPuzzle, h: Hfunc): int =
  let hs = [($Manhattan, manhattan), ($LcManhattan, lcmanhattan),
            ($Euclidean, euclidean), ($Hamming, hamming)]
  for (k, p) in hs:
    if k == $h:
      return core(n, p)

proc showPath(info: NPuzzleInfo) =
  var line = ""
  for p in info.path:
    for i, t in p.tails:
      line &= $p.tails[i] & " "
      if (i + 1) mod info.width == 0:
        echo line; line = ""
    echo ""

proc show*(i: NPuzzleInfo) =
  echo "Moves: ", i.path.len - 1
  echo "Total number of states: ", i.totalStates
  echo "Maximum states: ", i.maxStates
  echo "Path to the solution: "
  i.showPath()

proc solve*(s: NPuzzle, ss: NPuzzleSettings, i: var NPuzzleInfo) =
  const
    depthLimit = 60
    nodeLimit = 600_000

  var hq = initHeapQueue[NPuzzle]()
  hq.push s

  var costSoFar = initTable[NPuzzle, int]()
  costSoFar[s] = 0

  var cameFrom = initTable[NPuzzle, NPuzzle]()
  cameFrom[s] = (0, @[], 0)

  var g = s.getGoal
  while hq.len > 0:
    inc i.totalStates
    if i.maxStates < hq.len:
      i.maxStates = hq.len

    let c = hq.pop

    if c == g:
      g = c
      break

    if costSoFar[c] + 1 == depthLimit:
      quit "Height limit exceeded!"

    if costSoFar.len == nodeLimit:
      quit "Node limit exceeded!"

    for n in c.neighbors:
      var nn = n
      let gScore = costSoFar[c] + 1
      if not costSoFar.hasKey(nn) or gScore < costSoFar[nn]:
        nn.priority = gScore + heuristic(n, ss.h)
        costSoFar[nn] = gScore
        cameFrom[nn] = c
        hq.push nn

  var c = g
  i.width = s.width
  i.path = initDeque[NPuzzle]()
  while c != s:
    i.path.addFirst cameFrom[c]
    c = cameFrom[c]
  i.path.addLast g

