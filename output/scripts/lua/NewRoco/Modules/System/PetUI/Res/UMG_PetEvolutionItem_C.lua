local UMG_PetEvolutionItem_C = _G.NRCPanelBase:Extend("UMG_PetEvolutionItem_C")

function UMG_PetEvolutionItem_C:OnConstruct()
  self:SetChildViews(self.item1, self.item2, self.item3, self.item4)
  self.uiData = {}
  self.uiItem = {}
  local itemPanels = {}
  local itemIcons = {
    self.item1,
    self.item2,
    self.item3,
    self.item4
  }
  local ChildrenCount = self.itemParent:GetChildrenCount()
  for i = 0, ChildrenCount - 1 do
    table.insert(itemPanels, self.itemParent:GetChildAt(i))
  end
  self.uiItem.itemIcons = itemIcons
  self.uiItem.itemPanels = itemPanels
  self.uiItem.itemPanelSize = self.itemParent.Slot:GetSize()
end

function UMG_PetEvolutionItem_C:OnDestruct()
  table.clear(self.uiData)
  table.clear(self.uiItem)
  self.uiData = nil
  self.uiItem = nil
end

function UMG_PetEvolutionItem_C:OnActive(_param, ...)
  _G.NRCPanelBase.OnActive(self, _param, ...)
  local uiData = self.uiData
  uiData.petData = _param.petData
  uiData.petBaseConf = _param.petBaseConf
  uiData.curEvolutionIndex = _param.curEvolutionIndex
  self:PlayAnimation(self.Appear)
  self:OnAddEventListener()
  self:updatePanelInfo()
end

function UMG_PetEvolutionItem_C:OnDeactive()
end

function UMG_PetEvolutionItem_C:OnAddEventListener()
  self:AddButtonListener(self.btnCancel, self.OnBtnCancelClick)
  self:AddButtonListener(self.btnOK, self.OnBtnOKClick)
end

function UMG_PetEvolutionItem_C:OnRemoveEventListener()
end

function UMG_PetEvolutionItem_C:updatePanelInfo()
  local petBaseConf = self.uiData.petBaseConf
  self:updateItemInfo(petBaseConf.evolution_need_items)
end

function UMG_PetEvolutionItem_C:updateItemInfo(_evolutionItems)
  local itemTypeCount = _evolutionItems and #_evolutionItems or 0
  local ChildrenCount = self.itemParent:GetChildrenCount()
  for i = 0, ChildrenCount - 1 do
    local index = i + 1
    local childItem = self.itemParent:GetChildAt(i)
    if i < itemTypeCount then
      local itemData = _evolutionItems[index]
      local itemId = itemData.evolution_need_item
      local itemCfg = itemId > 0 and _G.DataConfigManager:GetBagItemConf(itemId) or nil
      local itemCount = self:getItemCount(itemId)
      self.uiItem.itemIcons[index]:SetData({
        itemId = itemId,
        itemCfg = itemCfg,
        needCount = itemData.number,
        itemCount = itemCount
      })
      childItem:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      childItem:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_PetEvolutionItem_C:getItemCount(_itemId)
  local itemData = _G.NRCModeManager:DoCmd(BagModuleCmd.GetBagItemByID, _itemId)
  if itemData then
    return itemData.num or 0
  end
  return 0
end

function UMG_PetEvolutionItem_C:OnBtnCancelClick()
  _G.NRCAudioManager:PlaySound2DAuto(1006, "UMG_PetEvolutionItem_C:OnBtnCancelClick")
  self:DoClose()
end

function UMG_PetEvolutionItem_C:OnBtnOKClick()
  _G.NRCAudioManager:PlaySound2DAuto(1002, "UMG_PetEvolutionItem_C:OnBtnOKClick")
  NRCModuleManager:DoCmd(PetUIModuleCmd.SendPetEvoluteReq, self.uiData.petData.gid, self.uiData.curEvolutionIndex - 1)
  self:PlayAnimation(self.Disappear)
end

function UMG_PetEvolutionItem_C:OnAnimationFinished(Animation)
  if Animation == self.Disappear then
    self:DoClose()
  end
end

return UMG_PetEvolutionItem_C
