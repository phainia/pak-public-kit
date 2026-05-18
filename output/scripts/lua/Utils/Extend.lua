function math.rand(n1, n2)
  return math.random(n1 * 10000, n2 * 10000) / 10000
end

function math.round(n)
  return math.floor(0.5 + n)
end

function math.clamp(v, minValue, maxValue)
  if v < minValue then
    return minValue
  end
  if maxValue < v then
    return maxValue
  end
  return v
end

function math.tableRandom(tab)
  local total = 0
  local temp = {}
  for i, content in pairs(tab) do
    total = total + content[2] or 0
    temp[i] = total
  end
  local index = math.random(1, total)
  for i, v in pairs(temp) do
    if index <= temp[i] then
      return tab[i]
    end
  end
  return tab[1]
end

function getGlobalName(object)
  if object then
    for k, v in pairs(_G) do
      if v == object then
        return k
      end
    end
  end
  return tostring(nil)
end

function toNumber(value, default)
  local ret = tonumber(value)
  return ret and ret or default or 0
end

function toTable(tableString)
  tableString = tableString or ""
  if #tableString >= 2 and string.sub(tableString, 1, 1) == "{" and string.sub(tableString, #tableString) == "}" then
    local x, y = pcall(loadstring("local __tempValue__ =" .. tableString .. " return __tempValue__"))
    if x then
      return y
    end
  end
  return {}
end

function toBool(value)
  if type(value) == "boolean" then
    return value
  elseif type(value) == "string" then
    local str = string.lower(value)
    if "true" == str or "yes" == str or "y" == str then
      return true
    else
      return false
    end
  elseif type(value) == "number" then
    if value > 0 then
      return true
    else
      return false
    end
  else
    return false
  end
end

table.empty = {}

function table.new(asize, hsize)
  return UE.NRCLuaUtils.CreateTable(asize, hsize)
end

function table.reset(t)
  UE.NRCLuaUtils.ResetTable(t)
end

function table.copy(source, destiny, overlay)
  if source then
    overlay = false ~= overlay
    destiny = destiny or {}
    for field, value in pairs(source) do
      if overlay then
        destiny[field] = value
      elseif not destiny[field] then
        destiny[field] = value
      end
    end
  end
  return destiny
end

function table.deepCopy(source, destiny, overlay)
  if type(source) ~= "table" then
    error("table.deepCopy  source is not a table")
    return
  end
  local visited = {}
  local deepCopyInternal = function(src, dest, depth)
    if depth > 1000 then
      error("table.deepCopy: recursion depth exceeds limit (1000)")
      return dest
    end
    if visited[src] then
      return visited[src]
    end
    dest = dest or {}
    visited[src] = dest
    for key, value in pairs(src or table.empty) do
      if overlay then
        if "table" == type(value) then
          dest[key] = deepCopyInternal(value, nil, depth + 1)
        else
          dest[key] = value
        end
      elseif not dest[key] then
        if "table" == type(value) then
          dest[key] = deepCopyInternal(value, nil, depth + 1)
        else
          dest[key] = value
        end
      end
    end
    return dest
  end
  return deepCopyInternal(source, destiny or {}, 1)
end

function table.copyTable(source, destiny)
  local destiny = destiny or {}
  for _, value in pairs(source or table.empty) do
    if "table" == type(value) then
      table.insert(destiny, table.copyTable(value))
    else
      table.insert(destiny, value)
    end
  end
  return destiny
end

function table.join(...)
  local ret = {}
  for i = 1, select("#", ...) do
    local tb = select(i, ...)
    for _, value in pairs(tb or table.empty) do
      table.insert(ret, value)
    end
  end
  return ret
end

function table.clear(tab)
  if tab then
    local field = next(tab)
    while field do
      tab[field] = nil
      field = next(tab)
    end
  end
  return tab
end

function table.removeValue(tab, value)
  local contain = false
  if tab then
    if table.isArray(tab) then
      local idx = 1
      for k, v in pairs(tab) do
        if v == value then
          contain = true
          table.remove(tab, idx)
          break
        end
        idx = idx + 1
      end
    else
      for k, v in pairs(tab) do
        if v == value then
          contain = true
          tab[k] = nil
          break
        end
      end
    end
  end
  return contain
