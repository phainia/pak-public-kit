REWARD_TAG = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.Name = r.Name
  if r.Name == "" then
    lua_record.Name = nil
  end
  REWARD_TAG[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = REWARD_TAG[_key]
  if nil == r then
    local r = TinyData.GetRecord("REWARD_TAG", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return REWARD_TAG[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("REWARD_TAG", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #REWARD_TAG then
    return REWARD_TAG
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return REWARD_TAG
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("REWARD_TAG")
end

return dataTable
