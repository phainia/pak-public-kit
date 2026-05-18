local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ChangeAvatar_Item_C = Base:Extend("UMG_ChangeAvatar_Item_C")

function UMG_ChangeAvatar_Item_C:OnConstruct()
end

function UMG_ChangeAvatar_Item_C:OnDestruct()
end

function UMG_ChangeAvatar_Item_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  self:InitPanel()
  self:SetOnNewState()
end

function UMG_ChangeAvatar_Item_C:UpdateHead(_data)
  self.data = _data
  self:InitPanel()
end

function UMG_ChangeAvatar_Item_C:InitPanel()
  local path = "Texture2D'/Game/NewRoco/Modules/System/Common/Icon/BigHeadIcon256/"
  local CardIconConf = _G.DataConfigManager:GetCardIconConf(self.data.card_item_id)
  if self.data and self.data.ConfigurationInfo then
    local AvatarPath = self.data.ConfigurationInfo.icon_resource_path
    AvatarPath = string.format("%s%s.%s'", path, AvatarPath, AvatarPath)
    self.HeadPortrait:SetPath(AvatarPath)
  end
  self.Checked:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:SetSelectState(false)
end

function UMG_ChangeAvatar_Item_C:CurrentUse(_IsUse)
  if _IsUse then
    self.Checked:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Checked:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_ChangeAvatar_Item_C:SetSelectState(_IsSelect)
  if _IsSelect then
    self.Select:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:PlayAnimation(self.Selected)
  else
    self.Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:PlayAnimationReverse(self.Selected)
  end
end

function UMG_ChangeAvatar_Item_C:SetOnNewState()
  if self.data and self.data.card_item_id then
    local id = self.data.card_item_id
    self.RedDot:SetupKey(171, id)
  end
end

function UMG_ChangeAvatar_Item_C:SetOnNewStateRemove()
  if self.data and self.data.card_item_id and self.RedDot and self.RedDot:IsRed() then
    self.RedDot:EraseRedPoint()
  end
end

function UMG_ChangeAvatar_Item_C:OnItemSelected(_bSelected)
  self:SetSelectState(_bSelected)
  if _bSelected then
    self:SetOnNewStateRemove()
    self:OnClick()
  end
end

function UMG_ChangeAvatar_Item_C:OnClick()
  _G.NRCModuleManager:DoCmd(FriendModuleCmd.SetSelectedAvatarItem, self.data)
end

function UMG_ChangeAvatar_Item_C:OnDeactive()
end

return UMG_ChangeAvatar_Item_C
