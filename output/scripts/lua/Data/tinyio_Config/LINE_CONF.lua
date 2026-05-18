LINE_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.scene_id = r.scene_id
  local _link = {}
  for i = 0, #r.link - 1 do
    local r_2 = r.link[i]
    local lua_record_2 = {}
    lua_record_2.link_type = r_2.link_type
    lua_record_2.link_param = r_2.link_param
    table.insert(_link, lua_record_2)
  end
  lua_record.link = _link
  LINE_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = LINE_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("LINE_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return LINE_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("LINE_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #LINE_CONF then
    return LINE_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return LINE_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("LINE_CONF")
end

return dataTable
