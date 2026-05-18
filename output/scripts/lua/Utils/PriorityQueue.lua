local PriorityQueue = {}
PriorityQueue.__index = PriorityQueue

local function DefaultCmp(item1, item2)
  return item1 < item2
end

setmetatable(PriorityQueue, {
  __call = function(class, ...)
    local instance = {}
    setmetatable(instance, PriorityQueue)
    instance:_new(...)
    return instance
  end
})

function PriorityQueue:_new(...)
  self:Clear(...)
end

function PriorityQueue:__tostring()
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

function PriorityQueue:Clear(useMap)
  if nil == useMap then
    useMap = true
  end
  self._items = {}
  self.cmp = DefaultCmp
  self._posMap = {}
  self.useMap = useMap
end

function PriorityQueue:Swap(x, y)
  if x == y then
    return
  end
  if self.useMap then
    self._posMap[self._items[x]] = y
    self._posMap[self._items[y]] = x
  end
  local temp = self._items[x]
  self._items[x] = self._items[y]
  self._items[y] = temp
end

function PriorityQueue:ReMoveTopNode(treePos)
  treePos = treePos or 1
  local last = #self._items
  self:Swap(treePos, last)
  if self.useMap then
    self._posMap[self._items[last]] = nil
  end
  self._items[last] = nil
  self:AdjustDown(treePos)
end

function PriorityQueue:InsertNode(item)
  table.insert(self._items, item)
  local last = #self._items
  if self.useMap then
    self._posMap[item] = last
  end
  self:AdjustUp(last)
end

function PriorityQueue:AdjustUp(pos)
  local parent = math.floor(pos / 2)
  while 0 ~= parent and self.cmp(self._items[pos], self._items[parent]) do
    self:Swap(pos, parent)
    pos = parent
    parent = math.floor(pos / 2)
  end
end

function PriorityQueue:AdjustDown(pos)
  local now = pos
  local c1 = now * 2
  local c2 = c1 + 1
  while self._items[c1] or self._items[c2] do
    if not self._items[c2] then
      if self.cmp(self._items[c1], self._items[now]) then
        self:Swap(now, c1)
      end
      break
    elseif not self._items[c1] then
      if self.cmp(self._items[c2], self._items[now]) then
        self:Swap(now, c2)
      end
      break
    else
      local val = self._items[now]
      local val1 = self._items[c1]
      local val2 = self._items[c2]
      if not (self.cmp(val1, val) or self.cmp(val2, val)) then
        break
      end
      local toSwap
      if self.cmp(val1, val2) then
        toSwap = c1
      else
        toSwap = c2
      end
      self:Swap(now, toSwap)
      now = toSwap
      c1 = now * 2
      c2 = c1 + 1
    end
  end
  return now
end

function PriorityQueue:Size()
  return #self._items
end

function PriorityQueue:Adjust(item)
  if not self.useMap then
    return
  end
  local pos = self._posMap[item]
  if not pos then
    return
  end
  local parent = math.max(1, math.floor(pos))
  if not self.cmp(self._items[parent], item) then
    self:AdjustUp(pos)
  else
    self:AdjustDown(pos)
  end
end

function PriorityQueue:EnQueue(item)
  self:InsertNode(item)
end

function PriorityQueue:DeQueue()
  if 0 == self:Size() then
    return nil
  end
  local ans = self._items[1]
  self:ReMoveTopNode()
  return ans
end

function PriorityQueue:Remove(item)
  if not self.useMap then
    return false
  end
  local pos = self._posMap[item]
  if not pos then
    return false
  end
  self:ReMoveTopNode(pos)
  return true
end

function PriorityQueue:Contains(item)
  if not self.useMap then
    return false
  end
  local pos = self._posMap[item]
  if pos then
    return true
  else
    return false
  end
end

function PriorityQueue:GetTop()
  if 0 == self:Size() then
    return nil
  end
  return self._items[1]
end

function PriorityQueue:SetCmpFunction(cmp)
  self.cmp = cmp
end

return PriorityQueue
