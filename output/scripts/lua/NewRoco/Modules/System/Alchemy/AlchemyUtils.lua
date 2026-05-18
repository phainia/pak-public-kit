local AlchemyUtils = {}

function AlchemyUtils.GetCanExchangeNum(exchange_conf, remain_exchange_times)
  local itemExchangeNum = AlchemyUtils.GetItemCanExchangeNum(exchange_conf)
  local coinExchangeNum = AlchemyUtils.GetCoinCanExchangeNum(exchange_conf)
  local limitExchangeNum = AlchemyUtils.GetItemExchangeRemainNum(exchange_conf)
  if remain_exchange_times then
    limitExchangeNum = math.min(remain_exchange_times, limitExchangeNum)
  end
  return math.min(itemExchangeNum, coinExchangeNum, limitExchangeNum)
end

function AlchemyUtils.GetItemExchangeRemainNum(exchange_conf)
  local remainNum = 9999
  if exchange_conf and exchange_conf.get_item and #exchange_conf.get_item > 0 then
    local Item = exchange_conf.get_item[1]
    if Item and Item.get_goods_type == _G.Enum.GoodsType.GT_VITEM and Item.get_goods_id == _G.Enum.VisualItem.VI_STAR_DEBRIS then
      local hasNum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(Item.get_goods_id) or 0
      local limitNum = _G.DataConfigManager:GetRoleGlobalConfig("star_debris_top_limit")
      remainNum = limitNum.num - hasNum
    end
  end
  return remainNum
end

function AlchemyUtils.GetItemCanExchangeNum(exchange_conf)
  if not exchange_conf then
    return 0
  end
  local canExchangeNum = -1
  local bubbleNum = _G.DataConfigManager:GetGlobalConfigNumByKey("exchange_bubble_max_num", 4)
  local alternateIndex = -1
  for i, costItem in ipairs(exchange_conf.cost_item) do
    local goodsList = costItem.cost_goods_id
    if 1 == #goodsList then
      local itemNum = _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.GetMaterialNum, goodsList[1], costItem.cost_goods_type)
      local num = math.floor(itemNum / costItem.cost_goods_num)
      if -1 == canExchangeNum then
        canExchangeNum = num
      elseif num < canExchangeNum then
        canExchangeNum = num
      end
      bubbleNum = bubbleNum - 1
    elseif #goodsList > 1 then
      alternateIndex = i
    end
  end
  if alternateIndex > 0 and bubbleNum > 0 then
    local costItem = exchange_conf.cost_item[alternateIndex]
    local alternateMaterials = _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.GetAlternateMaterials)
    local itemNum = 0
    local materialMap = {}
    for _, material_id in ipairs(alternateMaterials) do
      if bubbleNum <= 0 then
        break
      end
      itemNum = itemNum + _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.GetMaterialNum, material_id, costItem.cost_goods_type)
      materialMap[material_id] = true
      bubbleNum = bubbleNum - 1
    end
    local dataList = {}
    for _, goodsId in ipairs(costItem.cost_goods_id) do
      local num = _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.GetMaterialNum, goodsId, costItem.cost_goods_type)
      local itemData = {itemId = goodsId, itemNum = num}
      table.insert(dataList, itemData)
    end
    dataList = _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.GetSortGoodsList, dataList, costItem.cost_goods_type)
    for _, itemData in ipairs(dataList) do
      if bubbleNum <= 0 then
        break
      end
      local goodsId = itemData.itemId
      if not materialMap[goodsId] then
        itemNum = itemNum + _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.GetMaterialNum, goodsId, costItem.cost_goods_type)
        bubbleNum = bubbleNum - 1
      end
    end
    local num = math.floor(itemNum / costItem.cost_goods_num)
    if -1 == canExchangeNum then
      canExchangeNum = num
    elseif num < canExchangeNum then
      canExchangeNum = num
    end
  end
  if -1 == canExchangeNum then
    canExchangeNum = 0
  end
  return canExchangeNum
end

function AlchemyUtils.GetCoinCanExchangeNum(exchange_conf)
  local canExchangeNum = 10000000
  local CurrentCoin = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_COIN) or 0
  if exchange_conf.visual_item_cost_num then
    local num = math.floor(CurrentCoin / exchange_conf.visual_item_cost_num)
    if canExchangeNum > num then
      canExchangeNum = num
    end
  end
  return canExchangeNum
end

function AlchemyUtils.BuildItemHash()
end

function AlchemyUtils.ClearHash()
end

function AlchemyUtils.GetBagItemByID(id)
  return _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.GetBagItemByID, id)
end

