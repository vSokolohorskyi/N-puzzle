import parseopt

type
  UserInput*[SS] = tuple
    settings: SS
    file: File

proc parseInput*[SS](params: seq[string]): UserInput[SS] =
  var opt = initOptParser(params)
  while true:
    opt.next()
    case opt.kind
    of cmdEnd:
      break
    of cmdShortOption, cmdLongOption:
      result.settings.getSettings(opt.key, opt.val)
    of cmdArgument:
      result.file = open(opt.key)


