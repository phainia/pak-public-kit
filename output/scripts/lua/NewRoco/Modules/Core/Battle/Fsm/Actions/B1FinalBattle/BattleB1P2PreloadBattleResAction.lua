local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattleActionBase
local BattleB1P2PreloadBattleResAction = Base:Extend("BattleB1P2PreloadBattleResAction")
FsmUtils.MergeMembers(Base, BattleB1P2PreloadBattleResAction, {})

function BattleB1P2PreloadBattleResAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self:SetActionType(BattleActionBase.ActionType.ClientSeqAction)
  self.timeout = 999
end

function BattleB1P2PreloadBattleResAction:OnEnter()
  if _G.BattleManager.debugEnv.closeB1FBP2Seq then
    self:PreloadP2StartG6()
    return
  end
  BattleResourceManager:LoadResAsync(self, BattleConst.B1P2EnterSequence, self.OnLoadSequence, self.OnLoadSequenceFailed, nil, nil, nil, PriorityEnum.Passive_Battle_High)
end

function BattleB1P2PreloadBattleResAction:OnLoadSequence()
  self:PreloadP2StartG6()
end

function BattleB1P2PreloadBattleResAction:OnLoadSequenceFailed()
  self:PreloadP2StartG6()
end

function BattleB1P2PreloadBattleResAction:PreloadP2StartG6()
  BattleSkillManager:PreLoadSingleResInternal(BattleConst.B1P2EnterG6, true)
  self:Finish()
end

return BattleB1P2PreloadBattleResAction
