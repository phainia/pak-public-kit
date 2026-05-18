local UMG_TwoScreenDialogue_C = _G.NRCPanelBase:Extend("UMG_TwoScreenDialogue_C")

function UMG_TwoScreenDialogue_C:OnActive(CallBack)
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  CallBack(self)
end

function UMG_TwoScreenDialogue_C:OnDeactive()
end

function UMG_TwoScreenDialogue_C:OnAddEventListener()
end

function UMG_TwoScreenDialogue_C:OnTick()
end

function UMG_TwoScreenDialogue_C:OnLogin()
end

function UMG_TwoScreenDialogue_C:OnConstruct()
end

function UMG_TwoScreenDialogue_C:OnDestruct()
end

function UMG_TwoScreenDialogue_C:OnAnimationFinished(anim)
end

return UMG_TwoScreenDialogue_C
