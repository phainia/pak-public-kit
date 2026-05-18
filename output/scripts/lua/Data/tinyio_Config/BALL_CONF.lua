BALL_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.editor_name = r.editor_name
  if r.editor_name == "" then
    lua_record.editor_name = nil
  end
  lua_record.model = r.model
  if "" == r.model then
    lua_record.model = nil
  end
  lua_record.fx_source = r.fx_source
  if "" == r.fx_source then
    lua_record.fx_source = nil
  end
  lua_record.ball_prob = r.ball_prob
  lua_record.history_sup_prob = r.history_sup_prob
  lua_record.hp_sup_prob = r.hp_sup_prob
  lua_record.pp_sup_prob = r.pp_sup_prob
  lua_record.happy_sup_prob = r.happy_sup_prob
  lua_record.debuff_sup_prob = r.debuff_sup_prob
  lua_record.refresh_prob = r.refresh_prob
  lua_record.global_catch_prob = r.global_catch_prob
  lua_record.npc_id = r.npc_id
  lua_record.hidden_capture_correction = r.hidden_capture_correction
  lua_record.ball_icon = r.ball_icon
  if "" == r.ball_icon then
    lua_record.ball_icon = nil
  end
  BALL_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = BALL_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("BALL_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return BALL_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("BALL_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #BALL_CONF then
    return BALL_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return BALL_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("BALL_CONF")
end

return dataTable
