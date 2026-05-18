BALL_ACT = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.editor_name = r.editor_name
  if r.editor_name == "" then
    lua_record.editor_name = nil
  end
  lua_record.Strength = r.Strength
  lua_record.Gravity = r.Gravity
  lua_record.Max_Auto_Find_Target_Distance = r.Max_Auto_Find_Target_Distance
  lua_record.Max_Auto_Find_Target_Angle = r.Max_Auto_Find_Target_Angle
  lua_record.Ball_Breaking_Distance_Min = r.Ball_Breaking_Distance_Min
  lua_record.Ball_Breaking_Distance_Max = r.Ball_Breaking_Distance_Max
  BALL_ACT[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = BALL_ACT[_key]
  if nil == r then
    local r = TinyData.GetRecord("BALL_ACT", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return BALL_ACT[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("BALL_ACT", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #BALL_ACT then
    return BALL_ACT
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return BALL_ACT
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("BALL_ACT")
end

return dataTable
