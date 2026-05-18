local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local Base = BattleActionBase
local BattleWaitOtherLoadAction = Base:Extend("BattleWaitOtherLoadAction")
FsmUtils.MergeMembers(Base, BattleWaitOtherLoadAction, {})

function BattleWaitOtherLoadAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleWaitOtherLoadAction:OnEnter()
  if BattleUtils.IsBattleServeWaitingLoad() then
    local waitTime = BattleManager.battleRuntimeData.roundTime - _G.ZoneServer:GetServerTime()
    if waitTime > 2 then
      self.fsm:Pause()
      self:SetTimeoutValue(waitTime)
      self.DelayId = _G.DelayManager:DelaySeconds(1, self.DelayOpenWaiting, self)
    else
      self:Finish()
    end
  else
    self:Finish()
  end
end

function BattleWaitOtherLoadAction:DelayOpenWaiting()
  if not self.finished and BattleUtils.IsBattleServeWaitingLoad() then
    _G.NRCModuleManager:DoCmd(_G.BattleUIModuleCmd.OpenPVPWaitingLoad)
  end
end

function BattleWaitOtherLoadAction:OnFinish()
  if self.DelayId then
    _G.DelayManager:CancelDelayById(self.DelayId)
    self.DelayId = nil
  end
  _G.NRCModuleManager:DoCmd(_G.BattleUIModuleCmd.ClosePVPWaitingLoad)
end

return BattleWaitOtherLoadAction
