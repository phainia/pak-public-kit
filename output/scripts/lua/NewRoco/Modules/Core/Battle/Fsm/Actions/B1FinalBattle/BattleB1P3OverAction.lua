local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local CastSkillObject = require("NewRoco.Modules.Core.Battle.BattleCore.Skill.CastSkillObject")
local Base = BattleActionBase
local BattleB1P3OverAction = Base:Extend("BattleB1P3OverAction")
FsmUtils.MergeMembers(Base, BattleB1P3OverAction, {})

function BattleB1P3OverAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self:SetActionType(BattleActionBase.ActionType.ClientSeqAction)
end

function BattleB1P3OverAction:OnEnter()
  BattleResourceManager:LoadResAsync(self, BattleConst.B1P3OverSequence, self.Finish, self.Finish)
end

return BattleB1P3OverAction
