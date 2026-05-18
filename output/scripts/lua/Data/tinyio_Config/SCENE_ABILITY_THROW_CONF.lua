SCENE_ABILITY_THROW_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.limit_pitch = r.limit_pitch
  lua_record.pitch_max = r.pitch_max
  lua_record.pitch_min = r.pitch_min
  lua_record.limit_yaw = r.limit_yaw
  lua_record.yaw_max = r.yaw_max
  lua_record.yaw_min = r.yaw_min
  lua_record.rideaim_pet_turn_speed = r.rideaim_pet_turn_speed
  SCENE_ABILITY_THROW_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = SCENE_ABILITY_THROW_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("SCENE_ABILITY_THROW_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return SCENE_ABILITY_THROW_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("SCENE_ABILITY_THROW_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #SCENE_ABILITY_THROW_CONF then
    return SCENE_ABILITY_THROW_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return SCENE_ABILITY_THROW_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("SCENE_ABILITY_THROW_CONF")
end

return dataTable
