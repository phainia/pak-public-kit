local UMG_ShareUI_Card_C = _G.NRCPanelBase:Extend("UMG_ShareUI_Card_C")

function UMG_ShareUI_Card_C:OnActive(data)
  self.data = data
  self.bExp = true
  self.cardIndex = 1
  self.cardIds = {}
  self.unlockData = nil
  self.bCardDebugFirstOpen = true
  self:OnAddEventListener()
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local req = ProtoMessage:newZoneGetShareFormInfoReq()
  req.pet_id = self.data.petData.base_conf_id
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_GET_SHARE_FORM_INFO_REQ, req, self, self.ShowCard, false, true)
end

function UMG_ShareUI_Card_C:OnDeactive()
  self:RemoveButtonListener(self.Btn1.btnLevelUp)
  self:RemoveButtonListener(self.Btn2.btnLevelUp)
  self:RemoveButtonListener(self.Button)
end

function UMG_ShareUI_Card_C:OnAddEventListener()
  self:AddButtonListener(self.Btn1.btnLevelUp, self.TurnLeft)
  self:AddButtonListener(self.Btn2.btnLevelUp, self.TurnRight)
  self:AddButtonListener(self.Button, self.OnClickExpButton)
end

function UMG_ShareUI_Card_C:ShowCard(rsp)
  if rsp.ret_info and 0 == rsp.ret_info.ret_code then
    local shareConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.PET_SHARE_ITEM_CONF):GetAllDatas()
    local cardBaseData = {}
    for _, v in pairs(shareConf) do
      if v.allowed_petbase == self.data.petData.base_conf_id then
        table.insert(cardBaseData, {
          v.id,
          v.share_pattern
        })
      end
    end
    local share_pattern = _G.DataConfigManager:GetSharePartConf(self.data.sharePartId).share_pattern
    local card_ids = {}
    for _, pattern in ipairs(share_pattern) do
      for _, v in ipairs(cardBaseData) do
        if v[2] == pattern then
          table.insert(card_ids, v[1])
          break
        end
      end
    end
    local unlockData = table.new(#card_ids, 0)
    if rsp.share_form_item then
      for i = 1, #card_ids do
        unlockData[i] = false
        for _, v in ipairs(rsp.share_form_item) do
          if v.id == card_ids[i] then
            unlockData[i] = true
            break
          end
        end
      end
    end
    local index = 1
    while index <= #card_ids do
      if not unlockData[index] and not _G.DataConfigManager:GetPetShareItemConf(card_ids[index]).is_show_unlock then
        table.remove(unlockData, index)
        table.remove(card_ids, index)
      else
        index = index + 1
      end
    end
    local openIndex
    for i = #unlockData, 1, -1 do
      if unlockData[i] then
        openIndex = i
        break
      end
    end
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.CardPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.cardIds = card_ids
    self.unlockData = unlockData
    self.PhotoSub:Init(self.data.petData, card_ids, unlockData)
    self:ChangeCard(openIndex)
  end
end

function UMG_ShareUI_Card_C:ChangeCard(cardIndex)
  self.cardIndex = cardIndex
  local visible = self.unlockData[cardIndex] and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.Visible
  self.Locked:SetVisibility(visible)
  self.PhotoSub:SetMaskVisibility(visible)
  self.PhotoSub:ChangeCard(cardIndex)
  if 1 == cardIndex then
    self.Btn1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if #self.cardIds > 1 then
      self.Btn2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
  if cardIndex == #self.cardIds then
    self.Btn2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if #self.cardIds > 1 then
      self.Btn1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
  if cardIndex > 1 and cardIndex < #self.cardIds then
    self.Btn1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Btn2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if _G.DataConfigManager:GetPetShareItemConf(self.cardIds[cardIndex]).share_pattern == Enum.SharePattern.ASP_CARD_RARE then
    self.PhotoSub.Slot:SetSize(UE4.FVector2D(1560, 580))
  else
    self.PhotoSub.Slot:SetSize(UE4.FVector2D(1150, 800))
  end
end

function UMG_ShareUI_Card_C:OpenCardDebugPanel()
  if self.bCardDebugFirstOpen then
    self.UMG_CardDebugPanel:SetCardPanel(self.PhotoSub, self.data.petData.base_conf_id)
    self.bCardDebugFirstOpen = false
  end
  self.UMG_CardDebugPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_ShareUI_Card_C:TurnLeft()
  _G.NRCAudioManager:PlaySound2DAuto(40004005, "UMG_ShareUI_Card_C:TurnLeft")
  if not self.PhotoSub:GetCanChange() then
    return
  end
  self:ChangeCard(self.cardIndex - 1)
end

function UMG_ShareUI_Card_C:TurnRight()
  _G.NRCAudioManager:PlaySound2DAuto(40004005, "UMG_ShareUI_Card_C:TurnRight")
  if not self.PhotoSub:GetCanChange() then
    return
  end
  self:ChangeCard(self.cardIndex + 1)
end

function UMG_ShareUI_Card_C:OnCardExpire(expireId)
  local expireIndex
  for i = 1, #self.cardIds do
    if self.cardIds[i] == expireId then
      expireIndex = i
      break
    end
  end
  if expireIndex then
    self.unlockData[expireIndex] = false
    if self.cardIndex == expireIndex then
      self.Locked:SetVisibility(UE4.ESlateVisibility.Visible)
      self.PhotoSub:SetMask(UE4.ESlateVisibility.Visible)
    end
  end
end

function UMG_ShareUI_Card_C:OnClickExpButton()
  _G.NRCAudioManager:PlaySound2DAuto(40004006, "UMG_ShareUI_Card_C:OnClickExpButton")
  if not self.PhotoSub:GetCanChange() then
    return
  end
  self.bExp = not self.bExp
  self.PhotoSub:SetExp(self.bExp)
  if self.bExp then
    self:PlayAnimation(self.Check_In)
  else
    self:PlayAnimation(self.Check_Out)
  end
end

function UMG_ShareUI_Card_C:GetShareCardId()
  return self.cardIds[self.cardIndex]
end

function UMG_ShareUI_Card_C:PlayInCard()
  self:PlayAnimation(self.In_Card)
end

function UMG_ShareUI_Card_C:PlayOutCard()
  self:PlayAnimation(self.Out_Card)
end

return UMG_ShareUI_Card_C
