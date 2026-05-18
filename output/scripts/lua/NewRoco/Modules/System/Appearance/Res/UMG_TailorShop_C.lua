local UMG_TailorShop_C = _G.NRCPanelBase:Extend("UMG_TailorShop_C")
local AppearanceModuleEvent = require("NewRoco.Modules.System.Appearance.AppearanceModuleEvent")
local AppearanceUtils = require("NewRoco.Modules.System.Appearance.AppearanceUtils")
local NPCShopUIModuleEvent = reload("NewRoco.Modules.System.NPCShopUI.NPCShopUIModuleEvent")
local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local NPCShopUIModuleEnum = require("NewRoco.Modules.System.NPCShopUI.NPCShopUIModuleEnum")
local NPCShopUtils = require("NewRoco.Modules.System.NPCShopUI.NPCShopUtils")
local BagModuleEvent = reload("NewRoco.Modules.System.Bag.BagModuleEvent")
local ENUM_PLAYER_DATA_EVENT = require("Data.Global.PlayerDataEvent")

function UMG_TailorShop_C:OnConstruct()
  self.uiData = {}
  self.data = self.module:GetData("AppearanceModuleData")
  local Action = self.data and self.data.NPCActionOpenShop
  if Action then
    local viewObj = Action:GetOwnerNPCView()
    if viewObj then
      self.animComp = viewObj:GetAnimComponent()
    else
      Log.Error("UMG_TailorShop_C:OnConstruct viewObj is invalid")
    end
  end
  self.RandomPlayTimeCount = 0
  self.hasStopTick = false
  self:OnAddEventListener()
  self:BtnInit()
  self.UMG_Owned:SetBtnText(LuaText.tailor_owned_btn or "")
  self.UMG_Owned:SetClickAble(false)
  self.UMG_Owned:SetShowLockIcon(false)
  self.Btn_Buy:SetBtnText(LuaText.tailor_buy_btn)
  self.ItemGainWay:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:SetCommonTitle()
  if self.InvalidationBox_47 then
    self.InvalidationBox_47:SetCanCache(false)
  end
  _G.NRCEventCenter:RegisterEvent("UMG_TailorShop_C", self, DialogueModuleEvent.DialogueEnded, self.OnCloseVisit)
end

function UMG_TailorShop_C:OnDestruct()
  self.uiData = nil
  if 0 == GlobalConfig.OpenMainPanelFromDebugBtn and self.data.NPCActionOpenShop and self.data.NPCActionOpenShop.Owner.owner.viewObj then
    local nameComponent = self.data.NPCActionOpenShop.Owner.owner.viewObj:GetComponentByClass(UE4.URocoWidgetComponent)
    nameComponent:SetComponentTickEnabled(true)
    self.data.NPCActionOpenShop.Owner.owner:SetVisible(true)
  end
  self:RestoreHudStatus()
  _G.NRCEventCenter:UnRegisterEvent(self, DialogueModuleEvent.DialogueEnded, self.OnCloseVisit)
  self:OnRemoveEventListener()
  self:StartCaptureTick(false)
end

function UMG_TailorShop_C:SetItemList(List)
  if List and #List > 0 then
    local ItemNum = {}
    if GlobalConfig.bShowProfilerLog then
      for i = 1, 6 do
        table.insert(ItemNum, List[i])
      end
      List = ItemNum
    end
    for i = 1, #List do
      List[i].callbackCaller = self
      List[i].callbackFunc = self.OnListItemSelected
    end
    self.Buy_List:ClearSelection()
    self.Buy_List:InitGridView(List)
  else
    self.Buy_List:Clear()
  end
end

local function SortShopItem(a, b)
  return a.Pos < b.Pos
end

function UMG_TailorShop_C:OnActive(param0, param, param1, ...)
  local shopId = tonumber(param0)
  self:OnReceiveShopData(shopId, param1)
  if _G.GlobalConfig.DebugOpenUI then
    UE4Helper.SetEnableWorldRendering(false)
    _G.NRCModuleManager:DoCmd(MainUIModuleCmd.ClosePanelLobbyMain)
  end
  self:PlayAnimation(self.In)
  _G.NRCAudioManager:PlaySound2DAuto(1142, "UMG_TailorShop_C:OnActive")
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
  if OpenNpcShopType ~= NPCShoTypeEnum.MagicManualMain then
    self:CaptureBackgroundAndNPC(true)
  end
  _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.ForceSetLensFlaresActorVisibility, false)
