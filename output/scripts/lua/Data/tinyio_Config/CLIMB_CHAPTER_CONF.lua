CLIMB_CHAPTER_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.ID = r.ID
  lua_record.name = r.name
  if r.name == "" then
    lua_record.name = nil
  end
  _stage = {}
  for i = 0, #r.stage - 1 do
    table.insert(_stage, r.stage[i])
  end
  lua_record.stage = _stage
  CLIMB_CHAPTER_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = CLIMB_CHAPTER_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("CLIMB_CHAPTER_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return CLIMB_CHAPTER_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("CLIMB_CHAPTER_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #CLIMB_CHAPTER_CONF then
    return CLIMB_CHAPTER_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.ID, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return CLIMB_CHAPTER_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("CLIMB_CHAPTER_CONF")
end

return dataTable
