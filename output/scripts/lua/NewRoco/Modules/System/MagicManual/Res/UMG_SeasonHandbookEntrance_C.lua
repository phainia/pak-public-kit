local MagicManualModuleEvent = require("NewRoco.Modules.System.MagicManual.MagicManualModuleEvent")
local UMG_SeasonHandbookEntrance_C = _G.NRCPanelBase:Extend("UMG_SeasonHandbookEntrance_C")

function UMG_SeasonHandbookEntrance_C:OnActive()
  self:OnAddEventListener()
end

function UMG_SeasonHandbookEntrance_C:OnDeactive()
end

function UMG_SeasonHandbookEntrance_C:OnAddEventListener()
  self:AddButtonListener(self.GetMorePetBtn, self.OnBtnPress)
end

function UMG_SeasonHandbookEntrance_C:OnBtnPress()
  self:PlayAnimation(self.Press)
end

function UMG_SeasonHandbookEntrance_C:OnConstruct()
end

function UMG_SeasonHandbookEntrance_C:OnDestruct()
end

function UMG_SeasonHandbookEntrance_C:OnAnimationFinished(anim)
  if anim == self.Press then
    _G.NRCEventCenter:DispatchEvent(MagicManualModuleEvent.OnRecallButtonAnimFinished)
  end
end

return UMG_SeasonHandbookEntrance_C
