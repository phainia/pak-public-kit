local NPCShopUIModuleEvent = reload("NewRoco.Modules.System.NPCShopUI.NPCShopUIModuleEvent")
local NPCActionOpenShop = require("NewRoco.Modules.Core.NPC.Actions.NPCActionOpenShop")
local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local NPCShopUIModuleEnum = require("NewRoco.Modules.System.NPCShopUI.NPCShopUIModuleEnum")
local NPCShopUtils = require("NewRoco.Modules.System.NPCShopUI.NPCShopUtils")
local ENUM_PLAYER_DATA_EVENT = require("Data.Global.PlayerDataEvent")
local BagModuleEvent = reload("NewRoco.Modules.System.Bag.BagModuleEvent")
local UMG_NPCShop_PlantAcquisition_C = _G.NRCPanelBase:Extend("UMG_NPCShop_PlantAcquisition_C")

function UMG_NPCShop_PlantAcquisition_C:OnConstruct()
  self.uiData = {}
  self.uiData.CurrentSelectedTotalNum = 0
  self.uiData.SellableTotalLimitNum = 0
  self.data = self.module:GetData("NPCShopUIModuleData")
  local Action = self.data and self.data.NPCActionOpenShop
  if Action then
    local NPC = Action:GetOwnerNPC()
    if NPC then
      self.animComp = NPC:GetAnimComponent()
    end
  end
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1069, "UMG_NPCShop_PlantAcquisition_C:OnConstruct")
  self.hasStopTick = false
  self:OnAddEventListener()
  self:InitText()
  local sellingAwardMoneyType = _G.Enum.VisualItem.VI_COIN
  local vItemConf = _G.DataConfigManager:GetVisualItemConf(sellingAwardMoneyType)
  if vItemConf then
    self.CurrencyIcon:SetPath(vItemConf.iconPath)
  end
  self.curSelectedIndex = 0
  _G.NRCEventCenter:RegisterEvent("UMG_NPCShop_PlantAcquisition_C", self, DialogueModuleEvent.DialogueEnded, self.OnCloseVisit)
end

function UMG_NPCShop_PlantAcquisition_C:OnDestruct()
  self.uiData = nil
  if 0 == GlobalConfig.OpenMainPanelFromDebugBtn and self.data.NPCActionOpenShop and self.data.NPCActionOpenShop.Owner.owner.viewObj then
    local nameComponent = self.data.NPCActionOpenShop.Owner.owner.viewObj:GetComponentByClass(UE4.URocoWidgetComponent)
    if nameComponent then
      nameComponent:SetComponentTickEnabled(true)
      nameComponent:SetRenderStatus(true, MainUIModuleEnum.DisableHudOpSource.EnterNpcShop)
    end
    self.data.NPCActionOpenShop.Owner.owner:SetVisible(true)
  end
  self:RestoreHudStatus()
  _G.NRCEventCenter:UnRegisterEvent(self, DialogueModuleEvent.DialogueEnded, self.OnCloseVisit)
  self:OnRemoveEventListener()
  self:StartCaptureTick(false)
end

function UMG_NPCShop_PlantAcquisition_C:OnActive(param0, param, param1, param2, bIsRefreshNPCShop, ...)
  self.NPCAction = param.NPCAction
  self.CanUpdate = true
  local IsRefreshNPCShop = bIsRefreshNPCShop
  local shopId = tonumber(param0)
  self.data:SetNPCContentID(self.NPCAction, shopId)
  self:OnReceiveShopData(shopId, param1, true)
  if not IsRefreshNPCShop then
    self:PlayAnimation(self.open)
  end
  if 0 == GlobalConfig.OpenMainPanelFromDebugBtn and self.data.NPCActionOpenShop then
    local npcActionOpenShop = self.data.NPCActionOpenShop
    local owner = npcActionOpenShop and npcActionOpenShop.Owner and npcActionOpenShop.Owner.owner
    owner:LockVisibility(true)
    local viewObj = owner and owner.viewObj
    if UE4.UObject.IsValid(viewObj) and viewObj.Mesh then
      UE4.UNRCStatics.ForceUpdateStreamingAssets(viewObj.Mesh.SkeletalMesh, 3)
      viewObj.Mesh:SetForcedLOD(1)
    end
  end
  local OpenNpcShopType = self.data:GetOpenNpcShopType()
  local NPCShoTypeEnum = NPCShopUIModuleEnum.OpenNPCShopFormType
  UE4.ACharacterStatusComputeActor.SetTickEnabled(false)
  local bCaptureNPC = self.data.NPCActionOpenShop and self.animComp
  if not bCaptureNPC and not IsRefreshNPCShop then
    self.previewImage:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:OnItemSelected(false, true)
  end
  if OpenNpcShopType ~= NPCShoTypeEnum.MagicManualMain and not IsRefreshNPCShop then
    self:CaptureBackgroundAndNPC(true)
  end
  _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.ForceSetLensFlaresActorVisibility, false)
