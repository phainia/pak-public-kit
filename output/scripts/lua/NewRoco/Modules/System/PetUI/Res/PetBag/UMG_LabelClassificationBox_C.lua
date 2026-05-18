local PetUIModuleEvent = require("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_LabelClassificationBox_C = Base:Extend("UMG_LabelClassificationBox_C")
local NPCShopUtils = require("NewRoco.Modules.System.NPCShopUI.NPCShopUtils")
local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
UMG_LabelClassificationBox_C.LineType = {
  None = 0,
  FrontLine = 1,
  BehindLine = 2
}

function UMG_LabelClassificationBox_C:OnConstruct()
  self.ModifyBtn.btnLevelUp.OnClicked:Add(self, self.OnRenameBtnClick)
  if self and self.AddButton then
    self.AddButton.OnClicked:Add(self, self.OnClickedAddButton)
  end
  local Module = NRCModuleManager:GetModule("PetUIModule")
  if Module then
    Module:RegisterEvent(self, PetUIModuleEvent.OnAddOrRemoveItemFromFreeList, self.OnAddOrRemoveItemFromFreeList)
    Module:RegisterEvent(self, PetUIModuleEvent.OnFreeListClear, self.OnFreeListClear)
    Module:RegisterEvent(self, PetUIModuleEvent.OnAllBoxFreeNumListUpdate, self.OnAllBoxFreeNumListUpdate)
  end
  self.maxNameLength = _G.DataConfigManager:GetPetGlobalConfig("box_name_length").num
end

function UMG_LabelClassificationBox_C:OnDestruct()
  self.ModifyBtn.btnLevelUp.OnClicked:Remove(self, self.OnRenameBtnClick)
  if self and self.AddButton then
    self.AddButton.OnClicked:Remove(self, self.OnClickedAddButton)
  end
  local Module = NRCModuleManager:GetModule("PetUIModule")
  if Module then
    Module:UnRegisterEvent(self, PetUIModuleEvent.OnAddOrRemoveItemFromFreeList, self.OnAddOrRemoveItemFromFreeList)
    Module:UnRegisterEvent(self, PetUIModuleEvent.OnFreeListClear, self.OnFreeListClear)
    Module:UnRegisterEvent(self, PetUIModuleEvent.OnAllBoxFreeNumListUpdate, self.OnAllBoxFreeNumListUpdate)
  end
end

function UMG_LabelClassificationBox_C:OnDespawn()
  if self.NRCImage and self.NRCImage_30 then
    self.NRCImage:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#FFFFFF05"))
    self.NRCImage_30:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#1F1F1FFF"))
  end
end

function UMG_LabelClassificationBox_C:OnTouchStarted(_MyGeometry, _TouchEvent)
  Base.OnTouchStarted(self, _MyGeometry, _TouchEvent)
  if self.bEditItem and self.parent then
    local screenPos = UE4.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(_TouchEvent)
    self.parent:OnBoxTouchStarted(screenPos)
  end
  self:OnSortingBtnPressed()
  return UE4.UWidgetBlueprintLibrary.UnHandled()
end

function UMG_LabelClassificationBox_C:OnDeactive()
end

function UMG_LabelClassificationBox_C:OnItemUpdate(_data, datalist, index)
  self:StopAnimation(self.Select_In)
  self.data = _data.boxInfo
  self.bEditItem = _data.bEditItem
  self.parent = _data.parent
  self.index = index
  self.bSelected = false
  self.boxInfo = self.data.petBoxInfo
  self.petCellNumber, self.petCellMaxNumber = self:GetBoxCell()
  self.mark_type = self.boxInfo and self.boxInfo.mark_type or _G.Enum.WarehouseMarkType.WMT_DEFAULT
  self.warehouseConf = _G.DataConfigManager:GetPetWarehouseConf(self.data.id)
  self.collectConf = self:GetCollectMarkConfigByType(self.mark_type)
  self.BoxSwitcher:SetActiveWidgetIndex(self.data.isLock and 1 or 0)
  self.DragDisplay:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.box_name = self.warehouseConf.warehouse_default_name
  if self.boxInfo and self.boxInfo.box_name and self.boxInfo.box_name ~= "" then
    self.box_name = self.boxInfo.box_name
  end
  self:SetBoxName(self.box_name)
  if self.boxInfo then
    self.QuantityText_1:SetText(self.boxInfo.box_id)
  end
  self.MarkIcon:SetPath(self.collectConf.mark_flat_icon)
  self.QuantityText:SetText(string.format("%d/%d", self.petCellNumber, self.petCellMaxNumber))
  self.Mask:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ModifyBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.BoxText_1:SetText(LuaText.warehouse_unlock_new_one)
  self.BoxText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#F4EEE1FF"))
  self.QuantityText_1:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#F4EEE0FF"))
  if self.NRCImage and self.NRCImage_30 then
    self.NRCImage:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#FFFFFF05"))
    self.NRCImage_30:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#1F1F1FFF"))
  end
  self:UpdateFreeInfoView()
  if self.data.isLock then
    self:SetClickable(false)
    self.CanvasPanel_Money:SetVisibility(UE4.ESlateVisibility.Collapsed)
    local rules = self.warehouseConf.unlock_rule
    for i = 1, #rules do
      local rule = rules[i]
      if rule.unlockcondition == _G.Enum.WarehouseUnlockCondition.WUC_EXPEND_MONEY then
        self.CanvasPanel_Money:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self.unlockCurrencyNum = rule.value
        self.CurrencyQuantityText:SetText(rule.value)
        local iconPath, _ = NPCShopUtils:GetGoodsCurrencyIconByType(_G.Enum.GoodsType.GT_VITEM, rule.unlock_vitem_type)
        if iconPath then
          self.CurrencyIcon:SetPath(iconPath)
        end
        break
      end
    end
  else
    self:SetClickable(true)
  end
  if self.bEditItem then
    if self.parent and self.parent.DragBoxInfo and self.boxInfo and self.boxInfo.box_id and self.parent.DragBoxInfo.box_id == self.boxInfo.box_id then
      self.Mask:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    self.BtnSwitcher:SetActiveWidgetIndex(1)
    self.ModifyBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.BtnSwitcher:SetActiveWidgetIndex(0)
    if 0 == self.petCellNumber then
      if self.mark_type == _G.Enum.WarehouseMarkType.WMT_DEFAULT then
        self.BoxText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#605E5CFF"))
        self.MarkIcon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/PetUI/PetUIStatic/Frames/img_Mark0_Flat_png.img_Mark0_Flat_png'")
      end
      self.QuantityText_1:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#62605EFF"))
    end
    if self.parent and not self.parent.CanScroll and not self:CheckHasEmptyPos() and not self:CheckIsLock() then
      self:OnDisableDragPetTo(true)
    end
  end
  if self.Line and self.Line2 then
    self.Line:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Line2:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_LabelClassificationBox_C:SetBoxName(boxName)
  local newName = string.ExtraLongAndOmittedWithWidth(boxName, self.maxNameLength)
  self.BoxText:SetText(newName)
end

function UMG_LabelClassificationBox_C:OnItemSelected(_bSelected)
  if self.bEditItem or _bSelected == self.bSelected then
    return
  end
  self:StopAnimation(self.Select_In)
  self.bSelected = _bSelected
  if _bSelected then
    self:PlayAnimation(self.Select_In)
    self.QuantityText_1:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#F4EEE0FF"))
    if not self.data.isLock then
      if self.mark_type and self.mark_type == _G.Enum.WarehouseMarkType.WMT_DEFAULT then
        self.MarkIcon:SetPath(self.collectConf.mark_small_flat_icon)
      end
      _G.NRCAudioManager:PlaySound2DAuto(40002006, "UMG_LabelClassificationBox_C:OnItemSelected")
      local petUIModule = _G.NRCModuleManager:GetModule("PetUIModule")
      if petUIModule:GetLastOpenBoxId() ~= self.boxInfo.box_id then
        petUIModule:DispatchEvent(PetUIModuleEvent.OnClickSelectPetBagBoxItem, self.data, self.index)
      end
    end
    self.ModifyBtn:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    if self.NRCImage and self.NRCImage_30 then
      self.NRCImage:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#FFFFFF05"))
      self.NRCImage_30:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#1F1F1FFF"))
    end
    if 0 == self.petCellNumber then
      self.BoxText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#605E5CFF"))
    else
      self.BoxText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#F4EEE1FF"))
    end
    self.ModifyBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if not self.data.isLock then
      if self.mark_type and self.mark_type == _G.Enum.WarehouseMarkType.WMT_DEFAULT then
        if 0 == self.petCellNumber then
          self.MarkIcon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/PetUI/PetUIStatic/Frames/img_Mark0_Flat_png.img_Mark0_Flat_png'")
        else
          self.MarkIcon:SetPath(self.collectConf.mark_flat_icon)
        end
      end
      if 0 == self.petCellNumber then
        self.QuantityText_1:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#62605EFF"))
      end
    end
  end
end

function UMG_LabelClassificationBox_C:OnAnimationFinished(Anim)
  if Anim == self.Select_In and 0 == self.petCellNumber then
    self.BoxText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#605E5CFF"))
  end
end

function UMG_LabelClassificationBox_C:UpdateFreeInfoView()
  if self.data then
    local FreeNum = _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.GetBoxFreePetNumInPortableBag, self.data.id)
    if self.CurrencyQuantityText_2 then
      self.CurrencyQuantityText_2:SetText("x" .. tostring(FreeNum))
    end
    if self.CanvasPanel_ReleaseLife then
      self.CanvasPanel_ReleaseLife:SetVisibility(FreeNum > 0 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_LabelClassificationBox_C:OnAddOrRemoveItemFromFreeList(isAdd, petData)
  self:UpdateFreeInfoView()
end

function UMG_LabelClassificationBox_C:OnFreeListClear()
  self:UpdateFreeInfoView()
end

function UMG_LabelClassificationBox_C:OnAllBoxFreeNumListUpdate()
  self:UpdateFreeInfoView()
end

function UMG_LabelClassificationBox_C:GetCollectMarkConfigByType(type)
  local confs = _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.GetAllWarehousCollectMarkConfigs)
  for _, conf in pairs(confs) do
    if conf.mark_type == type then
      return conf
    end
  end
  return nil
