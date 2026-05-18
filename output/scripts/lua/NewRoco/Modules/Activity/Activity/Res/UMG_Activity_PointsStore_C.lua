local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_Base_C")
local UMG_Activity_PointsStore_C = Base:Extend("UMG_Activity_PointsStore_C")

function UMG_Activity_PointsStore_C:BindUIElements()
  local uiElements = {}
  uiElements.desireActivityType = Enum.ActivityType.ATP_SHOP
  uiElements.title = self.Text_Title
  uiElements.promptText = self.Text_Describe
  uiElements.bgImage = self.MythicalCreaturesBG
  uiElements.timeRemainingRoot = self.CanvasPanel_356
  uiElements.timeRemaining = self.Text_TimeRemaining
  uiElements.particularsBtn = self.ParticularsBtn
  uiElements.openAnimName = "In"
  uiElements.changeAnimName = "In"
  uiElements.closeAnimName = "Out"
  return uiElements
end

function UMG_Activity_PointsStore_C:OnConstruct()
  Base.OnConstruct(self)
  local _activityInst = self.activityInst
  self.Btn_ViewTheStore:SetBtnText(_activityInst:GetButtonText())
  self.NRCImage_Icon:SetPath(_activityInst:GetShopGoodIcon())
  self.NRCText1:SetText(_activityInst:GetShopGoodText())
  self.AwardList:InitList(_activityInst:GetSortGoodsData())
  self:AddButtonListener(self.Btn_ViewTheStore.btnLevelUp, self.OpenMapTrace)
end

function UMG_Activity_PointsStore_C:OpenMapTrace()
  self.activityInst:GotoShop()
end

function UMG_Activity_PointsStore_C:OnDestruct()
  self:RemoveButtonListener(self.Btn_ViewTheStore.btnLevelUp)
end

return UMG_Activity_PointsStore_C
