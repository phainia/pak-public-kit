MAIL_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.mail_id = r.mail_id
  lua_record.condition_type = r.condition_type
  lua_record.zone_id = r.zone_id
  lua_record.channel = r.channel
  if r.channel == "" then
    lua_record.channel = nil
  end
  lua_record.channel_id = r.channel_id
  lua_record.plat_id = r.plat_id
  lua_record.version = r.version
  lua_record.language = r.language
  if "" == r.language then
    lua_record.language = nil
  end
  lua_record.is_copy_content = r.is_copy_content
  lua_record.title = r.title
  if "" == r.title then
    lua_record.title = nil
  end
  lua_record.contents = r.contents
  if "" == r.contents then
    lua_record.contents = nil
  end
  lua_record.enable = r.enable
  lua_record.type = r.type
  lua_record.client_sys_jump = r.client_sys_jump
  lua_record.client_web_jump = r.client_web_jump
  if "" == r.client_web_jump then
    lua_record.client_web_jump = nil
  end
  lua_record.expire_time = r.expire_time
  lua_record.time_start = r.time_start
  lua_record.time_end = r.time_end
  lua_record.reward_goods = r.reward_goods
  MAIL_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = MAIL_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("MAIL_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return MAIL_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("MAIL_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #MAIL_CONF then
    return MAIL_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return MAIL_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("MAIL_CONF")
end

return dataTable