end

function UMG_LabelClassificationBox_C:OnRenameBtnClick()
  if self.data then
    _G.NRCAudioManager:PlaySound2DAuto(40002003, "UMG_LabelClassificationBox_C:OnRenameBtnClick")
    _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OpenNetPetBagMarkWarehousePanel, {
      id = self.data.id,
      mark_type = self.mark_type,
      box_name = self.box_name
    })
  end
end

function UMG_LabelClassificationBox_C:OnSortingBtnPressed()
  if not self.bEditItem then
    return
  end
  if self.boxInfo then
    self.Mask:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OnCmdBoxDragStart, self.boxInfo)
  end
end

function UMG_LabelClassificationBox_C:OnClickedAddButton()
  if self.data.isLock then
    _G.NRCAudioManager:PlaySound2DAuto(40002003, "UMG_LabelClassificationBox_C:OnItemSelected")
    self:OpenRemindPanel()
  end
end

function UMG_LabelClassificationBox_C:UpdateMarkIconAndName(mark_type, box_name)
  if mark_type then
    self.mark_type = mark_type
    self.box_name = box_name
    if self.boxInfo then
      self.boxInfo.mark_type = mark_type
      self.boxInfo.box_name = box_name
    end
    self:SetBoxName(self.box_name)
    local conf = self:GetCollectMarkConfigByType(mark_type)
    if conf then
      self.collectConf = conf
      local icon = conf.mark_flat_icon
      if self.mark_type and self.mark_type == _G.Enum.WarehouseMarkType.WMT_DEFAULT and self.bSelected then
        icon = conf.mark_small_flat_icon
      end
      if icon then
        self.MarkIcon:SetPath(icon)
      end
    end
  end
