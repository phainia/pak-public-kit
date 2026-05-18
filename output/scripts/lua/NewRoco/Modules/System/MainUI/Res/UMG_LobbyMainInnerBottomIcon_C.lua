local LoginUtils = require("NewRoco.Modules.System.LoginModule.LoginUtils")
local LoginEnum = require("NewRoco.Modes.LoginMode.LoginEnum")
local FunctionBanModuleEvent = require("NewRoco.Modules.System.FunctionBan.FunctionBanModuleEvent")
local UMG_LobbyMainInnerBottomIcon_C = _G.NRCPanelBase:Extend("UMG_LobbyMainInnerBottomIcon_C")
local CommonUtils = require("NewRoco.Utils.CommonUtils")

function UMG_LobbyMainInnerBottomIcon_C:OnActive()
  self:UpdateQQVisibility()
  self.WeChat:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:OnAddEventListener()
  _G.NRCEventCenter:DispatchEvent(_G.MainUIModuleEvent.OnLobbyMainInnerIconLoaded, self)
  self:UpdateMoreServiceBtn()
  _G.NRCEventCenter:RegisterEvent("UMG_LobbyMainInnerBottomIcon_C", self, FunctionBanModuleEvent.OnUIFuncVisibilityChange, self.OnUIFuncVisibilityChange)
end

function UMG_LobbyMainInnerBottomIcon_C:OnDeactive()
  self:RemoveButtonListener(self.Return.btnLevelUp, self.OnClickedExit)
  self:RemoveButtonListener(self.CustomerService.btnLevelUp, self.OnClickedCustomerService)
  self:RemoveButtonListener(self.QQ.btnLevelUp, self.OnClickedQQGameCenter)
  self:RemoveButtonListener(self.WeChat.btnLevelUp, self.OnClickedCustomerService)
  self:RemoveButtonListener(self.SettingUp.btnLevelUp, self.OnClickedSetting)
  self:RemoveButtonListener(self.MoreService.btnLevelUp, self.OnClickedMoreService)
  self.MoreService.btnLevelUp.OnPressed:Remove(self, self.UpdateMoreListFocus)
  self.MoreService.btnLevelUp.OnReleased:Remove(self, self.OnReleaseMoreListFocus)
  _G.NRCEventCenter:UnRegisterEvent(self, FunctionBanModuleEvent.OnUIFuncVisibilityChange, self.OnUIFuncVisibilityChange)
end

function UMG_LobbyMainInnerBottomIcon_C:OnAddEventListener()
  self:AddButtonListener(self.Return.btnLevelUp, self.OnClickedExit)
  self:AddButtonListener(self.CustomerService.btnLevelUp, self.OnClickedCustomerService)
  self:AddButtonListener(self.QQ.btnLevelUp, self.OnClickedQQGameCenter)
  self:AddButtonListener(self.WeChat.btnLevelUp, self.OnClickedCustomerService)
  self:AddButtonListener(self.SettingUp.btnLevelUp, self.OnClickedSetting)
  self:AddButtonListener(self.MoreService.btnLevelUp, self.OnClickedMoreService)
  self.MoreService.btnLevelUp.OnPressed:Add(self, self.UpdateMoreListFocus)
  self.MoreService.btnLevelUp.OnReleased:Add(self, self.OnReleaseMoreListFocus)
end

function UMG_LobbyMainInnerBottomIcon_C:UpdateQQVisibility()
  self.QQ:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_LobbyMainInnerBottomIcon_C:OnUIFuncVisibilityChange(uiFunctionId, isHide)
  if uiFunctionId == _G.Enum.FunctionEntrance.FE_PRIVILEGE_QQ_GIFT then
    self:UpdateQQVisibility()
  end
end

function UMG_LobbyMainInnerBottomIcon_C:OnClickedExit()
  self:OpenExitConfirmDialog()
end

function UMG_LobbyMainInnerBottomIcon_C:OpenExitConfirmDialog()
  local StepAwayDialog = DialogContext()
  StepAwayDialog:SetCallback(self, self.ReturnToLogin)
  StepAwayDialog:SetContent(RocoEnv.PLATFORM_WINDOWS and LuaText.setting_quit_the_client or LuaText.setting_switch_account)
  StepAwayDialog:SetMode(DialogContext.Mode.OK_CANCEL)
  StepAwayDialog:SetTitle(LuaText.TIPS)
  local okbtnStr = _G.DataConfigManager:GetLocalizationConf("tips_dialog_butten_accept").msg
  local noBtnStr = _G.DataConfigManager:GetLocalizationConf("tips_dialog_butten_cancel").msg
  StepAwayDialog:SetButtonText(okbtnStr, noBtnStr)
  self:OpenDialog(StepAwayDialog)
