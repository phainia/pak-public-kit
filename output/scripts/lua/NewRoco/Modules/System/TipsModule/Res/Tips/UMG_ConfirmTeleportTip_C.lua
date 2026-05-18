local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local TipEnum = require("NewRoco.Modules.System.TipsModule.Utils.TipEnum")
local UMG_ConfirmTeleportTip_C = _G.NRCPanelBase:Extend("UMG_ConfirmTeleportTip_C")

function UMG_ConfirmTeleportTip_C:OnConstruct()
  self.Confirm.OnClicked:Add(self, self.OnButtonClick)
  NRCEventCenter:RegisterEvent("UMG_FailTransTip_C", self, SceneEvent.PlayerTeleportFinish, self.OnPlayerTeleportFinish)
  NRCEventCenter:RegisterEvent("UMG_FailTransTip_C", self, SceneEvent.PlayerTeleportStart, self.OnPlayerTeleportStart)
  NRCEventCenter:RegisterEvent("UMG_FailTransTip_C", self, SceneEvent.OnRelogin, self.OnRelogin)
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.PauseTip, TipEnum.TipsPauseReason.ConfirmTeleportTip)
end

function UMG_ConfirmTeleportTip_C:OnActive(CompOwner)
  Log.Debug("UMG_ConfirmTeleportTip_C: OnActive")
  self._hasConfirm = false
  local titleTxt = _G.DataConfigManager:GetLocalizationConf("Loading_Tips_AllTired_Title")
  local playerName = _G.DataModelMgr.PlayerDataModel:GetPlayerName()
  local infoTxt = _G.DataConfigManager:GetLocalizationConf("Loading_Tips_AllTired_Text")
  local bIsMale = _G.DataModelMgr.PlayerDataModel:IsMale()
  self.Title:SetText(titleTxt.msg)
  self.info:SetText(string.format(infoTxt.msg, playerName))
  self.Confirm_Txt:SetText(LuaText.Loading_Tips_AllTired_Click_Text)
  self.info:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.Title:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:AddPcInputBlock()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1059, "UMG_ConfirmTeleportTip_C:OnConstruct")
  Log.Debug("UMG_ConfirmTeleportTip_C: Active with no teleport notify ")
  self.Confirm:SetVisibility(UE4.ESlateVisibility.Visible)
  self.Confirm_Txt:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  if bIsMale then
    self.male:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.female:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.male:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.female:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if CompOwner then
    CompOwner:BindUMG(self)
    self.CompOwner = CompOwner
  end
  UE4Helper.SetDesiredShowCursor(true, "UMG_ConfirmTeleportTip_C")
  _G.NRCAudioManager:SetStateByName("Alive_Death", "Death", "StopAllBGM")
end

function UMG_ConfirmTeleportTip_C:SetNotify(notify)
  if notify then
    local titleTxt
    if notify.teleport_reason == ProtoEnum.TeleportReason.ENUM.DUNGEON_RUN_AWAY then
      titleTxt = _G.DataConfigManager:GetLocalizationConf("Loading_Tips_Escape_Title").msg
    elseif notify.teleport_reason == ProtoEnum.TeleportReason.ENUM.BATTLE_SURRENDER then
      titleTxt = LuaText.umg_confirmteleporttip_1
    end
    if titleTxt then
      self.Title:SetText(titleTxt)
    end
  end
end

function UMG_ConfirmTeleportTip_C:OnAnimationFinished(Animation)
  if Animation == self.TweenIn and self.CompOwner then
    self:PlayAnimation(self.Loading_In)
    self.CompOwner:OnBlackEnd()
  end
end

function UMG_ConfirmTeleportTip_C:OnButtonClick()
  Log.Debug("UMG_ConfirmTeleportTip_C:OnButtonClick")
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1002, "UMG_FailTransTip_C:OnButtonClick")
  if self.CompOwner and not BattleManager:IsInBattle() then
    self.CompOwner:OnConfirmTeleport()
  end
end

function UMG_ConfirmTeleportTip_C:OnPlayerTeleportStart()
  Log.Debug("UMG_ConfirmTeleportTip_C:OnPlayerTeleportStart")
  self:FinishConfirm()
end

function UMG_ConfirmTeleportTip_C:OnRelogin()
  Log.Debug("UMG_ConfirmTeleportTip_C:OnRelogin")
  self:FinishConfirm()
end

function UMG_ConfirmTeleportTip_C:FinishConfirm()
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not self._hasConfirm then
    return
  end
  player:OnReborn()
  player.statusComponent:RemoveStatus(ProtoEnum.WorldPlayerStatusType.WPST_DEATH)
  player:SendEvent(PlayerModuleEvent.ON_PLAYER_REBORN)
  _G.NRCEventCenter:DispatchEvent(SceneEvent.OnPlayerReborn)
  Log.Debug("UMG_ConfirmTeleportTip_C:OnPlayerTeleportStart Event Sent")
  if self.CompOwner then
    self.CompOwner:UnBindUMG()
    self.CompOwner = nil
  end
  self:DoClose()
end

function UMG_ConfirmTeleportTip_C:OnPlayerTeleportFinish()
  Log.Debug("UMG_ConfirmTeleportTip_C:OnPlayerTeleportFinish")
  self:FinishConfirm()
end

function UMG_ConfirmTeleportTip_C:OnDeactive()
  self:RemovePcInputBlock()
  UE4Helper.ReleaseDesiredShowCursor("UMG_ConfirmTeleportTip_C")
end

function UMG_ConfirmTeleportTip_C:OnDestruct()
  NRCEventCenter:UnRegisterEvent(self, SceneEvent.PlayerTeleportFinish, self.OnPlayerTeleportFinish)
  NRCEventCenter:UnRegisterEvent(self, SceneEvent.PlayerTeleportStart, self.OnPlayerTeleportStart)
  NRCEventCenter:UnRegisterEvent(self, SceneEvent.OnRelogin, self.OnRelogin)
  _G.NRCPanelManager:CloseAllPanelByLayer(_G.Enum.UILayerType.UI_LAYER_FULLSCREEN)
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.ResumeTip, TipEnum.TipsPauseReason.ConfirmTeleportTip)
  _G.NRCAudioManager:SetStateByName("Alive_Death", "Alive", "ActiveBGM")
end

function UMG_ConfirmTeleportTip_C:AddPcInputBlock()
  _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.AddBlockIMC, self, self.depth)
end

function UMG_ConfirmTeleportTip_C:RemovePcInputBlock()
  _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.RemoveBlockIMC, self)
end

return UMG_ConfirmTeleportTip_C
