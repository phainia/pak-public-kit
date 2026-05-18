REWARD_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.Type = r.Type
  lua_record.Icon = r.Icon
  if r.Icon == "" then
    lua_record.Icon = nil
  end
  lua_record.DisplayName = r.DisplayName
  if "" == r.DisplayName then
    lua_record.DisplayName = nil
  end
  lua_record.Tag = r.Tag
  lua_record.Description = r.Description
  if "" == r.Description then
    lua_record.Description = nil
  end
  lua_record.DropChance = r.DropChance
  lua_record.DropRound = r.DropRound
  local _RewardItem = {}
  for i = 0, #r.RewardItem - 1 do
    local r_2 = r.RewardItem[i]
    local lua_record_2 = {}
    lua_record_2.Type = r_2.Type
    lua_record_2.Id = r_2.Id
    lua_record_2.Count = r_2.Count
    _DropWeight = {}
    for i = 0, #r_2.DropWeight - 1 do
      table.insert(_DropWeight, r_2.DropWeight[i])
    end
    lua_record_2.DropWeight = _DropWeight
    table.insert(_RewardItem, lua_record_2)
  end
  lua_record.RewardItem = _RewardItem
  REWARD_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = REWARD_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("REWARD_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return REWARD_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("REWARD_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #REWARD_CONF then
    return REWARD_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return REWARD_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("REWARD_CONF")
end

return dataTable
