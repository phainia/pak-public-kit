SKILL_TAG = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.tag = r.tag
  if r.tag == "" then
    lua_record.tag = nil
  end
  _condition_skillid = {}
  for i = 0, #r.condition_skillid - 1 do
    table.insert(_condition_skillid, r.condition_skillid[i])
  end
  lua_record.condition_skillid = _condition_skillid
  _condition_effecttype = {}
  for i = 0, #r.condition_effecttype - 1 do
    table.insert(_condition_effecttype, r.condition_effecttype[i])
  end
  lua_record.condition_effecttype = _condition_effecttype
  _condition_bufftype = {}
  for i = 0, #r.condition_bufftype - 1 do
    table.insert(_condition_bufftype, r.condition_bufftype[i])
  end
  lua_record.condition_bufftype = _condition_bufftype
  lua_record.tag_icon = r.tag_icon
  if "" == r.tag_icon then
    lua_record.tag_icon = nil
  end
  SKILL_TAG[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = SKILL_TAG[_key]
  if nil == r then
    local r = TinyData.GetRecord("SKILL_TAG", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return SKILL_TAG[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("SKILL_TAG", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #SKILL_TAG then
    return SKILL_TAG
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return SKILL_TAG
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("SKILL_TAG")
end

return dataTable
