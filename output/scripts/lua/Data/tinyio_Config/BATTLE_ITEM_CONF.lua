BATTLE_ITEM_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.name = r.name
  if r.name == "" then
    lua_record.name = nil
  end
  lua_record.priority_in_bag = r.priority_in_bag
  lua_record.legally_used_object = r.legally_used_object
  lua_record.use_time_in_round = r.use_time_in_round
  lua_record.resource_usage_path = r.resource_usage_path
  if "" == r.resource_usage_path then
    lua_record.resource_usage_path = nil
  end
  lua_record.use_effect_type_in_battle = r.use_effect_type_in_battle
  lua_record.effect_value = r.effect_value
  lua_record.model = r.model
  if "" == r.model then
    lua_record.model = nil
  end
  BATTLE_ITEM_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = BATTLE_ITEM_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("BATTLE_ITEM_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return BATTLE_ITEM_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("BATTLE_ITEM_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #BATTLE_ITEM_CONF then
    return BATTLE_ITEM_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return BATTLE_ITEM_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("BATTLE_ITEM_CONF")
end

return dataTable