end

function UMG_NPCShop_PlantAcquisition_C:CaptureBackgroundAndNPC(bCaptureNPC)
  if bCaptureNPC then
    self:StartCaptureTick(true)
    self.previewImage:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.UMG_CaptureBackground:SetVisibility(UE4.ESlateVisibility.Collapsed)
    
    local function waitUntilNpcCaptureFinished(InSelf)
      self.previewImage:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self:StartCaptureTick(false)
      
      local function splitHideAndStopCapture()
        if 0 == GlobalConfig.OpenMainPanelFromDebugBtn and self.data.NPCActionOpenShop then
          local npc = self.data.NPCActionOpenShop.Owner.owner
          if npc then
            npc:SetVisible(false)
          end
        end
        self.UMG_CaptureBackground:StartCapture()
        
        local function waitUntilBGCaptureFinished()
          local FillBackgroundMat = "Material'/Game/ArtRes/Material/UI/MI_UI_FIllBackground.MI_UI_FIllBackground'"
          self:LoadPanelRes(FillBackgroundMat, 255, function(caller, resRequest, asset)
            local UICameraClass = _G.NRCBigWorldPreloader:Get("DialogueUICamera")
            local CameraActor = UE4.UGameplayStatics.GetActorOfClass(UE4Helper.GetCurrentWorld(), UICameraClass)
            local CameraCom = CameraActor and CameraActor:GetComponentByClass(UE4.UCameraComponent)
            if CameraCom then
              CameraCom:AddOrUpdateBlendable(asset, 1.0)
            end
            self:SetDialogueUICameraCullingMask(128, true)
            self:SetActorCullingMask(128, true)
            
            local function HideOldNPCCapture()
              if 0 == GlobalConfig.OpenMainPanelFromDebugBtn and self.data.NPCActionOpenShop then
                local npc = self.data.NPCActionOpenShop.Owner.owner
                if npc then
                  npc:SetVisible(true)
                end
              end
              self.previewImage:SetVisibility(UE4.ESlateVisibility.Collapsed)
            end
            
            self:DelayFrames(2, HideOldNPCCapture, self)
          end, nil, nil)
        end
        
        self:DelayFrames(3, waitUntilBGCaptureFinished, self)
      end
      
      self:DelayFrames(1, splitHideAndStopCapture, self)
    end
    
    self:DelayFrames(3, waitUntilNpcCaptureFinished, self)
  else
    self.previewImage:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.UMG_CaptureBackground:StartCapture()
    
    local function OnCaptureBackgroundDone()
      self.UMG_CaptureBackground:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    
    self:DelayFrames(3, OnCaptureBackgroundDone, self)
  end
end

function UMG_NPCShop_PlantAcquisition_C:OnDeactive()
  GlobalConfig.OpenMainPanelFromDebugBtn = 0
  self:ReleaseCaptureResource()
  _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.ForceSetLensFlaresActorVisibility, true)
  UE4.ACharacterStatusComputeActor.SetTickEnabled(true)
end

function UMG_NPCShop_PlantAcquisition_C:OnReceiveShopData(shopId, _rsp, bOnActive)
  self.data = self.module:GetData("NPCShopUIModuleData")
  self.uiData = {}
  local shopConf = _G.DataConfigManager:GetShopConf(shopId)
  if shopConf then
    self.Title1:SetSubtitle(shopConf.shop_name)
    if shopConf.shop_icon then
      self.Title1:SetBg(shopConf.shop_icon)
    end
  end
  local itemList1 = self:GenerateCustomInfo(_rsp, shopId)
  self.uiData.itemList1 = itemList1
  self.uiData.shopId = shopId
  self:updatePanelInfo(bOnActive)
