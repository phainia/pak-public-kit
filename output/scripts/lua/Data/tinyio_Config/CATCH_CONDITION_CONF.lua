CATCH_CONDITION_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.name = r.name
  if r.name == "" then
    lua_record.name = nil
  end
  lua_record.des = r.des
  if "" == r.des then
    lua_record.des = nil
  end
  lua_record.res_id = r.res_id
  if "" == r.res_id then
    lua_record.res_id = nil
  end
  lua_record.flavor_text = r.flavor_text
  if "" == r.flavor_text then
    lua_record.flavor_text = nil
  end
  lua_record.change_value = r.change_value
  lua_record.max_trigger_time = r.max_trigger_time
  lua_record.effect_order = r.effect_order
  local _condition_param = {}
  for i = 0, #r.condition_param - 1 do
    local r_2 = r.condition_param[i]
    local lua_record_2 = {}
    _params = {}
    for i = 0, #r_2.params - 1 do
      table.insert(_params, r_2.params[i])
    end
    lua_record_2.params = _params
    table.insert(_condition_param, lua_record_2)
  end
  lua_record.condition_param = _condition_param
  CATCH_CONDITION_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = CATCH_CONDITION_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("CATCH_CONDITION_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return CATCH_CONDITION_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("CATCH_CONDITION_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #CATCH_CONDITION_CONF then
    return CATCH_CONDITION_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return CATCH_CONDITION_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("CATCH_CONDITION_CONF")
end

return dataTable
