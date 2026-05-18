AREA_UI_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.editor_name = r.editor_name
  if r.editor_name == "" then
    lua_record.editor_name = nil
  end
  lua_record.BlockType1 = r.BlockType1
  lua_record.BlockType2 = r.BlockType2
  lua_record.BlockType3 = r.BlockType3
  lua_record.BlockType4 = r.BlockType4
  lua_record.BlockType5 = r.BlockType5
  AREA_UI_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = AREA_UI_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("AREA_UI_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return AREA_UI_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("AREA_UI_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #AREA_UI_CONF then
    return AREA_UI_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return AREA_UI_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("AREA_UI_CONF")
end

return dataTable