end

function UMG_LabelClassificationBox_C:OpenRemindPanel()
  local checkPass, _ = self:CheckCanUnlock()
  local iconPath, coinNum, coinType = self:GetCoinInfo()
  local popUpData = _G.NRCCommonPopUpData()
  if checkPass then
    if iconPath and coinNum then
      popUpData.Btn_RightTitle = {MoneyIcon = iconPath, QuantityText = coinNum}
    end
    popUpData.Btn_RightText = LuaText.umg_bag_11
    popUpData.Btn_RightHandler = self.UnlockBox
  elseif iconPath and coinNum then
    if coinType == _G.Enum.VisualItem.VI_COUPON then
      popUpData.Btn_RightTitle = {
        MoneyIcon = iconPath,
        QuantityText = coinNum,
        Color = "#C7494AFF"
      }
      popUpData.Btn_RightText = LuaText.umg_bag_11
      popUpData.Btn_RightHandler = self.OpenPopUpTips
    else
      popUpData.Btn_GrayStateTitle = {
        MoneyIcon = iconPath,
        QuantityText = coinNum,
        Color = "#C7494AFF"
      }
      popUpData.Btn_GrayStateText = LuaText.umg_bag_11
      popUpData.Btn_GrayStateHandler = self.UnlockBox
    end
  end
  if coinType then
    local IsShowBuyIcon = false
    if coinType == _G.Enum.VisualItem.VI_COUPON or coinType == _G.Enum.VisualItem.VI_DIAMOND then
      IsShowBuyIcon = true
    end
    local totalNum = self:GetCoinNum(coinType)
    local moneyInfo = {
      {
        moneyType = coinType,
        sum = totalNum,
        IsShowBuyIcon = IsShowBuyIcon,
        currencyId = coinType
      }
    }
    popUpData.MoneyInfo = moneyInfo
  end
  popUpData.Call = self
  popUpData.Btn_LeftText = LuaText.CANCEL
  popUpData.TitleText = LuaText.warehouse_buy_new_one
  popUpData.ContentText = self:GetRemindDesc()
  _G.NRCModuleManager:DoCmd(_G.CommonPopUpModuleCmd.OpenRemindPanel, popUpData)
