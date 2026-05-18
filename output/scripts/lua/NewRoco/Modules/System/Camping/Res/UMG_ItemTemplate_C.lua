local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ItemTemplate_C = Base:Extend("UMG_ItemTemplate_C")

function UMG_ItemTemplate_C:OnConstruct()
  self.uiData = {}
end

function UMG_ItemTemplate_C:OnDestruct()
  self.uiData = nil
end

function UMG_ItemTemplate_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  self.index = index
  local bagItemId = _data.getItem.get_goods_id
  local bagItemConf = _G.DataConfigManager:GetBagItemConf(bagItemId)
  if bagItemConf then
    self:SetQuality(bagItemConf.item_quality)
    self.NumText:SetText(bagItemConf.name)
    self.ItemIcon_1:SetPath(bagItemConf.big_icon)
  end
  self:SetMaskVisibility(0 == _data.canExchangeNum)
  if self.uiData.IsRefresh == true then
    self:PlayAnimation(self.normal)
  end
end

function UMG_ItemTemplate_C:OnItemSelected(_bSelected)
  if _bSelected then
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1003, "UMG_BagItemTemplate_C:OnItemSelected")
    if not self:IsAnimationPlaying(self.select) then
      self:PlayAnimation(self.change1)
    end
    _G.NRCModuleManager:GetModule("CampingModule"):DispatchEvent(CampingModuleEvent.EXCHANGE_ITEM_SELECTED, self.index)
  else
    self:StopAllAnimations()
    self:PlayAnimation(self.change2)
  end
end

function UMG_ItemTemplate_C:OnDeactive()
end

function UMG_ItemTemplate_C:SetMaskVisibility(isVisible)
  if isVisible then
    self.ItemIcon_1:SetColorAndOpacity(UE4.FLinearColor(0.2, 0.2, 0.2, 1))
    self.NumText:SetOpacity(0.5)
  else
    self.ItemIcon_1:SetColorAndOpacity(UE4.FLinearColor(1, 1, 1, 1))
    self.NumText:SetOpacity(1)
  end
end

function UMG_ItemTemplate_C:SetQuality(quality)
  local color = UE4.UNRCStatics.HexToSlateColor("#ffffff")
  if 1 == quality then
    color = UE4.UNRCStatics.HexToSlateColor("#ffffff")
  elseif 2 == quality then
    color = UE4.UNRCStatics.HexToSlateColor("#96db71")
  elseif 3 == quality then
    color = UE4.UNRCStatics.HexToSlateColor("#43adef")
  elseif 4 == quality then
    color = UE4.UNRCStatics.HexToSlateColor("#c67fcc")
  elseif 5 == quality then
    color = UE4.UNRCStatics.HexToSlateColor("#e6c142")
  end
  self.NumText:SetColorAndOpacity(color)
end

function UMG_ItemTemplate_C:SetSelectedVisible(visible)
  if visible then
    self.Selected:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.Selected:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_ItemTemplate_C:OnAnimationFinished(Animation)
  if Animation == self.change1 then
    self:PlayAnimation(self.select, 0, 9999)
  end
  if Animation == self.change2 then
  end
end

return UMG_ItemTemplate_C
