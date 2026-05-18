BST_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.update_ring_objs_interval = r.update_ring_objs_interval
  lua_record.ring_bst_limit = r.ring_bst_limit
  lua_record.be_joined_ring_bst_limit = r.be_joined_ring_bst_limit
  lua_record.ring_cnt = r.ring_cnt
  _ring_limit_rates = {}
  for i = 0, #r.ring_limit_rates - 1 do
    table.insert(_ring_limit_rates, r.ring_limit_rates[i])
  end
  lua_record.ring_limit_rates = _ring_limit_rates
  _ring_size_rates = {}
  for i = 0, #r.ring_size_rates - 1 do
    table.insert(_ring_size_rates, r.ring_size_rates[i])
  end
  lua_record.ring_size_rates = _ring_size_rates
  _sight_extent = {}
  for i = 0, #r.sight_extent - 1 do
    table.insert(_sight_extent, r.sight_extent[i])
  end
  lua_record.sight_extent = _sight_extent
  lua_record.insight_weight = r.insight_weight
  lua_record.distance_max_weight = r.distance_max_weight
  lua_record.object_weight = r.object_weight
  _hist_insight_weight = {}
  for i = 0, #r.hist_insight_weight - 1 do
    table.insert(_hist_insight_weight, r.hist_insight_weight[i])
  end
  lua_record.hist_insight_weight = _hist_insight_weight
  BST_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = BST_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("BST_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return BST_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("BST_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #BST_CONF then
    return BST_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return BST_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("BST_CONF")
end

return dataTable
