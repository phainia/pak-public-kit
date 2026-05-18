local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Leader_Item_C = Base:Extend("UMG_Leader_Item_C")

function UMG_Leader_Item_C:OnConstruct()
end

function UMG_Leader_Item_C:OnDestruct()
end

function UMG_Leader_Item_C:OnItemUpdate(_data, datalist, index)
  self.ItemData = _data
  self.ItemIcon:SetPath(self.ItemData.BagItemConf.icon)
  self.Selected:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ItemIcon:SwitchToSetBrushFromMaterialInstanceMode(true)
  self.ItemIconMask:SetVisibility(self.ItemData.IsHas and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible)
  self:SetQuality()
end

function UMG_Leader_Item_C:OnItemSelected(_bSelected)
  if _bSelected then
    self:PlayAnimation(self.Selected_In)
    _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_Leader_Item_C:OnItemSelected")
    _G.NRCModeManager:DoCmd(PetUIModuleCmd.SelectLeaderItem, self.ItemData)
  else
    self:PlayAnimation(self.Selected_out)
  end
end

function UMG_Leader_Item_C:SetQuality()
  local Quality = self.ItemData.BagItemConf.item_quality
  if 0 == Quality then
  elseif 1 == Quality then
    self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_1))
  elseif 2 == Quality then
    self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_2))
  elseif 3 == Quality then
    self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_3))
  elseif 4 == Quality then
    self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_4))
  elseif 5 == Quality then
    self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_5))
  end
end

function UMG_Leader_Item_C:OnDeactive()
end

return UMG_Leader_Item_C
