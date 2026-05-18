local FriendModuleEvent = reload("NewRoco.Modules.System.Friend.FriendModuleEvent")
local UMG_ChangeAvatar_C = _G.NRCPanelBase:Extend("UMG_ChangeAvatar_C")

function UMG_ChangeAvatar_C:OnConstruct()
  self.data = self.module:GetData("FriendModuleData")
  self:OnAddEventListener()
end

function UMG_ChangeAvatar_C:OnDestruct()
end

function UMG_ChangeAvatar_C:OnActive()
  self:SetItemList()
  self:PlayAnimation(self.open)
end

function UMG_ChangeAvatar_C:OnDeactive()
end

function UMG_ChangeAvatar_C:OnAddEventListener()
  self:AddButtonListener(self.UMG_Btn3.btnLevelUp, self.OnClickConfirm)
  self:AddButtonListener(self.UMG_Btn2.btnLevelUp, self.CloseAvatarPanel)
  self:RegisterEvent(self, FriendModuleEvent.SetChooseItemInfo, self.SetItemInfo)
end

function UMG_ChangeAvatar_C:SetItemList()
  self.IconList = self.data:GetIconList()
  self.CardBriefInfo = _G.DataModelMgr.PlayerDataModel:GetCardBriefInfo()
  self.List:InitGridView(self.IconList)
  for i, Icon in ipairs(self.IconList) do
    if Icon.id == self.CardBriefInfo.card_icon_selected then
      self.List:SelectItemByIndex(i - 1)
      local Item = self.List:GetItemByIndex(i - 1)
      Item:CurrentUse()
      break
    end
  end
end

function UMG_ChangeAvatar_C:SetItemInfo(CardIconConf)
  local path = "Texture2D'/Game/NewRoco/Modules/System/Common/Icon/HeadIcon/"
  local AvatarItemInfo = _G.DataConfigManager:GetCardIconConf(CardIconConf.card_item_id)
  if CardIconConf.ConfigurationInfo ~= nil then
    local AvatarPath = CardIconConf.ConfigurationInfo.icon_resource_path
    self.AvatarPath = string.format("%s%s.%s'", path, AvatarPath, AvatarPath)
    self.AvatarIconId = AvatarItemInfo.id
  else
    return
  end
  self.HeadPortrait:SetPath(self.AvatarPath)
  self.Name:SetText(AvatarItemInfo.icon_resource_name)
end

function UMG_ChangeAvatar_C:OnClickConfirm()
  _G.NRCAudioManager:PlaySound2DAuto(1002, "UMG_ChangeAvatar_C:OnClickConfirm")
  if self.CardBriefInfo.card_icon_selected ~= self.AvatarIconId then
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.SetStudentCardAvatarPath, self.AvatarPath, self.AvatarIconId)
  end
  self:PlayAnimation(self.close)
end

function UMG_ChangeAvatar_C:CloseAvatarPanel()
  _G.NRCAudioManager:PlaySound2DAuto(1002, "UMG_ChangeAvatar_C:CloseAvatarPanel")
  self:PlayAnimation(self.close)
end

function UMG_ChangeAvatar_C:OnAnimationFinished(Animation)
  if Animation == self.close then
    _G.NRCModeManager:DoCmd(LevelUpUIModuleCmd.LevelUpCloseCardSetLock, false)
    self:DoClose()
  end
end

return UMG_ChangeAvatar_C
