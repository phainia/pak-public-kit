local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_CardTips_Item_C = Base:Extend("UMG_CardTips_Item_C")

function UMG_CardTips_Item_C:OnConstruct()
end

function UMG_CardTips_Item_C:OnDestruct()
end

function UMG_CardTips_Item_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  self.LockBtn.OnClicked:Add(self, self.OnLockBtn)
  self:SetInfo()
end

function UMG_CardTips_Item_C:SetInfo()
  local data = self.data
  self.Name:SetText(data.Name)
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
  self.Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if data.bFixed then
    self.LockSwitcher:SetActiveWidgetIndex(0)
  else
    self.LockSwitcher:SetActiveWidgetIndex(1)
  end
end

function UMG_CardTips_Item_C:SelectInfo(_bSelected)
  if _bSelected then
    if self.Select:GetVisibility() == UE4.ESlateVisibility.SelfHitTestInvisible then
      self.Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.Select:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
end

function UMG_CardTips_Item_C:OnItemSelected(_bSelected)
  self:SelectInfo(_bSelected)
  if _bSelected then
    local Add = false
    if self.Select:GetVisibility() == UE4.ESlateVisibility.SelfHitTestInvisible then
      Add = true
    end
    _G.NRCModuleManager:DoCmd(BattleRogueModuleCmd.SelectCombineCard, Add, self.index)
  end
end

function UMG_CardTips_Item_C:OnLockBtn()
  if 0 == self.LockSwitcher:GetActiveWidgetIndex() then
    self.LockSwitcher:SetActiveWidgetIndex(1)
  else
    self.LockSwitcher:SetActiveWidgetIndex(0)
  end
  _G.NRCModuleManager:DoCmd(BattleRogueModuleCmd.SendFixedEventReq, self.index)
end

function UMG_CardTips_Item_C:OnDeactive()
end

return UMG_CardTips_Item_C
