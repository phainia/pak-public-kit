local PreProcessEnterBattleAction = require("NewRoco.Modules.Core.Battle.Fsm.Actions.PreProcessEnterBattleAction")
local Base = BattleActionBase
local PreProcessEnterB1BattleAction = Base:Extend("PreProcessEnterB1BattleAction")

function PreProcessEnterB1BattleAction:OnEnter()
  self.hasCheck = false
  self:OnTick()
end

function PreProcessEnterB1BattleAction:OnTick(DeltaTime)
  if self.hasCheck then
    return
  end
  local skillPath = BattleConst.B1P1EnterG6
  local class = BattleSkillManager:GetLoadedClass(skillPath)
  if class then
    self.hasCheck = true
    self:Finish()
  end
end

return PreProcessEnterB1BattleAction
