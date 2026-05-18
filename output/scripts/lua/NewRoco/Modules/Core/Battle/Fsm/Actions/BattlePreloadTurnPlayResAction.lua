local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local Base = BattleActionBase
local BattlePreloadTurnPlayResAction = Base:Extend("BattlePreloadTurnPlayResAction")
FsmUtils.MergeMembers(Base, BattlePreloadTurnPlayResAction, {
  {name = "Flows", type = "table"},
  {name = "SettleInfo", type = "table"}
})

function BattlePreloadTurnPlayResAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self:SetActionType(BattleActionBase.ActionType.ClientLoadResAction)
end

function BattlePreloadTurnPlayResAction:OnEnter()
  BattleEventCenter:Bind(self, BattleEvent.OnAllSkillResLoaded)
  local Flows = self:GetProperty("Flows")
  local SettleInfo = self:GetProperty("SettleInfo")
  if Flows and not Flows.IsFastPlay and not BattleManager.isPureLogicMode then
    self.fsm:Pause()
    BattleSkillManager:PreProcessPerformCMDToReslist(Flows, SettleInfo)
  else
    self:Finish()
  end
end

function BattlePreloadTurnPlayResAction:OnFinish()
  BattleEventCenter:UnBind(self)
  if _G.BattleManager.debugEnv and _G.BattleManager.debugEnv.BattleSettlement then
    _G.BattleManager.stateFsm:Pause()
    if _G.AppMain:HasDebug() then
      local DebugBattlePVPShowResultUI = require("NewRoco.Modules.System.Debug.Res.ClothingScreenRecording.DebugBattlePVPShowResultUI")
      DebugBattlePVPShowResultUI:PlaySkillInfo()
    end
    _G.BattleManager.debugEnv.BattleSettlement = false
    return
  end
end

function BattlePreloadTurnPlayResAction:OnBattleEvent(eventName)
  if eventName == BattleEvent.OnAllSkillResLoaded then
    Log.Debug("BattleEvent.OnAllSkillResLoaded:", eventName)
    self.fsm:Resume()
    self:Finish()
    return true
  end
end

return BattlePreloadTurnPlayResAction