end

function UMG_LabelClassificationBox_C:OpenPopUpTips()
  local Ctx = DialogContext()
  local _, coinNum, coinType = self:GetCoinInfo()
  if coinNum and coinType then
    local itemConf = _G.DataConfigManager:GetVisualItemConf(coinType)
    if itemConf and itemConf.displayName then
      Ctx:SetTitle(LuaText.TIPS)
      Ctx:SetContent(string.format(LuaText.Recharge_Tips3, coinNum, itemConf.displayName))
      Ctx:SetMode(DialogContext.Mode.OK_CANCEL)
      Ctx:SetCallbackOkOnly(self, self.OpenTopUpShop)
      Ctx:SetCloseOnCancel(true)
      Ctx:SetButtonText(LuaText.YES, LuaText.NO)
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Ctx)
    end
  end
end

function UMG_LabelClassificationBox_C:OpenTopUpShop()
  _G.NRCModuleManager:DoCmd(_G.ShopModuleCmd.OnCmdOpenTopUpShop, true)
end

function UMG_LabelClassificationBox_C:GetCoinNum(VItemType)
  local coin_num = _G.DataModelMgr.PlayerDataModel:GetVItemCount(VItemType) or 0
  return coin_num
end

function UMG_LabelClassificationBox_C:GetRemindDesc()
  if self.warehouseConf then
    local rules = self.warehouseConf.unlock_rule
    local Desc = string.format("%s\n", LuaText.warehouse_unlock_condition)
    for _, rule in pairs(rules or {}) do
      if rule and rule.unlock_rule_text and rule.value then
        if not Desc then
          Desc = string.format(rule.unlock_rule_text, rule.value)
        else
          local str = string.format(rule.unlock_rule_text, rule.value)
          Desc = string.format([[
%s
%s]], Desc, str)
        end
      end
    end
    return Desc
  end
  return ""
end

function UMG_LabelClassificationBox_C:UnlockBox()
  local checkPass, reason = self:CheckCanUnlock()
  if checkPass then
    if self.data and self.data.id then
      _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OnCmdZonePetBoxUnlockReq, self.data.id)
    end
  elseif reason then
    if reason == _G.Enum.WarehouseUnlockCondition.WUC_EXPEND_MONEY then
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.umg_npcshopitem_1_1)
    elseif reason == _G.Enum.WarehouseUnlockCondition.WUC_RECORD_PET then
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.warehouse_unlock_not_enough_pet)
    end
  end
end

function UMG_LabelClassificationBox_C:CheckCanUnlock()
  if self.data and self.data.isLock then
    local rules = self.warehouseConf.unlock_rule
    for _, rule in pairs(rules or {}) do
      if rule.unlockcondition == _G.Enum.WarehouseUnlockCondition.WUC_EXPEND_MONEY then
        local coinNum = self:GetCoinNum(rule.unlock_vitem_type)
        if coinNum < rule.value then
          return false, _G.Enum.WarehouseUnlockCondition.WUC_EXPEND_MONEY
        end
      elseif rule.unlockcondition == _G.Enum.WarehouseUnlockCondition.WUC_RECORD_PET then
        local collectedPetsNum = _G.NRCModuleManager:DoCmd(_G.HandbookModuleCmd.GetHandbookCollectedPetsNum)
        if collectedPetsNum < rule.value then
          return false, _G.Enum.WarehouseUnlockCondition.WUC_RECORD_PET
        end
      end
    end
    return true
  end
  return false
end

