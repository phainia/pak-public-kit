local UMG_Friend_Privilege_C = _G.NRCViewBase:Extend("UMG_Friend_Privilege_C")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")

function UMG_Friend_Privilege_C:OnConstruct()
end

function UMG_Friend_Privilege_C:SetData(CliLoginChannel, StartUpPrivilegeInfo)
  self.StartUpPrivilegeInfo = StartUpPrivilegeInfo
  Log.Debug("UMG_Friend_Privilege_C", CliLoginChannel)
  if self.StartUpPrivilegeInfo then
    local svrTimeStamp = ActivityUtils.GetSvrTimestamp()
    Log.Debug("UMG_Friend_Privilege_C", StartUpPrivilegeInfo.cli_startup_channel, StartUpPrivilegeInfo.cli_startup_day, svrTimeStamp)
  end
  local IsPrivilegeIndex = self:GetPrivilegeInfoIsStart()
  if CliLoginChannel == Enum.CliLoginChannel.CLC_WX then
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif CliLoginChannel == Enum.CliLoginChannel.CLC_QQ then
    if 1 == IsPrivilegeIndex then
      self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Switcher1:SetActiveWidgetIndex(0)
      self.WidgetSwitcher_0:SetActiveWidgetIndex(0)
    end
  end
end

function UMG_Friend_Privilege_C:GetPrivilegeInfoIsStart()
  local svrTimeStamp = ActivityUtils.GetSvrTimestamp()
  local PrivilegeChannel = self.StartUpPrivilegeInfo.cli_startup_channel
  if (PrivilegeChannel == Enum.CliStartUpChannel.CSUC_WX_GAME_CENTER or PrivilegeChannel == Enum.CliStartUpChannel.CSUC_QQ_GAME_CENTER) and self.StartUpPrivilegeInfo.cli_startup_day and svrTimeStamp >= self.StartUpPrivilegeInfo.cli_startup_day and svrTimeStamp - self.StartUpPrivilegeInfo.cli_startup_day <= 86400 then
    return 0
  end
  return 1
end

function UMG_Friend_Privilege_C:OnClickedQQ()
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_Friend_Privilege_C:OnClickedQQ")
  _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.LobbyMainInnerBottonMoreOpenPanel, "PrivilegeIntroductionPopUp", Enum.CliLoginChannel.CLC_QQ)
end

function UMG_Friend_Privilege_C:OnClickedWX()
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_Friend_Privilege_C:OnClickedWX")
  _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.LobbyMainInnerBottonMoreOpenPanel, "PrivilegeIntroductionPopUp", Enum.CliLoginChannel.CLC_WX)
end

function UMG_Friend_Privilege_C:OnDestruct()
end

function UMG_Friend_Privilege_C:OnDeactive()
end

return UMG_Friend_Privilege_C
