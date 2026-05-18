local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_Base_C")
local UMG_Activity_404NotFound_C = Base:Extend("UMG_Activity_404NotFound_C")

function UMG_Activity_404NotFound_C:BindUIElements()
  local uiElements = {}
  uiElements.openAnimName = "In"
  uiElements.changeAnimName = "In"
  uiElements.closeAnimName = "Out"
  return uiElements
end

function UMG_Activity_404NotFound_C:OnConstruct()
  Base.OnConstruct(self)
  self:AddButtonListener(self.CloseBtn, self.OnClickBtn)
end

function UMG_Activity_404NotFound_C:OnDestruct()
  Base.OnDestruct(self)
end

function UMG_Activity_404NotFound_C:OnClickBtn()
  _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.LuaText.unupdated_activity_tip)
end

return UMG_Activity_404NotFound_C
