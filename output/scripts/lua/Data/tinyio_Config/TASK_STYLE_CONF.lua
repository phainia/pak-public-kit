TASK_STYLE_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.icon_open = r.icon_open
  if r.icon_open == "" then
    lua_record.icon_open = nil
  end
  lua_record.icon_wait = r.icon_wait
  if "" == r.icon_wait then
    lua_record.icon_wait = nil
  end
  lua_record.icon_done = r.icon_done
  if "" == r.icon_done then
    lua_record.icon_done = nil
  end
  lua_record.minimap_open = r.minimap_open
  lua_record.minimap_wait = r.minimap_wait
  lua_record.normal_item = r.normal_item
  if "" == r.normal_item then
    lua_record.normal_item = nil
  end
  lua_record.selected_item = r.selected_item
  if "" == r.selected_item then
    lua_record.selected_item = nil
  end
  lua_record.track_mark = r.track_mark
  if "" == r.track_mark then
    lua_record.track_mark = nil
  end
  lua_record.background = r.background
  if "" == r.background then
    lua_record.background = nil
  end
  TASK_STYLE_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = TASK_STYLE_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("TASK_STYLE_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return TASK_STYLE_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("TASK_STYLE_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #TASK_STYLE_CONF then
    return TASK_STYLE_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return TASK_STYLE_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("TASK_STYLE_CONF")
end

return dataTable
