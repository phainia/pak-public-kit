AREA_FUNC_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.editor_name = r.editor_name
  if r.editor_name == "" then
    lua_record.editor_name = nil
  end
  _area_id = {}
  for i = 0, #r.area_id - 1 do
    table.insert(_area_id, r.area_id[i])
  end
  lua_record.area_id = _area_id
  lua_record.name = r.name
  if "" == r.name then
    lua_record.name = nil
  end
  lua_record.safe_region_name = r.safe_region_name
  if "" == r.safe_region_name then
    lua_record.safe_region_name = nil
  end
  lua_record.name_priority = r.name_priority
  lua_record.battle_source = r.battle_source
  if "" == r.battle_source then
    lua_record.battle_source = nil
  end
  lua_record.bgm_id = r.bgm_id
  lua_record.switch_group_name = r.switch_group_name
  if "" == r.switch_group_name then
    lua_record.switch_group_name = nil
  end
  local _area_bgm = {}
  for i = 0, #r.area_bgm - 1 do
    local r_2 = r.area_bgm[i]
    local lua_record_2 = {}
    lua_record_2.start_time = r_2.start_time
    lua_record_2.end_time = r_2.end_time
    lua_record_2.switch = r_2.switch
    if "" == r_2.switch then
      lua_record_2.switch = nil
    end
    table.insert(_area_bgm, lua_record_2)
  end
  lua_record.area_bgm = _area_bgm
  lua_record.bgm_priority = r.bgm_priority
  lua_record.amb_id = r.amb_id
  local _scene_effect = {}
  for i = 0, #r.scene_effect - 1 do
    local r_2 = r.scene_effect[i]
    local lua_record_2 = {}
    lua_record_2.effect_type = r_2.effect_type
    lua_record_2.effect_param1 = r_2.effect_param1
    lua_record_2.effect_param2 = r_2.effect_param2
    table.insert(_scene_effect, lua_record_2)
  end
  lua_record.scene_effect = _scene_effect
  AREA_FUNC_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = AREA_FUNC_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("AREA_FUNC_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return AREA_FUNC_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("AREA_FUNC_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #AREA_FUNC_CONF then
    return AREA_FUNC_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return AREA_FUNC_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("AREA_FUNC_CONF")
end

return dataTable
