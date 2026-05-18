local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Bag_PetHeadPicture_Select_C = Base:Extend("UMG_Bag_PetHeadPicture_Select_C")

function UMG_Bag_PetHeadPicture_Select_C:OnConstruct()
end

function UMG_Bag_PetHeadPicture_Select_C:OnDestruct()
end

function UMG_Bag_PetHeadPicture_Select_C:OnItemUpdate(_data, datalist, index)
end

function UMG_Bag_PetHeadPicture_Select_C:OnItemSelected(_bSelected)
end

function UMG_Bag_PetHeadPicture_Select_C:OnDeactive()
end

function UMG_Bag_PetHeadPicture_Select_C:OnAnimationFinished(anim)
  if anim == self.Loop then
    self:PlayAnimation(self.Loop)
  end
end

return UMG_Bag_PetHeadPicture_Select_C
