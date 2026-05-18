local Base = BattleActionBase
local PreProcessEnterB3BattleAction = Base:Extend("PreProcessEnterB3BattleAction")

function PreProcessEnterB3BattleAction:OnEnter()
  self:OnTick()
end

function PreProcessEnterB3BattleAction:OnTick(DeltaTime)
  local skillPath = BattleConst.B1P3EnterG6
  local class = BattleSkillManager:GetLoadedClass(skillPath)
  if class then
    self:Finish()
  end
end

return PreProcessEnterB3BattleAction
