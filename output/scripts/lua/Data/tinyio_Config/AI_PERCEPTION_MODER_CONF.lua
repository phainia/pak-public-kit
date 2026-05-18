AI_PERCEPTION_MODER_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.editor_name = r.editor_name
  if r.editor_name == "" then
    lua_record.editor_name = nil
  end
  _offset_angle = {}
  for i = 0, #r.offset_angle - 1 do
    table.insert(_offset_angle, r.offset_angle[i])
  end
  lua_record.offset_angle = _offset_angle
  _tod = {}
  for i = 0, #r.tod - 1 do
    table.insert(_tod, r.tod[i])
  end
  lua_record.tod = _tod
  AI_PERCEPTION_MODER_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = AI_PERCEPTION_MODER_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("AI_PERCEPTION_MODER_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return AI_PERCEPTION_MODER_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("AI_PERCEPTION_MODER_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #AI_PERCEPTION_MODER_CONF then
    return AI_PERCEPTION_MODER_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return AI_PERCEPTION_MODER_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("AI_PERCEPTION_MODER_CONF")
end

return dataTable