end

function UMG_TailorShop_C:CaptureBackgroundAndNPC(bCaptureNPC)
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

function UMG_TailorShop_C:SetCommonTitle()
  self.titleConf = _G.DataConfigManager:GetTitleConf(self:GetPanelName())
  self.Title1:Set_MainTitle(self.titleConf.title)
  self.Title1:SetBg(self.titleConf.head_icon)
  self.Title1:SetSubtitle(self.titleConf.subtitle[1].subtitle)
end

function UMG_TailorShop_C:OnReceiveShopData(shopId, _rsp, param, ...)
  self.data = self.module:GetData("AppearanceModuleData")
  self.uiData = {}
  local itemList1 = self:GenerateCustomInfo(_rsp, shopId)
  self.uiData.itemList1 = itemList1
  self.uiData.shopId = shopId
  self.uiData.IsTailorShop = true
  self:updatePanelInfo()
  if #itemList1 >= 1 then
    local newSelectedIndex = 1
    if self.PreferSelectIndex and self.PreferSelectIndex > 0 and self.PreferSelectIndex <= #itemList1 then
      newSelectedIndex = self.PreferSelectIndex
      self.PreferSelectIndex = 0
    end
    self.Buy_List:SelectItemByIndex(newSelectedIndex - 1)
  end
end

function UMG_TailorShop_C:OnDeactive()
  if _G.GlobalConfig.DebugOpenUI then
    UE4Helper.SetEnableWorldRendering(true)
    _G.NRCModuleManager:DoCmd(MainUIModuleCmd.OpenPanelLobbyMain)
  end
  GlobalConfig.OpenMainPanelFromDebugBtn = 0
  self:ReleaseCaptureResource()
  _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.ForceSetLensFlaresActorVisibility, true)
  UE4.ACharacterStatusComputeActor.SetTickEnabled(false)
end

function UMG_TailorShop_C:updatePanelInfo()
  self:SetItemList(self.uiData.itemList1)
  self:ShowMoney()
end

function UMG_TailorShop_C:ShowMoney()
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

function UMG_TailorShop_C:RandomPlayShowAnim(deltaTime)
  self.RandomPlayTimeCount = self.RandomPlayTimeCount + deltaTime
  if 7.0 == math.floor(self.RandomPlayTimeCount) then
    self.RandomPlayTimeCount = 0
    if self.animComp then
      self.animComp:PlayAnimByName("IdleRelax2")
    end
  end
end

function UMG_TailorShop_C:OnListItemSelected(item, index, bSoldOut)
  _G.NRCAudioManager:PlaySound2DAuto(1236, "UMG_TailorShop_C:OnListItemSelected")
  self.curSelectedIndex = index
  self:OnItemClick(index, item)
  self:SwitchBtnSoldOutState(bSoldOut)
end

