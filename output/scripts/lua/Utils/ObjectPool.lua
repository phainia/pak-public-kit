local Class = _G.MakeSimpleClass
local ObjectPool = Class("ObjectPool")

function ObjectPool:Ctor(createFunc, cleanFunc, maxSize, tagStr)
  self.createFunc = createFunc or function()
    return {}
  end
  self.cleanFunc = cleanFunc or function()
  end
  self.maxSize = maxSize or 100
  self.pool = {}
  self.name = tagStr
end

function ObjectPool:WarmingUp()
  for _ = 1, self.maxSize do
    local newObj = self.createFunc()
    table.insert(self.pool, newObj)
  end
end

function ObjectPool:get(...)
  if #self.pool > 0 then
    return table.remove(self.pool)
  else
    return self.createFunc(...)
  end
end

function ObjectPool:release(obj)
  if #self.pool < self.maxSize then
    self.cleanFunc(obj)
    table.insert(self.pool, obj)
    return true
  end
  return false
end

function ObjectPool:available()
  return #self.pool
end

return ObjectPool
