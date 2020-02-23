import strutils, pegs, sequtils, algorithm
import types

proc getSettings*(ss: var NPuzzleSettings, k: string, v: string) =
  let algos = [$Astar, $Greedy, $Uniform]
  let heurs = [$Manhattan, $Hamming, $LcManhattan, $Euclidean]

  if k == "a" and v in algos:
    ss.a = parseEnum[Algorithm](v)
  elif k == "h" and v in heurs:
    ss.h = parseEnum[Heuristic](v)

proc isValid*(p: NPuzzle): bool =
  if p.width < 3 or p.tails.len mod p.width != 0:
    return false

  var ts = p.tails
  ts.sort do(x, y: int) -> int:
    cmp(x, y)

  if ts[0] != 0:
    return false

  var n = 0
  while n < ts.len:
    if ts[n] != n:
      return false
    inc n

  return true

proc getRawTails(str: string): seq[string] =
  result = str.split("#")[0].split(" ")
  result.keepIf do(x: string) -> bool:
    x != ""

proc getTails(str: string): seq[int] =
  let ts = getRawTails str
  result = ts.map do(t: string) -> int:
    if t.match(peg"\d+"):
      t.parseInt
    else:
      raise newException(ValueError, "Invalid integer: " & t)

proc parseNPuzzle*(f: File): NPuzzle =
  if f.isNil:
    raise newException(IoError, "There is no file to read from!")

  for line in f.lines:
    let nn = line.getTails
    if nn.len > 0:
      if result.width == 0:
        result.width = nn[0]
      elif nn.len != result.width:
        raise newException(ValueError, "Invalid puzzle")
      else:
        for n in nn:
          result.tails.add n
    else:
      continue

