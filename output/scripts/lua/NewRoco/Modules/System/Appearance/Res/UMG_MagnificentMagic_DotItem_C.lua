local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local AppearanceModuleEvent = require("NewRoco.Modules.System.Appearance.AppearanceModuleEvent")
local UMG_MagnificentMagic_DotItem_C = Base:Extend("UMG_MagnificentMagic_DotItem_C")

function UMG_MagnificentMagic_DotItem_C:OnConstruct()
end

function UMG_MagnificentMagic_DotItem_C:OnDestruct()
end

function UMG_MagnificentMagic_DotItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  self.Bright:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_MagnificentMagic_DotItem_C:SelectInfo(_bSelected)
  if _bSelected then
    self.Bright:SetVisibility(UE4.ESlateVisibility.Visible)
    self:PlayAnimation(self.Select)
  else
    self:PlayAnimation(self.Select_not)
  end
end

function UMG_MagnificentMagic_DotItem_C:OnItemSelected(_bSelected)
  self:SelectInfo(_bSelected)
  if _bSelected then
    _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.OnMagnificentMagicDotItemSelected, self.index)
  end
end

function UMG_MagnificentMagic_DotItem_C:OnDeactive()
end

function UMG_MagnificentMagic_DotItem_C:OnAnimationFinished(Anim)
  if Anim == self.Select_not then
    self.Bright:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

return UMG_MagnificentMagic_DotItem_C
