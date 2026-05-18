local BattlePerformNodePool = NRCClass:Extend("BattlePerformPlayer")

function BattlePerformNodePool:Ctor()
  self.free = {}
end

function BattlePerformNodePool:Get(nodeCla, player)
  local node = table.remove(self.free, #self.free)
  if node then
    node:ResetData()
    node:Init(player)
    return node
  else
    return nodeCla(player)
  end
end

function BattlePerformNodePool:Release(node)
  table.insert(self.free, node)
end

function BattlePerformNodePool:Empty()
  self.free = {}
end

return BattlePerformNodePool