end

function UMG_NPCShop_PlantAcquisition_C:updatePanelInfo(bOnActive)
  self.ItemList:InitList(self.uiData.itemList1)
  self.ItemList:NRCScrollToStart()
  self.curSelectedIndex = 0
  self:UpdateDetailPanel()
  self:ShowMoney()
  self:CheckSelectAllButton(true)
  self:DoSumSellingPrice()
  local count = self.ItemList:GetItemCount()
  local randomNum = math.round(math.rand(1, 3))
  for i = 1, count do
    self.ItemList:OpItemByIndex(i, 1, randomNum)
  end
end

function UMG_NPCShop_PlantAcquisition_C:GenerateCustomInfo(rsp, shopId)
  local itemDataArray = {}
  self.uiData.ShopInfoRsp = rsp
  if not (rsp and rsp.shop_data) or not rsp.shop_data.goods_data then
    return itemDataArray
  end
  local allPlantGrowConf = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.PLANT_GROW_CONF):GetAllDatas()
  local myHomeLevel = 0
  local localHomeBriefInfo = _G.HomeIndoorSandbox.Server:GetLocalHomeBriefInfo()
  if localHomeBriefInfo then
    myHomeLevel = localHomeBriefInfo.home_level or 0
  end
  local ItemNeedShow = {}
  local unlockHomeLevel = table.new(0, 32)
  for itemId, plantGrowConf in pairs(allPlantGrowConf) do
    if plantGrowConf.plant_harvest then
      unlockHomeLevel[plantGrowConf.plant_harvest] = plantGrowConf.home_lv
    end
    local itemNum
    local bagItemData = _G.NRCModuleManager:DoCmd(BagModuleCmd.GetBagItemByID, plantGrowConf.plant_harvest)
    if bagItemData and bagItemData.num > 0 then
      itemNum = bagItemData.num
    end
    if plantGrowConf.home_lv and myHomeLevel >= plantGrowConf.home_lv and not itemNum then
      itemNum = 0
    end
    if itemNum and plantGrowConf.plant_harvest then
      ItemNeedShow[plantGrowConf.plant_harvest] = itemNum
    end
  end
  local availableItemNum = 0
  local TotalLimitNum = math.maxinteger
  local NumHadBuy = 0
  for idx, goodsData in ipairs(rsp.shop_data.goods_data) do
    local normalShopConf = _G.DataConfigManager:GetNormalShopConf(goodsData and goodsData.goods_id, true)
    local sellableItemId
    if goodsData and 0 ~= (goodsData.limit_buy_num or 0) and goodsData.buy_num then
      TotalLimitNum = goodsData.limit_buy_num
      NumHadBuy = goodsData.buy_num
    end
    if goodsData and goodsData.real_price and goodsData.real_price.goods_type == Enum.GoodsType.GT_BAGITEM and goodsData.real_price.goods_id then
      sellableItemId = goodsData.real_price.goods_id
    end
    if goodsData and sellableItemId and normalShopConf and nil ~= ItemNeedShow[sellableItemId] then
      table.insert(itemDataArray, {
        shopLibId = goodsData.goods_id,
        itemId = sellableItemId,
        npcShopId = rsp.shop_data.id,
        priceNum = normalShopConf.item_num,
        limitNum = goodsData.limit_buy_num,
        boughtNum = goodsData.buy_num,
        currentOwnNum = ItemNeedShow[sellableItemId],
        selectedNum = 0,
        callbackCaller = self,
        callbackFunc = self.OnListItemSelected,
        callbackFunc1 = self.OnSelectNumChanged,
        callbackFunc2 = self.PreCheckAvailableSelectedNum
      })
      if 0 ~= ItemNeedShow[sellableItemId] then
        availableItemNum = availableItemNum + 1
      end
    end
  end
  self.uiData.SellableTotalLimitNum = TotalLimitNum - NumHadBuy
  self.uiData.CurrentSelectedTotalNum = 0
  table.sort(itemDataArray, function(a, b)
    if a.currentOwnNum * b.currentOwnNum > 0 or 0 == a.currentOwnNum and 0 == b.currentOwnNum then
      local aLv = unlockHomeLevel[a.itemId] or math.maxinteger
      local bLv = unlockHomeLevel[b.itemId] or math.maxinteger
      if aLv == bLv then
        return a.itemId < b.itemId
      else
        return aLv < bLv
      end
    else
      return a.currentOwnNum > 0
    end
  end)
  self:InitSelectAllButtonChecker(availableItemNum)
  return itemDataArray
