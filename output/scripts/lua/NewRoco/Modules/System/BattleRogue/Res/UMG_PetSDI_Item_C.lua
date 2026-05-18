local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PetSDI_Item_C = Base:Extend("UMG_PetSDI_Item_C")

function UMG_PetSDI_Item_C:OnConstruct()
end

function UMG_PetSDI_Item_C:OnDestruct()
end

function UMG_PetSDI_Item_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  self:SetInfo()
end

function UMG_PetSDI_Item_C:SetInfo()
  local data = self.data
  if data.NodeID then
    if not data.NodeUIEventData then
      self.SDISwitch:SetActiveWidgetIndex(1)
      self.IndexText:SetText(self.index)
      self.Attr:SetVisibility(UE4.ESlateVisibility.Collapsed)
    elseif data.bHide then
      self.SDISwitch:SetActiveWidgetIndex(2)
      self.Attr:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.AlreadyReceived:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      if data.NodeUIEventData.EventType == Enum.IncidentType.IT_MONSTER_1 then
        self.HeadIcon:SetIconPath(data.NodeUIEventData.HeadIcons[1])
        self.Attr:InitGridView(data.NodeUIEventData.PetsTypes)
        self.HeadIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self.Icon_Makeup:SetVisibility(UE4.ESlateVisibility.Collapsed)
        self.Attr:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      else
        self.Icon_Makeup:SetPath(data.NodeUIEventData.HeadIcons[1])
        self.HeadIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
        self.Icon_Makeup:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self.Attr:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
      self.SDISwitch:SetActiveWidgetIndex(0)
      self.Name:SetText(data.NodeUIEventData.Name)
    end
    if data.bFinished then
      self.AlreadyReceived:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.AlreadyReceived:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  else
    self.SDISwitch:SetActiveWidgetIndex(0)
    if data.EventType == Enum.IncidentType.IT_MONSTER_1 then
      self.HeadIcon:SetIconPath(data.HeadIcons[1])
      self.Attr:InitGridView(data.PetsTypes)
      self.HeadIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Icon_Makeup:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Attr:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.Icon_Makeup:SetPath(data.HeadIcons[1])
      self.HeadIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Icon_Makeup:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Attr:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self.AlreadyReceived:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Name:SetText(data.Name)
  end
end

function UMG_PetSDI_Item_C:OnItemSelected(_bSelected)
end

function UMG_PetSDI_Item_C:OnDeactive()
end

return UMG_PetSDI_Item_C
