local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattleActionBase
local BattleB1P1PreloadBattleResAction = Base:Extend("BattleB1P1PreloadBattleResAction")
FsmUtils.MergeMembers(Base, BattleB1P1PreloadBattleResAction, {})

function BattleB1P1PreloadBattleResAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self:SetActionType(BattleActionBase.ActionType.ClientSeqAction)
  self.timeout = 999
end

function BattleB1P1PreloadBattleResAction:OnEnter()
  if _G.BattleManager.debugEnv.closeB1FBP1Seq then
    self:PreloadP1StartG6()
    return
  end
  BattleResourceManager:LoadResAsync(self, BattleConst.B1P1EnterSequence, self.OnLoadSequence, self.OnLoadSequenceFailed, nil, nil, nil, PriorityEnum.Passive_Battle_High)
end

function BattleB1P1PreloadBattleResAction:OnLoadSequence()
  self:PreloadP1StartG6()
end

function BattleB1P1PreloadBattleResAction:OnLoadSequenceFailed()
  self:PreloadP1StartG6()
end

function BattleB1P1PreloadBattleResAction:PreloadP1StartG6()
  BattleSkillManager:PreLoadSingleResInternal(BattleConst.B1P1EnterG6, true)
  self:Finish()
end

return BattleB1P1PreloadBattleResAction
