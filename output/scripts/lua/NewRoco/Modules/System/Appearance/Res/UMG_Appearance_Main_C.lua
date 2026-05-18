local AppearanceModuleEvent = require("NewRoco.Modules.System.Appearance.AppearanceModuleEvent")
local UMG_Appearance_Main_C = _G.NRCPanelBase:Extend("UMG_Appearance_Main_C")

function UMG_Appearance_Main_C:OnConstruct()
  self.data = self.module:GetData("AppearanceModuleData")
  self:OnAddEventListener()
  self.SubTitleVisible = true
  self.isItemClick = false
  self.IsPlaySound = true
  self.ClickTime = 0
  self.DelayTime = 500
  self.IsFirstOpenAppearance = false
  self.FirstOpenDelayTime = 0
  self.IsNeedScollToStart = false
  NRCModuleManager:DoCmd(EnvSystemModuleCmd.CustomBloom, self.panelName, true, 1, 1, -1)
  self:SetBackgroundVisible(false)
end

function UMG_Appearance_Main_C:OnActive(itemListInfo, npcAction)
  self.data.curAppearChooseType = _G.Enum.FashionLabelType.FLT_SUIT
  _G.NRCProfilerLog:NRCPanelOpenAnimation(true, self.panelName)
  self:PlayAnimation(self.open)
  self.onlyShowOwned = false
  self.module:CreateAvatarPlayer(npcAction)
  self.itemListInfo = itemListInfo
  if npcAction and npcAction.Owner then
    if npcAction.Owner.owner.config.id == 61006 then
      self.data.bOpenCamping = false
      self.data.onlyShowOwned = false
      local shopTitle = _G.DataConfigManager:GetLocalizationConf("fashion_title_pika").msg
      self.BagTitle:SetText(shopTitle)
    else
      self.data.bOpenCamping = true
      self.data.onlyShowOwned = true
      local shopTitle = _G.DataConfigManager:GetLocalizationConf("fashion_title_molizhiyuan").msg
      self.BagTitle:SetText(shopTitle)
    end
  else
    self.isLocal = true
  end
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:BindInputAction()
end

function UMG_Appearance_Main_C:OnOpenSkillEnd()
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  _G.NRCAudioManager:PlaySound2DAuto(1011, "UMG_Appearance_Main_C:OnConstruct")
end

function UMG_Appearance_Main_C:SetCaptureBackground(TextureTarget)
  self.Background:StartCapture()
  self:SetBackgroundVisible(true)
end

function UMG_Appearance_Main_C:OnDeactive()
  self:UnBindInputAction()
end

function UMG_Appearance_Main_C:OnDestruct()
  NRCModuleManager:DoCmd(EnvSystemModuleCmd.CustomBloom, self.panelName, false, 5, 4, 0)
  self.data:ClearDataOnAppearClosed()
  GlobalConfig.OpenMainPanelFromDebugBtn = 0
end

function UMG_Appearance_Main_C:BindInputAction()
  local imc = UE.UNRCEnhancedInputHelper.GetInputMappingContext("IMC_NpcShop")
  _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.EnhancedInputHelperAddInputMappingContext, imc, self.depth)
  local ia = UE.UNRCEnhancedInputHelper.GetInputAction("IA_CloseNpcShopUI")
  UE.UNRCEnhancedInputHelper.BindAction(ia, UE.ETriggerEvent.Triggered, self, "OnPcClose")
end

function UMG_Appearance_Main_C:UnBindInputAction()
  local ia = UE.UNRCEnhancedInputHelper.GetInputAction("IA_CloseNpcShopUI")
  UE.UNRCEnhancedInputHelper.UnBindAction(ia)
  local imc = UE.UNRCEnhancedInputHelper.GetInputMappingContext("IMC_NpcShop")
  _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.EnhancedInputHelperRemoveInputMappingContext, imc)
end

function UMG_Appearance_Main_C:OnPcClose()
  self:OnCloseBtnClicked()
end

function UMG_Appearance_Main_C:SetConfirmBtnClickable(bClickable)
  if bClickable then
    self.Btn_Confirm:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Btn_Confirm:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  end
