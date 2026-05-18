ATTRIBUTE_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.attribute = r.attribute
  lua_record.editor_name = r.editor_name
  if r.editor_name == "" then
    lua_record.editor_name = nil
  end
  lua_record.attribute_name = r.attribute_name
  if "" == r.attribute_name then
    lua_record.attribute_name = nil
  end
  lua_record.attribute_icon = r.attribute_icon
  if "" == r.attribute_icon then
    lua_record.attribute_icon = nil
  end
  lua_record.attr_ui_type = r.attr_ui_type
  lua_record.is_ui_show = r.is_ui_show
  lua_record.is_percent_attr = r.is_percent_attr
  ATTRIBUTE_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = ATTRIBUTE_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("ATTRIBUTE_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return ATTRIBUTE_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("ATTRIBUTE_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #ATTRIBUTE_CONF then
    return ATTRIBUTE_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.attribute, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return ATTRIBUTE_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("ATTRIBUTE_CONF")
end

return dataTable
