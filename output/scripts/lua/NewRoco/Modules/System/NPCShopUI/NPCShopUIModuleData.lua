local NPCShopUIModuleData = _G.NRCData:Extend("NPCShopUIModuleData")
local NPCShopUIModuleEvent = reload("NewRoco.Modules.System.NPCShopUI.NPCShopUIModuleEvent")
local NPCShopUtils = require("NewRoco.Modules.System.NPCShopUI.NPCShopUtils")

function NPCShopUIModuleData:Ctor()
  NRCData.Ctor(self)
  self.NPCActionOpenShop = nil
  self.itemData = {}
  self.showMoneyType = nil
  self.costInfo = {
    0,
    0,
    0
  }
  self.sumCoinCost = 0
  self.sumDiamondCost = 0
  self.PackageContentHadOwnedWhenPurchase = {}
  self.shopDataMap = {}
  self.shopVersionMap = {}
  self.goodsDataMap = {}
end

function NPCShopUIModuleData:SetShopData(ShopRsp)
  Log.Dump(ShopRsp, 8, "NPCShopUIModuleDump---NPCShopUIModuleData:SetShopData_Dump")
  if 0 == ShopRsp.ret_info.ret_code then
    if ShopRsp.shop_data and ShopRsp.shop_data.id then
      local shopID = ShopRsp.shop_data.id
      if shopID then
        self.shopDataMap[shopID] = ShopRsp
        if ShopRsp.shop_data.version ~= nil then
          self.shopVersionMap[shopID] = ShopRsp.shop_data.version
          Log.Info("NPCShopUIModuleData:SetShopData set new version", shopID, ShopRsp.shop_data.version)
        else
          Log.Error("NPCShopUIModuleData:SetShopData shop_data.version is nil", shopID)
        end
        self.goodsDataMap[shopID] = {}
        if ShopRsp.shop_data.goods_data then
          for _, goodsData in ipairs(ShopRsp.shop_data.goods_data) do
            self.goodsDataMap[shopID][goodsData.goods_id] = goodsData
            Log.Info("NPCShopUIModuleData:SetShopData set goodsData", shopID, goodsData.goods_id)
          end
        end
      else
        Log.Warning("NPCShopUIModuleData:SetShopData", "shopID is nil")
      end
    else
      Log.Warning("NPCShopUIModuleData:SetShopData", "shop_data is nil or shop_data.id is nil")
    end
  elseif ShopRsp.ret_info.ret_code == _G.ProtoEnum.MOBA_RET.ZoneErr.ERR_ZONE_SHOP_DATA_NEWEST then
    Log.Info("NPCShopUIModuleData:SetShopData \229\149\134\229\186\151\230\149\176\230\141\174\229\183\178\230\156\128\230\150\176,\228\189\191\231\148\168\231\188\147\229\173\152\230\149\176\230\141\174", ShopRsp.shop_data.id)
  else
    Log.Warning("NPCShopUIModuleData:SetShopData", ShopRsp.ret_info.ret_code, " \229\149\134\229\186\151\230\149\176\230\141\174\233\148\153\232\175\175", ShopRsp.shop_data.id)
  end
end

function NPCShopUIModuleData:GetGoodsSeverData(shopID, goodsID, ignoreWarning)
  if not shopID or not goodsID then
    Log.Error("NPCShopUIModuleData:GetGoodsSeverData", "Invalid parameters", shopID, goodsID)
    return nil
  end
  if not self.goodsDataMap[shopID] then
    Log.Warning("NPCShopUIModuleData:GetGoodsSeverData", "Shop data not found", shopID)
    return nil
  end
  if not self.goodsDataMap[shopID][goodsID] then
    if nil ~= ignoreWarning and ignoreWarning then
      return nil
    end
    Log.Warning("NPCShopUIModuleData:GetGoodsSeverData", "Goods data not found", shopID, goodsID)
    return nil
  end
  return self.goodsDataMap[shopID][goodsID]
end

function NPCShopUIModuleData:GetSubGoodsSeverData(shopID, goodsID, subGoodsID)
  if not (shopID and goodsID) or not subGoodsID then
    Log.Error("NPCShopUIModuleData:GetSubGoodsSeverData", "Invalid parameters", shopID, goodsID, subGoodsID)
    return nil
  end
  local goodsData = self:GetGoodsSeverData(shopID, goodsID)
  if goodsData and goodsData.sub_goods then
    for _, subGoodsData in ipairs(goodsData.sub_goods) do
      if subGoodsData.goods_id == subGoodsID then
        return subGoodsData
      end
    end
  else
    Log.Warning("NPCShopUIModuleData:GetSubGoodsSeverData", "Goods data not found", shopID, goodsID, subGoodsID)
    return nil
  end
  Log.Warning("NPCShopUIModuleData:GetSubGoodsSeverData", "Sub goods data not found", shopID, goodsID, subGoodsID)
  return nil
end

function NPCShopUIModuleData:GetShopData(shopID)
  if self.shopDataMap[shopID] then
    return self.shopDataMap[shopID]
  end
  Log.Warning("NPCShopUIModuleData:GetShopData", "shopID not found", shopID)
  return nil
end

function NPCShopUIModuleData:GetShopDataVersion(shopID)
  if self.shopVersionMap[shopID] then
    return self.shopVersionMap[shopID]
  end
  Log.Info("NPCShopUIModuleData:GetShopDataVersion", "shopID not found or version is 0", shopID)
  return 0
