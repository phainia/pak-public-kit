TELEPORT_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.resurrection_group = r.resurrection_group
  _teleport_actor_types = {}
  for i = 0, #r.teleport_actor_types - 1 do
    table.insert(_teleport_actor_types, r.teleport_actor_types[i])
  end
  lua_record.teleport_actor_types = _teleport_actor_types
  lua_record.teleport_actor_param = r.teleport_actor_param
  if r.teleport_actor_param == "" then
    lua_record.teleport_actor_param = nil
  end
  lua_record.teleport_begin_point_type = r.teleport_begin_point_type
  lua_record.teleport_dest_type = r.teleport_dest_type
  local _teleport_dest = {}
  for i = 0, #r.teleport_dest - 1 do
    local r_2 = r.teleport_dest[i]
    local lua_record_2 = {}
    lua_record_2.dest_id = r_2.dest_id
    lua_record_2.dest_param = r_2.dest_param
    if "" == r_2.dest_param then
      lua_record_2.dest_param = nil
    end
    lua_record_2.dest_weight = r_2.dest_weight
    table.insert(_teleport_dest, lua_record_2)
  end
  lua_record.teleport_dest = _teleport_dest
  TELEPORT_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = TELEPORT_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("TELEPORT_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return TELEPORT_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("TELEPORT_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #TELEPORT_CONF then
    return TELEPORT_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return TELEPORT_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("TELEPORT_CONF")
end

return dataTable
