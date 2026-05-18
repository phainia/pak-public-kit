local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local FriendEnum = require("NewRoco.Modules.System.Friend.FriendEnum")
local UMG_ChangeCard_Item_C = Base:Extend("UMG_ChangeCard_Item_C")

function UMG_ChangeCard_Item_C:OnConstruct()
  self.IsFirstOpen = true
end

function UMG_ChangeCard_Item_C:OnDestruct()
end

function UMG_ChangeCard_Item_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  self:InitPanel()
  self:SetOnNewState()
end

function UMG_ChangeCard_Item_C:InitPanel()
  local Type = _G.NRCModeManager:DoCmd(FriendModuleCmd.GetImageEditorIndex)
  self.NRCSwitcher_Type:SetActiveWidgetIndex(Type)
  if Type == FriendEnum.ImageEditorType.Theme then
    local CardSkinConf = self.data.ConfigurationInfo
    self.CardBg:SetPath(string.format(UEPath.CARD_COMMON_PATH, CardSkinConf.skin_resource_path, "Small", CardSkinConf.skin_resource_path, "Small"))
    self.Mask:SetVisibility(self.data.is_initial_unlock and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Lock:SetVisibility(self.data.is_initial_unlock and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Name_content:SetText(CardSkinConf.skin_resource_name)
  elseif Type == FriendEnum.ImageEditorType.Clothing then
    self.Skin:SetPath(self.data.Icon)
    self.Name_content:SetText(self.data.Name)
    self.Mask:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Lock:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif Type == FriendEnum.ImageEditorType.PlayerAction then
    self.Name_content:SetText(self.data.ConfigurationInfo.name_text)
    self.pose:SetPath(self.data.ConfigurationInfo.icon_path)
    self.Mask:SetVisibility(self.data.is_initial_unlock and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Lock:SetVisibility(self.data.is_initial_unlock and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  self:IsShowCurrentUse(false)
  if self.IsFirstOpen then
    self.Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Select_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.IsFirstOpen = false
    self:PlayAnimation(self.Init)
  end
end

function UMG_ChangeCard_Item_C:IsShowCurrentUse(_IsShow)
  if _IsShow then
    self.Checked:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Checked:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_ChangeCard_Item_C:OnItemSelected(_bSelected)
  if _bSelected then
    self:OnClick()
  else
    self:SetSelectedVisible(false)
  end
end

function UMG_ChangeCard_Item_C:SetOnNewState()
  if self.data and self.data.card_item_id then
    local Type = _G.NRCModeManager:DoCmd(FriendModuleCmd.GetImageEditorIndex)
    if Type == FriendEnum.ImageEditorType.Theme then
      local id = self.data.card_item_id
      self.RedDot:SetupKey(172, id)
    elseif Type == FriendEnum.ImageEditorType.Clothing then
      local id = self.data.card_item_id
      self.RedDot:SetupKey(173, id)
    elseif Type == FriendEnum.ImageEditorType.PlayerAction then
      local id = self.data.card_item_id
      self.RedDot:SetupKey(175, id)
    end
  end
end

function UMG_ChangeCard_Item_C:SetOnNewStateRemove()
  if self.data and self.data.is_initial_unlock and self.RedDot and self.RedDot:IsRed() then
    self.RedDot:EraseRedPoint()
  end
end

function UMG_ChangeCard_Item_C:OnClick()
  self:SetSelectedVisible(true)
  _G.NRCModuleManager:DoCmd(FriendModuleCmd.SelectImageEditorTypeItem, self.data, self.index)
end

function UMG_ChangeCard_Item_C:SetSelectedVisible(visible)
  self:StopAllAnimations()
  if visible then
    self:SetOnNewStateRemove()
    self.Select:SetVisibility(UE4.ESlateVisibility.visible)
    self.Select_1:SetVisibility(UE4.ESlateVisibility.visible)
    self:PlayAnimation(self.Selected)
  else
    self.Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Select_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:PlayAnimation(self.Selected_out)
  end
end

function UMG_ChangeCard_Item_C:OnDeactive()
end

return UMG_ChangeCard_Item_C
