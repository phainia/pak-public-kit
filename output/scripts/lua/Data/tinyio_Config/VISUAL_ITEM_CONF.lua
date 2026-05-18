VISUAL_ITEM_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.displayName = r.displayName
  if r.displayName == "" then
    lua_record.displayName = nil
  end
  lua_record.discription = r.discription
  if "" == r.discription then
    lua_record.discription = nil
  end
  lua_record.bigIcon = r.bigIcon
  if "" == r.bigIcon then
    lua_record.bigIcon = nil
  end
  lua_record.iconPath = r.iconPath
  if "" == r.iconPath then
    lua_record.iconPath = nil
  end
  lua_record.item_quality = r.item_quality
  lua_record.type_desc = r.type_desc
  if "" == r.type_desc then
    lua_record.type_desc = nil
  end
  local _acquire_struct = {}
  for i = 0, #r.acquire_struct - 1 do
    local r_2 = r.acquire_struct[i]
    local lua_record_2 = {}
    lua_record_2.acquire_way_text = r_2.acquire_way_text
    if "" == r_2.acquire_way_text then
      lua_record_2.acquire_way_text = nil
    end
    lua_record_2.behavior_id = r_2.behavior_id
    table.insert(_acquire_struct, lua_record_2)
  end
  lua_record.acquire_struct = _acquire_struct
  VISUAL_ITEM_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = VISUAL_ITEM_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("VISUAL_ITEM_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return VISUAL_ITEM_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("VISUAL_ITEM_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #VISUAL_ITEM_CONF then
    return VISUAL_ITEM_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return VISUAL_ITEM_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("VISUAL_ITEM_CONF")
end

return dataTable
