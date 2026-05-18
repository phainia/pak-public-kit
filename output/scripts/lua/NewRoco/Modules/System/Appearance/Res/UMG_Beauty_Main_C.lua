local AppearanceModuleEvent = require("NewRoco.Modules.System.Appearance.AppearanceModuleEvent")
local UMG_Beauty_Main_C = _G.NRCPanelBase:Extend("UMG_Beauty_Main_C")

function UMG_Beauty_Main_C:OnConstruct()
  self:SetChildViews(self.Tab)
  self.data = self.module:GetData("AppearanceModuleData")
  self:OnAddEventListener()
  self.data.SavedBeautyData = {}
  self.isItemClick = false
  self.ClickTime = 0
  self.bShowDecorator = true
  self.ViewItemList = nil
  self.IsPlaySound = true
  self.IsFirstOpenBeauty = false
  self.FirstOpenDelayTime = 0
  self.DelayTime = _G.DataConfigManager:GetGlobalConfigByKeyType("waiguan_item_colddowntime", _G.DataConfigManager.ConfigTableId.GLOBAL_CONFIG).num
end

function UMG_Beauty_Main_C:OnActive(itemListInfo, npcAction)
  self.data.curBeautyChooseType = _G.Enum.SalonLabelType.SLT_SKIN
  _G.NRCProfilerLog:NRCPanelOpenAnimation(true, self.panelName)
  self:PlayAnimation(self.open)
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if itemListInfo then
    self.isLocal = nil == npcAction or nil == npcAction.Owner
    self.itemListInfo = itemListInfo
    self.CloseBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if npcAction then
    self.module:CreateAvatarPlayer(npcAction)
  end
end

function UMG_Beauty_Main_C:OnOpenSkillEnd()
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  _G.NRCAudioManager:PlaySound2DAuto(1011, "UMG_Beauty_Main_C:OnOpenSkillEnd")
  self:ShowDecorators(false, false)
end

function UMG_Beauty_Main_C:OnDeactive()
end

function UMG_Beauty_Main_C:OnAddEventListener()
  self:AddButtonListener(self.CloseBtn.btnClose, self.OnCloseBtnClicked)
  self:AddButtonListener(self.Btn_Confirm.btnLevelUp, self.OnConfirmBtnClicked)
  self:AddButtonListener(self.Btn, self.OnSelectBtnClicked)
  self:RegisterEvent(self, AppearanceModuleEvent.BeautyConfirm, self.ConfirmConfirm)
  self:RegisterEvent(self, AppearanceModuleEvent.BeautyDelayedHit, self.DelayedHit)
  _G.NRCEventCenter:RegisterEvent("UMG_Beauty_Main_C", self, _G.NRCGlobalEvent.ON_DISCONNECT, self.OnDisconnected)
end

function UMG_Beauty_Main_C:OnRemoveEventListener()
  self:UnRegisterEvent(self, AppearanceModuleEvent.BeautyConfirm)
  self:UnRegisterEvent(self, AppearanceModuleEvent.BeautyDelayedHit)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_DISCONNECT, self.OnDisconnected)
end

function UMG_Beauty_Main_C:OnDestruct()
  self.data:ClearDataOnBeautyClosed()
  self:CancelDelay()
  GlobalConfig.OpenMainPanelFromDebugBtn = 0
  self:OnRemoveEventListener()
  self.data.SavedBeautyData = nil
end

function UMG_Beauty_Main_C:OnDisconnected()
  local isChange = self:CompareDataIsChange()
  if not isChange then
    self:ShowDecorators(true, false)
    self.module:BackToWorldBeauty(true)
  end
end

function UMG_Beauty_Main_C:OnCloseBtnClicked()
  if self.isLocal then
    self.module:BackToWorldBeauty(true)
    self:ConfirmClose()
    return
  end
  local isChange = self:CompareDataIsChange()
  if not isChange then
    self:ConfirmClose()
  else
    self.module:OnCmdOpenTips(AppearanceModuleEnum.OpenTipType.SALON_CLOSE)
  end
end

function UMG_Beauty_Main_C:DelayedHit()
  self.View_List:SetItemClickAble(false)
  self.Props_List:SetItemClickAble(false)
  self.isItemClick = true
end

function UMG_Beauty_Main_C:SetPlaySoundState(_IsPlaySound)
  self.IsPlaySound = _IsPlaySound
  for i, ViewItem in ipairs(self.ViewItemList) do
    local Item = self.View_List:GetItemByIndex(i - 1)
    if Item then
      Item:SetPlaySoundState(self.IsPlaySound)
    end
  end
end

