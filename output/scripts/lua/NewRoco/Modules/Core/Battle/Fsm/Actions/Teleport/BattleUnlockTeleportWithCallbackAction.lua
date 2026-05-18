local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local TeleportLockEnum = require("NewRoco.Modules.Core.Scene.Component.RoleHP.TeleportLockEnum")
local BattleHandleTeleportBaseAction = require("NewRoco.Modules.Core.Battle.Fsm.Actions.Base.BattleHandleTeleportBaseAction")
local Base = BattleHandleTeleportBaseAction
local BattleUnlockTeleportWithCallbackAction = Base:Extend("BattleUnlockTeleportWithCallbackAction")
FsmUtils.MergeMembers(Base, BattleUnlockTeleportWithCallbackAction, {})

function BattleUnlockTeleportWithCallbackAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleUnlockTeleportWithCallbackAction:OnEnter()
  self:BindCallBack()
  self:Unlock()
  self:CheckTeleportStart()
end

function BattleUnlockTeleportWithCallbackAction:BindCallBack()
  _G.NRCModuleManager:DoCmd(PlayerModuleCmd.BindTeleportCallback, TeleportLockEnum.CallbackStamp.ON_TELEPORT_UI_SHOWN, self, self.Finish)
end

function BattleUnlockTeleportWithCallbackAction:CheckTeleportStart()
  local TM = NRCModuleManager:GetModule("TipsModule")
  if TM and (TM:HasPanel("ConfirmTeleportTips") or TM:IsPanelInOpening("ConfirmTeleportTips")) then
    return
  end
  self:Finish()
end

function BattleUnlockTeleportWithCallbackAction:OnFinish()
end

function BattleUnlockTeleportWithCallbackAction:OnExit()
end

return BattleUnlockTeleportWithCallbackAction
