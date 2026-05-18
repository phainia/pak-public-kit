UI_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  if r.id == "" then
    lua_record.id = nil
  end
  lua_record.id_num = r.id_num
  lua_record.umg_path = r.umg_path
  if "" == r.umg_path then
    lua_record.umg_path = nil
  end
  lua_record.module = r.module
  if "" == r.module then
    lua_record.module = nil
  end
  lua_record.layer = r.layer
  if "" == r.layer then
    lua_record.layer = nil
  end
  lua_record.no_close_behind = r.no_close_behind
  lua_record.no_loading_modal = r.no_loading_modal
  lua_record.cache_mode = r.cache_mode
  lua_record.parameters = r.parameters
  if "" == r.parameters then
    lua_record.parameters = nil
  end
  UI_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = UI_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("UI_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return UI_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("UI_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #UI_CONF then
    return UI_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id_num, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return UI_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("UI_CONF")
end

return dataTable
