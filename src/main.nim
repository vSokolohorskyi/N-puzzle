import
  os, parseopt, strutils, pegs, sequtils, algorithm

type
  Gfunc {.pure.} = enum
    Astar = "a"
    Greedy = "g"
    Uniform = "u"

  Hfunc {.pure.} = enum
    Manhattan = "m"

  NPuzzleSettings = tuple
    g: Gfunc
    hs: set[Hfunc]

  NPuzzle = tuple
    length: int
    tails: seq[int]
    isSolvable: bool

  UserInput[SS] = tuple
    settings: SS
    file: File
    help: bool

  Info = tuple

proc getSettings(ss: var NPuzzleSettings, k: string, v: string) =
  let gfuncs = [$Astar, $Greedy, $Uniform]
  let hfuncs = [$Manhattan]

  if k == "g" and v in gfuncs:
    if v != $ss.g:
      ss.g = parseEnum[Gfunc](v)
  elif k == "h" and v in hfuncs:
     let h = parseEnum[Hfunc](v)
     if h notin ss.hs:
       ss.hs.incl h

proc parseInput[SS](params: seq[string]): UserInput[SS] =
  var opt = initOptParser(params)
  while true:
    opt.next()
    case opt.kind
    of cmdEnd:
      break
    of cmdShortOption, cmdLongOption:
      if opt.key == "help":
        result.help = true
        break
      else:
        result.settings.getSettings(opt.key, opt.val)
    of cmdArgument:
      result.file = open(opt.key)

template helpMsg: string =
  ("Help msg")

template unsolvableMsg: string =
  ("Unsolvable puzzle")

proc show(i: Info) =
  discard

proc solve[F, SS, I](figure: F, ss: SS, info: var I) =
  discard

proc getRawTails(str: string): seq[string] =
  # TO DO: use pegs
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

proc parseNPuzzle(f: File): NPuzzle =
  if f.isNil:
    return

  for line in f.lines:
    let nn = line.getTails
    if nn.len > 0:
      if result.length == 0:
        result.length = nn[0]
      else:
        for n in nn:
          result.tails.add n
    else:
      continue

proc isValid(np: NPuzzle): bool =
  var ts = np.tails
  ts.sort do(x, y: int) -> int:
    cmp(x, y)

  var n = 0
  while n < ts.len - 1:
    if ts[n] + 1 != ts[n + 1]:
      return false
    inc n

  result = true

proc main() =
  try:
    let (ss, f, h) = parseInput[NPuzzleSettings] commandLineParams()
    if h:
      quit helpMsg()
    let np = parseNPuzzle f
    if np.isValid():
      var i: Info
      solve(np, ss, i)
      i.show()
    else:
      quit unsolvableMsg()

  except Exception as e:
    echo e.msg

when isMainModule:
  main()
