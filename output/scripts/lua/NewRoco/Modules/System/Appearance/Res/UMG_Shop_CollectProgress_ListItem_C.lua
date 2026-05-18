local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Shop_CollectProgress_ListItem_C = Base:Extend("UMG_Shop_CollectProgress_ListItem_C")

function UMG_Shop_CollectProgress_ListItem_C:OnConstruct()
  Log.Dump(self, 2, "UMG_Shop_CollectProgress_ListItem_C OnConstruct")
  self.ActiveIndex = 0
end

function UMG_Shop_CollectProgress_ListItem_C:OnDestruct()
end

function UMG_Shop_CollectProgress_ListItem_C:OnItemUpdate(_data, datalist, index)
  local enumToIndex = {
    _G.Enum.FashionLabelType.FLT_TOPS,
    _G.Enum.FashionLabelType.FLT_BOTTOMS,
    _G.Enum.FashionLabelType.FLT_DRESSES,
    _G.Enum.FashionLabelType.FLT_SOCKS,
    _G.Enum.FashionLabelType.FLT_SHOES,
    _G.Enum.FashionLabelType.FLT_HATS,
    _G.Enum.FashionLabelType.FLT_RINGS,
    _G.Enum.FashionLabelType.FLT_BAGS
  }
  self.FieldMap = enumToIndex
  self.UIData = _data
  local ActiveIndex = 0
  for i, value in ipairs(enumToIndex) do
    if _data.type == value then
      ActiveIndex = i - 1
      self.ActiveIndex = ActiveIndex
      Log.Debug("UMG_Shop_CollectProgress_ListItem_C ", value, ActiveIndex)
      self.NRCSwitcher_19:SetActiveWidgetIndex(ActiveIndex)
      self.NRCSwitcher:SetActiveWidgetIndex(ActiveIndex)
      local ActiveWidget = self.NRCSwitcher_19:GetActiveWidget()
      if ActiveWidget and not _data.isNewlyAcquired then
        ActiveWidget:SwitchToSetBrushFromMaterialInstanceMode(not _data.collected)
      else
        Log.Warning("UMG_Shop_CollectProgress_ListItem_C: ActiveWidget is nil")
      end
      if ActiveWidget then
        ActiveWidget:SetPath(_data.icon)
      end
      if _data.collected and not self.UIData.isNewlyAcquired then
        self.Collected_2:SetVisibility(UE4.ESlateVisibility.Visible)
      else
        self.Collected_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
      local ActiveWidget2 = self.NRCSwitcher:GetActiveWidget()
      if ActiveWidget2 then
        ActiveWidget2:SwitchToSetBrushFromMaterialInstanceMode(not _data.collected)
        ActiveWidget2:SetPath(_data.icon)
        break
      end
      Log.Warning("UMG_Shop_CollectProgress_ListItem_C: ActiveWidget2 is nil")
      break
    end
  end
  if self.Collected then
    if _data.collected then
      self.Collected:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      self.Collected:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_Shop_CollectProgress_ListItem_C:OnItemSelected(_bSelected)
end

function UMG_Shop_CollectProgress_ListItem_C:OnDeactive()
end

function UMG_Shop_CollectProgress_ListItem_C:OnAnimationFinished(Anim)
  if Anim == self.Sticker and self.UmgParent ~= nil and self.UmgParent.PlayCollect then
    self.UmgParent:PlayCollect()
  end
end

function UMG_Shop_CollectProgress_ListItem_C:OnPlaySticker(Parent)
  self.UmgParent = Parent
  if self.Sticker and self.UIData.collected and self.UIData.isNewlyAcquired then
    self:PlayAnimation(self.Sticker)
  end
end

return UMG_Shop_CollectProgress_ListItem_C