end

function UMG_Appearance_Main_C:EnterChatUIPCMode(bEnter)
  if UE4.UNRCPlatformGameInstance.GetInstance():IsPCMode() then
    local player = _G.NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
    if player then
      local playerController = player:GetUEController()
      playerController:ToggleCursor(bEnter)
      player.inputComponent:SetInputEnable(self, not bEnter)
    end
  end
end

function UMG_Appearance_Main_C:SetBackgroundVisible(bVisible)
  if bVisible then
    self.Background:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Background:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Appearance_Main_C:BuyDelayedHit()
  self.Buy_List:SetItemClickAble(false)
  self.isItemClick = true
end

function UMG_Appearance_Main_C:ViewDelayedHit()
  self.View_List:SetItemClickAble(false)
  self.isItemClick = true
end

function UMG_Appearance_Main_C:OnTick(DeltaTime)
  if self.isItemClick then
    self.ClickTime = self.ClickTime + DeltaTime * 1000
    if self.ClickTime >= self.DelayTime then
      self.ClickTime = 0
      if self.Buy_List then
        self.Buy_List:SetItemClickAble(true)
      end
      if self.View_List then
        self.View_List:SetItemClickAble(true)
      end
      self.isItemClick = false
    end
  end
  if not self.IsFirstOpenAppearance then
    self.FirstOpenDelayTime = self.FirstOpenDelayTime + DeltaTime
    if self.FirstOpenDelayTime >= 2.3 then
      self.IsFirstOpenAppearance = true
      self:PlayFirstInAnim()
    end
  end
end

function UMG_Appearance_Main_C:OnAddEventListener()
  self:AddButtonListener(self.CloseBtn.btnClose, self.OnCloseBtnClicked)
  self:AddButtonListener(self.Btn_Confirm.btnLevelUp, self.OnConfirmBtnClicked)
  self:AddButtonListener(self.Btn, self.OnHasBtnClicked)
  self:AddButtonListener(self.Return.btnLevelUp, self.OnReturnBtnClicked)
  self.Return.btnLevelUp.OnPressed:Add(self, self.OnClickBtnPressed)
  self.Return.btnLevelUp.OnReleased:Add(self, self.OnClickBtnReleased)
  self:RegisterEvent(self, AppearanceModuleEvent.AppearanceBuyDelayedHit, self.BuyDelayedHit)
  self:RegisterEvent(self, AppearanceModuleEvent.AppearanceViewDelayedHit, self.ViewDelayedHit)
end

function UMG_Appearance_Main_C:OnCloseBtnClicked()
  if self.isLocal then
    self:OnConfirmBtnClicked()
  end
  local hasChanged = self:HasChanged()
  if hasChanged then
    self.module:OnCmdOpenTips(AppearanceModuleEnum.OpenTipType.FASHION_CLOSE)
  else
    self:ConfirmClose()
  end
end

function UMG_Appearance_Main_C:HasChanged()
  if not self.module then
    return
  end
  self.module:GetTempDataFromAvatar()
  local curIndex = self.data:GetCurSelectWardrobeIndex()
  local wardrobeFashionList = self.data:GetWardrobeDataByIndex(curIndex)
  local SameNum = 0
  local fashionListNum = 0
  local wearNum = 0
  if wardrobeFashionList and #wardrobeFashionList > 0 then
    for k, v in ipairs(wardrobeFashionList) do
      if 0 ~= v then
        fashionListNum = fashionListNum + 1
      end
    end
  end
  if self.data.TempAppearData and #self.data.TempAppearData > 0 then
    for i = 1, #self.data.TempAppearData do
      if 0 ~= self.data.TempAppearData[i].FashionId then
        wearNum = wearNum + 1
      end
      if wardrobeFashionList and #wardrobeFashionList > 0 then
        for k, v in ipairs(wardrobeFashionList) do
          if 0 ~= v and self.data.TempAppearData[i].FashionId == v then
            SameNum = SameNum + 1
          end
        end
      end
    end
  else
    SameNum = 0
  end
  if (0 ~= SameNum and SameNum == fashionListNum or 0 == SameNum and 0 == wearNum and 0 == fashionListNum) and fashionListNum == wearNum then
    return false
  end
  return true
