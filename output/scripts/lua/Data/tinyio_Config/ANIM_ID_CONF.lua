ANIM_ID_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.anim_name = r.anim_name
  if r.anim_name == "" then
    lua_record.anim_name = nil
  end
  lua_record.id = r.id
  ANIM_ID_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = ANIM_ID_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("ANIM_ID_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return ANIM_ID_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("ANIM_ID_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #ANIM_ID_CONF then
    return ANIM_ID_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return ANIM_ID_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("ANIM_ID_CONF")
end

return dataTable
