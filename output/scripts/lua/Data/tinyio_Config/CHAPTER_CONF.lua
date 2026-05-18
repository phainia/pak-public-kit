CHAPTER_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.title = r.title
  if r.title == "" then
    lua_record.title = nil
  end
  CHAPTER_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = CHAPTER_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("CHAPTER_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return CHAPTER_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("CHAPTER_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #CHAPTER_CONF then
    return CHAPTER_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return CHAPTER_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("CHAPTER_CONF")
end

return dataTable
