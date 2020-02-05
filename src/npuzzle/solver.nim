import types

proc even(n: int): bool = n mod 2 == 0
proc odd(n: int): bool = not even(n)

proc bOnOddFromBot(p: NPuzzle): bool =
  var raws = 1
  var t = 0
  while t < p.tails.len:
    if (t + 1) mod p.width == 0:
      inc raws
    if p.tails[t] == 0:
      return raws.even # we count from top, hence it odd from bot
    inc t

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
  return p.width.even and not (p.bOnOddFromBot xor p.invs.even)

proc solve*(p: NPuzzle, ss: NPuzzleSettings, i: var NPuzzleInfo) =
  discard
