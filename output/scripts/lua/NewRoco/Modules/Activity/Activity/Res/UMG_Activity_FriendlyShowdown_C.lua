local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_Base_C")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local UMG_Activity_FriendlyShowdown_C = Base:Extend("UMG_Activity_FriendlyShowdown_C")

function UMG_Activity_FriendlyShowdown_C:OnConstruct()
  Base.OnConstruct(self)
  self.PromptText:SetText(ActivityUtils.GetActivityGlobalConfig("Introduce_SocialMedia_RankedMatch").str)
  self.BattleBtn:SetBtnText(ActivityUtils.GetActivityGlobalConfig("LeftButton_SocialMedia_RankedMatch").str)
  self.CommunityBtn:SetBtnText(ActivityUtils.GetActivityGlobalConfig("RightButton_SocialMedia_RankedMatch").str)
  self:AddButtonListener(self.BattleBtn.btnLevelUp, self.OnClickBattleBtn)
  self:AddButtonListener(self.CommunityBtn.btnLevelUp, self.OnClickCommunityBtn)
end

function UMG_Activity_FriendlyShowdown_C:OnDestruct()
  Base.OnDestruct(self)
end

function UMG_Activity_FriendlyShowdown_C:BindUIElements()
  local uiElements = {}
  uiElements.particularsBtn = self.ParticularsBtn
  uiElements.timeRemaining = self.TimeRemaining
  uiElements.openAnimName = "In"
  uiElements.changeAnimName = "In"
  uiElements.closeAnimName = "Out"
  return uiElements
end

function UMG_Activity_FriendlyShowdown_C:OnClickBattleBtn()
  local npcInfo = _G.NRCModuleManager:DoCmd(_G.BigMapModuleCmd.GetNpcInfoByConfigId, 63035)
  local refreshId = npcInfo and npcInfo.npc_refresh_id
  if refreshId then
    _G.NRCModuleManager:DoCmd(_G.BigMapModuleCmd.OpenWorldMap, {centerNPCRefreshId = refreshId, scaleSliderValue = 0.7})
  else
    self:LogError("\230\137\190\228\184\141\229\136\176npc\231\154\132refreshId")
  end
end

function UMG_Activity_FriendlyShowdown_C:OnClickCommunityBtn()
  local url = ActivityUtils.GetActivityGlobalConfig("Adress_SocialMedia_RankedMatch").str
  ActivityUtils.OpenUrl(url)
end

return UMG_Activity_FriendlyShowdown_C
