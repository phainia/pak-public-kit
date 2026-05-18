local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_Base_C")
local UMG_Activity_SurroundingRaffle_C = Base:Extend("UMG_Activity_SurroundingRaffle_C")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")

function UMG_Activity_SurroundingRaffle_C:BindUIElements()
  local uiElements = {}
  uiElements.openAnimName = "In"
  uiElements.changeAnimName = "In"
  uiElements.loopAnimName = "Loop"
  uiElements.particularsBtn = self.ParticularsBtn
  uiElements.title = self.Text_Title
  uiElements.promptText = self.Text_Describe
  return uiElements
end

function UMG_Activity_SurroundingRaffle_C:OnConstruct()
  Base.OnConstruct(self)
  self:AddButtonListener(self.Btn_Claimable.btnLevelUp, self.OnClickJoinActivity)
  local _activityInst = self.activityInst
  local _itemObject = _activityInst:CreateWebSiteItem(_activityInst:GetSinglePartId())
  if _itemObject then
    self.Btn_Claimable:SetBtnText(_itemObject:GetInteractiveText())
  end
end

function UMG_Activity_SurroundingRaffle_C:OnClickJoinActivity()
  _G.NRCAudioManager:PlaySound2DAuto(40008005, "UMG_Activity_SurroundingRaffle_C:OnClickJoinActivity")
  self:DelaySeconds(0.1, function()
    local _activityInst = self.activityInst
    if _activityInst then
      local _itemObject = _activityInst:GetWebSiteItem(_activityInst:GetSinglePartId())
      return _activityInst:PerformActivityInteraction(ActivityEnum.ActivityInteractionType.Join, _itemObject)
    end
  end)
end

return UMG_Activity_SurroundingRaffle_C
