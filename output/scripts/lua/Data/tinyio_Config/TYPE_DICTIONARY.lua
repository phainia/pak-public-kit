TYPE_DICTIONARY = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.type_restraint1 = r.type_restraint1
  lua_record.type_restraint2 = r.type_restraint2
  lua_record.type_restraint3 = r.type_restraint3
  lua_record.type_restraint4 = r.type_restraint4
  lua_record.type_restraint5 = r.type_restraint5
  lua_record.type_restraint6 = r.type_restraint6
  lua_record.type_restraint7 = r.type_restraint7
  lua_record.type_restraint8 = r.type_restraint8
  lua_record.type_restraint9 = r.type_restraint9
  lua_record.type_restraint10 = r.type_restraint10
  lua_record.type_restraint11 = r.type_restraint11
  lua_record.type_restraint12 = r.type_restraint12
  lua_record.type_restraint13 = r.type_restraint13
  lua_record.type_restraint14 = r.type_restraint14
  lua_record.type_restraint15 = r.type_restraint15
  lua_record.type_restraint16 = r.type_restraint16
  lua_record.type_restraint17 = r.type_restraint17
  lua_record.type_restraint18 = r.type_restraint18
  lua_record.type_restraint19 = r.type_restraint19
  lua_record.type_restraint20 = r.type_restraint20
  lua_record.type_name = r.type_name
  if r.type_name == "" then
    lua_record.type_name = nil
  end
  lua_record.short_name = r.short_name
  if "" == r.short_name then
    lua_record.short_name = nil
  end
  lua_record.type_icon = r.type_icon
  if "" == r.type_icon then
    lua_record.type_icon = nil
  end
  lua_record.evo_bg_path = r.evo_bg_path
  if "" == r.evo_bg_path then
    lua_record.evo_bg_path = nil
  end
  lua_record.evo_banding_color = r.evo_banding_color
  if "" == r.evo_banding_color then
    lua_record.evo_banding_color = nil
  end
  lua_record.field_res = r.field_res
  if "" == r.field_res then
    lua_record.field_res = nil
  end
  TYPE_DICTIONARY[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = TYPE_DICTIONARY[_key]
  if nil == r then
    local r = TinyData.GetRecord("TYPE_DICTIONARY", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return TYPE_DICTIONARY[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("TYPE_DICTIONARY", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #TYPE_DICTIONARY then
    return TYPE_DICTIONARY
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return TYPE_DICTIONARY
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("TYPE_DICTIONARY")
end

return dataTable