function UMG_Beauty_Main_C:OnTick(DeltaTime)
  if self.isItemClick then
    self.ClickTime = self.ClickTime + DeltaTime * 1000
    if self.ClickTime >= self.DelayTime then
      self.ClickTime = 0
      self.Props_List:SetItemClickAble(true)
      self.View_List:SetItemClickAble(true)
      self.isItemClick = false
    end
  end
  if not self.IsFirstOpenBeauty then
    self.FirstOpenDelayTime = self.FirstOpenDelayTime + DeltaTime
    if self.FirstOpenDelayTime >= 1.7 then
      self.IsFirstOpenBeauty = true
      self:PlayFirstInAnim()
    end
  end
end

function UMG_Beauty_Main_C:CompareDataIsChange()
  local tempBeautyData = _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.GetTempAppearOrBeautyData, _G.Enum.GoodsType.GT_SALON)
  if #tempBeautyData ~= #self.data.SavedBeautyData then
    return true
  end
  for i = 1, #tempBeautyData do
    if tempBeautyData[i].SalonId ~= self.data.SavedBeautyData[i].SalonId then
      return true
    end
    if tempBeautyData[i].SalonColorIndex ~= self.data.SavedBeautyData[i].SalonColorIndex then
      return true
    end
    if tempBeautyData[i].SalonGoodsId ~= self.data.SavedBeautyData[i].SalonGoodsId then
      return true
    end
    if tempBeautyData[i].SalonType ~= self.data.SavedBeautyData[i].SalonType then
      return true
    end
  end
  return false
end

function UMG_Beauty_Main_C:ConfirmClose(bNotSaved)
  self:ShowDecorators(true, false)
  self.module:SyncAvatar2Player()
  self:PlayAnimation(self.close)
  self.module:ConfirmCloseBeauty(bNotSaved)
end

function UMG_Beauty_Main_C:OnConfirmBtnClicked()
  if self.isLocal then
    self.module:BackToWorldBeauty(true)
    return
  end
  self.module:OnCmdOpenTips(AppearanceModuleEnum.OpenTipType.SALON_CONFIRM)
  _G.NRCAudioManager:PlaySound2DAuto(1002, "UMG_Beauty_Main_C:ConfirmClose")
end

function UMG_Beauty_Main_C:OnSelectBtnClicked()
  self.bShowDecorator = not self.bShowDecorator
  self:ShowDecorators(self.bShowDecorator, true)
  _G.NRCAudioManager:PlaySound2DAuto(1071, "UMG_Beauty_Main_C:OnSelectBtnClicked")
end

function UMG_Beauty_Main_C:ShowDecorators(bShow, bShowTips)
  local TempAppearData = self.data.TempAppearData
  local decoratorData = {}
  local tipText = _G.DataConfigManager:GetLocalizationConf("salon_checkbox_none_text").msg
  if TempAppearData and #TempAppearData > 0 then
    for k, v in ipairs(TempAppearData) do
      if v.FashionType == _G.Enum.FashionLabelType.FLT_HATS or v.FashionType == _G.Enum.FashionLabelType.FLT_GLASSES then
        table.insert(decoratorData, v.FashionId)
      end
    end
    if #decoratorData > 0 then
      self.data.bShowDecorators = self.bShowDecorator
      if bShow then
        self.SelectSwitcher:SetActiveWidgetIndex(1)
        for k, v in ipairs(decoratorData) do
          self.module:ChangeSkeletalMesh(_G.Enum.GoodsType.GT_FASHION, v, true)
        end
      else
        self.SelectSwitcher:SetActiveWidgetIndex(0)
        for k, v in ipairs(decoratorData) do
          self.module:ChangeSkeletalMesh(_G.Enum.GoodsType.GT_FASHION, v, false)
        end
      end
    elseif true == bShowTips then
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, tipText)
    end
  elseif true == bShowTips then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, tipText)
  end
end

function UMG_Beauty_Main_C:ConfirmConfirm()
  self.module:OnCmdSetSalonDataReq()
  local tempBeautyData = _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.GetTempAppearOrBeautyData, _G.Enum.GoodsType.GT_SALON)
  table.clear(self.data.SavedBeautyData)
  for i = 1, #tempBeautyData do
    table.insert(self.data.SavedBeautyData, {
      SalonColorIndex = tempBeautyData[i].SalonColorIndex,
      SalonGoodsId = tempBeautyData[i].SalonGoodsId,
      SalonId = tempBeautyData[i].SalonId,
      SalonType = tempBeautyData[i].SalonType
    })
  end
end

