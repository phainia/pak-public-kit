local Base = BattleActionBase
local PreProcessEnterB2BattleAction = Base:Extend("PreProcessEnterB2BattleAction")

function PreProcessEnterB2BattleAction:OnEnter()
  self:OnTick()
end

function PreProcessEnterB2BattleAction:OnTick(DeltaTime)
  local skillPath = BattleConst.B1P2EnterG6
  local class = BattleSkillManager:GetLoadedClass(skillPath)
  if class then
    self:Finish()
  end
end

return PreProcessEnterB2BattleAction
