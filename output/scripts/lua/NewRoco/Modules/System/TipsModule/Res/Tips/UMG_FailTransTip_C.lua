local ProtoEnum = require("Data.PB.ProtoEnum")
local Enum = require("Data.Config.Enum")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local UMG_FailTransTip_C = _G.NRCPanelBase:Extend("UMG_FailTransTip_C")

function UMG_FailTransTip_C:OnConstruct()
  self.WaitForNotify = false
  self.Confirm.OnClicked:Add(self, self.OnButtonClick)
  NRCEventCenter:RegisterEvent("UMG_FailTransTip_C", self, SceneEvent.PlayerTeleportFinish, self.OnPlayerTeleportFinish)
  NRCEventCenter:RegisterEvent("UMG_FailTransTip_C", self, SceneEvent.PlayerTeleportStart, self.OnPlayerTeleportStart)
  NRCEventCenter:RegisterEvent("UMG_FailTransTip_C", self, SceneEvent.OnRelogin, self.OnRelogin)
end

function UMG_FailTransTip_C:OnActive()
  Log.Debug("UMG_FailTransTip_C: OnActive")
  local titleTxt = _G.DataConfigManager:GetLocalizationConf("Loading_Tips_AllTired_Title")
  local playerName = _G.DataModelMgr.PlayerDataModel:GetPlayerName()
  local infoTxt = _G.DataConfigManager:GetLocalizationConf("Loading_Tips_AllTired_Text")
  local confirmTxt = _G.DataConfigManager:GetLocalizationConf("Loading_Tips_AllTired_Bottom")
  if self.module:GetTeleportNotify() and self.module.CachedTeleportNotify.teleport_reason == ProtoEnum.TeleportReason.ENUM.RUN_AWAY then
    titleTxt = _G.DataConfigManager:GetLocalizationConf("Loading_Tips_Escape_Title")
  end
  self.Title:SetText(titleTxt.msg)
  self.info:SetText(string.format(infoTxt.msg, playerName))
  self.info:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.Title:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Confirm_Txt:SetText(confirmTxt.msg)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1059, "UMG_FailTransTip_C:OnConstruct")
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local playerCtrl = player:GetUEController()
  if nil == playerCtrl then
    playerCtrl = UE4.UGameplayStatics.GetPlayerControllerFromID(_G.UE4Helper.GetCurrentWorld(), 0)
  end
  playerCtrl:SetViewTargetWithBlend(self.viewObj, 0, UE4.EViewTargetBlendFunction.VTBlend_EaseOut, 2)
  if self.module:GetTeleportNotify() then
    Log.Debug("UMG_FailTransTip_C: Active with valid teleport notify then show confirm button")
    self:ShowTeleportButton()
  else
    Log.Debug("UMG_FailTransTip_C: Active with no teleport notify ")
    self.Confirm:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.WaitForNotify = true
  end
end

function UMG_FailTransTip_C:ShowTeleportButton()
  Log.Debug("UMG_FailTransTip_C: Show Teleport Button")
  self.Confirm:SetVisibility(UE4.ESlateVisibility.Visible)
  self.WaitForNotify = false
end

function UMG_FailTransTip_C:OnTick(DeltaTime)
  if not self.WaitForNotify then
    return
  end
  if self.module:GetTeleportNotify() then
    Log.Debug("UMG_FailTransTip_C: On tick wait for teleport and receive!")
    self:ShowTeleportButton()
  end
end

function UMG_FailTransTip_C:OnButtonClick()
  Log.Debug("UMG_FailTransTip_C:OnButtonClick and send teleport confirm req start")
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1002, "UMG_FailTransTip_C:OnButtonClick")
  local req = _G.ProtoMessage:newZoneConfirmReviveReq()
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_CONFIRM_REVIVE_REQ, req, self, self.OnConfirmTeleport, true, true)
  Log.Debug("UMG_FailTransTip_C:OnButtonClick and send teleport confirm req finish")
end

function UMG_FailTransTip_C:OnConfirmTeleport(rsp)
  Log.Debug("UMG_FailTransTip_C: teleport confirm req receive rsp. Teleported!!")
end

function UMG_FailTransTip_C:OnPlayerTeleportStart()
  Log.Debug("UMG_FailTransTip_C:OnPlayerTeleportStart")
  self.module:RevokeTeleportNotify()
  _G.NRCEventCenter:DispatchEvent(BattleEvent.LoadingBattleFailedUIComplete)
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  player:OnReborn()
  player.statusComponent:RemoveStatus(ProtoEnum.WorldPlayerStatusType.WPST_DEATH)
  player:SendEvent(PlayerModuleEvent.ON_PLAYER_REBORN)
  _G.NRCEventCenter:DispatchEvent(SceneEvent.OnPlayerReborn)
  Log.Debug("UMG_FailTransTip_C:OnPlayerTeleportStart Event Sent")
  self:DoClose()
end

function UMG_FailTransTip_C:OnRelogin()
  Log.Debug("UMG_FailTransTip_C:OnRelogin")
  self.module:RevokeTeleportNotify()
  _G.NRCEventCenter:DispatchEvent(BattleEvent.LoadingBattleFailedUIComplete)
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  player:OnReborn()
  player.statusComponent:RemoveStatus(ProtoEnum.WorldPlayerStatusType.WPST_DEATH)
  player:SendEvent(PlayerModuleEvent.ON_PLAYER_REBORN)
  _G.NRCEventCenter:DispatchEvent(SceneEvent.OnPlayerReborn)
  Log.Debug("UMG_FailTransTip_C:OnRelogin Event sent")
  self:DoClose()
end

function UMG_FailTransTip_C:OnPlayerTeleportFinish()
end

function UMG_FailTransTip_C:OnDeactive()
  self.WaitForNotify = false
end

function UMG_FailTransTip_C:OnDestruct()
  self.WaitForNotify = false
  NRCEventCenter:UnRegisterEvent(self, SceneEvent.PlayerTeleportFinish, self.OnPlayerTeleportFinish)
  NRCEventCenter:UnRegisterEvent(self, SceneEvent.PlayerTeleportStart, self.OnPlayerTeleportStart)
  NRCEventCenter:UnRegisterEvent(self, SceneEvent.OnRelogin, self.OnRelogin)
end

return UMG_FailTransTip_C
