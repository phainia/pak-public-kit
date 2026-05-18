local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_Base_C")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local UMG_PetCollectionEvent_C = Base:Extend("UMG_PetCollectionEvent_C")

function UMG_PetCollectionEvent_C:OnConstruct()
  Base.OnConstruct(self)
  self.PromptText:SetText(ActivityUtils.GetActivityGlobalConfig("Introduce_SocialMedia_PetCollectionEvent").str)
  self.ViewHandbookBtn:SetBtnText(ActivityUtils.GetActivityGlobalConfig("LeftButton_SocialMedia_PetCollectionEvent").str)
  self.ViewLeaderboardBtn:SetBtnText(ActivityUtils.GetActivityGlobalConfig("RightButton_SocialMedia_PetCollectionEvent").str)
  self:AddButtonListener(self.ViewHandbookBtn.btnLevelUp, self.OnClickViewHandbookBtn)
  self:AddButtonListener(self.ViewLeaderboardBtn.btnLevelUp, self.OnClickViewLeaderboardBtn)
end

function UMG_PetCollectionEvent_C:OnDestruct()
  Base.OnDestruct(self)
end

function UMG_PetCollectionEvent_C:BindUIElements()
  local uiElements = {}
  uiElements.particularsBtn = self.ParticularsBtn
  uiElements.timeRemaining = self.TimeRemaining
  uiElements.openAnimName = "In"
  uiElements.changeAnimName = "In"
  uiElements.closeAnimName = "Out"
  return uiElements
end

function UMG_PetCollectionEvent_C:OnClickViewHandbookBtn()
  _G.NRCModuleManager:DoCmd(HandbookModuleCmd.OpenHandbookCover, {openCollectRewards = true})
end

function UMG_PetCollectionEvent_C:OnClickViewLeaderboardBtn()
  local url = ActivityUtils.GetActivityGlobalConfig("Adress_SocialMedia_PetCollectionEvent").str
  ActivityUtils.OpenUrl(url)
end

return UMG_PetCollectionEvent_C
