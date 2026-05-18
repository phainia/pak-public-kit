MODEL_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.editor_name = r.editor_name
  if r.editor_name == "" then
    lua_record.editor_name = nil
  end
  lua_record.path = r.path
  if "" == r.path then
    lua_record.path = nil
  end
  lua_record.lua_class = r.lua_class
  if "" == r.lua_class then
    lua_record.lua_class = nil
  end
  lua_record.icon = r.icon
  if "" == r.icon then
    lua_record.icon = nil
  end
  lua_record.ui_icon = r.ui_icon
  if "" == r.ui_icon then
    lua_record.ui_icon = nil
  end
  lua_record.small_icon = r.small_icon
  if "" == r.small_icon then
    lua_record.small_icon = nil
  end
  lua_record.tired_small_icon = r.tired_small_icon
  if "" == r.tired_small_icon then
    lua_record.tired_small_icon = nil
  end
  lua_record.anim_conf_id = r.anim_conf_id
  MODEL_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = MODEL_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("MODEL_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return MODEL_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("MODEL_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #MODEL_CONF then
    return MODEL_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return MODEL_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("MODEL_CONF")
end

return dataTable
