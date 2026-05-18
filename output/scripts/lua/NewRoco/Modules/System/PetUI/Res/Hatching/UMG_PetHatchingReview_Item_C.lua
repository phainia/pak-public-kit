local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_ItemBase_C")
local UMG_PetHatchingReview_Item_C = Base:Extend("UMG_PetHatchingReview_Item_C")

function UMG_PetHatchingReview_Item_C:OnConstruct()
  Base.OnConstruct(self)
end

function UMG_PetHatchingReview_Item_C:OnDestruct()
  Base.OnDestruct(self)
end

function UMG_PetHatchingReview_Item_C:OnEnter()
  self:PlayInAnimation()
end

function UMG_PetHatchingReview_Item_C:OnItemUpdate(_data, datalist, index)
  self.ColorfulHeadIcon:SetIconPathAndMaterial(_data.base_conf_id, _data.mutation_type, _data.glass_info)
  self:SetQuality(_data.BgCol)
  self.Egg:SetPath(_data.EggIconPath)
  self.Day:SetText(_data.Week)
  self.Time:SetText(_data.Time)
end

function UMG_PetHatchingReview_Item_C:PlayInAnimation()
  self:TryPlayAnimation(self.In, false, 0)
end

function UMG_PetHatchingReview_Item_C:SetQuality(quality)
  self.IconBgColour:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(quality))
end

return UMG_PetHatchingReview_Item_C