end

function NPCShopUIModuleData:InitItemData(storeList)
  if storeList then
    local storeListCnt = #storeList
    for i = 1, storeListCnt do
      table.insert(self.itemData, {
        shopItemId = storeList[i].shopItemId,
        itemNum = 0,
        itemSumCost = 0
      })
    end
    Log.Dump(storeList, 2, "store_list")
  end
end

function NPCShopUIModuleData:ChangeItemNum(_itemId, _itemNum, shopId)
  local costGoodType, costGoodId
  if self.itemData then
    local itemCnt = #self.itemData
    for i = 1, itemCnt do
      if self.itemData[i].shopItemId == _itemId then
        self.itemData[i].itemNum = _itemNum
        local goodsConf = NPCShopUtils:GetAdjustGoodConf(_itemId, shopId)
        local goodsSevData = self:GetGoodsSeverData(shopId, _itemId)
        local price = goodsConf.origin_price
        if goodsSevData then
          price = goodsSevData.real_price.num
          costGoodType = goodsSevData.real_price.goods_type
          costGoodId = goodsSevData.real_price.goods_id
        end
        self.itemData[i].itemSumCost = _itemNum * price
      end
    end
  end
  self:CalcSumCost(costGoodType, costGoodId)
end

function NPCShopUIModuleData:CalcSumCost(costGoodsType, costGoodId)
  if not costGoodsType or not costGoodId then
    return
  end
  if costGoodsType ~= Enum.GoodsType.GT_VITEM then
    return
  end
  local itemCnt = #self.itemData
  self.costInfo = {
    0,
    0,
    0
  }
  if self.itemData then
    for i = 1, itemCnt do
      local itemID = self.itemData[i].shopItemId
      local _needMoneyType = costGoodId
      if _needMoneyType == self.showMoneyType[1] then
        self.costInfo[1] = self.costInfo[1] + self.itemData[i].itemSumCost
      elseif _needMoneyType == self.showMoneyType[2] then
        self.costInfo[2] = self.costInfo[2] + self.itemData[i].itemSumCost
      elseif _needMoneyType == self.showMoneyType[3] then
        self.costInfo[3] = self.costInfo[3] + self.itemData[i].itemSumCost
      end
    end
  end
  _G.NRCModuleManager:GetModule("NPCShopUIModule"):DispatchEvent(NPCShopUIModuleEvent.NPCSHOP_REFRESH_SUM_COST, self.costInfo)
end

function NPCShopUIModuleData:ClearNum(storeList)
  local itemCnt = #storeList
  for i = 1, itemCnt do
    self.itemData[i].itemNum = 0
    self.itemData[i].itemSumCost = 0
  end
end

function NPCShopUIModuleData:SetOpenNpcShopType(type)
  self.OpenNpcShopType = type
end

function NPCShopUIModuleData:GetOpenNpcShopType()
  return self.OpenNpcShopType
end

function NPCShopUIModuleData:SetMysteriousStoreShopList(itemInfo)
  local shopTable = {}
  local tempList = {}
  for k, v in ipairs(itemInfo) do
    local rewards = _G.NRCCommonItemIconData()
    local goodsConf = _G.DataConfigManager:GetRandomGoodsConf(v.goods_id)
    local itemQuality = 0
    local sortId = 0
    if goodsConf.Type == Enum.GoodsType.GT_BAGITEM then
      local bagItemConf = _G.DataConfigManager:GetBagItemConf(goodsConf.item_id)
      itemQuality = bagItemConf.item_quality or 0
      sortId = bagItemConf.sort_id or 0
      rewards.itemQuantity = itemQuality
    elseif goodsConf.Type == Enum.GoodsType.GT_VITEM then
      local vItemConf = _G.DataConfigManager:GetVisualItemConf(goodsConf.item_id)
      itemQuality = vItemConf.item_quality or 0
      sortId = vItemConf.sort_id or 0
      rewards.itemQuantity = itemQuality
    end
    rewards.itemType = goodsConf.Type
    rewards.itemId = goodsConf.item_id
    rewards.bShowTip = true
    table.insert(tempList, {
      rewards = rewards,
      itemQuality = itemQuality,
      sortId = sortId
    })
  end
  table.sort(tempList, function(a, b)
    if a.itemQuality ~= b.itemQuality then
      return a.itemQuality > b.itemQuality
    else
      return a.sortId < b.sortId
    end
  end)
  for _, v in ipairs(tempList) do
    table.insert(shopTable, v.rewards)
  end
  return shopTable
end

function NPCShopUIModuleData:SetNPCContentID(NPCAction, shopId)
  if NPCAction and NPCAction.OwnerNpc and NPCAction.OwnerNpc.serverData and NPCAction.OwnerNpc.serverData.npc_base and NPCAction.OwnerNpc.serverData.npc_base.npc_content_cfg_id then
    local NPCContentID = NPCAction.OwnerNpc.serverData.npc_base.npc_content_cfg_id
    Log.Debug("NPCShopUIModuleData:SetNPCContentID", shopId, NPCContentID)
    if self.contenthoMap == nil then
      self.contenthoMap = {}
    end
    self.contenthoMap[shopId] = NPCContentID
  end
end

function NPCShopUIModuleData:GetNPCContentID(shopId)
  if self.contenthoMap and self.contenthoMap[shopId] then
    return self.contenthoMap[shopId]
  end
  return nil
end

return NPCShopUIModuleData
