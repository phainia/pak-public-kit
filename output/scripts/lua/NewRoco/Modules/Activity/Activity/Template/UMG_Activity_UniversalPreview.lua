local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_Base_C")
local UMG_Activity_UniversalPreview = Base:Extend("UMG_Activity_UniversalPreview")

function UMG_Activity_UniversalPreview:OnConstruct()
  Base.OnConstruct(self)
  if self.PromptText then
    self.PromptText:SetText(self.activityInst:GetActivityPromptText())
  end
end

function UMG_Activity_UniversalPreview:OnDestruct()
  Base.OnDestruct(self)
end

function UMG_Activity_UniversalPreview:BindUIElements()
  local uiElements = {}
  uiElements.particularsBtn = self.ParticularsBtn and self.ParticularsBtn.btnLevelUp
  uiElements.timeRemaining = self.TimeRemaining
  uiElements.openAnimName = "In"
  uiElements.changeAnimName = "In"
  uiElements.closeAnimName = "Out"
  return uiElements
end

return UMG_Activity_UniversalPreview
