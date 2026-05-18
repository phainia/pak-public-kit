LOADING_TIPS_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.loading_tips_title = r.loading_tips_title
  if r.loading_tips_title == "" then
    lua_record.loading_tips_title = nil
  end
  lua_record.loading_tips_text = r.loading_tips_text
  if "" == r.loading_tips_text then
    lua_record.loading_tips_text = nil
  end
  LOADING_TIPS_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = LOADING_TIPS_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("LOADING_TIPS_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return LOADING_TIPS_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("LOADING_TIPS_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #LOADING_TIPS_CONF then
    return LOADING_TIPS_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return LOADING_TIPS_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("LOADING_TIPS_CONF")
end

return dataTable
