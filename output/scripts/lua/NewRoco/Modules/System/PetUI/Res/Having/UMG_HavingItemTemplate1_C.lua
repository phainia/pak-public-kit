local UMG_HavingItemTemplate1_C = _G.NRCViewBase:Extend("UMG_HavingItemTemplate1_C")

function UMG_HavingItemTemplate1_C:OnConstruct()
  self:OnAddEventListener()
end

function UMG_HavingItemTemplate1_C:OnDestruct()
end

function UMG_HavingItemTemplate1_C:OnActive()
end

function UMG_HavingItemTemplate1_C:OnDeactive()
end

function UMG_HavingItemTemplate1_C:OnAddEventListener()
  self:AddButtonListener(self.NRCButton_72, self.OnClickNRCButton_72)
end

function UMG_HavingItemTemplate1_C:OnClickNRCButton_72()
end

return UMG_HavingItemTemplate1_C