end

function UMG_Appearance_Main_C:ConfirmClose(bNotSave)
  self.module:SyncAvatar2Player()
  local player = _G.NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if self.data.TempAppearData and #self.data.TempAppearData > 0 then
    for k, v in ipairs(self.data.TempAppearData) do
      if v.FashionType == _G.Enum.FashionLabelType.FLT_WAND then
        player:ChangeDefaultWand(v.FashionId)
      end
    end
  end
  if self.module.AvatarPlayer then
    if self.module.bDialogueEnded == true then
      self.module:ChangeSuitConfig(true)
    end
    self.module.AvatarPlayer:BakeToCharacter(player.viewObj)
  end
  self.module:ShowLocalPlayer()
  _G.NRCAudioManager:PlaySound2DAuto(1007, "UMG_Appearance_Main_C:ConfirmClose")
  self:PlayAnimation(self.close)
  self.module:PlayCloseFashionPanelSkill()
  self.module:ConfirmCloseMain()
end

function UMG_Appearance_Main_C:OnConfirmBtnClicked()
  if self.isLocal then
    local player = _G.NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
    if self.module.AvatarPlayer then
      self.module.AvatarPlayer:BakeToCharacter(player.viewObj)
    end
    self:ConfirmClose()
    return
  end
  self.module:OnCmdSendNPCShopBuyReq()
  _G.NRCAudioManager:PlaySound2DAuto(1002, "UMG_Appearance_Main_C:OnConfirmBtnClicked")
end

function UMG_Appearance_Main_C:OnHasBtnClicked()
  self.data.onlyShowOwned = not self.data.onlyShowOwned
  if self.data.onlyShowOwned then
    self.SelectSwitcher:SetActiveWidgetIndex(1)
  else
    self.SelectSwitcher:SetActiveWidgetIndex(0)
  end
  self:UpdateAppearanceList()
  _G.NRCAudioManager:PlaySound2DAuto(1071, "UMG_Appearance_Main_C:OnHasBtnClicked")
end

function UMG_Appearance_Main_C:OnReturnBtnClicked()
  local lastWardrobeData = self.data:GetWardrobeDataByIndex(self.data.lastSelectedWardrobeIndex)
  local SameNum = 0
  local change = false
  self:PlayAnimation(self.Btn_Press)
  if self.data.TempAppearData and #self.data.TempAppearData > 0 then
    for i = 1, #self.data.TempAppearData do
      if lastWardrobeData and #lastWardrobeData > 0 then
        for k, v in ipairs(lastWardrobeData) do
          if 0 ~= v and self.data.TempAppearData[i].FashionId == v then
            SameNum = SameNum + 1
          end
        end
      end
    end
    if SameNum < #self.data.TempAppearData then
      change = true
    else
      change = false
    end
  end
  if change then
    self.data.TempAppearData = nil
    local fashionIds = {}
    local returnText = _G.DataConfigManager:GetLocalizationConf("fashion_return_text").msg
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, returnText)
    if lastWardrobeData and #lastWardrobeData > 0 then
      for k, v in ipairs(lastWardrobeData) do
        if 0 ~= v and self.data and self.data.FashionIdToGoodsIdMap[v] and self.data.FashionIdToGoodsIdMap[v].id then
          local fashionGoodsId = self.data.FashionIdToGoodsIdMap[v].id
          table.insert(fashionIds, v)
          _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.SetAppearance, v, fashionGoodsId, true)
        end
      end
    end
    self.module:SetDefaultSuitAvatar(true, fashionIds)
  else
    local returnText1 = _G.DataConfigManager:GetLocalizationConf("fashion_return_none_text").msg
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, returnText1)
  end
  _G.NRCAudioManager:PlaySound2DAuto(1070, "UMG_Appearance_Main_C:OnReturnBtnClicked")
  self.module:GetTempDataFromAvatar()
  self:RefreshPanelInfo(self.itemListInfo, false)
end

function UMG_Appearance_Main_C:OnClickBtnPressed()
  self.Return:PlayAnimation(self.Return.Press)
