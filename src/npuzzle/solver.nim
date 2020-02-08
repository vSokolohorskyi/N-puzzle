import deques, sets, hashes, tables, heapqueue
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

proc print(p: NPuzzle) =
  # temporary, only for 8-puzzle
  echo "p: ", p.priority
  echo "[", p.tails[0], "," ,p.tails[1], ",", p.tails[2], "]"
  echo "[", p.tails[3], "," ,p.tails[4], ",", p.tails[5], "]"
  echo "[", p.tails[6], "," ,p.tails[7], ",", p.tails[8], "]"
  echo "||"
  echo "\\//"

proc `==`(a,b: NPuzzle): bool = a.tails == b.tails
proc `!=`(a,b: NPuzzle): bool = not (a == b)

proc getGoal(p: NPuzzle): NPuzzle =
  result.width = p.width
  result.tails = @[1,2,3,4,5,6,7,8,0]

proc `<`(a,b: NPuzzle): bool = a.priority < b.priority

proc manhattan(n, g: NPuzzle): int = discard

proc heuristic(n, g: NPuzzle, h: Hfunc): int =
  case h:
  of Hfunc.Manhattan:
    manhattan(n, g)

# To implement:
# 1. getGoal proc
# 2. 3 heuristics procs
# 3. counter of info
# 4. checker and tests
#
proc solve*(s: NPuzzle, ss: NPuzzleSettings, i: var NPuzzleInfo) =
  var hq = initHeapQueue[NPuzzle]()
  hq.push s

  var costSoFar = initTable[NPuzzle, int]()
  costSoFar[s] = 0

  var cameFrom = initTable[NPuzzle, NPuzzle]()
  cameFrom[s] = (0, @[], 0)

  var g = s.getGoal
  while hq.len > 0:
    let c = hq.pop

    if c == g:
      g = c
      break

    for n in c.neighbors:
      var nn = n
      let gScore = costSoFar[c] + 1
      if not costSoFar.hasKey(nn) or gScore < costSoFar[nn]:
        nn.priority = gScore + n.heuristic(g, ss.h)
        costSoFar[nn] = gScore
        cameFrom[nn] = c
        hq.push nn

  # After
  # [g: 3 -> 2 -> 1 -> s: 0]

  var c = g
  var path = initDeque[NPuzzle]()
  while c != s:
    path.addFirst cameFrom[c]
    c = cameFrom[c]
  path.addLast g

  # After
  # path: [ 0 <- 1 <- 2 <- 3 ]

  for s in path:
    s.print

