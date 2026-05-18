NPC_GLOBAL_CONFIG = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.key = r.key
  if r.key == "" then
    lua_record.key = nil
  end
  lua_record.editor_name = r.editor_name
  if "" == r.editor_name then
    lua_record.editor_name = nil
  end
  lua_record.num = r.num
  _numList = {}
  for i = 0, #r.numList - 1 do
    table.insert(_numList, r.numList[i])
  end
  lua_record.numList = _numList
  lua_record.str = r.str
  if "" == r.str then
    lua_record.str = nil
  end
  lua_record.is_svr_ctl = r.is_svr_ctl
  NPC_GLOBAL_CONFIG[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = NPC_GLOBAL_CONFIG[_key]
  if nil == r then
    local r = TinyData.GetRecord("NPC_GLOBAL_CONFIG", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return NPC_GLOBAL_CONFIG[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("NPC_GLOBAL_CONFIG", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #NPC_GLOBAL_CONFIG then
    return NPC_GLOBAL_CONFIG
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.key, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return NPC_GLOBAL_CONFIG
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("NPC_GLOBAL_CONFIG")
end

return dataTable
