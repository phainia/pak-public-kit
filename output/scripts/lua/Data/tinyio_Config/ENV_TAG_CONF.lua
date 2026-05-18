ENV_TAG_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.env_tag = r.env_tag
  lua_record.mask_name = r.mask_name
  if r.mask_name == "" then
    lua_record.mask_name = nil
  end
  lua_record.env_temp = r.env_temp
  lua_record.physical_surface = r.physical_surface
  if "" == r.physical_surface then
    lua_record.physical_surface = nil
  end
  ENV_TAG_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = ENV_TAG_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("ENV_TAG_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return ENV_TAG_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("ENV_TAG_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #ENV_TAG_CONF then
    return ENV_TAG_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return ENV_TAG_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("ENV_TAG_CONF")
end

return dataTable
