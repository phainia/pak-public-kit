table = _G.table

function table.makeReadOnly(t)
  if type(t) ~= "table" then
    error("makeReadOnly expects a table, got " .. type(t))
  end
  local makeSubReadOnly = function(subT)
    local proxy = {}
    local mt = {
      __index = function(_, k)
        local v = subT[k]
        if type(v) == "table" then
          return makeSubReadOnly(v)
        end
        return v
      end,
      __newindex = function(_, k, v)
        error("Attempt to modify read-only table. Key: " .. tostring(k), 2)
      end,
      __metatable = "Read-only table",
      __original = subT
    }
    return setmetatable(proxy, mt)
  end
  return makeSubReadOnly(t)
end

function table.makeEnumTable(t)
  for k, v in pairs(t) do
    if type(k) == "number" then
      t[v] = k
    elseif type(v) == "number" then
      t[k] = v
      t[v] = k
    end
  end
  
  function t:tostring(value)
    return tostring(t[value])
  end
  
  return t
end

function table.unlockReadOnly(roTable)
  local mt = getmetatable(roTable)
  if not mt or mt.__metatable ~= "Read-only table" then
    error("Given table is not a read-only table created by makeReadOnly")
  end
  local unlockSubReadOnly = function(proxy)
    local original = getmetatable(proxy).__original
    for k, v in pairs(original) do
      if type(v) == "table" then
        original[k] = unlockSubReadOnly(proxy[k])
      end
    end
    return original
  end
  return unlockSubReadOnly(roTable)
end

table.shallowCopy = table.shallowCopy or function(orig)
  local copy = {}
  for k, v in pairs(orig) do
    copy[k] = v
  end
  return copy
end

function table.createNullableTable()
  local tbl = {}
  local meta = {
    __add = function(a, b)
      if getmetatable(a) == meta then
        return b
      end
      return a
    end,
    __sub = function(a, b)
      if getmetatable(a) == meta then
        return -b
      end
      return a
    end,
    __mul = function(a, b)
      if getmetatable(a) == meta then
        return b
      end
      return a
    end,
    __div = function(a, b)
      if getmetatable(a) == meta then
        return 1 / b
      end
      return a
    end,
    __tostring = function()
      return "NullableTable"
    end,
    __index = function(t, k)
      return table.createNullableTable()
    end,
    __eq = function()
      return false
    end,
    __unm = function()
      return 0
    end,
    __mod = function()
      return 0
    end,
    __pow = function()
      return 1
    end,
    __concat = function()
      return "NullableTable"
    end,
    __len = function()
      return 0
    end,
    __lt = function()
      return false
    end,
    __le = function()
      return false
    end,
    __call = function()
      return nil
    end,
    __newindex = function()
    end,
    __metatable = "NullableTableMeta"
  }
  return setmetatable(tbl, meta)
end