function UMG_TailorShop_C:OnItemClick(index, item)
  local selectedSuitId = self.uiData.itemList1[index].itemId
  local suitConf = DataConfigManager:GetFashionSuitsConf(selectedSuitId)
  if nil == suitConf then
    return
  end
  self.ItemName:SetText(suitConf.name)
  if suitConf.suits_icon then
    self.Icon:SetPath(suitConf.suits_icon)
  else
    self.Icon:SetPath("")
  end
  local color = AppearanceUtils:GetSuitGradeColor(suitConf.suit_grade)
  self.QualityColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(color))
  local fashionOwned, fashionNotOwned = self.data:GetFashionOwnedBySuitId(selectedSuitId)
  local giftItemList = _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.GetSuitGiftFashion, selectedSuitId)
  local initList = {}
  if #fashionOwned > 0 and 0 == #fashionNotOwned then
    for k, v in ipairs(fashionOwned) do
      table.insert(initList, {
        itemId = v,
        bOwned = false,
        bIsGift = false,
        bIsInTailorShop = true
      })
    end
    for k, v in ipairs(giftItemList) do
      local shopConf = _G.DataConfigManager:GetNormalShopConf(v)
      if shopConf then
        table.insert(initList, {
          itemId = shopConf.item_id,
          bOwned = false,
          bIsGift = true,
          bIsInTailorShop = true
        })
      end
    end
  else
    for k, v in ipairs(fashionNotOwned) do
      table.insert(initList, {
        itemId = v,
        bOwned = false,
        bIsGift = false,
        bIsInTailorShop = true
      })
    end
    for k, v in ipairs(giftItemList) do
      local shopConf = _G.DataConfigManager:GetNormalShopConf(v)
      if shopConf then
        local bOwned = _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.CheckHasOwned, shopConf.Type, shopConf.item_id)
        table.insert(initList, {
          itemId = shopConf.item_id,
          bOwned = bOwned,
          bIsGift = true,
          bIsInTailorShop = true
        })
      end
    end
    for k, v in ipairs(fashionOwned) do
      table.insert(initList, {
        itemId = v,
        bOwned = true,
        bIsGift = false,
        bIsInTailorShop = true
      })
    end
  end
  self.Item:InitGridView(initList)
  self.ItemDesc:SetText(suitConf.flavor_text)
  self:updateMoneyCost(index)
  self:PlayAnimation(self.Change_icon)
  if self.selectedSuitId ~= selectedSuitId then
    self.UMG_Common_BIconPar:CloseOpen()
    self.selectedSuitId = selectedSuitId
  end
end

function UMG_TailorShop_C:updateMoneyCost(selectedIndex)
  if not selectedIndex then
    return
  end
  if self.uiData.itemList1 and selectedIndex <= #self.uiData.itemList1 and self.uiData.itemList1[selectedIndex] then
    local itemData = self.uiData.itemList1[selectedIndex]
    local price = self.uiData.itemList1[selectedIndex].priceNum
    local iconPath = NPCShopUtils:GetGoodsCurrencyIconPath(itemData.npcShopId, itemData.shopItemId)
    self.Btn_Buy:SetTitleTextAndIcon(iconPath, price)
    self.UMG_Owned:SetTitleTextAndIcon(iconPath, price)
    local hasNum = NPCShopUtils:GetGoodsCurrencyNum(itemData.npcShopId, itemData.shopItemId) or 0
    local ColorString
    if price <= hasNum then
      ColorString = "F4EEE1FF"
    else
      ColorString = "AF3D3EFF"
    end
    self.Btn_Buy:SetQuantityTextColor(ColorString)
    self.UMG_Owned:SetQuantityTextColor(ColorString)
    self.UMG_Owned.TitleCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_TailorShop_C:OnAddEventListener()
  self:AddButtonListener(self.Close.btnClose, self.OnCloseButtonClicked)
  self:AddButtonListener(self.Btn_Buy.btnLevelUp, self.OnBuyBtnClick)
  self:RegisterEvent(self, AppearanceModuleEvent.TailorShopReceiveShopData, self.OnReceiveShopData)
  self:RegisterEvent(self, AppearanceModuleEvent.TailorShopClose, self.CloseNPCShop)
  self:RegisterEvent(self, AppearanceModuleEvent.TailorShopCancelBuy, self.SetNPCShopBtnEnable)
  self:RegisterEvent(self, AppearanceModuleEvent.OnTryOnBuyPanelClose, self.OnTryOnBuyPanelClose)
  _G.DataModelMgr.PlayerDataModel:AddEventListener(self, ENUM_PLAYER_DATA_EVENT.UPDATE_DATA, self.OnPlayerDataUpdate)
  NRCEventCenter:RegisterEvent("UMG_TailorShop_C", self, BagModuleEvent.BagItemAdd, self.OnBagChange)
  NRCEventCenter:RegisterEvent("UMG_TailorShop_C", self, BagModuleEvent.BagItemUpdate, self.OnBagChange)
end

function UMG_TailorShop_C:OnRemoveEventListener()
  self:UnRegisterEvent(self, AppearanceModuleEvent.TailorShopReceiveShopData)
  self:UnRegisterEvent(self, AppearanceModuleEvent.TailorShopClose, self.CloseNPCShop)
  self:UnRegisterEvent(self, AppearanceModuleEvent.TailorShopCancelBuy, self.SetNPCShopBtnEnable)
  _G.DataModelMgr.PlayerDataModel:RemoveEventListener(self, ENUM_PLAYER_DATA_EVENT.UPDATE_DATA, self.OnPlayerDataUpdate)
  NRCEventCenter:UnRegisterEvent(self, BagModuleEvent.BagItemAdd, self.OnBagChange)
  NRCEventCenter:UnRegisterEvent(self, BagModuleEvent.BagItemUpdate, self.OnBagChange)