function UMG_LabelClassificationBox_C:GetCoinInfo()
  if self.data and self.data.isLock then
    local rules = self.warehouseConf.unlock_rule
    for _, rule in pairs(rules or {}) do
      if rule.unlockcondition == _G.Enum.WarehouseUnlockCondition.WUC_EXPEND_MONEY then
        local coinNum = rule.value
        local iconPath, _ = NPCShopUtils:GetGoodsCurrencyIconByType(_G.Enum.GoodsType.GT_VITEM, rule.unlock_vitem_type)
        return iconPath, coinNum, rule.unlock_vitem_type
      end
    end
  end
  return nil, nil, nil
end

function UMG_LabelClassificationBox_C:ReadyDragPetToBox(bDrag)
  if bDrag then
    self.DragDisplay:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.DragDisplay:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_LabelClassificationBox_C:CheckHasEmptyPos()
  if self.petCellNumber and self.petCellMaxNumber and self.petCellMaxNumber - self.petCellNumber > 0 then
    return true
  end
  return false
end

function UMG_LabelClassificationBox_C:GetEmptyPos()
  if self:CheckHasEmptyPos() and self.boxInfo then
    for pos, pet in pairs(self.boxInfo.pet_gid or {}) do
      if 0 == pet then
        return self.boxInfo.box_id, pos
      end
    end
  end
  return nil, nil
end

function UMG_LabelClassificationBox_C:CheckIsLock()
  if self.data then
    return self.data.isLock
  end
  return false
end

function UMG_LabelClassificationBox_C:OnDisableDragPetTo(bDisable)
  if bDisable then
    self.Mask:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Mask:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_LabelClassificationBox_C:OnDrag(box_info)
  if box_info then
    self.boxInfo = box_info
    local mark_type = box_info.mark_type or _G.Enum.WarehouseMarkType.WMT_DEFAULT
    local warehouseConf = _G.DataConfigManager:GetPetWarehouseConf(box_info.box_id)
    local collectConf = self:GetCollectMarkConfigByType(mark_type)
    local boxName = warehouseConf.warehouse_default_name
    if self.boxInfo.box_name and self.boxInfo.box_name ~= "" then
      boxName = self.boxInfo.box_name
    end
    self.BoxSwitcher:SetActiveWidgetIndex(0)
    self.BtnSwitcher:SetActiveWidgetIndex(1)
    self:SetBoxName(boxName)
    self.MarkIcon:SetPath(collectConf.mark_flat_icon)
    self.petCellNumber, self.petCellMaxNumber = self:GetBoxCell()
    self.QuantityText:SetText(string.format("%d/%d", self.petCellNumber, self.petCellMaxNumber))
    self.QuantityText_1:SetText(box_info.box_id)
    self.Mask:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.DragDisplay:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_LabelClassificationBox_C:ReadyDragTo(bReady, lineType)
  if self.bReadyToDrag == bReady and self.curLineType == lineType then
    return
  end
  self.bReadyToDrag = bReady
  if self.curLineType and self.curLineType ~= lineType then
    if self.curLineType == self.LineType.FrontLine then
      self:StopAnimation(self.red_line_in)
      if not self:IsAnimationPlaying(self.red_line_Out) then
        self:PlayAnimation(self.red_line_Out)
      end
    elseif self.curLineType == self.LineType.BehindLine then
      self:StopAnimation(self.red_line_in_R)
      if not self:IsAnimationPlaying(self.red_line_Out_R) then
        self:PlayAnimation(self.red_line_Out_R)
      end
    end
  end
  self.curLineType = lineType
  if bReady then
    if self.curLineType == self.LineType.FrontLine then
      self:StopAnimation(self.red_line_Out)
      if not self:IsAnimationPlaying(self.red_line_in) then
        self.Line:SetVisibility(UE4.ESlateVisibility.Visible)
        self:PlayAnimation(self.red_line_in)
      end
    elseif self.curLineType == self.LineType.BehindLine then
      self:StopAnimation(self.red_line_Out_R)
      if not self:IsAnimationPlaying(self.red_line_in_R) then
        self.Line2:SetVisibility(UE4.ESlateVisibility.Visible)
        self:PlayAnimation(self.red_line_in_R)
      end
    end
  else
    self.curLineType = self.LineType.None
  end
end

function UMG_LabelClassificationBox_C:GetBoxCell()
  if self.boxInfo and self.boxInfo.pet_gid then
    local emptyCell = 0
    local maxCell = 0
    for _, gid in pairs(self.boxInfo.pet_gid) do
      if 0 == gid then
        emptyCell = emptyCell + 1
      end
      maxCell = maxCell + 1
    end
    return maxCell - emptyCell, maxCell
  end
  return 0, 0
end

return UMG_LabelClassificationBox_C
