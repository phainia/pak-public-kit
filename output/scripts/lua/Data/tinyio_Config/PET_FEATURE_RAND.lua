PET_FEATURE_RAND = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.editor_name = r.editor_name
  if r.editor_name == "" then
    lua_record.editor_name = nil
  end
  local _feature_rand = {}
  for i = 0, #r.feature_rand - 1 do
    local r_2 = r.feature_rand[i]
    local lua_record_2 = {}
    lua_record_2.pet_feature_id = r_2.pet_feature_id
    lua_record_2.weight = r_2.weight
    table.insert(_feature_rand, lua_record_2)
  end
  lua_record.feature_rand = _feature_rand
  PET_FEATURE_RAND[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = PET_FEATURE_RAND[_key]
  if nil == r then
    local r = TinyData.GetRecord("PET_FEATURE_RAND", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return PET_FEATURE_RAND[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("PET_FEATURE_RAND", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #PET_FEATURE_RAND then
    return PET_FEATURE_RAND
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return PET_FEATURE_RAND
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("PET_FEATURE_RAND")
end

return dataTable