end

function UMG_LobbyMainInnerBottomIcon_C:OpenDialog(StepAwayDialog)
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, StepAwayDialog)
  _G.NRCAudioManager:PlaySound2DAuto(1291, "UMG_BattleMainWindow_C:OpenStepAwayDialog")
end

function UMG_LobbyMainInnerBottomIcon_C:ReturnToLogin(result)
  self.CurReConnectTimes = 0
  if result then
    if _G.ZoneServer.bPause then
      _G.ZoneServer:Resume()
    end
    if _G.RocoEnv.PLATFORM_ANDROID then
      CommonUtils.SendClientEventToCGSDK("{\"name\":\"game-event-progress\", \"content\":{\"type\":\"logout\"}}")
    end
    _G.AppMain.BackToLogin()
  end
end

function UMG_LobbyMainInnerBottomIcon_C:OnClickedCustomerService()
  _G.NRCAudioManager:PlaySound2DAuto(1011, "UMG_LobbyMainInnerBottomIcon_C:OnClickedCustomerService")
  self.DelayId = _G.DelayManager:DelaySeconds(0.1, function()
    _G.NRCSDKManager:CustomerService(5)
  end)
end

function UMG_LobbyMainInnerBottomIcon_C:OnClickedSetting()
  _G.NRCEventCenter:DispatchEvent(_G.MainUIModuleEvent.OnMainUIFuncPanelOpen, _G.ProtoEnum.LobbyMainInnerUIType.LMIUT_SETTING)
end

function UMG_LobbyMainInnerBottomIcon_C:UpdateMoreServiceBtn()
  local MoreData = _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.GetMoreInnerBottomList)
  if next(MoreData) then
    self.MoreService:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.MoreService:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_LobbyMainInnerBottomIcon_C:UpdateMoreListFocus()
  _G.NRCEventCenter:DispatchEvent(MainUIModuleEvent.ChangeMoreServiceClickState, true)
end

function UMG_LobbyMainInnerBottomIcon_C:OnReleaseMoreListFocus()
  _G.NRCEventCenter:DispatchEvent(MainUIModuleEvent.ChangeMoreServiceClickState, false)
end

function UMG_LobbyMainInnerBottomIcon_C:OnClickedMoreService()
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_LobbyMainInnerBottomIcon_C:OnClickedMoreService")
  local ListIsVisible = _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.GetBottomIconListVisible)
  _G.NRCEventCenter:DispatchEvent(MainUIModuleEvent.OnMainUIVisibileBottomIconList, not ListIsVisible)
end

function UMG_LobbyMainInnerBottomIcon_C:OnClickedQQGameCenter()
  if not _G.RocoEnv.IS_EDITOR then
    if _G.RocoEnv.PLATFORM_WINDOWS then
      return
    end
    if not self:IsQQChannel() then
      return
    end
    _G.NRCAudioManager:PlaySound2DAuto(1011, "UMG_LobbyMainInnerBottomIcon_C:OnClickedQQGameCenter")
    self.DelayId = _G.DelayManager:DelaySeconds(0.1, function()
      _G.NRCSDKManager:OpenQQGameCenterDetail()
    end)
  else
    _G.NRCAudioManager:PlaySound2DAuto(1011, "UMG_LobbyMainInnerBottomIcon_C:OnClickedQQGameCenter")
    self.DelayId = _G.DelayManager:DelaySeconds(0.1, function()
      _G.NRCSDKManager:OpenQQGameCenterDetail()
    end)
  end
end

function UMG_LobbyMainInnerBottomIcon_C:IsQQChannel()
  local LoginModule = _G.NRCModuleManager:GetModule("LoginModule")
  if LoginModule and LoginUtils:GetLoginData() and LoginUtils:GetLoginData():GetChannel() then
    local TempAppChannel = LoginUtils:GetLoginData():GetChannel()
    return TempAppChannel == LoginEnum.ChannelNames.QQ
  else
    local onlineModuleData = _G.NRCModuleManager:DoCmd(_G.OnlineModuleCmd.GetUserAccountInfo)
    if onlineModuleData then
      return onlineModuleData.plat_info.cli_login_channel == Enum.CliLoginChannel.CLC_QQ
    end
  end
  return false
end

return UMG_LobbyMainInnerBottomIcon_C
