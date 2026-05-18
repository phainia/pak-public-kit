SCENE_ABILITY_DASH_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.allow_long_press = r.allow_long_press
  lua_record.dash_accelerate = r.dash_accelerate
  lua_record.dash_acc_curve = r.dash_acc_curve
  if r.dash_acc_curve == "" then
    lua_record.dash_acc_curve = nil
  end
  lua_record.dash_deacc_curve = r.dash_deacc_curve
  if "" == r.dash_deacc_curve then
    lua_record.dash_deacc_curve = nil
  end
  lua_record.speed_curve = r.speed_curve
  if "" == r.speed_curve then
    lua_record.speed_curve = nil
  end
  lua_record.dash_max_speed = r.dash_max_speed
  lua_record.vitality_id = r.vitality_id
  lua_record.dash_start_vitality_cost = r.dash_start_vitality_cost
  lua_record.dash_duration = r.dash_duration
  lua_record.dashing_vitality_cost = r.dashing_vitality_cost
  lua_record.dash_cooldown = r.dash_cooldown
  lua_record.dash_rotate_speed = r.dash_rotate_speed
  lua_record.maintain_press_time = r.maintain_press_time
  SCENE_ABILITY_DASH_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = SCENE_ABILITY_DASH_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("SCENE_ABILITY_DASH_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return SCENE_ABILITY_DASH_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("SCENE_ABILITY_DASH_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #SCENE_ABILITY_DASH_CONF then
    return SCENE_ABILITY_DASH_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return SCENE_ABILITY_DASH_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("SCENE_ABILITY_DASH_CONF")
end

return dataTable
