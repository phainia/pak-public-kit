local Base = require("NewRoco.AI.BehaviorTree.LuaDecoratorBase")
local LuaDecoratorIsInBattle = Base:Extend("LuaDecoratorBoolOp")

function LuaDecoratorIsInBattle:PerformConditionCheck(OwnerController, ...)
  local owner = OwnerController
  if self.InstanceNRCModuleManager == nil then
    self.InstanceNRCModuleManager = NRCModuleManager
  end
  if nil == self.InstanceBattleModuleCmd then
    self.InstanceBattleModuleCmd = BattleModuleCmd
  end
  if nil == self.InstanceNpcModuleCmd then
    self.InstanceNpcModuleCmd = NPCModuleCmd
  end
  local resultValue = self.InstanceNRCModuleManager:DoCmd(self.InstanceNpcModuleCmd.GetHasEnterBattle)
  return resultValue
end

return LuaDecoratorIsInBattle
