PET_INTERACTION_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.editor_name = r.editor_name
  if r.editor_name == "" then
    lua_record.editor_name = nil
  end
  local _pet_interact_group = {}
  for i = 0, #r.pet_interact_group - 1 do
    local r_2 = r.pet_interact_group[i]
    local lua_record_2 = {}
    local _interact_cond_group = {}
    for i = 0, #r_2.interact_cond_group - 1 do
      local r_2_2 = r_2.interact_cond_group[i]
      local lua_record_2_2 = {}
      lua_record_2_2.interact_cond = r_2_2.interact_cond
      _interact_cond_param = {}
      for i = 0, #r_2_2.interact_cond_param - 1 do
        table.insert(_interact_cond_param, r_2_2.interact_cond_param[i])
      end
      lua_record_2_2.interact_cond_param = _interact_cond_param
      table.insert(_interact_cond_group, lua_record_2_2)
    end
    lua_record_2.interact_cond_group = _interact_cond_group
    lua_record_2.action_type = r_2.action_type
    lua_record_2.action_param1 = r_2.action_param1
    if "" == r_2.action_param1 then
      lua_record_2.action_param1 = nil
    end
    lua_record_2.action_param2 = r_2.action_param2
    if "" == r_2.action_param2 then
      lua_record_2.action_param2 = nil
    end
    lua_record_2.action_param3 = r_2.action_param3
    if "" == r_2.action_param3 then
      lua_record_2.action_param3 = nil
    end
    table.insert(_pet_interact_group, lua_record_2)
  end
  lua_record.pet_interact_group = _pet_interact_group
  PET_INTERACTION_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = PET_INTERACTION_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("PET_INTERACTION_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return PET_INTERACTION_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("PET_INTERACTION_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #PET_INTERACTION_CONF then
    return PET_INTERACTION_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return PET_INTERACTION_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("PET_INTERACTION_CONF")
end

return dataTable