end

function UMG_TailorShop_C:IsAnimPlaying()
  if self.animComp then
    return self.animComp:IsAnimPlaying("IdleRelax2")
  end
end

function UMG_TailorShop_C:OnCloseButtonClicked()
  self:Log("UMG_TailorShop_C OnCloseButtonClicked")
  self.MoneyBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:ReleaseCaptureResource()
  if self.Out then
    if not self:IsAnimationPlaying(self.Out) then
      self:PlayAnimation(self.Out)
    end
  else
    self:ShopClose()
  end
end

function UMG_TailorShop_C:OnCloseVisit()
  self:Log("UMG_TailorShop_C OnCloseButtonClicked")
  self:ShopCloseVisit()
end

function UMG_TailorShop_C:CloseNPCShop(shopId)
  if 101 ~= shopId and 102 ~= shopId then
    self:StartCaptureTick(false)
    self:DelaySeconds(1, function()
      self:ShopClose()
    end)
  end
end

function UMG_TailorShop_C:SetNPCShopBtnEnable()
  self.Btn_Buy.btnLevelUp:SetIsEnabled(true)
end

function UMG_TailorShop_C:OnTryOnBuyPanelClose()
  self:ShowOrHideMoneyBtn(true)
end

function UMG_TailorShop_C:OnAnimationFinished(anim)
  self:Log("UMG_TailorShop_C OnAnimationFinished:", anim:GetName())
  if anim == self.Out then
    self:ShopClose()
  end
end

function UMG_TailorShop_C:ShopClose()
  if self.data then
    self:StartCaptureTick(false)
    _G.NRCAudioManager:PlaySound2DAuto(1142, "UMG_Tryon_Buy_C:ShopClose")
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

function UMG_TailorShop_C:ShopCloseVisit()
  if self.data then
    self:StartCaptureTick(false)
    _G.NRCAudioManager:PlaySound2DAuto(1142, "UMG_Tryon_Buy_C:ShopCloseVisit")
    self:RestoreHudStatus()
    self:ReleaseCaptureResource()
    if 0 == GlobalConfig.OpenMainPanelFromDebugBtn then
      self.data.NPCActionOpenShop.Owner.owner:LockVisibility(false)
      if self.data.NPCActionOpenShop ~= nil and not _G.DataModelMgr.PlayerDataModel:IsVisitState() then
        self.data.NPCActionOpenShop:Finish()
        self.data.NPCActionOpenShop = nil
      end
    end
    self:DoClose()
  end
end

function UMG_TailorShop_C:OnBuyBtnClick()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1220002026, "UMG_TailorShop_C:OnBuyBtnClick")
  if self.uiData.itemList1 == nil or 0 == #self.uiData.itemList1 then
    Log.Info("\229\149\134\229\159\142\230\151\160\229\149\134\229\147\129")
    return
  end
  if nil == self.curSelectedIndex then
    Log.Error("\233\162\132\230\150\153\228\185\139\229\164\150\231\154\132\233\148\153\232\175\175\239\188\154\230\156\170\233\128\137\228\184\173\229\149\134\229\147\129\230\131\133\229\134\181\228\184\139\231\130\185\229\135\187\228\186\134\232\180\173\228\185\176\230\140\137\233\146\174")
    return
  end
  if nil == self.uiData.itemList1[self.curSelectedIndex] then
    Log.Error("\233\162\132\230\150\153\228\185\139\229\164\150\231\154\132\233\148\153\232\175\175\239\188\154\233\128\137\228\184\173\229\149\134\229\147\129\230\178\161\230\156\137\230\149\176\230\141\174")
    return
  end
  local item = self.uiData.itemList1[self.curSelectedIndex]
  local normalShopConf = _G.DataConfigManager:GetNormalShopConf(item.shopItemId, true)
  if not normalShopConf then
    Log.Error("\230\137\190\228\184\141\229\136\176\229\149\134\229\147\129\233\133\141\231\189\174", item.shopItemId)
    return
  end
  if normalShopConf.Type == _G.Enum.GoodsType.GT_FASHION_SUITS then
    _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.OpenFashionShopConfirm, item.npcShopId, {
      shopLibId = normalShopConf.id
    }, false, 0)
    self:ShowOrHideMoneyBtn(false)
    return
  end
  _G.NRCModuleManager:DoCmd(NPCShopUIModuleCmd.OpenNPCShopConfirmNew, item, self.uiData, self.data, self.curSelectedIndex)
  self:ShowOrHideMoneyBtn(false)
