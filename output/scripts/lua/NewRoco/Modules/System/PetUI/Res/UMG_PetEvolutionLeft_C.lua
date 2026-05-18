local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local enum = reload("Data.Config.Enum")
local UMG_PetEvolutionLeft_C = _G.NRCViewBase:Extend("UMG_PetEvolutionLeft_C")

function UMG_PetEvolutionLeft_C:Initialize(Initializer)
end

function UMG_PetEvolutionLeft_C:OnConstruct()
end

function UMG_PetEvolutionLeft_C:OnDestruct()
end

function UMG_PetEvolutionLeft_C:OnEnable()
end

function UMG_PetEvolutionLeft_C:OnDisable()
end

function UMG_PetEvolutionLeft_C:OnAddEventListener()
end

function UMG_PetEvolutionLeft_C:OnRemoveEventListener()
end

function UMG_PetEvolutionLeft_C:updatePanelInfo()
  self.itemPanel:SetVisibility(UE4.ESlateVisibility.Visible)
  self.taskPanel:SetVisibility(UE4.ESlateVisibility.Hidden)
end

function UMG_PetEvolutionLeft_C:OnAnimationFinished(Animation)
  if Animation == self.Out then
    self:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_PetEvolutionLeft_C:OnPanelStateChange(_isShow)
  self:StopAllAnimations()
  if _isShow then
    self:updatePanelInfo()
    self:PlayAnimation(self.In, 0, 1, 0, 1.5)
  else
    self:PlayAnimation(self.Out)
  end
end

return UMG_PetEvolutionLeft_C
