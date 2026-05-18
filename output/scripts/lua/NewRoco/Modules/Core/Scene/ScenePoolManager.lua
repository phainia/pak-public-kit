local Class = _G.MakeSimpleClass
local InstancePool = require("Utils.InstancePool")
local ScenePoolManager = Class("ScenePoolManager")

function ScenePoolManager:Ctor()
  self.pools = {}
end

function ScenePoolManager:GetPool(PoolKey)
  local pool = self.pools[PoolKey]
  if not pool then
    pool = InstancePool(PoolKey, nil, 0)
    self.pools[PoolKey] = pool
  end
  return pool
end

function ScenePoolManager:DestroyPool(PoolKey)
  local pool = self.pools[PoolKey]
  if pool then
    self.pools[PoolKey] = nil
    pool:Clear(true)
  end
end

function ScenePoolManager:Clear()
  if self.pools then
    for _, v in pairs(self.pools) do
      if v then
        v:Clear(true)
      end
    end
  end
  self.pools = {}
end

return ScenePoolManager
