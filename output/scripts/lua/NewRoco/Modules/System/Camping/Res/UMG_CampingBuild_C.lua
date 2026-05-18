local BagModuleEvent = require("NewRoco.Modules.System.Bag.BagModuleEvent")
local UMG_CampingBuild_C = _G.NRCPanelBase:Extend("UMG_CampingBuild_C")

function UMG_CampingBuild_C:OnConstruct()
  self:SetChildViews(self.Camping_Build_Info)
  self.uiData = {}
  self.selectedIndex = 1
  self.IsRefresh = true
  self:OnAddEventListener()
  self:PlayAnimation(self.open)
end

function UMG_CampingBuild_C:OnDestruct()
  self:OnRemoveEventListener()
end

function UMG_CampingBuild_C:OnActive(_action)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1069, "UMG_CampingBuild_C:OnActive")
  self.action = _action
  self:RefreshUI()
end

function UMG_CampingBuild_C:OnDeactive()
  UE4Helper.SetEnableWorldRendering(true)
end

function UMG_CampingBuild_C:OnAddEventListener()
  self:AddButtonListener(self.CloseBtn, self.OnCloseBtnClick)
  self:RegisterEvent(self, CampingModuleEvent.EXCHANGE_ITEM_SELECTED, self.OnExchangeItemSelected)
  self:RegisterEvent(self, CampingModuleEvent.UpdatePanelInfo, self.OnUpdatePanelInfo)
  NRCEventCenter:RegisterEvent("UMG_CampingBuild_C", self, BagModuleEvent.BagItemAdd, self.OnBagChange)
  NRCEventCenter:RegisterEvent("UMG_CampingBuild_C", self, BagModuleEvent.BagItemUpdate, self.OnBagChange)
end

function UMG_CampingBuild_C:OnRemoveEventListener()
  self:RemoveButtonListener(self.CloseBtn, self.OnCloseBtnClick)
  self:UnRegisterEvent(self, CampingModuleEvent.EXCHANGE_ITEM_SELECTED)
  self:UnRegisterEvent(self, CampingModuleEvent.UpdatePanelInfo, self.RefreshUI)
  NRCEventCenter:UnRegisterEvent(self, BagModuleEvent.BagItemAdd, self.OnBagChange)
  NRCEventCenter:UnRegisterEvent(self, BagModuleEvent.BagItemUpdate, self.OnBagChange)
end

function UMG_CampingBuild_C:OnExchangeItemSelected(_index)
  self.selectedIndex = _index
  self:RefreshInfoView()
end

function UMG_CampingBuild_C:OnUpdatePanelInfo()
  self.IsRefresh = false
  self:RefreshUI()
end

function UMG_CampingBuild_C:OnBagChange()
  self.IsRefresh = false
  self:RefreshUI()
end

function UMG_CampingBuild_C:RefreshUI()
  local req = _G.ProtoMessage:newZoneGetUnlockedExchangeReq()
  _G.ZoneServer:SendWithHandler(_G.ProtoEnum.ZoneSvrCmd.ZONE_GET_UNLOCKED_EXCHANGE_REQ, req, self, self.OnGetUnlockedExchangeRsp, true, true)
end

function UMG_CampingBuild_C:OnGetUnlockedExchangeRsp(rsp)
  if 0 == rsp.ret_info.ret_code then
    self:GenerateExchangeData(rsp.recipes.recipes)
    self:RefreshExchangeList()
  else
    self:GenerateExchangeData({})
    self:RefreshExchangeList()
    Log.Error("\231\130\188\233\135\145\232\167\163\233\148\129\228\191\161\230\129\175\229\155\158\229\140\133\233\148\153\232\175\175: ", table.tostring(rsp))
  end
end

function UMG_CampingBuild_C:GenerateExchangeData(exchange_ids)
  local datas = self:GetExchangeItemDatas(exchange_ids)
  self.uiData.buildItems = datas
end

function UMG_CampingBuild_C:RefreshExchangeList()
  self.GridView:InitGridView(self.uiData.buildItems)
  self.GridView:SelectItemByIndex(self.selectedIndex - 1)