function UMG_Beauty_Main_C:RefreshPanelInfo(_itemListInfo, _IsPlaySound)
  local itemListInfo
  if _itemListInfo then
    itemListInfo = _itemListInfo
  else
    itemListInfo = self.itemListInfo
  end
  self.itemList = itemListInfo
  self.IsPlaySound = _IsPlaySound
  self:UpdateBeautyList()
  local tempBeautyData = _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.GetTempAppearOrBeautyData, _G.Enum.GoodsType.GT_SALON)
  table.clear(self.data.SavedBeautyData)
  if tempBeautyData and #tempBeautyData > 0 then
    for i = 1, #tempBeautyData do
      table.insert(self.data.SavedBeautyData, {
        SalonColorIndex = tempBeautyData[i].SalonColorIndex,
        SalonGoodsId = tempBeautyData[i].SalonGoodsId,
        SalonId = tempBeautyData[i].SalonId,
        SalonType = tempBeautyData[i].SalonType
      })
    end
  end
  self.Tab:OnBtnSkinClicked(self.IsPlaySound)
end

function UMG_Beauty_Main_C:UpdateBeautyList()
  local itemList
  self.ColorBottle:SetVisibility(UE4.ESlateVisibility.Collapsed)
  itemList = self:GetBeautyData(self.data.curBeautyChooseType)
  self.ViewItemList = itemList
  self.View_List:InitGridView(itemList)
  local chooseFlag = false
  if self.data.TempBeautyData and #self.data.TempBeautyData > 0 then
    for k, v in ipairs(self.data.TempBeautyData) do
      if v.SalonType == self.data.curBeautyChooseType then
        for i = 1, #itemList do
          if itemList[i].SalonId[1] == v.SalonId then
            self.View_List:SelectItemByIndex(i - 1)
            chooseFlag = true
          end
        end
      end
    end
  end
  if false == chooseFlag then
    Log.Error("chooseFlag=false")
    self.View_List:SelectItemByIndex(0)
  end
end

function UMG_Beauty_Main_C:SetBeautyColorList(colorList)
  self.ColorBottle:SetVisibility(UE4.ESlateVisibility.Visible)
  self.Props_List:InitGridView(colorList)
  local salonItemConf = _G.DataConfigManager:GetSalonItemConf(colorList[1].salonId)
  local uiIndex = self.data.ColorIndexToColorIdMap[colorList[1].salonColorIndex].ui_value
  if salonItemConf.type == _G.Enum.SalonLabelType.SLT_HAIR then
    if colorList[1].salonColorIndex >= 0 then
      self.Props_List:SelectItemByIndex(uiIndex)
    else
      self.Props_List:SelectItemByIndex(0)
    end
  elseif colorList[1].salonColorIndex >= 0 then
    if uiIndex > 8 then
      self.Props_List:SelectItemByIndex(uiIndex - 1)
    else
      self.Props_List:SelectItemByIndex(uiIndex)
    end
  else
    self.Props_List:SelectItemByIndex(0)
  end
end

function UMG_Beauty_Main_C:GetBeautyData(beautyType)
  local showList = {}
  if not self.itemList then
    return showList
  end
  for i = 1, #self.itemList do
    local salonGoodsConf = _G.DataConfigManager:GetNormalShopConf(self.itemList[i].goods_id)
    local salonItemConf = _G.DataConfigManager:GetSalonItemConf(salonGoodsConf.item_id)
    if salonItemConf.type == beautyType and (self.module.player.gender == salonItemConf.gender or salonItemConf.gender == Enum.ESexValue.SEX_NOT_SEL) then
      table.insert(showList, {
        SalonId = {
          salonGoodsConf.item_id
        },
        SalonGoodsId = self.itemList[i].goods_id,
        IsPlaySound = self.IsPlaySound
      })
    end
  end
  return showList
end

function UMG_Beauty_Main_C:SetSwitcher()
  if self.data.curBeautyChooseType == _G.Enum.SalonLabelType.SLT_SKIN then
    self.StateSwitcher:SetActiveWidgetIndex(1)
  else
    self.StateSwitcher:SetActiveWidgetIndex(0)
  end
end

function UMG_Beauty_Main_C:PlayFirstInAnim()
  local itemList = self:GetBeautyData(self.data.curBeautyChooseType)
  self.View_List:InitGridView(itemList)
end

function UMG_Beauty_Main_C:OnAnimationFinished(anim)
  if anim == self.close then
    if self.isLocal then
      _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.OpenPanelLobbyMain)
    end
    self:DoClose()
  elseif anim == self.open then
    _G.NRCProfilerLog:NRCPanelOpenAnimation(false, self.panelName)
  end
end

function UMG_Beauty_Main_C:LuaOnTouchMoved(dir)
  self.module:SetAvatarRotation(dir.X)
end

return UMG_Beauty_Main_C
