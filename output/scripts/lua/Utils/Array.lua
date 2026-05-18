local Array = {}
Array.__index = Array
setmetatable(Array, {
  __call = function(class, ...)
    local instance = {_items = nil}
    setmetatable(instance, Array)
    instance:_new(...)
    return instance
  end
})

function Array:_new(...)
  local args = {
    ...
  }
  if #args > 0 then
    self._items = args
  else
    self._items = table.new(8, 0)
  end
end

function Array:__tostring()
  local seperator = ", "
  local size = self:Size()
  local buffer = {"["}
  for i, v in ipairs(self._items) do
    if i == size then
      table.insert(buffer, string.format("%d: %s", i, tostring(v)))
    else
      table.insert(buffer, string.format("%d: %s%s", i, tostring(v), seperator))
    end
  end
  table.insert(buffer, "]")
  return table.concat(buffer)
end

function Array:Clone()
  local ret = Array()
  for i = 1, self:Size() do
    ret:Add(self._items[i])
  end
  return ret
end

function Array:Clear()
  table.clear(self._items)
end

function Array:IsEmpty()
  return 0 == #self._items
end

function Array:Items()
  return self._items
end

function Array:Size()
  return #self._items
end

function Array:Set(index, value)
  assert(index > 0 and index <= #self._items, string.format("index out of range(%d/%d)", index, #self._items))
  self._items[index] = value
end

function Array:Get(index)
  assert(index > 0 and index <= #self._items, string.format("index out of range(%d/%d)", index, #self._items))
  return self._items[index]
end

function Array:GetIn(index)
  if index > #self._items then
    return true
  end
  return false
end

function Array:Add(item)
  table.insert(self._items, item)
end

function Array:Insert(pos, item)
  table.insert(self._items, pos, item)
end

function Array:Push(item)
  table.insert(self._items, item)
end

function Array:Remove(item)
  local index = self:IndexOf(item)
  if index > 0 then
    table.remove(self._items, index)
  end
end

function Array:RemoveAt(idx)
  assert(idx >= 1 and idx <= #self._items, string.format("index out of range, (%d/%d).", idx, #self._items))
  table.remove(self._items, idx)
end

function Array:Pop()
  assert(#self._items > 0, "stack underflow.")
  local ret = self._items[#self._items]
  table.remove(self._items)
  return ret
end

function Array:IndexOf(item)
  for i = 1, #self._items do
    if self._items[i] == item then
      return i
    end
  end
  return -1
end

function Array:Slice(start, finish)
  local ret = Array()
  finish = finish or #self._items
  start = start < 1 and 1 or start
  finish = finish > #self._items and #self._items or finish
  for i = start, finish do
    ret:Add(self._items[i])
  end
  return ret
end

function Array:Sliced(start, finish)
  finish = finish or #self._items
  assert(start > 0 and finish <= #self._items and start <= finish, string.format("start(%d/%d) or finish(%d/%d) is out of range.", start, #self._items, finish, #self._items))
  for i = #self._items, finish + 1, -1 do
    self._items[i] = nil
  end
  for i = 1, start - 1 do
    table.remove(self._items, 1)
  end
end

function Array:Reverse()
  local ret = Array()
  if 0 == self:Size() then
    return ret
  end
  for i = self:Size(), 1, -1 do
    ret:Add(self:Get(i))
  end
  return ret
end

function Array:Reversed()
  if 0 == self:Size() then
    return
  end
  local new_items = {}
  local size = self:Size()
  for i = 1, size / 2 do
    local temp = self._items[i]
    self._items[i] = self._items[size - i + 1]
    self._items[size - i + 1] = temp
  end
end

function Array:First()
  return self._items[1]
end

function Array:Last()
  return self._items[#self._items]
end

function Array:Map(callback)
  local ret = Array()
  for i = 1, self:Size() do
    ret:Add(callback(self._items[i], i))
  end
  return ret
end

function Array:Mapped(callback)
  for i = 1, self:Size() do
    self._items[i] = callback(self._items[i], i)
  end
end

function Array:Filter(callback)
  local ret = Array()
  for i = 1, self:Size() do
    if callback(self._items[i], i) then
      ret:Add(self._items[i])
    end
  end
  return ret
end

function Array:Filtered(callback)
  for i = self:Size(), 1, -1 do
    if not callback(self._items[i], i) then
      self:RemoveAt(i)
    end
  end
end

function Array:Reduce(callback)
  if self:Size() < 2 then
    return nil
  end
  local ret = callback(self:Get(1), self:Get(2))
  for i = 3, self:Size() do
    ret = callback(ret, self._items[i])
  end
  return ret
end

function Array:Concat(otherArr)
  local ret = self:Clone()
  for i = 1, otherArr:size() do
    ret:Add(otherArr._items[i])
  end
  return ret
end

function Array:Unique()
  local ret = Array()
  local s = {}
  for i = 1, self:Size() do
    local item = self._items[i]
    if not s[item] then
      ret:Add(item)
      s[item] = true
    end
  end
  return ret
end

function Array:Uniqued()
  local s = {}
  for i = self:Size(), 1, -1 do
    local item = self._items[i]
    if s[item] then
      self:RemoveAt(s[item])
    end
    s[item] = i
  end
end

return Array