end

function UMG_TailorShop_C:ShowOrHideMoneyBtn(_IsShow)
  if _IsShow then
    self.MoneyBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.MoneyBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_TailorShop_C:ShowTopMoney(datas, umgs, IsTop)
  if not IsTop then
    for i = 1, #umgs do
      if i > #datas then
        umgs[i]:SetVisibility(UE4.ESlateVisibility.Collapsed)
      else
        umgs[i]:SetInfo(datas[i].currencyType, datas[i].num, false)
        umgs[i]:SetVisibility(UE4.ESlateVisibility.Visible)
      end
    end
  else
    for i = 1, #umgs do
      if i > #datas then
        umgs[i]:SetVisibility(UE4.ESlateVisibility.Collapsed)
      else
        umgs[i]:OnActive(datas[i])
        umgs[i]:SetVisibility(UE4.ESlateVisibility.Visible)
      end
    end
  end
end

function UMG_TailorShop_C:StartCaptureTick(bStart)
  if self.data == nil then
    Log.Error("UMG_TailorShop_C  self.data is nil\239\188\140\230\156\137\233\151\174\233\162\152\239\188\129\229\133\136\229\138\160\228\191\157\230\138\164\239\188\140\233\152\178\230\173\162\229\141\161\230\173\187")
    return
  end
  if self.data.NPCActionOpenShop and bStart ~= self.hasStopTick and not _G.GlobalConfig.DebugOpenUI then
    _G.NRCModuleManager:DoCmd(DialogueModuleCmd.SetUICameraCaptureTickable, bStart)
    self.hasStopTick = bStart
  end
end

function UMG_TailorShop_C:BtnInit()
end

function UMG_TailorShop_C:SwitchBtnSoldOutState(_issoldout)
  if _issoldout then
    self.UMG_Owned:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.UMG_Owned.TitleCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Btn_Buy:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.UMG_Owned:SetBtnText(LuaText.tailor_owned_btn or "")
  elseif self.uiData.itemList1 and #self.uiData.itemList1 >= self.curSelectedIndex and self.uiData.itemList1[self.curSelectedIndex] then
    local itemData = self.uiData.itemList1[self.curSelectedIndex]
    local price = itemData.priceNum or 0
    local hasNum = NPCShopUtils:GetGoodsCurrencyNum(itemData.npcShopId, itemData.shopLibId) or 0
    if price <= hasNum then
      self.Btn_Buy:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.UMG_Owned:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.UMG_Owned:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.UMG_Owned.TitleCanvas:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Btn_Buy:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.UMG_Owned:SetBtnText(LuaText.tailor_buy_btn)
    end
  end
end

function UMG_TailorShop_C:SortSoldGoods(_goods)
  local soldOutGoods = {}
  local availableGoods = {}
  for i, item in ipairs(_goods) do
    if 0 ~= item.limitNum and item.boughtNum >= item.limitNum then
      table.insert(soldOutGoods, item)
    else
      table.insert(availableGoods, item)
    end
  end
  for i, item in ipairs(soldOutGoods) do
    table.insert(availableGoods, item)
  end
  return availableGoods
end

