MALL_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.name = r.name
  if r.name == "" then
    lua_record.name = nil
  end
  lua_record.IconPath = r.IconPath
  if "" == r.IconPath then
    lua_record.IconPath = nil
  end
  lua_record.Desc = r.Desc
  if "" == r.Desc then
    lua_record.Desc = nil
  end
  lua_record.Enable = r.Enable
  lua_record.limit_type = r.limit_type
  lua_record.replenish_cnt = r.replenish_cnt
  lua_record.keep_replenish_cnt = r.keep_replenish_cnt
  lua_record.keep_replenish_limit = r.keep_replenish_limit
  lua_record.ISWeekendSell = r.ISWeekendSell
  lua_record.IsHide = r.IsHide
  lua_record.EnableTime = r.EnableTime
  lua_record.DisableTime = r.DisableTime
  lua_record.GoodsType = r.GoodsType
  lua_record.MaxBuyCount = r.MaxBuyCount
  lua_record.time_start = r.time_start
  lua_record.time_end = r.time_end
  lua_record.RewardGoodsType = r.RewardGoodsType
  lua_record.RewardGoodsId = r.RewardGoodsId
  lua_record.RewardGoodsNum = r.RewardGoodsNum
  lua_record.limitID = r.limitID
  lua_record.Discount = r.Discount
  local _SellPriceItem = {}
  for i = 0, #r.SellPriceItem - 1 do
    local r_2 = r.SellPriceItem[i]
    local lua_record_2 = {}
    lua_record_2.Type = r_2.Type
    lua_record_2.Id = r_2.Id
    lua_record_2.Cost = r_2.Cost
    table.insert(_SellPriceItem, lua_record_2)
  end
  lua_record.SellPriceItem = _SellPriceItem
  lua_record.LimitTime = r.LimitTime
  lua_record.Isfree = r.Isfree
  MALL_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = MALL_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("MALL_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return MALL_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("MALL_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #MALL_CONF then
    return MALL_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return MALL_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("MALL_CONF")
end

return dataTable
