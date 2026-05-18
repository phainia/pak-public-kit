local BattlePlayerBase = require("NewRoco.Modules.Core.Battle.BattleCore.BattlePlayerBase")
local BattleParallelPlayer = BattlePlayerBase:Extend()

function BattleParallelPlayer:Ctor()
  BattlePlayerBase.Ctor(self)
end

function BattleParallelPlayer:Reset()
  self.parallel_count = 0
  self.parallel_nodes = {}
end

function BattleParallelPlayer:Play(performNode)
  self:Reset()
  self.performNode = performNode
  self.parallel_nodes = self.performNode:GetParallelNodes()
  local parallel_perform_nodes = {}
  for _, node in ipairs(self.parallel_nodes) do
    local group = node.OwnerGroup
    local player = node:GetPlayer()
    if group and player then
      self.parallel_count = self.parallel_count + 1
      if player.SetFinishCallback then
        player:SetFinishCallback(self, self.OnParallelPlayerFinish)
      end
      table.insert(parallel_perform_nodes, node)
    end
  end
  self.parallel_count = #parallel_perform_nodes
  if self.parallel_count > 0 then
    for _, node in ipairs(parallel_perform_nodes) do
      local group = node.OwnerGroup
      group:PlayNode(node)
    end
  else
    self:OnFinish()
  end
end

function BattleParallelPlayer:OnParallelPlayerFinish(player)
  self.parallel_count = self.parallel_count - 1
  if 0 == self.parallel_count then
    self:OnFinish()
  end
end

function BattleParallelPlayer:OnFinish()
  if self:GetRuntimeData("is_finish") then
    return
  end
  self:SetRuntimeData("is_finish", true)
  _G.BattleManager.battleRuntimeData:ReduceResonancePerform()
  self.performNode:PerformComplete()
end

return BattleParallelPlayer