end

function UMG_NPCShop_PlantAcquisition_C:RefreshNPCShopMainPanel(shopId, rsp)
  self:OnReceiveShopData(shopId, rsp)
end

function UMG_NPCShop_PlantAcquisition_C:OnAddEventListener()
  self:AddButtonListener(self.CloseBtn.btnClose, self.OnCloseButtonClicked)
  self:AddButtonListener(self.Sell_Btn.btnLevelUp, self.OnClickSellButton)
  self:AddButtonListener(self.SelectAll_Btn.btnLevelUp, self.OnClickSelectAllButton)
  self:RegisterEvent(self, NPCShopUIModuleEvent.NPCSHOP_REFRESH_MAIN_PANEL, self.RefreshNPCShopMainPanel)
  _G.DataModelMgr.PlayerDataModel:AddEventListener(self, ENUM_PLAYER_DATA_EVENT.UPDATE_DATA, self.OnPlayerDataUpdate)
  NRCEventCenter:RegisterEvent("UMG_NPCShop_PlantAcquisition_C", self, BagModuleEvent.BagItemAdd, self.OnBagChange)
  NRCEventCenter:RegisterEvent("UMG_NPCShop_PlantAcquisition_C", self, BagModuleEvent.BagItemUpdate, self.OnBagChange)
end

function UMG_NPCShop_PlantAcquisition_C:OnRemoveEventListener()
  _G.DataModelMgr.PlayerDataModel:RemoveEventListener(self, ENUM_PLAYER_DATA_EVENT.UPDATE_DATA, self.OnPlayerDataUpdate)
  NRCEventCenter:UnRegisterEvent(self, BagModuleEvent.BagItemAdd, self.OnBagChange)
  NRCEventCenter:UnRegisterEvent(self, BagModuleEvent.BagItemUpdate, self.OnBagChange)
end

function UMG_NPCShop_PlantAcquisition_C:OnListItemSelected(item, index)
  _G.NRCAudioManager:PlaySound2DAuto(1236, "UMG_NPCShop_PlantAcquisition_C:OnListItemSelected")
  self.curSelectedIndex = index
  self:OnItemClick(index, item)
end

function UMG_NPCShop_PlantAcquisition_C:OnItemClick(index, item)
  self:UpdateDetailPanel()
end

function UMG_NPCShop_PlantAcquisition_C:UpdateDetailPanel()
  if 0 ~= self.curSelectedIndex then
    local itemData
    if self.uiData and self.uiData.itemList1 then
      itemData = self.uiData.itemList1[self.curSelectedIndex]
    end
    if itemData then
      self.NRCSwitcher_0:SetActiveWidgetIndex(0)
      local bagItemConf = _G.DataConfigManager:GetBagItemConf(itemData.itemId, true)
      if bagItemConf then
        self.ItemName:SetText(bagItemConf.name)
        self.ItemProperty:SetText(bagItemConf.type_desc)
        self.HeadIcon:SetPath(bagItemConf.big_icon)
        self.ItemDesc:SetText(bagItemConf.description)
        if bagItemConf.flavor_text == nil or bagItemConf.flavor_text == "" then
          self.TextDes:SetVisibility(UE4.ESlateVisibility.Collapsed)
          self.TextDes:SetText("")
        else
          self.TextDes:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
          self.TextDes:SetText(bagItemConf.flavor_text)
        end
      end
      self.hasCount:SetText(itemData.currentOwnNum)
    else
      self.NRCSwitcher_0:SetActiveWidgetIndex(1)
    end
  else
    self.NRCSwitcher_0:SetActiveWidgetIndex(1)
  end