end

function UMG_Appearance_Main_C:OnClickBtnReleased()
  self.Return:PlayAnimation(self.Return.Up)
end

function UMG_Appearance_Main_C:RefreshPanelInfo(_itemListInfo, _IsPlaySound, isRefreshNewIcon)
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local itemListInfo, bClicked
  if _itemListInfo then
    itemListInfo = _itemListInfo
  else
    itemListInfo = self.itemListInfo
  end
  self.IsPlaySound = _IsPlaySound
  self.data:SetHasItemList()
  self.itemList = itemListInfo
  self:ShowMoneyInfo()
  self:UpdateCostMoney()
  self:UpdateTab()
  local playerFashionInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerFashionInfo()
  if not self.IsNeedScollToStart then
    bClicked = false
  else
    bClicked = true
  end
  if self.Suit.UpdateList then
    self.Suit:UpdateList(playerFashionInfo, bClicked, self.IsPlaySound, isRefreshNewIcon)
  else
    Log.Error("Suit.UpdateList \228\184\186\231\169\186")
  end
end

function UMG_Appearance_Main_C:UpdateTab()
  local tabConfTable = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.FASHION_TAB_CONF)
  local tabConfDatas = tabConfTable:GetAllDatas()
  local showTable = {}
  for k, v in pairs(tabConfDatas) do
    if v.rank_value and v.rank_value > 0 then
      table.insert(showTable, {
        Order = v.rank_value,
        Type = v.use_FashionLabelType,
        Icon = v.icon
      })
    end
  end
  self.Appearance_Tab1:InitGridView(showTable)
  self.Appearance_Tab1:SelectItemByIndex(0)
end

function UMG_Appearance_Main_C:UpdateAppearanceList(_IsNeedScollToStart)
  local itemList
  if self.data.curAppearChooseType == _G.Enum.FashionLabelType.FLT_XIEWA or self.data.curAppearChooseType == _G.Enum.FashionLabelType.FLT_SHIPIN then
    itemList = self:GetAppearanceData(self.data.curAppearChooseSubType)
    self:ShowSubTitle(true)
  else
    itemList = self:GetAppearanceData(self.data.curAppearChooseType)
    self:ShowSubTitle(false)
  end
  if _IsNeedScollToStart then
    self.IsNeedScollToStart = true
    self.ScrollBoxA:ScrollToStart()
  else
    self.IsNeedScollToStart = false
  end
  self:OpenThroughCamping(self.data.bOpenCamping, itemList)
end

function UMG_Appearance_Main_C:OpenThroughCamping(bCamping, itemList)
  if #itemList > 0 then
    if bCamping then
      self.CampingSwitcher:SetActiveWidgetIndex(1)
      self.View_List:InitGridView(itemList)
      self:ShowMoney(false)
      local selectNum = 0
      if self.data.curAppearChooseType ~= _G.Enum.FashionLabelType.FLT_SUIT then
        selectNum = self:GetCurWearIndex(itemList)
        if selectNum > 0 then
          self.View_List:SelectItemByIndex(selectNum - 1)
        else
          self.View_List:ClearSelection()
        end
      end
    else
      self.CampingSwitcher:SetActiveWidgetIndex(0)
      self.Buy_List:ClearSelection()
      self.Buy_List:InitGridView(itemList)
      self:ShowMoney(true)
      local selectNum = 0
      if self.data.curAppearChooseType ~= _G.Enum.FashionLabelType.FLT_SUIT then
        selectNum = self:GetCurWearIndex(itemList)
        if selectNum > 0 then
          self.Buy_List:SelectItemByIndex(selectNum - 1)
        elseif self.data.curAppearChooseSubType == _G.Enum.FashionLabelType.FLT_WAND then
          self.Buy_List:SelectItemByIndex(0)
        else
          self.Buy_List:ClearSelection()
        end
      end
    end
  else
    self.CampingSwitcher:SetActiveWidgetIndex(2)
    self.Description:SetText(_G.DataConfigManager:GetLocalizationConf("fashion_tab_none").msg)
  end
end

