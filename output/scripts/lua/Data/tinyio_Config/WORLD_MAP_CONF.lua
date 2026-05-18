WORLD_MAP_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.map_show_type = r.map_show_type
  _area_func_ids = {}
  for i = 0, #r.area_func_ids - 1 do
    table.insert(_area_func_ids, r.area_func_ids[i])
  end
  lua_record.area_func_ids = _area_func_ids
  _npc_refresh_ids = {}
  for i = 0, #r.npc_refresh_ids - 1 do
    table.insert(_npc_refresh_ids, r.npc_refresh_ids[i])
  end
  lua_record.npc_refresh_ids = _npc_refresh_ids
  lua_record.name_area_id = r.name_area_id
  lua_record.unexplored_in_compass = r.unexplored_in_compass
  lua_record.explored_in_compass = r.explored_in_compass
  lua_record.unfinished_in_compass = r.unfinished_in_compass
  lua_record.h_detection_range = r.h_detection_range
  if r.h_detection_range == "" then
    lua_record.h_detection_range = nil
  end
  lua_record.v_detection_range = r.v_detection_range
  if "" == r.v_detection_range then
    lua_record.v_detection_range = nil
  end
  lua_record.unexplored_in_map = r.unexplored_in_map
  lua_record.explored_in_map = r.explored_in_map
  lua_record.unfinished_in_map = r.unfinished_in_map
  lua_record.areaicon_unexplore = r.areaicon_unexplore
  if "" == r.areaicon_unexplore then
    lua_record.areaicon_unexplore = nil
  end
  lua_record.areaicon_explore = r.areaicon_explore
  if "" == r.areaicon_explore then
    lua_record.areaicon_explore = nil
  end
  lua_record.areaicon_unfinished = r.areaicon_unfinished
  if "" == r.areaicon_unfinished then
    lua_record.areaicon_unfinished = nil
  end
  lua_record.npcicon_lock = r.npcicon_lock
  if "" == r.npcicon_lock then
    lua_record.npcicon_lock = nil
  end
  lua_record.npcicon_unlock = r.npcicon_unlock
  if "" == r.npcicon_unlock then
    lua_record.npcicon_unlock = nil
  end
  lua_record.npcicon_unfinished = r.npcicon_unfinished
  if "" == r.npcicon_unfinished then
    lua_record.npcicon_unfinished = nil
  end
  lua_record.teleport_id = r.teleport_id
  _unlock_zone = {}
  for i = 0, #r.unlock_zone - 1 do
    table.insert(_unlock_zone, r.unlock_zone[i])
  end
  lua_record.unlock_zone = _unlock_zone
  lua_record.element_show_scale = r.element_show_scale
  lua_record.lock_element_show_top = r.lock_element_show_top
  lua_record.unlock_element_show_top = r.unlock_element_show_top
  lua_record.map_tips_show_type = r.map_tips_show_type
  lua_record.element_text_name = r.element_text_name
  if "" == r.element_text_name then
    lua_record.element_text_name = nil
  end
  lua_record.world_map_NPCicon_des = r.world_map_NPCicon_des
  if "" == r.world_map_NPCicon_des then
    lua_record.world_map_NPCicon_des = nil
  end
  lua_record.worldmap_npc_des = r.worldmap_npc_des
  if "" == r.worldmap_npc_des then
    lua_record.worldmap_npc_des = nil
  end
  lua_record.unlock_warn_tips = r.unlock_warn_tips
  if "" == r.unlock_warn_tips then
    lua_record.unlock_warn_tips = nil
  end
  lua_record.dungeon_type_des = r.dungeon_type_des
  if "" == r.dungeon_type_des then
    lua_record.dungeon_type_des = nil
  end
  lua_record.dungeon_title_bg = r.dungeon_title_bg
  if "" == r.dungeon_title_bg then
    lua_record.dungeon_title_bg = nil
  end
  lua_record.zone_name = r.zone_name
  if "" == r.zone_name then
    lua_record.zone_name = nil
  end
  lua_record.name_scale = r.name_scale
  lua_record.is_invisible = r.is_invisible
  _area_id = {}
  for i = 0, #r.area_id - 1 do
    table.insert(_area_id, r.area_id[i])
  end
  lua_record.area_id = _area_id
  _pet_base_id = {}
  for i = 0, #r.pet_base_id - 1 do
    table.insert(_pet_base_id, r.pet_base_id[i])
  end
  lua_record.pet_base_id = _pet_base_id
  WORLD_MAP_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = WORLD_MAP_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("WORLD_MAP_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return WORLD_MAP_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("WORLD_MAP_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #WORLD_MAP_CONF then
    return WORLD_MAP_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return WORLD_MAP_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("WORLD_MAP_CONF")
end

return dataTable
