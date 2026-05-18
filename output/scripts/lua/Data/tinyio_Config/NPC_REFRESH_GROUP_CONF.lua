NPC_REFRESH_GROUP_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.editor_name = r.editor_name
  if r.editor_name == "" then
    lua_record.editor_name = nil
  end
  _content_id = {}
  for i = 0, #r.content_id - 1 do
    table.insert(_content_id, r.content_id[i])
  end
  lua_record.content_id = _content_id
  local _group_reset = {}
  for i = 0, #r.group_reset - 1 do
    local r_2 = r.group_reset[i]
    local lua_record_2 = {}
    lua_record_2.reset_cond = r_2.reset_cond
    lua_record_2.reset_cond_para = r_2.reset_cond_para
    table.insert(_group_reset, lua_record_2)
  end
  lua_record.group_reset = _group_reset
  NPC_REFRESH_GROUP_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = NPC_REFRESH_GROUP_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("NPC_REFRESH_GROUP_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return NPC_REFRESH_GROUP_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("NPC_REFRESH_GROUP_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #NPC_REFRESH_GROUP_CONF then
    return NPC_REFRESH_GROUP_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return NPC_REFRESH_GROUP_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("NPC_REFRESH_GROUP_CONF")
end

return dataTable
