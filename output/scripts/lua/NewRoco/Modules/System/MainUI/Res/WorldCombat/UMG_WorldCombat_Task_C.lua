local WorldCombatModuleEvent = require("NewRoco.Modules.System.WorldCombat.WorldCombatModuleEvent")
local UMG_WorldCombat_Task_C = _G.NRCPanelBase:Extend("UMG_WorldCombat_Task_C")

function UMG_WorldCombat_Task_C:OnConstruct()
  self:AddButtonListener(self.Button, self.OnButtonClick)
  self.PCKey:SetKeyVisibility(true)
  self.PCKey:SetText("X")
end

function UMG_WorldCombat_Task_C:OnButtonClick()
  _G.NRCEventCenter:DispatchEvent(WorldCombatModuleEvent.OnExitButtonClicked)
end

return UMG_WorldCombat_Task_C