end

function table.removeKey(tab, key)
  if tab then
    for k, v in pairs(tab) do
      if k == key then
        tab[k] = nil
        break
      end
    end
  end
  return tab
end

function table.findAll(tab, caller, filterFuc)
  if not tab or type(tab) ~= "table" then
    return nil
  end
  local out = {}
  for k, v in pairs(tab) do
    local ret = filterFuc(caller, v, k, tab)
    if ret then
      table.insert(out, v)
    end
  end
  return out
end

function table.size(tab)
  local size = 0
  if tab then
    size = #tab
    for k, v in pairs(tab) do
      size = size + 1
    end
  end
  return size
end

local function empty_fun()
end

function table.iterator(tab)
  if tab then
    local index = 0
    local auxTable = {}
    local count = 0
    for k, v in pairs(tab) do
      count = count + 1
      rawset(auxTable, count, k)
    end
    return function()
      index = index + 1
      if index <= count then
        local field = auxTable[index]
        return field, tab[field]
      end
    end
  else
    return empty_fun
  end
end

function table.sortIterator(tab, comparator)
  if tab then
    local index = 0
    local auxTable = {}
    local count = 0
    for k, v in pairs(tab) do
      count = count + 1
      rawset(auxTable, count, k)
    end
    table.sort(auxTable, comparator)
    return function()
      index = index + 1
      if index <= count then
        local field = auxTable[index]
        return field, tab[field]
      end
    end
  else
    return empty_fun
  end
end

function table.contains(tab, object)
  if tab and object then
    for field, value in pairs(tab) do
      if object == value then
        return true
      end
    end
  end
  return false
end

function table.containsKey(tab, key)
  if tab and key then
    for field, value in pairs(tab) do
      if key == field then
        return true
      end
    end
  end
  return false
end

function table.compair(t1, t2, diffLst)
  if type(t1) ~= "table" or type(t2) ~= "table" then
    return diffLst
  end
  for k, v in pairs(t2) do
    local t1v = t1[k]
    if nil ~= t1v then
      if type(v) ~= "table" then
        if v ~= t1v then
          local t = {}
          t.key = k
          t.oriValue = t1v
          t.newValue = v
          table.insert(diffLst, t)
        end
      else
        table.compair(t1v, v, diffLst)
      end
    else
      local t = {}
      t.key = k
      t.oriValue = "nil"
      t.newValue = v
      table.insert(diffLst, t)
    end
  end
  return diffLst
end

function table.valueEquals(t1, t2)
  local type1 = type(t1)
  local type2 = type(t2)
  if type1 ~= type2 then
    return false
  end
  if "table" ~= type1 then
    return t1 == t2
  end
  local mt1 = getmetatable(t1)
  local mt2 = getmetatable(t2)
  if mt1 ~= mt2 then
    return false
  end
  for key, value1 in pairs(t1) do
    local value2 = t2[key]
    if nil == value2 or not table.valueEquals(value1, value2) then
      return false
    end
  end
  for key, value2 in pairs(t2) do
    local value1 = t1[key]
    if nil == value1 or not table.valueEquals(value1, value2) then
      return false
    end
  end
  return true
end

function table.compairAndPrint(t1, t2)
  local diffList = table.compair(t1, t2, {})
  for i = 1, #diffList do
    print("diffList:", diffList[i].key, diffList[i].oriValue, diffList[i].newValue)
  end
  if 0 == #diffList then
    print("diffList:no diff")
  end
end

function table.insertUnique(tab, object)
  if tab and object then
    for field, value in pairs(tab) do
      if object == value then
        return
      end
    end
    table.insert(tab, object)
  end
end