function AlchemyUtils.GetRemainExchangeTimes(exchange_time_limit_group, group_info_table)
  if exchange_time_limit_group then
    local exchangeTimeLimitConf = _G.DataConfigManager:GetExchangeTimeLimitConf(exchange_time_limit_group, true)
    if exchangeTimeLimitConf and group_info_table and group_info_table[exchange_time_limit_group] then
      return exchangeTimeLimitConf.exchange_manufacture_times - group_info_table[exchange_time_limit_group].exchange_times
    end
  end
  return nil
end

function AlchemyUtils.GetCurrentExchangeNum(exchange_conf)
  if not exchange_conf then
    return 0
  end
  local canExchangeNum = -1
  local bubbleNum = _G.DataConfigManager:GetGlobalConfigNumByKey("exchange_bubble_max_num", 4)
  local alternateIndex = -1
  for i, costItem in ipairs(exchange_conf.cost_item) do
    local goodsList = costItem.cost_goods_id
    if 1 == #goodsList then
      local itemNum = _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.GetMaterialNum, goodsList[1], costItem.cost_goods_type)
      local num = math.floor(itemNum / costItem.cost_goods_num)
      if -1 == canExchangeNum then
        canExchangeNum = num
      elseif num < canExchangeNum then
        canExchangeNum = num
      end
      bubbleNum = bubbleNum - 1
    elseif #goodsList > 1 then
      alternateIndex = i
    end
  end
  if alternateIndex > 0 and bubbleNum > 0 then
    local costItem = exchange_conf.cost_item[alternateIndex]
    local alternateMaterials = _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.GetAlternateMaterials)
    local itemNum = 0
    for _, material_id in ipairs(alternateMaterials) do
      if bubbleNum <= 0 then
        break
      end
      itemNum = itemNum + _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.GetMaterialNum, material_id, costItem.cost_goods_type)
      bubbleNum = bubbleNum - 1
    end
    local num = math.floor(itemNum / costItem.cost_goods_num)
    if -1 == canExchangeNum then
      canExchangeNum = num
    elseif num < canExchangeNum then
      canExchangeNum = num
    end
  end
  if canExchangeNum <= 0 then
    canExchangeNum = 1
  end
  return canExchangeNum
end

function AlchemyUtils.GetCanExchange(exchange_conf, group_info_table)
  if not exchange_conf or not group_info_table then
    return false
  end
  local remainExchangeTimes = AlchemyUtils.GetRemainExchangeTimes(exchange_conf.exchange_time_limit_group, group_info_table)
  if remainExchangeTimes and remainExchangeTimes <= 0 then
    return false
  end
  local itemExchangeRemainNum = AlchemyUtils.GetItemExchangeRemainNum(exchange_conf)
  if itemExchangeRemainNum <= 0 then
    return false
  end
  local CurrentCoin = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_COIN) or 0
  if exchange_conf.visual_item_cost_num and CurrentCoin < exchange_conf.visual_item_cost_num then
    return false
  end
  local bubbleNum = _G.DataConfigManager:GetGlobalConfigNumByKey("exchange_bubble_max_num", 4)
  local alternateIndex = -1
  for i, costItem in ipairs(exchange_conf.cost_item) do
    local goodsList = costItem.cost_goods_id
    if 1 == #goodsList then
      local itemNum = _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.GetMaterialNum, goodsList[1], costItem.cost_goods_type)
      if itemNum < costItem.cost_goods_num then
        return false
      end
      bubbleNum = bubbleNum - 1
    elseif #goodsList > 1 then
      alternateIndex = i
    end
  end
  if alternateIndex > 0 and bubbleNum > 0 then
    local costItem = exchange_conf.cost_item[alternateIndex]
    local itemNum = 0
    local dataList = {}
    for _, goodsId in ipairs(costItem.cost_goods_id) do
      local num = _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.GetMaterialNum, goodsId, costItem.cost_goods_type)
      local itemData = {itemId = goodsId, itemNum = num}
      table.insert(dataList, itemData)
    end
    dataList = _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.GetSortGoodsList, dataList, costItem.cost_goods_type)
    for _, itemData in ipairs(dataList) do
      local goodsId = itemData.itemId
      itemNum = itemNum + _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.GetMaterialNum, goodsId, costItem.cost_goods_type)
      bubbleNum = bubbleNum - 1
      if itemNum >= costItem.cost_goods_num then
        return true
      end
      if bubbleNum <= 0 then
        break
      end
    end
    if itemNum < costItem.cost_goods_num then
      return false
    end
  end
  return true
end

return AlchemyUtils
