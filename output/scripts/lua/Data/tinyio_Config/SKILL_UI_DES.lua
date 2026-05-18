SKILL_UI_DES = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  if r.id == "" then
    lua_record.id = nil
  end
  lua_record.ui_des = r.ui_des
  if "" == r.ui_des then
    lua_record.ui_des = nil
  end
  lua_record.icon = r.icon
  if "" == r.icon then
    lua_record.icon = nil
  end
  SKILL_UI_DES[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = SKILL_UI_DES[_key]
  if nil == r then
    local r = TinyData.GetRecord("SKILL_UI_DES", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return SKILL_UI_DES[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("SKILL_UI_DES", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #SKILL_UI_DES then
    return SKILL_UI_DES
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return SKILL_UI_DES
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("SKILL_UI_DES")
end

return dataTable
