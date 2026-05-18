STAGE_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.name = r.name
  if r.name == "" then
    lua_record.name = nil
  end
  lua_record.next_id = r.next_id
  lua_record.battle_id = r.battle_id
  lua_record.show_reward_id = r.show_reward_id
  lua_record.STAGE_introduce = r.STAGE_introduce
  if "" == r.STAGE_introduce then
    lua_record.STAGE_introduce = nil
  end
  lua_record.Recommend_lv = r.Recommend_lv
  lua_record.Lv_count = r.Lv_count
  _battle_time = {}
  for i = 0, #r.battle_time - 1 do
    table.insert(_battle_time, r.battle_time[i])
  end
  lua_record.battle_time = _battle_time
  lua_record.CD_explain = r.CD_explain
  if "" == r.CD_explain then
    lua_record.CD_explain = nil
  end
  STAGE_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = STAGE_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("STAGE_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return STAGE_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("STAGE_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #STAGE_CONF then
    return STAGE_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return STAGE_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("STAGE_CONF")
end

return dataTable
