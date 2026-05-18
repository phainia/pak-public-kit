PET_HANDBOOK = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.handbook_id = r.handbook_id
  lua_record.name = r.name
  if r.name == "" then
    lua_record.name = nil
  end
  lua_record.id = r.id
  lua_record.JL_res = r.JL_res
  if "" == r.JL_res then
    lua_record.JL_res = nil
  end
  lua_record.XG_res_1 = r.XG_res_1
  if "" == r.XG_res_1 then
    lua_record.XG_res_1 = nil
  end
  lua_record.description_meet = r.description_meet
  if "" == r.description_meet then
    lua_record.description_meet = nil
  end
  lua_record.XG_res_2 = r.XG_res_2
  if "" == r.XG_res_2 then
    lua_record.XG_res_2 = nil
  end
  lua_record.description_catch = r.description_catch
  if "" == r.description_catch then
    lua_record.description_catch = nil
  end
  local _pet_handbook = {}
  for i = 0, #r.pet_handbook - 1 do
    local r_2 = r.pet_handbook[i]
    local lua_record_2 = {}
    lua_record_2.handbook_level_point = r_2.handbook_level_point
    lua_record_2.handbook_exp = r_2.handbook_exp
    lua_record_2.award_type = r_2.award_type
    _award_data = {}
    for i = 0, #r_2.award_data - 1 do
      table.insert(_award_data, r_2.award_data[i])
    end
    lua_record_2.award_data = _award_data
    table.insert(_pet_handbook, lua_record_2)
  end
  lua_record.pet_handbook = _pet_handbook
  PET_HANDBOOK[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = PET_HANDBOOK[_key]
  if nil == r then
    local r = TinyData.GetRecord("PET_HANDBOOK", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return PET_HANDBOOK[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("PET_HANDBOOK", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #PET_HANDBOOK then
    return PET_HANDBOOK
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return PET_HANDBOOK
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("PET_HANDBOOK")
end

return dataTable
