SEQUENCE_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.editor_name = r.editor_name
  if r.editor_name == "" then
    lua_record.editor_name = nil
  end
  lua_record.sequence_path = r.sequence_path
  if "" == r.sequence_path then
    lua_record.sequence_path = nil
  end
  lua_record.begin_black = r.begin_black
  lua_record.end_black = r.end_black
  lua_record.act_x = r.act_x
  lua_record.act_y = r.act_y
  lua_record.act_z = r.act_z
  lua_record.is_hide_npc = r.is_hide_npc
  local _npc_refresh = {}
  for i = 0, #r.npc_refresh - 1 do
    local r_2 = r.npc_refresh[i]
    local lua_record_2 = {}
    lua_record_2.tag = r_2.tag
    if "" == r_2.tag then
      lua_record_2.tag = nil
    end
    lua_record_2.refresh_cfg_id = r_2.refresh_cfg_id
    table.insert(_npc_refresh, lua_record_2)
  end
  lua_record.npc_refresh = _npc_refresh
  SEQUENCE_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = SEQUENCE_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("SEQUENCE_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return SEQUENCE_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("SEQUENCE_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #SEQUENCE_CONF then
    return SEQUENCE_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return SEQUENCE_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("SEQUENCE_CONF")
end

return dataTable
