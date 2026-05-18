local BattleTurnPlayer = require("NewRoco.Modules.Core.Battle.Players.BattleTurnPlayer")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local Base = BattleActionBase
local BattleTurnPlayerAction = Base:Extend("BattleTurnPlayerAction")
FsmUtils.MergeMembers(Base, BattleTurnPlayerAction, {
  {name = "Flows", type = "table"},
  {name = "SettleInfo", type = "table"}
})

function BattleTurnPlayerAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.TurnPlayer = BattleTurnPlayer()
  self:SetActionType(BattleActionBase.ActionType.ClientTurnPlayAction)
end

function BattleTurnPlayerAction:OnEnter()
  self.timeout = BattleActionBase.PerformTimeoutValue
  _G.BattleManager.EscapeContext:Close()
  if self.TurnPlayer then
    self.TurnPlayer:OnActionAquireFromPool()
  end
  _G.BattleManager:SetTurnPlayer(self.TurnPlayer)
  local Flows = self:GetProperty("Flows")
  BattleConst.UpdateFootDelta = 0.3
  self:DoPerform()
end

function BattleTurnPlayerAction:DoPerform()
  local Flows = self:GetProperty("Flows")
  local SettleInfo = self:GetProperty("SettleInfo")
  local IsMySelfPerform = self:GetProperty("IsMySelfPerform")
  if nil == IsMySelfPerform then
    IsMySelfPerform = true
  end
  if Flows and Flows.perform_info then
    self.TurnPlayer:RunFlows(Flows, SettleInfo, self, self.Finish, IsMySelfPerform)
  else
    BattleEventCenter:Dispatch(BattlePerformEvent.TurnPlayComplete)
    self:Finish()
  end
end

function BattleTurnPlayerAction:OnFinish()
  self:DestroyProperty("camActor_0002")
  self:DestroyProperty("camActor_0002_SA")
  if not _G.BattleManager.battleRuntimeData:IsDelayRiOf() and _G.BattleManager.battleRuntimeData:GetCacheRidOfBuffTrigger() then
    if _G.BattleManager.vBattleField.battleCameraManager then
      _G.BattleManager.vBattleField.battleCameraManager:CalcPos()
    end
    BattleSkillManager:ClearCache()
    BattleManager.battlePawnManager:ClearRequestDict()
  end
  if self.TurnPlayer then
    self.TurnPlayer:OnActionReleaseToPool()
  end
  _G.BattleManager:SetTurnPlayer(nil)
end

function BattleTurnPlayerAction:DoFinalize()
  Base.DoFinalize(self)
  if self.TurnPlayer then
    self.TurnPlayer:DoFinalize()
  end
end

function BattleTurnPlayerAction:OnExit()
end

function BattleTurnPlayerAction:DestroyProperty(name)
  local Actor = self.fsm:GetProperty(name, nil)
  if Actor and Actor:IsValid() then
    Actor:K2_DestroyActor()
    Actor = nil
  end
  self.fsm:SetProperty(name, nil)
end

return BattleTurnPlayerAction
