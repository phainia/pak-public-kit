local DEFAULT_ITEM_SIZE = 8
local Queue = {}
Queue.__index = Queue
setmetatable(Queue, {
  __call = function(class, ...)
    local instance = {
      _items = nil,
      firstIndex = 1,
      lastIndex = 0
    }
    setmetatable(instance, Queue)
    instance:_new(...)
    return instance
  end
})

function Queue:_new(Size)
  self:Clear(Size)
end

function Queue:__tostring()
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

function Queue:Clear(Size)
  self._items = table.new(Size or DEFAULT_ITEM_SIZE, 0)
  self.firstIndex = 1
  self.lastIndex = 0
end

function Queue:Size()
  return self.lastIndex - self.firstIndex + 1
end

function Queue:AddFirst(Item)
  self.firstIndex = self.firstIndex - 1
  self._items[self.firstIndex] = Item
end

function Queue:RemoveFirst()
  if self.firstIndex > self.lastIndex then
    error("Queue is empty")
  end
  local value = self._items[self.firstIndex]
  self._items[self.firstIndex] = nil
  self.firstIndex = self.firstIndex + 1
  return value
end

function Queue:First()
  if self.firstIndex > self.lastIndex then
    error("Queue is empty")
  end
  return self._items[self.firstIndex]
end

function Queue:AddLast(Item)
  self.lastIndex = self.lastIndex + 1
  self._items[self.lastIndex] = Item
end

function Queue:RemoveLast()
  if self.firstIndex > self.lastIndex then
    error("Queue is empty")
  end
  local value = self._items[self.lastIndex]
  self._items[self.lastIndex] = nil
  self.lastIndex = self.lastIndex - 1
  return value
end

function Queue:Last()
  if self.firstIndex > self.lastIndex then
    error("Queue is empty")
  end
  return self._items[self.lastIndex]
end

function Queue:Enqueue(Item)
  self:AddLast(Item)
end

function Queue:Dequeue()
  return self:RemoveFirst()
end

function Queue.pairs(queue)
  local function iter(self, idx)
    if self.lastIndex + 1 == self.firstIndex then
      return nil, nil
    end
    if not idx then
      idx = self.firstIndex
    else
      idx = idx + 1 <= self.lastIndex and idx + 1 or nil
    end
    return idx, idx and self._items[idx]
  end
  
  return iter, queue, nil
end

return Queue