function UMG_TailorShop_C:GenerateCustomInfo(rsp, shopId)
  local itemList1 = {}
  local showType = _G.DataConfigManager:GetShopConf(shopId)
  if nil == showType then
    return itemList1
  end
  local playerGender = self.module.player.gender
  if rsp and rsp.shop_data.goods_data then
    for idx, goodsData in ipairs(rsp.shop_data.goods_data) do
      local goodsConf = _G.DataConfigManager:GetNormalShopConf(goodsData.goods_id)
      local goodsShopConf = goodsConf
      if goodsConf and goodsShopConf then
        if goodsConf.Type == Enum.GoodsType.GT_FASHION_SUITS then
          local suitId = goodsConf.item_id
          local suitConf = DataConfigManager:GetFashionSuitsConf(suitId)
          if nil == suitConf then
            Log.Warning("\232\163\129\231\188\157\233\147\186\231\154\132\229\165\151\232\163\133\229\149\134\229\147\129\233\133\141\231\189\174\228\184\141\229\173\152\229\156\168", shopId, goodsData.goods_id)
          elseif playerGender ~= suitConf.gender then
            Log.Warning("\232\163\129\231\188\157\233\147\186\231\154\132\229\165\151\232\163\133\229\149\134\229\147\129\230\128\167\229\136\171\228\184\141\229\140\185\233\133\141", shopId, goodsData.goods_id, playerGender, suitConf.gender)
          else
            local fashionOwned, fashionNotOwned = self.data:GetFashionOwnedBySuitId(suitId)
            if #fashionOwned > 0 and #fashionNotOwned > 0 then
              Log.Error("\232\163\129\231\188\157\233\147\186\231\154\132\229\165\151\232\163\133\229\149\134\229\147\129\228\184\141\229\186\148\232\175\165\229\135\186\231\142\176\231\142\169\229\174\182\229\183\178\231\187\143\228\184\148\228\187\133\230\139\165\230\156\137\233\131\168\229\136\134\229\165\151\232\163\133\229\134\133\233\131\168\228\187\182\231\154\132\230\131\133\229\134\181", shopId, goodsData.goods_id)
            end
            local itemInfo = {
              IsTailorShopGoods = true,
              shopItemId = goodsData.goods_id,
              shopLibId = goodsData.goods_id,
              selectedNum = 1,
              priceNum = goodsData.real_price.num,
              itemId = goodsConf.item_id,
              limitType = goodsConf.buy_cond_type,
              limitNum = goodsData.limit_buy_num,
              boughtNum = goodsData.buy_num,
              selectedNum = 0,
              selectedState = false,
              npcShopId = rsp.shop_data.id,
              showMoneyCost = {
                0,
                0,
                0
              },
              next_refresh_time = goodsData.next_refresh_time,
              goods_unlock_type = goodsShopConf.unlock_type
            }
            table.insert(itemList1, itemInfo)
            if suitId == self.selectedSuitId then
              self.PreferSelectIndex = #itemList1
            end
          end
        else
          Log.Error("\232\163\129\231\188\157\233\147\186\230\148\182\229\136\176\228\186\134\233\153\164\229\165\151\232\163\133\229\149\134\229\147\129\228\187\165\229\164\150\231\154\132\229\149\134\229\147\129", shopId, goodsData.goods_id)
        end
      end
    end
  end
  self:Log("UMG_TailorShop_C:GenerateCustomInfo:", itemList1)
  return itemList1
end

function UMG_TailorShop_C:SetDialogueUICameraCullingMask(Mask, bCache)
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

function UMG_TailorShop_C:SetActorCullingMask(Mask, bCache)
  local ActionOpenShop = self.data and self.data.NPCActionOpenShop
  local owner = ActionOpenShop and ActionOpenShop.Owner and ActionOpenShop.Owner.owner
  if owner and owner.viewObj then
    if bCache then
      self.CachedActorCullingMask = owner.viewObj.NRCLayerMask
    end
    owner.viewObj:SetLayerMask(Mask or 1, true)
  end
end

function UMG_TailorShop_C:OnPlayerDataUpdate()
  self:ShowMoney()
  self:updateMoneyCost(self.curSelectedIndex)
  local item = self.Buy_List:GetItemByIndex(self.curSelectedIndex - 1)
  if item then
    self:SwitchBtnSoldOutState(item.bHasOwned)
  end
end

function UMG_TailorShop_C:OnBagChange()
  self:ShowMoney()
  self:updateMoneyCost(self.curSelectedIndex)
end

function UMG_TailorShop_C:RestoreHudStatus()
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

function UMG_TailorShop_C:ReleaseCaptureResource()
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

return UMG_TailorShop_C
