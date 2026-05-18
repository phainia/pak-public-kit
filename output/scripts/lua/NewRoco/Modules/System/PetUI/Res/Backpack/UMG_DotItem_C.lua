local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_DotItem_C = Base:Extend("UMG_DotItem_C")

function UMG_DotItem_C:OnConstruct()
end

function UMG_DotItem_C:OnDestruct()
end

function UMG_DotItem_C:OnItemUpdate(_data, datalist, index)
  if _data and _data.pet_infos and #_data.pet_infos > 0 then
    self.Normal:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Empty:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.Normal:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Empty:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end

function UMG_DotItem_C:OnItemSelected(_bSelected)
  if _bSelected then
    self:StopAllAnimations()
    self:PlayAnimation(self.Select)
  else
    self:StopAllAnimations()
    self:PlayAnimation(self.Select_not)
  end
end

function UMG_DotItem_C:OnDeactive()
end

return UMG_DotItem_C
