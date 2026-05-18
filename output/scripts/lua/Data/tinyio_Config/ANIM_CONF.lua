ANIM_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  local _anim_info = {}
  for i = 0, #r.anim_info - 1 do
    local r_2 = r.anim_info[i]
    local lua_record_2 = {}
    lua_record_2.anim_name = r_2.anim_name
    if r_2.anim_name == "" then
      lua_record_2.anim_name = nil
    end
    lua_record_2.anim_id = r_2.anim_id
    lua_record_2.anim_len = r_2.anim_len
    table.insert(_anim_info, lua_record_2)
  end
  lua_record.anim_info = _anim_info
  ANIM_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = ANIM_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("ANIM_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return ANIM_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("ANIM_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #ANIM_CONF then
    return ANIM_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return ANIM_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("ANIM_CONF")
end

return dataTable