function UMG_Appearance_Main_C:GetCurWearIndex(itemList)
  local selectFahionId = 0
  if self.data.TempAppearData == nil or #self.data.TempAppearData <= 0 then
    return 0
  end
  if self.data.curAppearChooseType == _G.Enum.FashionLabelType.FLT_XIEWA or self.data.curAppearChooseType == _G.Enum.FashionLabelType.FLT_SHIPIN then
    for k, v in ipairs(self.data.TempAppearData) do
      if v.FashionType == self.data.curAppearChooseSubType then
        selectFahionId = v.FashionId
      end
    end
  else
    for k, v in ipairs(self.data.TempAppearData) do
      if v.FashionType == self.data.curAppearChooseType then
        selectFahionId = v.FashionId
      end
    end
  end
  for k, v in ipairs(itemList) do
    if v.FashionId[1] == selectFahionId then
      return k
    end
  end
  return 0
end

function UMG_Appearance_Main_C:ShowMoney(bShow)
  if bShow then
    self.Btn:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Currency:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.MoneyBtn1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.MoneyBtn2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Btn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Currency:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.MoneyBtn1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.MoneyBtn2:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Appearance_Main_C:GetAppearanceData(FashionType)
  local showList = {}
  local hasList = self.data.fashionHasList
  if FashionType == _G.Enum.FashionLabelType.FLT_SUIT then
    local suitTable = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.FASHION_SUITS_CONF)
    local suitData = suitTable:GetAllDatas()
    for i, val in pairs(suitData) do
      if self.module.player.gender == suitData[i].gender then
        local fashionGoodsIdList = {}
        if self.data.onlyShowOwned then
          local hasNum = 0
          for j = 1, #suitData[i].item_id do
            for k, v in ipairs(hasList) do
              if suitData[i].item_id[j] == v then
                hasNum = hasNum + 1
              end
            end
          end
          if hasNum == #suitData[i].item_id then
            for k, v in ipairs(suitData[i].item_id) do
              local goodsId = self.data.FashionIdToGoodsIdMap[v].id
              table.insert(fashionGoodsIdList, goodsId)
            end
          end
          if #fashionGoodsIdList > 0 then
            if hasNum >= #suitData[i].item_id then
              table.insert(showList, {
                FashionId = suitData[i].item_id,
                FashionGoodsId = fashionGoodsIdList,
                SuitIndex = i,
                bOwned = true
              })
            elseif hasNum < #suitData[i].item_id then
              table.insert(showList, {
                FashionId = suitData[i].item_id,
                FashionGoodsId = fashionGoodsIdList,
                SuitIndex = i,
                bOwned = false
              })
            end
          end
        else
          local hasNum = 0
          for j = 1, #suitData[i].item_id do
            for k, v in ipairs(hasList) do
              if suitData[i].item_id[j] == v then
                hasNum = hasNum + 1
              end
            end
          end
          for j = 1, #suitData[i].item_id do
            local goodsId = self.data.FashionIdToGoodsIdMap[suitData[i].item_id[j]].id
            table.insert(fashionGoodsIdList, goodsId)
          end
          if hasNum >= #suitData[i].item_id then
            table.insert(showList, {
              FashionId = suitData[i].item_id,
              FashionGoodsId = fashionGoodsIdList,
              SuitIndex = i,
              bOwned = true
            })
          elseif not (hasNum < #suitData[i].item_id) or true == suitData[i].display_suit or self:CheckSuitHasNotSaleItem(suitData[i].item_id, fashionGoodsIdList) then
          else
            table.insert(showList, {
              FashionId = suitData[i].item_id,
              FashionGoodsId = fashionGoodsIdList,
              SuitIndex = i,
              bOwned = false
            })
          end
        end
      end
    end
  else
    if self.itemList then
      for i = 1, #self.itemList do
        local fashionGoodsConf = _G.DataConfigManager:GetNormalShopConf(self.itemList[i].goods_id)
        if not fashionGoodsConf then
          break
        end
        local fashionItemConf = _G.DataConfigManager:GetFashionItemConf(fashionGoodsConf.item_id)
        if fashionItemConf.type == FashionType and (fashionItemConf.gender ~= Enum.ESexValue.SEX_NOT_SEL and self.module.player.gender == fashionItemConf.gender or fashionItemConf.gender == Enum.ESexValue.SEX_NOT_SEL) then
          if self.data.onlyShowOwned then
            for k, v in ipairs(self.data.fashionHasList) do
              if fashionGoodsConf.item_id == v then
                table.insert(showList, {
                  FashionId = {
                    fashionGoodsConf.item_id
                  },
                  FashionGoodsId = {
                    self.itemList[i].goods_id
                  },
                  bOwned = true
                })
              end
            end
          else
            local hasSame = false
            for k, v in ipairs(self.data.fashionHasList) do
              if fashionGoodsConf.item_id == v then
                hasSame = true
                table.insert(showList, {
                  FashionId = {
                    fashionGoodsConf.item_id
                  },
                  FashionGoodsId = {
                    self.itemList[i].goods_id
                  },
                  bOwned = true
                })
              end
            end
            if false == hasSame and false == fashionItemConf.display_item then
              table.insert(showList, {
                FashionId = {
                  fashionGoodsConf.item_id
                },
                FashionGoodsId = {
                  self.itemList[i].goods_id
                },
                bOwned = false
              })
            end
          end
        end
      end
    end
    for k, hasItemID in ipairs(self.data.fashionHasList) do
      local fashionItemConf = _G.DataConfigManager:GetFashionItemConf(hasItemID)
      if fashionItemConf and fashionItemConf.type == FashionType and self.module.player.gender == fashionItemConf.gender then
        local showListHasItem = false
        for _, fashionGoodsConf in pairs(showList) do
          if fashionGoodsConf.FashionId[1] == hasItemID then
            showListHasItem = true
          end
        end
        if false == showListHasItem and self.data.FashionIdToGoodsIdMap[hasItemID] then
          local goodsId = self.data.FashionIdToGoodsIdMap[hasItemID].id
          table.insert(showList, {
            FashionId = {hasItemID},
            FashionGoodsId = {goodsId},
            bOwned = true
          })
        end
      end
    end
  end
  table.sort(showList, function(a, b)
    return (a.FashionGoodsId[1] or 0) < (b.FashionGoodsId[1] or 0)
  end)
  self.data:SetAppearShopItemList(self.itemList)
  return showList
end

function UMG_Appearance_Main_C:ShowSubTitle(bShow)
  if bShow then
    if self.SubTitleVisible == false then
      self:PlayAnimationReverse(self.state)
    end
    self.SubTitleVisible = true
    local fashionTabId = self.data:GetFashionTabConfByEnum(self.data.curAppearChooseType).id
    local subTypeList = self.data:GetSubTypeFromFashionTabId(fashionTabId)
    if subTypeList and #subTypeList > 0 then
      table.sort(subTypeList, function(a, b)
        return a.rankValue < b.rankValue
      end)
      local showTable = {}
      for k, v in pairs(subTypeList) do
        if v.tabConfId and v.tabConfId > 0 then
          local tabConf = _G.DataConfigManager:GetFashionTabConf(v.tabConfId)
          table.insert(showTable, {
            Order = tabConf.subrank_value,
            Type = tabConf.use_FashionLabelType,
            Icon = tabConf.icon
          })
        end
      end
      self.HorizontalTab1:InitGridView(showTable)
    end
  else
    self.data.curAppearChooseSubType = _G.Enum.FashionLabelType.FLT_BEGIN
    if self.SubTitleVisible == true then
      self:PlayAnimation(self.state)
    end
    self.SubTitleVisible = false
  end
end

function UMG_Appearance_Main_C:UnChooseCrossAnimation()
  self.TabCross:UnChooseAnimation(self.IsPlaySound)
end

function UMG_Appearance_Main_C:SetPlaySoundState(_IsPlaySound)
  self.IsPlaySound = _IsPlaySound
  self.Suit:SetPlaySoundState(_IsPlaySound)
end

function UMG_Appearance_Main_C:SetWardrobeIndex(index)
  self.Suit:SetWardrobeIndex(index)
end

function UMG_Appearance_Main_C:ShowMoneyInfo()
  local npcShopId = self.module:GetShopId()
  local shopConf = _G.DataConfigManager:GetShopConf(tonumber(npcShopId))
  if not shopConf then
    return
  end
  local showMoneyType = shopConf.goods
  for k, v in ipairs(showMoneyType) do
    if v.goods_type == Enum.GoodsType.GT_VITEM then
      if 1 == k then
        local moneyNum1 = _G.DataModelMgr.PlayerDataModel:GetVItemCount(v.goods_id)
        local moneyPath1 = _G.DataConfigManager:GetVisualItemConf(v.goods_id).iconPath
        self.MoneyBtn1:SetInfo(v.goods_id, moneyNum1, false)
        self.MoneyBtn2_A.MoneyIcon:SetPath(moneyPath1)
        self.MoneyBtn2_A.currencyId = v.goods_id
      elseif 2 == k then
        local moneyNum2 = _G.DataModelMgr.PlayerDataModel:GetVItemCount(v.goods_id)
        local moneyPath2 = _G.DataConfigManager:GetVisualItemConf(v.goods_id).iconPath
        self.MoneyBtn2:SetInfo(v.goods_id, moneyNum2, false)
        self.MoneyBtn1_A.MoneyIcon:SetPath(moneyPath2)
        self.MoneyBtn1_A.currencyId = v.goods_id
      end
    end
  end
end

function UMG_Appearance_Main_C:UpdateCostMoney()
  local moneyNum1 = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_DIAMOND) or 0
  local moneyNum2 = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_COIN) or 0
  local diamondCost, coinCost = self.data:SumAppearCostMoney()
  if moneyNum1 < diamondCost then
    self.MoneyBtn2_A.SumNum:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("BA4A4FFF"))
  else
    self.MoneyBtn2_A.SumNum:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("FFFFFFFF"))
  end
  if moneyNum2 < coinCost then
    self.MoneyBtn1_A.SumNum:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("BA4A4FFF"))
  else
    self.MoneyBtn1_A.SumNum:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("FFFFFFFF"))
  end
  self.MoneyBtn2_A.SumNum:SetText(tostring(diamondCost))
  self.MoneyBtn1_A.SumNum:SetText(tostring(coinCost))
