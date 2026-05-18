local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local UMG_Pet_HatchingAttribute_C = _G.NRCViewBase:Extend("UMG_Pet_HatchingAttribute_C")

function UMG_Pet_HatchingAttribute_C:OnActive()
end

function UMG_Pet_HatchingAttribute_C:OnDeactive()
end

function UMG_Pet_HatchingAttribute_C:OnConstruct()
  _G.NRCEventCenter:RegisterEvent(self.name, self, PetUIModuleEvent.OnUpdateHatchSecs, self.OnUpdateHatchSecs)
end

function UMG_Pet_HatchingAttribute_C:UpdateEggInfo(eggInfo)
end

function UMG_Pet_HatchingAttribute_C:OnUpdateHatchSecs(secs)
end

function UMG_Pet_HatchingAttribute_C:OnAddEventListener()
end

function UMG_Pet_HatchingAttribute_C:OnDestruct()
  _G.NRCEventCenter:UnRegisterEvent(self, PetUIModuleEvent.OnUpdateHatchSecs, self.OnUpdateHatchSecs)
end

function UMG_Pet_HatchingAttribute_C:OnAnimationFinished(anim)
end

function UMG_Pet_HatchingAttribute_C:OnSwitcherSwitcher(SwitcherIndex)
  self.Switcher:SetActiveWidgetIndex(SwitcherIndex)
end

function UMG_Pet_HatchingAttribute_C:OnSwitcherNRCSwitcher_130(SwitcherIndex)
  self.NRCSwitcher_130:SetActiveWidgetIndex(SwitcherIndex)
end

return UMG_Pet_HatchingAttribute_C
