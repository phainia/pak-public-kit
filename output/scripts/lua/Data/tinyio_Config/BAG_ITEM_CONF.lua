BAG_ITEM_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.npcid = r.npcid
  lua_record.name = r.name
  if r.name == "" then
    lua_record.name = nil
  end
  lua_record.editor_name = r.editor_name
  if "" == r.editor_name then
    lua_record.editor_name = nil
  end
  lua_record.description = r.description
  if "" == r.description then
    lua_record.description = nil
  end
  lua_record.flavor_text = r.flavor_text
  if "" == r.flavor_text then
    lua_record.flavor_text = nil
  end
  lua_record.icon = r.icon
  if "" == r.icon then
    lua_record.icon = nil
  end
  lua_record.big_icon = r.big_icon
  if "" == r.big_icon then
    lua_record.big_icon = nil
  end
  lua_record.model = r.model
  if "" == r.model then
    lua_record.model = nil
  end
  lua_record.type = r.type
  lua_record.lable_type = r.lable_type
  lua_record.type_desc = r.type_desc
  if "" == r.type_desc then
    lua_record.type_desc = nil
  end
  lua_record.can_see = r.can_see
  lua_record.throw_function_id = r.throw_function_id
  lua_record.can_charging = r.can_charging
  lua_record.icon_charging1 = r.icon_charging1
  if "" == r.icon_charging1 then
    lua_record.icon_charging1 = nil
  end
  lua_record.icon_charging2 = r.icon_charging2
  if "" == r.icon_charging2 then
    lua_record.icon_charging2 = nil
  end
  lua_record.initial_use_times = r.initial_use_times
  lua_record.can_use_in_battle = r.can_use_in_battle
  lua_record.can_use_in_bag = r.can_use_in_bag
  lua_record.can_use_in_pet_bag = r.can_use_in_pet_bag
  lua_record.is_consume = r.is_consume
  lua_record.is_auto_use = r.is_auto_use
  local _item_behavior = {}
  for i = 0, #r.item_behavior - 1 do
    local r_2 = r.item_behavior[i]
    local lua_record_2 = {}
    lua_record_2.use_action = r_2.use_action
    _ratio = {}
    for i = 0, #r_2.ratio - 1 do
      table.insert(_ratio, r_2.ratio[i])
    end
    lua_record_2.ratio = _ratio
    table.insert(_item_behavior, lua_record_2)
  end
  lua_record.item_behavior = _item_behavior
  lua_record.can_stack = r.can_stack
  lua_record.can_compose = r.can_compose
  lua_record.compose_num = r.compose_num
  lua_record.compose_id = r.compose_id
  lua_record.expire_time = r.expire_time
  lua_record.item_quality = r.item_quality
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
  BAG_ITEM_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = BAG_ITEM_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("BAG_ITEM_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return BAG_ITEM_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("BAG_ITEM_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #BAG_ITEM_CONF then
    return BAG_ITEM_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return BAG_ITEM_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("BAG_ITEM_CONF")
end

return dataTable
