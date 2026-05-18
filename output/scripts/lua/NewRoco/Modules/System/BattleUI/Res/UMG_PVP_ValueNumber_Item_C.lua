local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PVP_ValueNumber_Item_C = Base:Extend("UMG_PVP_ValueNumber_Item_C")
UMG_PVP_ValueNumber_Item_C.IconNormalColor = UE4.UNRCStatics.HexToLinearColor("#C4C2B6FF")
UMG_PVP_ValueNumber_Item_C.IconSelectedColor = UE4.UNRCStatics.HexToLinearColor("#1F1F1FFF")
UMG_PVP_ValueNumber_Item_C.NumberTextNormalColor = UE4.UNRCStatics.HexToSlateColor("#8D8A77FF")
UMG_PVP_ValueNumber_Item_C.NumberTextSelectedColor = UE4.UNRCStatics.HexToSlateColor("#1F1F1FFF")

function UMG_PVP_ValueNumber_Item_C:OnConstruct()
  local BackgroundImageVisibility = UE.ESlateVisibility.Visible
  self.currentIsSelected = false
  self.BackgroundImage:SetVisibility(BackgroundImageVisibility)
end

function UMG_PVP_ValueNumber_Item_C:OnDestruct()
end

function UMG_PVP_ValueNumber_Item_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.Quantity:SetText(self.data.label)
end

function UMG_PVP_ValueNumber_Item_C:OnItemSelected(_bSelected)
  if _bSelected then
    self.BackgroundImage:SetRenderOpacity(1)
    if not self.currentIsSelected and not self:IsAnimationPlaying(self.select) then
      self:PlayAnimation(self.select)
    end
    if self.data.OnSelectCallback then
      if self.data.OnSelectCallbackOwner then
        self.data.OnSelectCallback(self.data.OnSelectCallbackOwner, self)
      else
        self.data.OnSelectCallback(self)
      end
    end
  else
    if self:IsAnimationPlaying(self.select) then
      self:StopAnimation(self.select)
    end
    self.BackgroundImage:SetRenderOpacity(0)
    self.Icon:SetColorAndOpacity(UMG_PVP_ValueNumber_Item_C.IconNormalColor)
    self.Quantity:SetColorAndOpacity(UMG_PVP_ValueNumber_Item_C.NumberTextNormalColor)
  end
  self.currentIsSelected = _bSelected
end

function UMG_PVP_ValueNumber_Item_C:OnDeactive()
  self.data = nil
end

return UMG_PVP_ValueNumber_Item_C
