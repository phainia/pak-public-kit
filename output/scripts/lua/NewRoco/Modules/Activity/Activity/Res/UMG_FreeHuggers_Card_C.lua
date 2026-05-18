local UMG_FreeHuggers_Card_C = _G.NRCPanelBase:Extend("UMG_FreeHuggers_Card_C")

function UMG_FreeHuggers_Card_C:OnActive(data)
  self.data = data
  self:OnAddEventListener()
  self:ShowInfo()
end

function UMG_FreeHuggers_Card_C:OnDeactive()
  self:RemoveButtonListener(self.CloseBtn.btnClose, self.OnClickCloseBtn)
  self:RemoveButtonListener(self.LeaveForBtn, self.OnGoToShare)
  self:RemoveButtonListener(self.FullScreen_Close, self.OnClickCloseBtn)
end

function UMG_FreeHuggers_Card_C:OnAddEventListener()
  self:AddButtonListener(self.CloseBtn.btnClose, self.OnClickCloseBtn)
  self:AddButtonListener(self.LeaveForBtn, self.OnGoToShare)
  self:AddButtonListener(self.FullScreen_Close, self.OnClickCloseBtn)
  self.CardLoader.OnLoadPanelCallbackDelegate:Add(self, self.OnLoadWidgetCallback)
end

function UMG_FreeHuggers_Card_C:OnClickCloseBtn()
  self:OnClose()
end

function UMG_FreeHuggers_Card_C:ShowInfo()
  self.ObtainDescription:SetText(LuaText.share_card_des)
  local activityObject = NRCModuleManager:DoCmd(ActivityModuleCmd.GetActivityInstById, self.data.activityId)
  local isGetCard = false
  if activityObject and activityObject.returnActivityData and activityObject.returnActivityData.pet_collection_data then
    local petCollectData = activityObject.returnActivityData.pet_collection_data
    local collectPetList = petCollectData.collection_pet
    local collectPetRewardList = petCollectData.pet_rewards
    local hasGetRewardPet = false
    if collectPetRewardList then
      for _, v in ipairs(collectPetRewardList) do
        if v.pet_base_id == self.data.petBaseConfId then
          hasGetRewardPet = true
          break
        end
      end
    end
    if collectPetList and table.contains(collectPetList, self.data.petBaseConfId) and hasGetRewardPet then
      isGetCard = true
    end
  end
  if isGetCard then
    self.LeaveForImage:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.LeaveForBtn:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.LeaveForImage:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.LeaveForBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.CardLoader:LoadPanel(self)
end

function UMG_FreeHuggers_Card_C:OnLoadWidgetCallback(Panel)
  if Panel then
    local cardPanel = self.CardLoader:GetPanel()
    cardPanel:SetMaskVisibility(UE4.ESlateVisibility.Collapsed)
    cardPanel:Init(nil, {
      self.data.cardId
    }, {true}, self.data.petBaseConfId)
    cardPanel:ChangeCard(1)
  end
end

function UMG_FreeHuggers_Card_C:OnGoToShare()
  local petInfoList = _G.DataModelMgr.PlayerDataModel:GetPlayerPetInfo()
  if petInfoList and petInfoList.pet_data then
    for _, petDataInfo in ipairs(petInfoList.pet_data) do
      if petDataInfo.base_conf_id == self.data.petBaseConfId then
        local shareBaseId = _G.Enum.ShareButtonType.SBT_PET
        local sharePartId = _G.Enum.ShareButtonType.SBT_PET_CARD
        local data = {
          shareBaseId = shareBaseId,
          sharePartId = sharePartId,
          petData = petDataInfo
        }
        _G.NRCModuleManager:DoCmd(ShareUIModuleCmd.OpenShareUIPanel, data)
        return
      end
    end
  end
end

function UMG_FreeHuggers_Card_C:OnClickCloseBtn()
  if not self.IsClose then
    _G.NRCAudioManager:PlaySound2DAuto(41400010, "UMG_FreeHuggers_C:OnClickCloseBtn")
    self.IsClose = true
    self:DoClose()
  end
end

return UMG_FreeHuggers_Card_C
