EFFECT_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.editor_name = r.editor_name
  if r.editor_name == "" then
    lua_record.editor_name = nil
  end
  lua_record.is_special = r.is_special
  lua_record.name = r.name
  if "" == r.name then
    lua_record.name = nil
  end
  lua_record.effect_res = r.effect_res
  lua_record.add_des = r.add_des
  if "" == r.add_des then
    lua_record.add_des = nil
  end
  lua_record.add_icon = r.add_icon
  lua_record.trigger_des = r.trigger_des
  if "" == r.trigger_des then
    lua_record.trigger_des = nil
  end
  lua_record.trigger_icon = r.trigger_icon
  lua_record.special_add = r.special_add
  lua_record.type = r.type
  lua_record.immune_effect_group = r.immune_effect_group
  lua_record.effect_order = r.effect_order
  local _effect_param = {}
  for i = 0, #r.effect_param - 1 do
    local r_2 = r.effect_param[i]
    local lua_record_2 = {}
    _params = {}
    for i = 0, #r_2.params - 1 do
      table.insert(_params, r_2.params[i])
    end
    lua_record_2.params = _params
    table.insert(_effect_param, lua_record_2)
  end
  lua_record.effect_param = _effect_param
  EFFECT_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = EFFECT_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("EFFECT_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return EFFECT_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("EFFECT_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #EFFECT_CONF then
    return EFFECT_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return EFFECT_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("EFFECT_CONF")
end

return dataTable
