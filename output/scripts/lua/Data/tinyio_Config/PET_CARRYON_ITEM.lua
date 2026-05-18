PET_CARRYON_ITEM = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.editor_name = r.editor_name
  if r.editor_name == "" then
    lua_record.editor_name = nil
  end
  lua_record.can_cost = r.can_cost
  local _carryon_effect = {}
  for i = 0, #r.carryon_effect - 1 do
    local r_2 = r.carryon_effect[i]
    local lua_record_2 = {}
    lua_record_2.sequence_desc = r_2.sequence_desc
    lua_record_2.param1 = r_2.param1
    lua_record_2.param2 = r_2.param2
    table.insert(_carryon_effect, lua_record_2)
  end
  lua_record.carryon_effect = _carryon_effect
  PET_CARRYON_ITEM[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = PET_CARRYON_ITEM[_key]
  if nil == r then
    local r = TinyData.GetRecord("PET_CARRYON_ITEM", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return PET_CARRYON_ITEM[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("PET_CARRYON_ITEM", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #PET_CARRYON_ITEM then
    return PET_CARRYON_ITEM
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return PET_CARRYON_ITEM
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("PET_CARRYON_ITEM")
end

return dataTable