function table.diff(tab1, tab2)
  local countMap = {}
  if tab1 and #tab1 > 0 then
    for i, v in ipairs(tab1) do
      if nil == countMap[v] then
        countMap[v] = 1
      else
        countMap[v] = countMap[v] + 1
      end
    end
  end
  if tab2 and #tab2 > 0 then
    for i, v in ipairs(tab2) do
      if nil == countMap[v] then
        countMap[v] = -1
      else
        countMap[v] = countMap[v] - 1
      end
    end
  end
  local onlyInTab1 = {}
  local onlyInTab2 = {}
  local inBoth = {}
  for k, v in pairs(countMap) do
    if 1 == v then
      table.insert(onlyInTab1, k)
    elseif -1 == v then
      table.insert(onlyInTab2, k)
    elseif 0 == v then
      table.insert(inBoth, k)
    end
  end
  return onlyInTab1, onlyInTab2, inBoth
end

function table.include(tab, element)
  for _, v in pairs(tab or table.empty) do
    local done = false
    if "table" == type(v) and "table" == type(element) then
      done = true
      if table.size(element) ~= table.size(v) then
        done = false
      end
      for k2, v2 in pairs(element) do
        if not v[k2] or v[k2] ~= v2 then
          done = false
          break
        end
      end
    elseif v == element then
      done = true
    end
    if done then
      return true
    end
  end
  return false
end

function table.includes(tab, elements)
  for k, v in pairs(elements or table.empty) do
    if not table.include(tab, v) then
      return false
    end
  end
  return true
end

function table.isArray(tab)
  if not tab then
    return false
  end
  local ret = true
  local idx = 1
  for f, v in pairs(tab) do
    if type(f) == "number" then
      if f ~= idx then
        ret = false
      end
    else
      ret = false
    end
    if not ret then
      break
    end
    idx = idx + 1
  end
  return ret
end

function table.isMap(tab)
  if not tab then
    return false
  end
  return table.isArray(tab) ~= true
end

function table.isEmpty(tab)
  return nil == tab or nil == _G.next(tab)
end

function table.isNotEmpty(tab)
  return nil ~= tab and nil ~= next(tab)
end

function table.getKeyName(tab, value)
  for k, v in pairs(tab or table.empty) do
    if v == value then
      return tostring(k)
    end
  end
  return ""
end

function table.save(tab, fname, name)
  if type(tab) == "table" then
    local f = io.open(fname, "w")
    if f then
      if type(name) == "string" then
        f:write(name .. " = ")
      end
      f:write(serialize(tab))
      f:close()
      return true
    end
  end
  return false
end

function table.format(desTab, srcTab)
  if type(srcTab) ~= "table" then
    print("table.format error", debug.traceback())
    return
  end
  for _, v in pairs(srcTab) do
    if type(v) ~= "table" then
      table.insert(desTab, v)
    else
      table.format(desTab, v)
    end
  end
end

function table.clone(tab)
  local object = {}
  for k, v in pairs(tab) do
    if type(v) == "table" then
      object[k] = table.clone(v)
    else
      object[k] = v
    end
  end
  return object
end

function table.print(tab)
  if not tab then
    return
  end
  for _, v in ipairs(tab) do
    print(v)
  end
end

function table.indexOf(t, item, checkIsArray)
  if checkIsArray and not table.isArray(t) then
    return nil
  end
  for i, k in ipairs(t) do
    if k == item then
      return i
    end
  end
  return nil
end

function table.reverse(t)
  if not table.isArray(t) then
    return
  end
  local n = #t
  for i = 1, math.floor(n / 2) do
    t[i], t[n] = t[n], t[i]
    n = n - 1
  end
end

local function insertionSort(arr, left, right, comp)
  for i = left + 1, right do
    local key = arr[i]
    local j = i - 1
    while left <= j and comp(key, arr[j]) do
      arr[j + 1] = arr[j]
      j = j - 1
    end
    arr[j + 1] = key
  end
end

local function merge(arr, temp, left, mid, right, comp)
  local i, j, k = left, mid + 1, left
  while mid >= i and right >= j do
    if not comp(arr[j], arr[i]) then
      temp[k] = arr[i]
      i = i + 1
    else
      temp[k] = arr[j]
      j = j + 1
    end
    k = k + 1
  end
  while mid >= i do
    temp[k] = arr[i]
    i = i + 1
    k = k + 1
  end
  while right >= j do
    temp[k] = arr[j]
    j = j + 1
    k = k + 1
  end
  for i = left, right do
    arr[i] = temp[i]
  end
end

function table.stableSort(arr, comp)
