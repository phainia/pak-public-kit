AI_PERCEPTION_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.editor_name = r.editor_name
  if r.editor_name == "" then
    lua_record.editor_name = nil
  end
  lua_record.visual_near = r.visual_near
  lua_record.visual_medium = r.visual_medium
  lua_record.visual_far = r.visual_far
  lua_record.visual_angle = r.visual_angle
  lua_record.hearing_radius = r.hearing_radius
  lua_record.alert_threshold = r.alert_threshold
  lua_record.perceiving_threshold = r.perceiving_threshold
  AI_PERCEPTION_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = AI_PERCEPTION_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("AI_PERCEPTION_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return AI_PERCEPTION_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("AI_PERCEPTION_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #AI_PERCEPTION_CONF then
    return AI_PERCEPTION_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return AI_PERCEPTION_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("AI_PERCEPTION_CONF")
end

return dataTable
