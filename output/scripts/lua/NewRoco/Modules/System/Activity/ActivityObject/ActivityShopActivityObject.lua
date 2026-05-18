local Base = require("NewRoco.Modules.System.Activity.ActivityObject.ActivityObjectBase")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local ActivityShopActivityObject = Base:Extend("ActivityShopActivityObject")

function ActivityShopActivityObject:OnConstruct(_conf)
  self.activityShopConf = _G.DataConfigManager:GetActivityShopConf(_conf.base_id[1])
end

function ActivityShopActivityObject:GotoShop()
  ActivityUtils.OpenWorldMap(tonumber(self.activityShopConf.slot_fuction_param))
end

function ActivityShopActivityObject:GetButtonText()
  return self.activityShopConf.open_shop_button_txt
end

function ActivityShopActivityObject:GetShopGoodText()
  return self.activityShopConf.shop_goods_txt
end

function ActivityShopActivityObject:GetShopGoodIcon()
  return self.activityShopConf.shop_goods_icon
end

function ActivityShopActivityObject:GetSortGoodsData()
  local shop_id = self.activityShopConf.activity_shop_id
  local normalShopConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.NORMAL_SHOP_CONF):GetAllDatas()
  local goodsData = {}
  for _, v in pairs(normalShopConf) do
    if v.shop_id == shop_id then
      local iconPath, quality = ActivityUtils.GetItemIconAndQuality(v.Type, v.item_id)
      local itemNum = v.item_num
      if v.buy_limit_num then
        itemNum = itemNum * v.buy_limit_num
      end
      local data = {
        itemType = v.Type,
        itemId = v.item_id,
        quality = quality,
        itemNum = itemNum,
        bShowNum = true
      }
      table.insert(goodsData, data)
    end
  end
  self:SortData(goodsData, function(a, b)
    if a.quality > b.quality then
      return false
    elseif a.quality < b.quality then
      return true
    elseif a.itemNum >= b.itemNum then
      return false
    else
      return true
    end
  end, 1, #goodsData)
  if #goodsData <= 6 then
    return goodsData
  else
    local retData = {}
    for i = 1, 6 do
      table.insert(retData, goodsData[i])
    end
    return retData
  end
end

function ActivityShopActivityObject:SortData(data, func, start, stop)
  if stop <= start then
    return
  end
  local baseItem = data[start]
  local left = start
  local right = stop
  local bRight = true
  while left < right do
    if bRight then
      if func(baseItem, data[right]) then
        data[left] = data[right]
        left = left + 1
        bRight = false
      else
        right = right - 1
      end
    elseif func(data[left], baseItem) then
      data[right] = data[left]
      right = right - 1
      bRight = true
    else
      left = left + 1
    end
  end
  data[left] = baseItem
  self:SortData(data, func, start, left - 1)
  self:SortData(data, func, left + 1, stop)
end

return ActivityShopActivityObject
