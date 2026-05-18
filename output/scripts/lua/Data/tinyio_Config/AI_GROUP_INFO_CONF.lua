AI_GROUP_INFO_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.visual_near = r.visual_near
  lua_record.visual_medium = r.visual_medium
  lua_record.visual_far = r.visual_far
  lua_record.visual_angle = r.visual_angle
  lua_record.hearing_radius = r.hearing_radius
  lua_record.alert_threshold = r.alert_threshold
  lua_record.perceiving_threshold = r.perceiving_threshold
  _tod_enum = {}
  for i = 0, #r.tod_enum - 1 do
    table.insert(_tod_enum, r.tod_enum[i])
  end
  lua_record.tod_enum = _tod_enum
  _tod_visual_factor = {}
  for i = 0, #r.tod_visual_factor - 1 do
    table.insert(_tod_visual_factor, r.tod_visual_factor[i])
  end
  lua_record.tod_visual_factor = _tod_visual_factor
  _weather_type = {}
  for i = 0, #r.weather_type - 1 do
    table.insert(_weather_type, r.weather_type[i])
  end
  lua_record.weather_type = _weather_type
  _weather_visual_factor = {}
  for i = 0, #r.weather_visual_factor - 1 do
    table.insert(_weather_visual_factor, r.weather_visual_factor[i])
  end
  lua_record.weather_visual_factor = _weather_visual_factor
  lua_record.pitch_offset_agngle = r.pitch_offset_agngle
  lua_record.yaw_offset_angle = r.yaw_offset_angle
  lua_record.start_state_id = r.start_state_id
  local _behavior_group = {}
  for i = 0, #r.behavior_group - 1 do
    local r_2 = r.behavior_group[i]
    local lua_record_2 = {}
    lua_record_2.state_id = r_2.state_id
    lua_record_2.behavior_id = r_2.behavior_id
    table.insert(_behavior_group, lua_record_2)
  end
  lua_record.behavior_group = _behavior_group
  AI_GROUP_INFO_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = AI_GROUP_INFO_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("AI_GROUP_INFO_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return AI_GROUP_INFO_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("AI_GROUP_INFO_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #AI_GROUP_INFO_CONF then
    return AI_GROUP_INFO_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return AI_GROUP_INFO_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("AI_GROUP_INFO_CONF")
end

return dataTable
