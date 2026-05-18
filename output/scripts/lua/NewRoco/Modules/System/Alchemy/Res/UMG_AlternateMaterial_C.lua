local UMG_AlternateMaterial_C = _G.NRCPanelBase:Extend("UMG_AlternateMaterial_C")

function UMG_AlternateMaterial_C:OnConstruct()
  self:SetChildViews(self.PopUp2)
end

function UMG_AlternateMaterial_C:OnDestruct()
end

function UMG_AlternateMaterial_C:OnActive(bForceSingleChoice)
  _G.NRCAudioManager:PlaySound2DAuto(41400007, "UMG_AlternateMaterial_C:OnConfirm")
  self.FirstSelect = true
  local exchangeId, exchangeNum = _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.GetMaterialItems)
  local exchangeConf = _G.DataConfigManager:GetExchangeConf(exchangeId)
  if not exchangeConf then
    return
  end
  local materialMap = {}
  local costMaterials = _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.GetCostMaterialItems, exchangeId, exchangeNum)
  for _, material in ipairs(costMaterials) do
    materialMap[material.goods_id] = material.goods_num
  end
  local ItemList = {}
  for _, costItem in ipairs(exchangeConf.cost_item) do
    if #costItem.cost_goods_id > 1 then
      local dataList = {}
      for _, goodsId in ipairs(costItem.cost_goods_id) do
        local num = _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.GetMaterialNum, goodsId, costItem.cost_goods_type)
        local itemData = {itemId = goodsId, itemNum = num}
        table.insert(dataList, itemData)
      end
      dataList = _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.GetSortGoodsList, dataList, costItem.cost_goods_type)
      for _, item in ipairs(dataList) do
        local goodsId = item.itemId
        local num = _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.GetMaterialNum, goodsId, costItem.cost_goods_type)
        local itemData = {
          itemId = goodsId,
          itemNum = num,
          needNum = materialMap[goodsId] or 0,
          itemType = costItem.cost_goods_type
        }
        table.insert(ItemList, itemData)
      end
      break
    end
  end
  self.View_List:SetMultipleChoice(not bForceSingleChoice)
  self.View_List:InitGridView(ItemList)
  for i = 1, self.View_List:GetItemCount() do
    local item = self.View_List:GetItemByIndex(i - 1)
    item:SetParent(self)
    if materialMap[item.data.itemId] and item.data.itemNum > 0 then
      self.View_List:SelectItemByIndex(i - 1)
    end
    item:OnItemLostFocus()
  end
  self:OnAddEventListener()
  self:LoadAnimation(0)
  self:AddPcInputBlock()
  self:SetCommonPopUpInfo()
end

function UMG_AlternateMaterial_C:SetCommonPopUpInfo()
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.TitleText = _G.DataConfigManager:GetLocalizationConf("exchange_raw_material").msg
  if self.View_List:GetMultipleChoice() then
    CommonPopUpData.Desc = _G.DataConfigManager:GetLocalizationConf("exchange_change_raw_text").msg
  end
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.OnCancel
  CommonPopUpData.Btn_RightHandler = self.OnConfirm
  CommonPopUpData.ClosePanelHandler = self.OnCancel
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  self.PopUp2:SetPanelInfo(CommonPopUpData)
end

function UMG_AlternateMaterial_C:OnDeactive()
  self:RemovePcInputBlock()
end

function UMG_AlternateMaterial_C:AddPcInputBlock()
end

function UMG_AlternateMaterial_C:RemovePcInputBlock()
end

function UMG_AlternateMaterial_C:OnPcClose()
  self:OnCancel()
end

function UMG_AlternateMaterial_C:OnAddEventListener()
end

function UMG_AlternateMaterial_C:OnConfirm()
  if self:CheckIsSelectBtn() then
    return
  end
  local touchReasonType = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, "AlternateMaterial").Confirm
  _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.LockIsSelectBtn, "AlchemyModule", "AlternateMaterial", touchReasonType)
  _G.NRCAudioManager:PlaySound2DAuto(40008006, "UMG_AlternateMaterial_C:OnConfirm")
  local materialIds = {}
  local selectedItems = self.View_List:GetSelectedItem()
  if self.View_List:GetMultipleChoice() then
    local itemList = {}
    local itemType = _G.Enum.GoodsType.GT_BAGITEM
    for _, item in pairs(selectedItems) do
      itemType = item.data.itemType
      table.insert(itemList, {
        itemId = item.data.itemId,
        itemNum = item.bagItemNum
      })
    end
    itemList = _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.GetSortGoodsList, itemList, itemType)
    for _, item in pairs(itemList) do
      table.insert(materialIds, item.itemId)
    end
  else
    table.insert(materialIds, selectedItems.data.itemId)
  end
  _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.SetExchangeMaterial, materialIds)
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.SetExchangeMaterial)
  self:OnClose()
end

function UMG_AlternateMaterial_C:OnCancel()
  if self:CheckIsSelectBtn() then
    return
  end
  local touchReasonType = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, "AlternateMaterial").CANCEL
  _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.LockIsSelectBtn, "AlchemyModule", "AlternateMaterial", touchReasonType)
  _G.NRCAudioManager:PlaySound2DAuto(40008006, "UMG_AlternateMaterial_C:OnCancel")
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.SetExchangeMaterial)
  self:OnClose()
end

function UMG_AlternateMaterial_C:SetFocusIndex(index)
  if self.FocusIndex and self.FocusIndex > 0 and self.FocusIndex ~= index then
    local item = self.View_List:GetItemByIndex(self.FocusIndex - 1)
    if item and item.OnItemLostFocus then
      item:OnItemLostFocus()
    end
  end
  _G.NRCAudioManager:PlaySound2DAuto(40001001, "UMG_AlternateMaterial_C:OnCancel")
  self.FocusIndex = index
end

function UMG_AlternateMaterial_C:OnClose()
  self:LoadAnimation(2)
end

function UMG_AlternateMaterial_C:OnAnimationFinished(Animation)
  if self:GetAnimByIndex(2) == Animation then
    local touchReasonType1 = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, "AlternateMaterial").Confirm
    _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.UnlockIsSelectBtn, "AlchemyModule", "AlternateMaterial", touchReasonType1)
    local touchReasonType2 = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, "AlternateMaterial").CANCEL
    _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.UnlockIsSelectBtn, "AlchemyModule", "AlternateMaterial", touchReasonType2)
    self:DoClose()
  end
end

function UMG_AlternateMaterial_C:CheckIsSelectBtn()
  return _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetIsSelectBtn, "AlchemyModule", "AlternateMaterial")
end

return UMG_AlternateMaterial_C