end

function UMG_NPCShop_PlantAcquisition_C:OnPcClose()
  self:OnCloseButtonClicked()
end

function UMG_NPCShop_PlantAcquisition_C:OnCloseVisit()
  self:ShopCloseVisit()
end

function UMG_NPCShop_PlantAcquisition_C:ShopCloseVisit()
  if self.data then
    self:StartCaptureTick(false)
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1008, "UMG_NPCShop_PlantAcquisition_C:OnCloseButtonClicked")
    self:RestoreHudStatus()
    self:ReleaseCaptureResource()
    if 0 == GlobalConfig.OpenMainPanelFromDebugBtn then
      self.data.NPCActionOpenShop.Owner.owner:LockVisibility(false)
      if self.data.NPCActionOpenShop ~= nil and not _G.DataModelMgr.PlayerDataModel:IsVisitState() then
        self.data.NPCActionOpenShop = nil
      end
    end
    self:DoClose()
  end
end

function UMG_NPCShop_PlantAcquisition_C:ShowMoney()
  local shopConf = _G.DataConfigManager:GetShopConf(self.uiData.shopId)
  local moneyInfo = {}
  if shopConf and shopConf.goods then
    for idx, v in ipairs(shopConf.goods) do
      local bShowBuyIcon = false
      local costGoodType = v.goods_type
      local costGoodId = v.goods_id
      local ownNum = NPCShopUtils:GetGoodsCurrencyNumByType(costGoodType, costGoodId)
      if costGoodType == Enum.GoodsType.GT_VITEM then
        bShowBuyIcon = costGoodId == Enum.VisualItem.VI_COUPON or costGoodId == Enum.VisualItem.VI_DIAMOND or costGoodId == Enum.VisualItem.VI_PIKA_POINT
      end
      table.insert(moneyInfo, {
        currencyType = costGoodType,
        currencyId = v.goods_id,
        moneyType = costGoodType,
        sum = ownNum,
        IsShowBuyIcon = bShowBuyIcon
      })
    end
  end
  self.MoneyBtn:InitGridView(moneyInfo)
end

function UMG_NPCShop_PlantAcquisition_C:OnCloseButtonClicked()
  self:Log("UMG_NPCShop_PlantAcquisition_C OnCloseButtonClicked")
  if self:IsAnimationPlaying(self.close_an) then
    return
  end
  self.MoneyBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:PlayAnimation(self.close_an)
  self:ReleaseCaptureResource()
end

function UMG_NPCShop_PlantAcquisition_C:ShopClose()
  if self.data then
    self:StartCaptureTick(false)
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1008, "UMG_NPCShop_PlantAcquisition_C:ShopClose")
    if 0 == GlobalConfig.OpenMainPanelFromDebugBtn and self.data.NPCActionOpenShop then
      self.data.NPCActionOpenShop.Owner.owner:LockVisibility(false)
      if self.data.NPCActionOpenShop ~= nil then
        self.data.NPCActionOpenShop:Finish()
        self.data.NPCActionOpenShop = nil
      end
    end
    if self.data:GetOpenNpcShopType() == NPCShopUIModuleEnum.OpenNPCShopFormType.MagicManualMain then
      _G.NRCModuleManager:DoCmd(_G.MagicManualModuleCmd.CmdShowMagicManualMain)
    elseif self.data:GetOpenNpcShopType() == NPCShopUIModuleEnum.OpenNPCShopFormType.PvpQualifier then
      _G.NRCModuleManager:DoCmd(_G.PVPRankedMatchModuleCmd.ShowUmgPVPQualifier)
    end
    _G.NRCModuleManager:DoCmd(NPCShopUIModuleCmd.SetNpcShopOpenType, nil)
    self:DoClose()
  end
end

function UMG_NPCShop_PlantAcquisition_C:StartCaptureTick(bStart)
  if self.data == nil then
    Log.Error("UMG_NPCShop_PlantAcquisition_C  self.data is nil\239\188\140\230\156\137\233\151\174\233\162\152\239\188\129\229\133\136\229\138\160\228\191\157\230\138\164\239\188\140\233\152\178\230\173\162\229\141\161\230\173\187")
    return
  end
  if self.data.NPCActionOpenShop and bStart ~= self.hasStopTick then
    _G.NRCModuleManager:DoCmd(DialogueModuleCmd.SetUICameraCaptureTickable, bStart)
    self.hasStopTick = bStart
  end