end

function UMG_Appearance_Main_C:SelectSuitItemByIndex(index)
  self.Suit:SetWardrobeIndex(index)
end

function UMG_Appearance_Main_C:OnAnimationFinished(anim)
  if anim == self.close then
    if self.isLocal then
      _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.OpenPanelLobbyMain)
    end
    self:DoClose()
  elseif anim == self.open then
    _G.NRCProfilerLog:NRCPanelOpenAnimation(false, self.panelName)
  elseif anim == self.Btn_Press then
    self:PlayAnimation(self.Btn_Recover)
  end
end

function UMG_Appearance_Main_C:LuaOnTouchMoved(dir)
  self.module:SetAvatarRotation(dir.X)
end

function UMG_Appearance_Main_C:ClearListSelection()
  self.View_List:ClearSelection()
  self.Buy_List:ClearSelection()
end

function UMG_Appearance_Main_C:PlayFirstInAnim()
  local itemList = self:GetAppearanceData(self.data.curAppearChooseType)
  if self.data.bOpenCamping then
    self.View_List:InitGridView(itemList)
  else
    self.Buy_List:InitGridView(itemList)
  end
end

function UMG_Appearance_Main_C:CheckSuitHasNotSaleItem(fashionIDs, fashionGoodsIDs)
  for i, fashionID in pairs(fashionIDs) do
    local fashionItemConf = _G.DataConfigManager:GetFashionItemConf(fashionID)
    if fashionItemConf.display_item == true then
      return true
    end
  end
  for i, fashionGoodsID in pairs(fashionGoodsIDs) do
    local fashionGoodsItemConf = _G.DataConfigManager:GetNormalShopConf(fashionGoodsID)
    if not fashionGoodsItemConf then
      return true
    end
    if fashionGoodsItemConf.enable == false then
      return true
    end
  end
  return false
end

return UMG_Appearance_Main_C
