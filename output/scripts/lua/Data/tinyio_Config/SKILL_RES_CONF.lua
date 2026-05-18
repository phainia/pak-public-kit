SKILL_RES_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.editor_name = r.editor_name
  if r.editor_name == "" then
    lua_record.editor_name = nil
  end
  lua_record.res_id = r.res_id
  if "" == r.res_id then
    lua_record.res_id = nil
  end
  SKILL_RES_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = SKILL_RES_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("SKILL_RES_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return SKILL_RES_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("SKILL_RES_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #SKILL_RES_CONF then
    return SKILL_RES_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return SKILL_RES_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("SKILL_RES_CONF")
end

return dataTable
