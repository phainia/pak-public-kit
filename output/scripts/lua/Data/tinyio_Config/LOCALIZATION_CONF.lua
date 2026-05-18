LOCALIZATION_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  if r.id == "" then
    lua_record.id = nil
  end
  lua_record.msg = r.msg
  if "" == r.msg then
    lua_record.msg = nil
  end
  lua_record.editor_name = r.editor_name
  if "" == r.editor_name then
    lua_record.editor_name = nil
  end
  LOCALIZATION_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = LOCALIZATION_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("LOCALIZATION_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return LOCALIZATION_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("LOCALIZATION_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #LOCALIZATION_CONF then
    return LOCALIZATION_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return LOCALIZATION_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("LOCALIZATION_CONF")
end

return dataTable