end

function UMG_NPCShop_PlantAcquisition_C:SetDialogueUICameraCullingMask(Mask, bCache)
  local UICameraClass = _G.NRCBigWorldPreloader:Get("DialogueUICamera")
  local CameraActor = UE4.UGameplayStatics.GetActorOfClass(UE4Helper.GetCurrentWorld(), UICameraClass)
  local CameraCom = CameraActor and CameraActor:GetComponentByClass(UE4.UCameraComponent)
  if CameraCom then
    if bCache then
      self.CachedCameraCullingMask = CameraCom.CullingMask
    end
    CameraCom.CullingMask = Mask or -1
  end
end

function UMG_NPCShop_PlantAcquisition_C:SetActorCullingMask(Mask, bCache)
  local ActionOpenShop = self.data and self.data.NPCActionOpenShop
  local owner = ActionOpenShop and ActionOpenShop.Owner and ActionOpenShop.Owner.owner
  if owner and owner.viewObj then
    if bCache then
      self.CachedActorCullingMask = owner.viewObj.NRCLayerMask
    end
    owner.viewObj:SetLayerMask(Mask or 1, true)
  end
end

function UMG_NPCShop_PlantAcquisition_C:OnAnimationFinished(anim)
  if anim == self.close_an then
    self:ShopClose()
  end
end

function UMG_NPCShop_PlantAcquisition_C:PreCheckAvailableSelectedNum(index, intendDeltaChange)
  if not self.uiData or not intendDeltaChange then
    return
  end
  local itemData = self.uiData.itemList1[index]
  if not itemData then
    return
  end
  local finalIntendDeltaChange = math.min(self.uiData.SellableTotalLimitNum - self.uiData.CurrentSelectedTotalNum, intendDeltaChange)
  if intendDeltaChange > 0 and 0 == finalIntendDeltaChange and itemData.selectedNum ~= itemData.currentOwnNum then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.home_plant_shop_sell_num_max_tips)
  end
  return finalIntendDeltaChange
end

function UMG_NPCShop_PlantAcquisition_C:OnSelectNumChanged(index, deltaChange, prevNum)
  if not self.uiData then
    return
  end
  local itemData = self.uiData.itemList1[index]
  if not itemData then
    return
  end
  if deltaChange then
    self.uiData.sellingPriceSum = self.uiData.sellingPriceSum + deltaChange * itemData.priceNum
    self.uiData.CurrentSelectedTotalNum = self.uiData.CurrentSelectedTotalNum + deltaChange
    self:CheckSelectAllButton(false, index, prevNum)
  else
    self:DoSumSellingPrice()
    self:CheckSelectAllButton(true)
  end
  self:ShowSellingPrice()
end

function UMG_NPCShop_PlantAcquisition_C:DoSumSellingPrice()
  if not self.uiData then
    return
  end
  local sum = 0
  for idx, itemData in ipairs(self.uiData.itemList1) do
    if itemData and itemData.priceNum and itemData.selectedNum then
      sum = sum + itemData.selectedNum * itemData.priceNum
    end
  end
  self.uiData.sellingPriceSum = sum
  self:ShowSellingPrice()
end

function UMG_NPCShop_PlantAcquisition_C:ShowSellingPrice()
  if not self.uiData then
    return
  end
  self.CostNum:SetText(self.uiData.sellingPriceSum or 0)
end