end

function UMG_CampingBuild_C:RefreshInfoView()
  local infoData = self.uiData.buildItems[self.selectedIndex]
  if self.Camping_Build_Info == nil then
    Log.Debug("Camping_Build_Info is nil")
  end
  self.Camping_Build_Info:SetExchangeInfoData(infoData)
end

function UMG_CampingBuild_C:OnCloseBtnClick()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1008, "UMG_CampingBuild_C:OnCloseBtnClick")
  if self:IsAnimationPlaying(self.close) then
    return
  end
  self:PlayAnimation(self.close)
  UE4Helper.SetEnableWorldRendering(true)
end

function UMG_CampingBuild_C:OnAnimationFinished(Animation)
  if Animation == self.close then
    if self.action then
      self.action:Finish()
    end
    self:DoClose()
  elseif Animation == self.open then
    UE4Helper.SetEnableWorldRendering(false)
  end
end

local function _SortExchangeFunc(a, b)
  local canExchangeA = a.canExchangeNum > 0 and 1 or 0
  local canExchangeB = b.canExchangeNum > 0 and 1 or 0
  if canExchangeA == canExchangeB then
    return a.exchangeId < b.exchangeId
  else
    return canExchangeA > canExchangeB
  end
end

function UMG_CampingBuild_C:GetExchangeItemDatas(exchange_ids)
  local datas = {}
  for _, unlock_exchange_data in ipairs(exchange_ids) do
    local cfg = _G.DataConfigManager:GetExchangeConf(unlock_exchange_data.exchange_id)
    if cfg.use_type == Enum.ExchangeUseType.EUT_MANUFACTURE then
      local item = {}
      local getItem = cfg.get_item[1]
      item.exchangeId = cfg.id
      item.exchange_time_lower_limit = cfg.exchange_time_lower_limit
      item.exchange_time_upper_limit = cfg.exchange_time_upper_limit
      item.getItem = getItem
      item.costItems = cfg.cost_item
      item.num = 0
      item.IsRefresh = self.IsRefresh
      if getItem.get_goods_type == _G.Enum.GoodsType.GT_BAGITEM then
        local bagItemData = _G.NRCModuleManager:DoCmd(BagModuleCmd.GetBagItemByID, getItem.get_goods_id)
        if bagItemData then
          item.num = bagItemData.num
        end
      end
      item.canExchangeNum = self:GetCanExchangeNum(getItem, cfg.cost_item, cfg.visual_item_cost_num or 0)
      table.insert(datas, item)
    end
  end
  table.sort(datas, _SortExchangeFunc)
  return datas
end

function UMG_CampingBuild_C:GetCanExchangeNum(getItem, costItems, costCoin)
  local canExchangeNum = 999999
  for _, costItem in ipairs(costItems) do
    local num = 0
    if costItem.cost_goods_type == Enum.GoodsType.GT_BAGITEM then
      local bagItemData = _G.NRCModuleManager:DoCmd(BagModuleCmd.GetBagItemByID, costItem.cost_goods_id)
      if bagItemData then
        num = math.floor(bagItemData.num / costItem.cost_goods_num)
      end
    elseif costItem.cost_goods_type == Enum.GoodsType.GT_VITEM then
      local vItemData = _G.DataModelMgr.PlayerDataModel:GetVItemCount(costItem.cost_goods_id)
      if vItemData then
        num = math.floor(vItemData / costItem.cost_goods_num)
      end
    end
    if canExchangeNum > num then
      canExchangeNum = num
    end
  end
  local CurrentCoin = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_COIN) or 0
  if costCoin then
    local num = math.floor(CurrentCoin / costCoin)
    if canExchangeNum > num then
      canExchangeNum = num
    end
  end
  if 999999 == canExchangeNum then
    canExchangeNum = 0
  end
  return canExchangeNum
end

function UMG_CampingBuild_C:LockPlayer(isLock)
  Log.Debug("UMG_CampingBuild_C:LockPlayer", isLock)
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  player.inputComponent:SetInputEnable(self, not isLock)
end

return UMG_CampingBuild_C
