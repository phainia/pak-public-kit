SCENE_PLAYER_STATUS_MATRIX = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.status_type = r.status_type
  _op_code = {}
  for i = 0, #r.op_code - 1 do
    table.insert(_op_code, r.op_code[i])
  end
  lua_record.op_code = _op_code
  SCENE_PLAYER_STATUS_MATRIX[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = SCENE_PLAYER_STATUS_MATRIX[_key]
  if nil == r then
    local r = TinyData.GetRecord("SCENE_PLAYER_STATUS_MATRIX", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return SCENE_PLAYER_STATUS_MATRIX[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("SCENE_PLAYER_STATUS_MATRIX", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #SCENE_PLAYER_STATUS_MATRIX then
    return SCENE_PLAYER_STATUS_MATRIX
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return SCENE_PLAYER_STATUS_MATRIX
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("SCENE_PLAYER_STATUS_MATRIX")
end

return dataTable
