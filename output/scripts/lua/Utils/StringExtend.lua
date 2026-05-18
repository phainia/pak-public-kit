function string.StartsWith(value, prefix, toffset)
  if value and prefix then
    toffset = (toffset or 1) > 0 and toffset or 1
    
    return string.sub(value, toffset, toffset + #prefix - 1) == prefix
  end
  return false
end

function string.EndsWith(value, suffix)
  if value and suffix then
    return string.sub(value, -#suffix) == suffix
  end
  return false
end

function string.Title(value)
  return string.upper(string.sub(value, 1, 1)) .. string.sub(value, 2, #value)
end

function string.CharAt(value, position)
  if value and position and position > 0 then
    local b = string.byte(value, position, position + 1)
    return b and string.char(b) or b
  end
end

function string.IsWhitespace(value)
  if value then
    local len = #value
    for i = 1, len do
      local char = string.CharAt(value, i)
      if " " ~= char and "\t" ~= char then
        return false
      end
    end
    return true
  end
  return false
end

function string.IsNilOrEmpty(value)
  return not value or "" == value
end

function string.ToArray(value)
  local ret = {}
  if value then
    local idx = 1
    local count = #value
    while idx <= count do
      local b = string.byte(value, idx, idx + 1)
      if b > 127 then
        table.insert(ret, string.sub(value, idx, idx + 1))
        idx = idx + 2
      else
        table.insert(ret, string.char(b))
        idx = idx + 1
      end
    end
  end
  return ret
end

function string.Bytecode(value)
  if value then
    local bytes = {}
    local idx = 1
    local count = #value
    while idx <= count do
      local b = string.byte(value, idx, idx + 1)
      if b >= 100 then
        table.insert(bytes, "\\" .. b)
      else
        table.insert(bytes, "\\0" .. b)
      end
      idx = idx + 1
    end
    local code, ret = pcall(loadstring(string.format("do local _='%s' return _ end", table.concat(bytes))))
    if code then
      return ret
    end
  end
  return ""
end

function string.Substr(value, startIndex, endIndex)
  if value then
    local ret = {}
    local idx = startIndex
    local count = endIndex or #value
    while idx <= count do
      local b = string.byte(value, idx, idx + 1)
      if not b then
        break
      end
      if b > 127 then
        table.insert(ret, string.sub(value, idx, idx + 1))
        idx = idx + 2
      else
        table.insert(ret, string.char(b))
        idx = idx + 1
      end
    end
    return table.concat(ret)
  end
end

function string.CheckCN(str)
  local len = str and #str or 0
  local start = 1
  local arr = {
    0,
    192,
    224,
    240,
    248,
    252
  }
  while len >= start do
    local tmp = string.byte(str, start)
    if not tmp then
      break
    end
    local i = #arr
    while i > 1 and tmp < arr[i] do
      i = i - 1
    end
    local byteCount = i
    if len < start + byteCount - 1 then
      byteCount = len - start + 1
    end
    if 3 == byteCount then
      return true
    end
    start = start + byteCount
  end
  return false
end

function string.HasSpecialChars(value)
  if string.IsNilOrEmpty(value) then
    return false
  end
  return string.find(value, "[\\@&=|:;\"'<>/.%%+%*?%[%]%^%$%(%){}%-]") ~= nil
end

local special_chars = {
  ["%"] = "%%",
  ["^"] = "%^",
  ["$"] = "%$",
  ["("] = "%(",
  [")"] = "%)",
  ["."] = "%.",
  ["["] = "%[",
  ["]"] = "%]",
  ["*"] = "%*",
  ["+"] = "%+",
  ["-"] = "%-",
  ["?"] = "%?"
}
local pattern_check = "([%^%$%(%)%%%.%[%]%*%+%-%?])"

function string.ConvertPatternToLiteral(text)
  if string.IsNilOrEmpty(text) then
    return text
  end
  if not string.find(text, pattern_check) then
    return text
  end
  return string.gsub(text, pattern_check, special_chars)
end

function string.SafeGsub(s, pattern, repl, n)
  if type(repl) == "string" then
    if string.find(repl, "%", 1, true) then
      return string.gsub(s, pattern, function()
        return repl
      end, n)
    else
      return string.gsub(s, pattern, repl, n)
    end
  else
    return string.gsub(s, pattern, repl, n)
  end
end

function string.SafeGsubLiteral(s, pattern, repl, n)
  return string.SafeGsub(s, string.ConvertPatternToLiteral(pattern), repl, n)
end

function string.Split(value, sep)
  sep = sep or "%s"
  local t = {}
  for field, s in string.gmatch(value, "([^" .. sep .. "]*)(" .. sep .. "?)") do
    table.insert(t, field)
    if "" == s then
      return t
    end
  end
  if #t > 0 then
    return t
  end
end

function string:split(delimiter)
  local result = {}
  local from = 1
  local delim_from, delim_to = string.find(self, delimiter, from)
  while delim_from do
    table.insert(result, string.sub(self, from, delim_from - 1))
    from = delim_to + 1
    delim_from, delim_to = string.find(self, delimiter, from)
  end
  table.insert(result, string.sub(self, from))
  return result
end

function string.GetPrintTable(str)
  local len = str and #str or 0
  local left = 0
  local arr = {
    0,
    192,
    224,
    240,
    248,
    252
  }
  local t = {}
  local start = 1
  local wordLen = 0
  while len ~= left do
    local tmp = string.byte(str, start)
    local i = #arr
    while arr[i] and not (tmp >= arr[i]) do
      i = i - 1
    end
    wordLen = i + wordLen
    local tmpString = string.sub(str, start, wordLen)
    start = start + i
    left = left + i
    t[#t + 1] = tmpString
  end
  return t
end

function string.ExtralongandOmitted(UseStr, LongLimit)
  local str = string.GetPrintTable(UseStr)
  local text = ""
  local NeedSub = false
  local Count = 0
  for i = 1, #str do
    local ByteCount = string.SubStringGetByteCount(str[i], 1)
    if ByteCount < 2 then
      Count = Count + 1
    else
      Count = Count + 1.6
    end
    if LongLimit < Count and Count - LongLimit > 0.6 then
      NeedSub = true
      break
    else
      text = text .. str[i]
    end
  end
  if NeedSub then
    return string.format("%s%s", text, "...")
  else
    return UseStr
  end
end

function string.ExtraLongAndOmittedWithWidth(UseStr, LongLimit)
  local str = string.GetPrintTable(UseStr)
  local text = ""
  local NeedSub = false
  local Count = 0
  local WideUpperCase = "WM"
  local NarrowUpperCase = "IJ"
  local WideLowerCase = "mw"
  local NarrowLowerCase = "iljtfr"
  for i = 1, #str do
    local char = str[i]
    local ByteCount = string.SubStringGetByteCount(char, 1)
    if ByteCount < 2 then
      if string.find(WideUpperCase, char, 1, true) or string.find(WideLowerCase, char, 1, true) then
        Count = Count + 2
      elseif string.find(NarrowUpperCase, char, 1, true) then
        Count = Count + 0.8
      elseif string.upper(char) == char then
        Count = Count + 1.6
      elseif string.find(NarrowLowerCase, char, 1, true) then
        Count = Count + 0.6
      else
        Count = Count + 1.2
      end
    else
      Count = Count + 2
    end
    if LongLimit < Count and Count > LongLimit - 2 then
      NeedSub = true
      break
    else
      text = text .. char
    end
  end
  if NeedSub then
    return string.format("%s%s", text, "...")
  else
    return UseStr
  end
end

function string.GetSubStr(pStr, pLen)
  local len = pStr and #pStr or 0
  local left = len
  local cnt = 0
  local arr = {
    0,
    192,
    224,
    240,
    248,
    252
  }
  while 0 ~= left do
    local tmp = string.byte(pStr, -left)
    local i = #arr
    while arr[i] do
      if tmp >= arr[i] then
        left = left - i
        break
      end
      i = i - 1
    end
    if 3 == i then
      cnt = cnt + 2
      if pLen < cnt then
        left = left + 3
        return string.sub(pStr, 1, len - left), cnt
      elseif cnt == pLen then
        return string.sub(pStr, 1, len - left), cnt
      end
    elseif 1 == i then
      cnt = cnt + 1
      if cnt == pLen then
        return string.sub(pStr, 1, len - left), cnt
      end
    end
  end
  return pStr, cnt
end

function string.StringGetTotalNum(str)
  local len = str and #str or 0
  local left = len
  local cnt = 0
  local arr = {
    0,
    192,
    224,
    240,
    248,
    252
  }
  while 0 ~= left do
    local tmp = string.byte(str, -left)
    local i = #arr
    while arr[i] do
      if tmp >= arr[i] then
        left = left - i
        break
      end
      i = i - 1
    end
    if 3 == i then
      cnt = cnt + 2
    elseif 1 == i then
      cnt = cnt + 1
    end
  end
  return cnt
end

function string.CipherTextEncode(chat_message)
  local FriendGlobalConfig = _G.DataConfigManager:GetFriendGlobalConfig("chat_message_cipher_text")
  local out = chat_message
  if FriendGlobalConfig then
    local EnglishString = FriendGlobalConfig.str
    local modified_string = EnglishString:gsub(";", "")
    if modified_string and utf8.len(modified_string) > 0 then
      out = ""
      local len = string.IsEmo(chat_message) and 1 or utf8.len(chat_message)
      for i = 1, len do
        local Index = math.random(1, utf8.len(modified_string))
        out = string.format("%s%s", out, string.CharAt(modified_string, Index))
      end
    end
  end
  Log.Debug(chat_message, utf8.len(chat_message), out, "string.CipherTextEncode")
  return out
end

function string.IsEmo(message)
  local index = string.find(message, "c#%%_")
  if index and 1 == index then
    return true
  end
  return false
end

function string.Escape(str)
  local pattern = "[^%w%d%._%-%* ]"
  local s = string.gsub(str, pattern, function(c)
    c = string.format("%%%02X", string.byte(c))
    return c
  end)
  s = string.gsub(s, " ", "+")
  return s
end

function string.SubStringUTF8(str, startIndex, endIndex)
  if startIndex < 0 then
    startIndex = string.SubStringGetTotalIndex(str) + startIndex + 1
  end
  if nil ~= endIndex and endIndex < 0 then
    endIndex = string.SubStringGetTotalIndex(str) + endIndex + 1
  end
  if nil == endIndex then
    return string.sub(str, string.SubStringGetTrueIndex(str, startIndex))
  else
    return string.sub(str, string.SubStringGetTrueIndex(str, startIndex), string.SubStringGetTrueIndex(str, endIndex + 1) - 1)
  end
end

function string.SubStringGetTotalIndex(str)
  local curIndex = 0
  local i = 1
  local lastCount = 1
  repeat
    lastCount = string.SubStringGetByteCount(str, i)
    i = i + lastCount
    curIndex = curIndex + 1
  until 0 == lastCount
  return curIndex - 1
end

function string.SubStringGetTrueIndex(str, index)
  local curIndex = 0
  local i = 1
  local lastCount = 1
  repeat
    lastCount = string.SubStringGetByteCount(str, i)
    i = i + lastCount
    curIndex = curIndex + 1
  until index <= curIndex
  return i - lastCount
end

function string.SubStringGetByteCount(str, index)
  local curByte = string.byte(str, index)
  local byteCount = 1
  if nil == curByte then
    byteCount = 0
  elseif curByte > 0 and curByte <= 127 then
    byteCount = 1
  elseif curByte >= 192 and curByte <= 223 then
    byteCount = 2
  elseif curByte >= 224 and curByte <= 239 then
    byteCount = 3
  elseif curByte >= 240 and curByte <= 247 then
    byteCount = 4
  end
  return byteCount
end

function string.TrimSize(str, size, suffix)
  if string.IsNilOrEmpty(str) then
    return str
  end
  size = size or 0
  if 0 == size then
    return ""
  end
  local strLen = string.SubStringGetTotalIndex(str)
  local suffixLen = string.IsNilOrEmpty(suffix) and 0 or string.SubStringGetTotalIndex(suffix)
  if size < suffixLen then
    return suffix
  end
  if size > strLen then
    return str
  else
    return string.format("%s%s", string.SubStringUTF8(str, 0, size - suffixLen), suffix)
  end
end

function string.AsClass(str)
  return UE.UClass.Load(str)
end

function string.AsObject(str)
  return UE.UObject.Load(str)
end