function UMG_NPCShop_PlantAcquisition_C:InitSelectAllButtonChecker(availableItemNum)
  self.uiData.availableItemNum = availableItemNum
  self.uiData.fullSellItemNum = 0
  self.uiData.zeroSellItemNum = availableItemNum
  self.uiData.bBtnActionIsSelectAll = true
  if 0 == availableItemNum then
    self.SelectAll_Btn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.SelectAll_Btn_Grey:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  else
    self.SelectAll_Btn:SetVisibility(UE4.ESlateVisibility.Visible)
    self.SelectAll_Btn_Grey:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_NPCShop_PlantAcquisition_C:CheckSelectAllButton(bRebuild, specificIndex, prevNum)
  if not self.uiData or not self.uiData.itemList1 then
    return
  end
  local newFullSellItemNum = 0
  local newZeroSellItemNum = 0
  if bRebuild then
    for idx, itemData in ipairs(self.uiData.itemList1) do
      if 0 ~= itemData.currentOwnNum then
        if itemData.selectedNum == itemData.currentOwnNum then
          newFullSellItemNum = newFullSellItemNum + 1
        elseif 0 == itemData.selectedNum then
          newZeroSellItemNum = newZeroSellItemNum + 1
        end
      end
    end
  else
    newFullSellItemNum = self.uiData.fullSellItemNum
    newZeroSellItemNum = self.uiData.zeroSellItemNum
    local itemData = self.uiData.itemList1[specificIndex]
    if itemData then
      if prevNum == itemData.currentOwnNum and itemData.selectedNum ~= itemData.currentOwnNum then
        newFullSellItemNum = newFullSellItemNum - 1
      elseif prevNum ~= itemData.currentOwnNum and itemData.selectedNum == itemData.currentOwnNum then
        newFullSellItemNum = newFullSellItemNum + 1
      end
      if 0 == prevNum and 0 ~= itemData.selectedNum then
        newZeroSellItemNum = newZeroSellItemNum - 1
      elseif 0 ~= prevNum and 0 == itemData.selectedNum then
        newZeroSellItemNum = newZeroSellItemNum + 1
      end
    end
  end
  local bReachSellableLimit = 0 == self.uiData.SellableTotalLimitNum - self.uiData.CurrentSelectedTotalNum
  local bSelectingSomething = self.uiData.CurrentSelectedTotalNum > 0
  local bPreviousSelectNothing = self.uiData.zeroSellItemNum == self.uiData.availableItemNum
  local bSelectNothing = newZeroSellItemNum == self.uiData.availableItemNum
  self.uiData.fullSellItemNum = newFullSellItemNum
  self.uiData.zeroSellItemNum = newZeroSellItemNum
  local prevBtnActionIsSelectAll = self.uiData.bBtnActionIsSelectAll
  if newFullSellItemNum == self.uiData.availableItemNum or bReachSellableLimit and bSelectingSomething then
    self.uiData.bBtnActionIsSelectAll = false
  elseif newZeroSellItemNum == self.uiData.availableItemNum then
    self.uiData.bBtnActionIsSelectAll = true
  end
  if bRebuild or prevBtnActionIsSelectAll ~= self.uiData.bBtnActionIsSelectAll then
    if self.uiData.bBtnActionIsSelectAll then
      self.SelectAll_Btn:SetBtnText(LuaText.home_plant_sell_button_select_all)
    else
      self.SelectAll_Btn:SetBtnText(LuaText.home_plant_sell_button_select_nothing)
    end
  end
  if bRebuild or bPreviousSelectNothing ~= bSelectNothing then
    if bSelectNothing then
      self.CanvasPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Sell_Btn_Grey:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      self.Sell_Btn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.CanvasPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Sell_Btn_Grey:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Sell_Btn:SetVisibility(UE4.ESlateVisibility.Visible)
    end
  end
end

function UMG_NPCShop_PlantAcquisition_C:OnClickSellButton()
  if not (self.uiData and self.uiData.itemList1) or not self.uiData.sellingPriceSum then
    return
  end
  local showConfirmItem = {}
  for idx, item in ipairs(self.uiData.itemList1) do
    if item and item.shopLibId and item.selectedNum and item.selectedNum > 0 then
      table.insert(showConfirmItem, item)
    end
  end
  if 0 == #showConfirmItem then
    Log.Error("UMG_NPCShop_PlantAcquisition_C:OnClickSellButton \230\178\161\230\156\137\233\128\137\228\184\173\228\187\187\228\189\149\228\184\156\232\165\191\229\141\150\229\135\186")
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(40008005, "UMG_NPCShop_PlantAcquisition_C:OnClickSellButton")
  _G.NRCModuleManager:DoCmd(NPCShopUIModuleCmd.OpenPlaneSellConfirm, self.uiData.shopId, showConfirmItem, _G.Enum.VisualItem.VI_COIN, self.uiData.sellingPriceSum)
