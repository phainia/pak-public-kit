TASK_NPC = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.npc_id = r.npc_id
  lua_record.name = r.name
  if r.name == "" then
    lua_record.name = nil
  end
  lua_record.scene_id = r.scene_id
  lua_record.pos_x = r.pos_x
  lua_record.pos_y = r.pos_y
  lua_record.pos_z = r.pos_z
  lua_record.rotation = r.rotation
  TASK_NPC[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = TASK_NPC[_key]
  if nil == r then
    local r = TinyData.GetRecord("TASK_NPC", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return TASK_NPC[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("TASK_NPC", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #TASK_NPC then
    return TASK_NPC
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return TASK_NPC
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("TASK_NPC")
end

return dataTable
