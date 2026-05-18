SCENE_ABILITY_FLYING_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.jump_height = r.jump_height
  lua_record.gravity = r.gravity
  lua_record.max_downward_spd = r.max_downward_spd
  lua_record.max_speed_curve = r.max_speed_curve
  if r.max_speed_curve == "" then
    lua_record.max_speed_curve = nil
  end
  lua_record.accelerate = r.accelerate
  lua_record.turn_threshold = r.turn_threshold
  lua_record.fly_delta_angular_speed = r.fly_delta_angular_speed
  lua_record.ride_pet_bp = r.ride_pet_bp
  if "" == r.ride_pet_bp then
    lua_record.ride_pet_bp = nil
  end
  lua_record.ascend_ability_id = r.ascend_ability_id
  lua_record.rider_anim_bp = r.rider_anim_bp
  if "" == r.rider_anim_bp then
    lua_record.rider_anim_bp = nil
  end
  lua_record.jump_curve = r.jump_curve
  if "" == r.jump_curve then
    lua_record.jump_curve = nil
  end
  SCENE_ABILITY_FLYING_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = SCENE_ABILITY_FLYING_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("SCENE_ABILITY_FLYING_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return SCENE_ABILITY_FLYING_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("SCENE_ABILITY_FLYING_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #SCENE_ABILITY_FLYING_CONF then
    return SCENE_ABILITY_FLYING_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return SCENE_ABILITY_FLYING_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("SCENE_ABILITY_FLYING_CONF")
end

return dataTable
