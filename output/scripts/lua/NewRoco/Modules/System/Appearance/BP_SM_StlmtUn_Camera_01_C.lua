require("UnLuaEx")
local BP_SM_StlmtUn_Camera_01_C = NRCClass()
local AppearanceModuleEvent = require("NewRoco.Modules.System.Appearance.AppearanceModuleEvent")

function BP_SM_StlmtUn_Camera_01_C:ReceiveBeginPlay()
  self.Overridden.ReceiveBeginPlay(self)
  local bSuccess = false
  if _G.NRCModeManager and _G.AppearanceModuleCmd then
    bSuccess = _G.NRCModeManager:DoCmd(_G.AppearanceModuleCmd.RegisterFashionShowPerformBP, "fashionShowProjector", self)
  end
  if not bSuccess and _G.NRCEventCenter then
    _G.NRCEventCenter:RegisterEvent("BP_SM_StlmtUn_Camera_01_C", self, AppearanceModuleEvent.OnAppearanceModuleActive, self.HandleAppearanceModuleActive)
  end
end

function BP_SM_StlmtUn_Camera_01_C:ReceiveEndPlay(endReason)
  if _G.NRCModeManager and _G.AppearanceModuleCmd then
    _G.NRCModeManager:DoCmd(_G.AppearanceModuleCmd.RegisterFashionShowPerformBP, "fashionShowProjector", nil)
  end
  self.Overridden.ReceiveEndPlay(self, endReason)
end

function BP_SM_StlmtUn_Camera_01_C:HandleAppearanceModuleActive()
  if _G.NRCModeManager and _G.AppearanceModuleCmd then
    _G.NRCModeManager:DoCmd(_G.AppearanceModuleCmd.RegisterFashionShowPerformBP, "fashionShowProjector", self)
  end
end

function BP_SM_StlmtUn_Camera_01_C:StartPerform()
  if self.bPerforming then
    return
  end
  self.bPerforming = true
  self:BPStartPerform()
end

function BP_SM_StlmtUn_Camera_01_C:StopPerform()
  if not self.bPerforming then
    return
  end
  self.bPerforming = false
  self:BPStopPerform()
end

return BP_SM_StlmtUn_Camera_01_C
