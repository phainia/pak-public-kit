local Base = require("NewRoco.AI.BehaviorTree.LuaServiceBase")
local LuaServiceUpdateBattleInfo = Base:Extend("LuaServiceUpdateBattleInfo")

function LuaServiceUpdateBattleInfo:OnUpdateService(OwnerController, DeltaTime, ...)
  local aiController = OwnerController
  if self.InstanceNRCModuleManager == nil then
    self.InstanceNRCModuleManager = NRCModuleManager
  end
  if nil == self.InstanceBattleModuleCmd then
    self.InstanceBattleModuleCmd = BattleModuleCmd
  end
  if nil == self.InstanceNpcModuleCmd then
    self.InstanceNpcModuleCmd = NPCModuleCmd
  end
  local isInBattle = self.InstanceNRCModuleManager:DoCmd(self.InstanceNpcModuleCmd.GetHasEnterBattle)
  if isInBattle ~= self.IsInBattle:GetValue(aiController) then
    self.IsInBattle:SetValue(aiController, isInBattle)
  end
  if isInBattle then
    local target = aiController.Npc
    if target then
      local pos = target:GetActorLocation()
      local battleCenter, battleRange = aiController:GetBattleCenterInfo()
      if nil ~= pos and nil ~= battleCenter and nil ~= battleRange then
        local dir_x = pos.X - battleCenter.X
        local dir_y = pos.Y - battleCenter.Y
        if dir_x * dir_x + dir_y * dir_y < battleRange * battleRange then
          if not self.IsInBattleField:GetValue(aiController) then
            self.IsInBattleField:SetValue(aiController, true)
          end
          return
        end
      else
        Log.WarningFormat("LuaDecoratorIsActorInBattleFiled Pos:%s, battleCenter:%s, battleRadius:%s", tostring(pos), tostring(battleCenter), tostring(battleRange))
      end
    end
  end
  if self.IsInBattleField:GetValue(aiController) then
    self.IsInBattleField:SetValue(aiController, false)
  end
end

return LuaServiceUpdateBattleInfo
