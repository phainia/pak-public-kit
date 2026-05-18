NPC_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.genre = r.genre
  lua_record.reward_drop_type = r.reward_drop_type
  lua_record.name = r.name
  if r.name == "" then
    lua_record.name = nil
  end
  lua_record.editor_name = r.editor_name
  if "" == r.editor_name then
    lua_record.editor_name = nil
  end
  lua_record.model_conf = r.model_conf
  lua_record.original_action = r.original_action
  if "" == r.original_action then
    lua_record.original_action = nil
  end
  lua_record.item_quality = r.item_quality
  lua_record.behavior_tree = r.behavior_tree
  if "" == r.behavior_tree then
    lua_record.behavior_tree = nil
  end
  lua_record.mf_behavior_tree = r.mf_behavior_tree
  if "" == r.mf_behavior_tree then
    lua_record.mf_behavior_tree = nil
  end
  lua_record.ai_group = r.ai_group
  lua_record.enable_server_ai = r.enable_server_ai
  lua_record.icon = r.icon
  if "" == r.icon then
    lua_record.icon = nil
  end
  lua_record.bulky = r.bulky
  lua_record.act = r.act
  if "" == r.act then
    lua_record.act = nil
  end
  lua_record.show_name_type = r.show_name_type
  lua_record.show_name = r.show_name
  lua_record.show_level = r.show_level
  lua_record.npc_level = r.npc_level
  lua_record.npc_nameplate_show_distance = r.npc_nameplate_show_distance
  lua_record.visible_distance = r.visible_distance
  lua_record.npc_speed = r.npc_speed
  lua_record.map_show_type = r.map_show_type
  lua_record.npc_act_type = r.npc_act_type
  lua_record.model_scale = r.model_scale
  lua_record.fx_locate = r.fx_locate
  lua_record.fx_source = r.fx_source
  if "" == r.fx_source then
    lua_record.fx_source = nil
  end
  lua_record.not_turn_face = r.not_turn_face
  lua_record.stop_distance = r.stop_distance
  lua_record.appear_perform = r.appear_perform
  if "" == r.appear_perform then
    lua_record.appear_perform = nil
  end
  lua_record.emerge_ani = r.emerge_ani
  if "" == r.emerge_ani then
    lua_record.emerge_ani = nil
  end
  lua_record.disappear_ani = r.disappear_ani
  if "" == r.disappear_ani then
    lua_record.disappear_ani = nil
  end
  lua_record.emerge_skill = r.emerge_skill
  if "" == r.emerge_skill then
    lua_record.emerge_skill = nil
  end
  lua_record.disappear_skill = r.disappear_skill
  if "" == r.disappear_skill then
    lua_record.disappear_skill = nil
  end
  lua_record.emerge_act = r.emerge_act
  if "" == r.emerge_act then
    lua_record.emerge_act = nil
  end
  lua_record.disappear_act = r.disappear_act
  if "" == r.disappear_act then
    lua_record.disappear_act = nil
  end
  lua_record.respond_distance = r.respond_distance
  lua_record.lock_on_ground = r.lock_on_ground
  lua_record.forbid_collision = r.forbid_collision
  lua_record.npc_interact_type = r.npc_interact_type
  lua_record.monster_fightflee_type = r.monster_fightflee_type
  _interactable_feature = {}
  for i = 0, #r.interactable_feature - 1 do
    table.insert(_interactable_feature, r.interactable_feature[i])
  end
  lua_record.interactable_feature = _interactable_feature
  lua_record.throwing_interact_type = r.throwing_interact_type
  _option_id = {}
  for i = 0, #r.option_id - 1 do
    table.insert(_option_id, r.option_id[i])
  end
  lua_record.option_id = _option_id
  lua_record.reset_npc = r.reset_npc
  lua_record.reset_interval = r.reset_interval
  lua_record.reset_in_view = r.reset_in_view
  _aura_id = {}
  for i = 0, #r.aura_id - 1 do
    table.insert(_aura_id, r.aura_id[i])
  end
  lua_record.aura_id = _aura_id
  lua_record.can_hide_in_sequence = r.can_hide_in_sequence
  lua_record.aoi_weight = r.aoi_weight
  lua_record.traverse_data_type = r.traverse_data_type
  _traverse_data_param = {}
  for i = 0, #r.traverse_data_param - 1 do
    table.insert(_traverse_data_param, r.traverse_data_param[i])
  end
  lua_record.traverse_data_param = _traverse_data_param
  NPC_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = NPC_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("NPC_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return NPC_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("NPC_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #NPC_CONF then
    return NPC_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return NPC_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("NPC_CONF")
end

return dataTable
