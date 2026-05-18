SCENE_ABILITY_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.ability_name = r.ability_name
  if r.ability_name == "" then
    lua_record.ability_name = nil
  end
  lua_record.skill_path = r.skill_path
  if "" == r.skill_path then
    lua_record.skill_path = nil
  end
  lua_record.skill_bp_path = r.skill_bp_path
  if "" == r.skill_bp_path then
    lua_record.skill_bp_path = nil
  end
  lua_record.skill_lua_path = r.skill_lua_path
  if "" == r.skill_lua_path then
    lua_record.skill_lua_path = nil
  end
  lua_record.ability_icon = r.ability_icon
  if "" == r.ability_icon then
    lua_record.ability_icon = nil
  end
  lua_record.ability_block_icon = r.ability_block_icon
  if "" == r.ability_block_icon then
    lua_record.ability_block_icon = nil
  end
  lua_record.scene_ability_slot_cast_type = r.scene_ability_slot_cast_type
  lua_record.cooldown_type = r.cooldown_type
  lua_record.cooldown = r.cooldown
  lua_record.scene_ability_type = r.scene_ability_type
  lua_record.scene_ability_type_id = r.scene_ability_type_id
  lua_record.priority = r.priority
  lua_record.is_passive = r.is_passive
  _add_status = {}
  for i = 0, #r.add_status - 1 do
    table.insert(_add_status, r.add_status[i])
  end
  lua_record.add_status = _add_status
  _remove_status = {}
  for i = 0, #r.remove_status - 1 do
    table.insert(_remove_status, r.remove_status[i])
  end
  lua_record.remove_status = _remove_status
  lua_record.disable_env = r.disable_env
  SCENE_ABILITY_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = SCENE_ABILITY_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("SCENE_ABILITY_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return SCENE_ABILITY_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("SCENE_ABILITY_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #SCENE_ABILITY_CONF then
    return SCENE_ABILITY_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return SCENE_ABILITY_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("SCENE_ABILITY_CONF")
end

return dataTable
