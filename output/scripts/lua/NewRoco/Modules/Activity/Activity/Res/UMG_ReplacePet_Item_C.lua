local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ReplacePet_Item_C = Base:Extend("UMG_ReplacePet_Item_C")
local PetUtils = require("NewRoco.Utils.PetUtils")

function UMG_ReplacePet_Item_C:OnConstruct()
  if self.TipsBtn then
    self.TipsBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_ReplacePet_Item_C:OnDestruct()
end

function UMG_ReplacePet_Item_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  self:PlayAnimation(self.normal)
  self.NumText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("908F85FF"))
  self.TipsBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.CheckCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Selected:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.TextBG_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.TheHoodBlack:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ItemIconMask:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ItemIcon:SetVisibility(UE4.ESlateVisibility.Visible)
  self.TextBG:SetVisibility(UE4.ESlateVisibility.Visible)
  self.NumText:SetVisibility(UE4.ESlateVisibility.Visible)
  self.TagIcon_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.CollectCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if _data.PetData.partner_mark and _data.PetData.partner_mark ~= ProtoEnum.PetPartnerMarkType.PPMT_NONE then
    self.CollectCanvas:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Star:SetPath(PetUtils.GetPetCollectTagIcon(_data.PetData.partner_mark))
  end
  if _data.isSelected then
    self.State:SetVisibility(UE4.ESlateVisibility.Visible)
    self.State:SetActiveWidgetIndex(8)
  elseif _data.isTeam then
    self.TeamMarker:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Text_Number:SetText(_data.teamIdx)
    self.State:SetVisibility(UE4.ESlateVisibility.Visible)
    self.State:SetActiveWidgetIndex(3)
  elseif _data.isTravel then
    self.State:SetVisibility(UE4.ESlateVisibility.Visible)
    self.State:SetActiveWidgetIndex(0)
  elseif _data.isInTemporarilyStoreBackpack then
    self.State:SetVisibility(UE4.ESlateVisibility.Visible)
    self.State:SetActiveWidgetIndex(5)
  elseif _data.isInHome then
    self.State:SetVisibility(UE4.ESlateVisibility.Visible)
    self.State:SetActiveWidgetIndex(6)
  elseif _data.isInGuard then
    self.State:SetVisibility(UE4.ESlateVisibility.Visible)
    self.State:SetActiveWidgetIndex(7)
  else
    self.State:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.ItemIcon:SetIconPathAndMaterial(_data.PetData.base_conf_id, _data.PetData.mutation_type, _data.PetData.glass_info)
  self.NumText:SetText(_data.PetData.level)
end

function UMG_ReplacePet_Item_C:OnItemSelected(_bSelected)
  if _bSelected then
    _G.NRCAudioManager:PlaySound2DAuto(40001001, "UMG_ReplacePet_Item_C:OnItemSelected")
  end
  self:SetSelected(_bSelected)
  local data = self.data
  if data and data.onSelectCallback then
    data.onSelectCallback(_bSelected, data)
  end
end

function UMG_ReplacePet_Item_C:SetSelected(_bSelected)
  self:StopAllAnimations()
  if _bSelected then
    self:PlayAnimation(self.select)
    self.NumText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("F4EEE1FF"))
    self.TextBG:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Selected:SetVisibility(UE4.ESlateVisibility.Visible)
    self.TextBG_2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Selectbg_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self:PlayAnimation(self.Unselect)
    self.NumText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("908F85FF"))
    self.TextBG:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Selected:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Selectbg_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_ReplacePet_Item_C:OnDespawn()
  if self._parent and self._parent._selectedItemIndex == self.index then
    self:SetSelected(false)
  end
end

return UMG_ReplacePet_Item_C