end

function UMG_NPCShop_PlantAcquisition_C:OnClickSelectAllButton()
  if not self.uiData or not self.uiData.itemList1 then
    return
  end
  if self.uiData.bBtnActionIsSelectAll then
    _G.NRCAudioManager:PlaySound2DAuto(41401004, "UMG_NPCShop_PlantAcquisition_C:OnClickSelectAllButton_ON")
    local availableDeltaNum = self.uiData.SellableTotalLimitNum - self.uiData.CurrentSelectedTotalNum
    local bShowTips = false
    for idx, itemData in ipairs(self.uiData.itemList1) do
      local deltaToFill = itemData.currentOwnNum - itemData.selectedNum
      local deltaActualFill = math.min(availableDeltaNum, deltaToFill)
      availableDeltaNum = availableDeltaNum - deltaActualFill
      itemData.selectedNum = itemData.selectedNum + deltaActualFill
      if not bShowTips and itemData.selectedNum ~= itemData.currentOwnNum then
        bShowTips = true
      end
      local itemWidget = self.ItemList:GetItemByIndex(idx - 1)
      if itemWidget and itemWidget.UpdateUIProperty then
        itemWidget:UpdateUIProperty()
      end
    end
    self.uiData.CurrentSelectedTotalNum = self.uiData.SellableTotalLimitNum - availableDeltaNum
    if bShowTips then
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.home_plant_shop_sell_num_max_tips)
    end
  else
    _G.NRCAudioManager:PlaySound2DAuto(41401005, "UMG_NPCShop_PlantAcquisition_C:OnClickSelectAllButton_OFF")
    for idx, itemData in ipairs(self.uiData.itemList1) do
      itemData.selectedNum = 0
      local itemWidget = self.ItemList:GetItemByIndex(idx - 1)
      if itemWidget and itemWidget.UpdateUIProperty then
        itemWidget:UpdateUIProperty()
      end
    end
    self.uiData.CurrentSelectedTotalNum = 0
  end
  self:DoSumSellingPrice()
  self:CheckSelectAllButton(true)
end

function UMG_NPCShop_PlantAcquisition_C:InitText()
  self.NRCText_85:SetText(LuaText.home_plant_sell_tips_top)
  self.IncomeText1:SetText(LuaText.plant_sell_expected_income_text)
end

function UMG_NPCShop_PlantAcquisition_C:OnPlayerDataUpdate()
  self:ShowMoney()
end

function UMG_NPCShop_PlantAcquisition_C:OnBagChange()
  self:ShowMoney()
end

function UMG_NPCShop_PlantAcquisition_C:RestoreHudStatus()
  local npcActionOpenShop = self.data.NPCActionOpenShop
  local owner = npcActionOpenShop and npcActionOpenShop.Owner and npcActionOpenShop.Owner.owner
  local viewObj = owner and owner.viewObj
  if UE4.UObject.IsValid(viewObj) then
    local nameComponent = viewObj:GetComponentByClass(UE4.URocoWidgetComponent)
    if nameComponent then
      nameComponent:SetComponentTickEnabled(true)
      nameComponent:SetRenderStatus(true, MainUIModuleEnum.DisableHudOpSource.EnterNpcShop)
    end
  end
end

function UMG_NPCShop_PlantAcquisition_C:ReleaseCaptureResource()
  if not self.data then
    return
  end
  local npcActionOpenShop = self.data.NPCActionOpenShop
  local owner = npcActionOpenShop and npcActionOpenShop.Owner and npcActionOpenShop.Owner.owner
  local viewObj = owner and owner.viewObj
  if UE4.UObject.IsValid(viewObj) and viewObj.Mesh then
    viewObj.Mesh:SetForcedLOD(0)
  end
  self:StartCaptureTick(false)
  self:SetDialogueUICameraCullingMask(self.CachedCameraCullingMask)
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "r.Shadow.CSMCaching.ForceUpdate 10")
  self:SetActorCullingMask(self.CachedActorCullingMask)
end

return UMG_NPCShop_PlantAcquisition_C
