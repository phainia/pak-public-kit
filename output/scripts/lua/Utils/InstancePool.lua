local InstancePool = {}
InstancePool.__index = InstancePool
setmetatable(InstancePool, {
  __call = function(self, name, class, preSize)
    return InstancePool.CreatePool(name, class, preSize)
  end
})

local function BoxPoolCacheEntry(inst)
  if UE4.UObject.IsValid(inst) then
    return {
      inst,
      UnLua.Ref(inst)
    }
  else
    return {inst}
  end
end

local function UnBoxPoolCacheEntry(entry)
  return entry and entry[1]
end

function InstancePool.CreatePool(name, class, preSize)
  local newPool = {}
  setmetatable(newPool, InstancePool)
  newPool:New(name, class, preSize)
  return newPool
end

function InstancePool:New(name, class, preSize)
  self.name = name
  self._class = class
  self._pool = {}
  if preSize > 0 then
    self:PreSize(preSize)
  end
end

function InstancePool:Get(create, ...)
  local ins
  local pool = self._pool
  if pool and #pool > 0 then
    ins = UnBoxPoolCacheEntry(pool[#pool])
    pool[#pool] = nil
  end
  if not ins and create and self._class then
    ins = self._class()
  end
  if ins and ins.AwakeFromPool then
    ins:AwakeFromPool(...)
  end
  return ins
end

function InstancePool:Push(ins)
  if self._pool then
    self._pool[#self._pool + 1] = BoxPoolCacheEntry(ins)
  end
end

function InstancePool:Recycle(ins, ...)
  if self._pool then
    self._pool[#self._pool + 1] = BoxPoolCacheEntry(ins)
    if ins.ReturnToPool then
      ins:ReturnToPool(...)
    end
  end
end

function InstancePool:PreSize(count)
  if count <= #self._pool then
    return false
  end
  local needCreateSize = count - #self._pool
  local ctor = self._class
  local createFunction = ctor and function()
    return ctor()
  end or function()
    return {}
  end
  for i = 1, needCreateSize do
    self._pool[#self._pool + 1] = BoxPoolCacheEntry(createFunction())
  end
  return true
end

function InstancePool:Clear(clearClass)
  local pool = self._pool
  for i = 1, #pool do
    local ins = UnBoxPoolCacheEntry(pool[i])
    pool[i] = nil
    if ins.Destroy then
      ins:Destroy()
    end
  end
  if clearClass then
    pool._class = nil
  end
end

function InstancePool:IsEmpty()
  local pool = self._pool
  if not pool or #pool <= 0 then
    return true
  end
  return false
end

function InstancePool:Count()
  if self._pool then
    return #self._pool
  end
  return 0
end

return InstancePool
