math.randomseed(os.time())

function table.Count(t)
  local i = 0
  for k in pairs(t) do
    i = i + 1
  end
  return i
end

function table.Random(t)
  local rk = math.random(1, table.Count(t))
  local i = 1
  for k, v in pairs(t) do
    if i == rk then
      return v, k
    end
    i = i + 1
  end
end

local namegen = {}
namegen.names = {}
namegen.names.vowels = {
  "???",
  "??",
  "?"
}
namegen.names.consentents = {
  "Thul",
  "Olas",
  "Pal",
  "Rar",
  "Ler",
  "Ano",
  "Kak",
  "Kek",
  "Kal",
  "Aziz",
  "Zac",
  "Lrz",
  "Rlz",
  "Thul",
  "C",
  "Ka",
  "Cth",
  "Yiz",
  "Arg",
  "Thel",
  "Gra",
  "Dol",
  "Zzik",
  "Lavi",
  "Han"
}
namegen.names.endings = {
  "dim",
  "zzzz",
  "loc",
  "rok",
  "zal",
  "mok",
  "lu",
  "apa",
  "rol",
  "thulu",
  "thun",
  "rollo",
  "sari",
  "adec",
  "sdac",
  "nbevr",
  "shizzel",
  "zizil",
  "zael"
}

function namegen.generate()
  local endingrand = math.random(0, 0)
  local isending = false
  if 0 == endingrand then
    isending = true
  end
  local namegenname
  if isending then
    namegenname = namegen.createName(table.Random(namegen.names.consentents), table.Random(namegen.names.vowels), true, table.Random(namegen.names.endings))
  else
    namegenname = namegen.createName(table.Random(namegen.names.consentents), table.Random(namegen.names.vowels), false)
  end
  return namegenname
end

function namegen.createName(const1, vowel1, endingbool, ending)
  if endingbool then
    return tostring(const1 .. "'" .. ending .. "" .. tostring(math.random(0, 100)))
  else
    return tostring(const1 .. "'" .. vowel1)
  end
end

return namegen
