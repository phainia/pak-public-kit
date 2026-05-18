local PGCModuleData = _G.NRCData:Extend("PGCModuleData")
local Enum = _G.Enum

function PGCModuleData:Ctor()
  NRCData.Ctor(self)
  self.NPCTypeDataList = {}
  self.NPCInstanceDataList = {}
  self.CurrentEditDataInfo = {
    DataType = PGCModuleEnum.DataType.NPCType,
    DataIndex = -1
  }
end

local TestData = {}
TestData.AREA_CONF = {
  id = 731030001,
  scene_res_id = 10003,
  scene_id = 103,
  editor_name = {},
  area_type = "AREAT_POINT",
  area_layer = 1,
  area_height = 0,
  is_visible = false,
  is_special = false,
  is_teleport = false,
  is_bt_use = false,
  is_open = "RBT_OPEN",
  stealth_on = 0,
  pos = {
    {
      position_xyz = {
        390946,
        629693,
        5988
      },
      rotation_xyz = {
        0,
        0,
        0
      }
    }
  },
  pos_empty = {},
  center_xyz = {
    390946,
    629693,
    5988
  },
  falcon_map_data_id = "",
  creator = "jaunwang",
  last_author = "jaunwang",
  comments = {}
}
TestData.NPC_CONF = {
  id = 730004,
  name = "\229\156\163\229\133\137\232\191\170\232\142\171",
  editor_name = "jaunwang\231\154\132\229\156\163\229\133\137\232\191\170\232\142\171",
  editor_name_1 = "1",
  genre = "CNT_NORMALFUNC",
  npc_tag = {},
  model_conf = 14023,
  model_scale = 100,
  icon = "yanjiuyuan",
  bulky = 2,
  BulkySizeType = "",
  show_name_type = "NNT_NONE",
  show_name = 1,
  show_level = 0,
  npc_level = 0,
  npc_worldtitle = "",
  title_icon_path = "",
  icon_show_distance = 0,
  npc_nameplate_show_distance = 1300,
  visible_distance = 0,
  min_map_disappear = 0,
  map_show_type = "",
  fx_locate = 0,
  fx_source = "",
  original_action = "",
  appear_perform = "",
  emerge_ani = "",
  disappear_ani = "",
  emerge_skill = "",
  disappear_skill = "",
  emerge_act = "",
  disappear_act = "",
  delay_disappear_performance = false,
  npc_speed = 400,
  stop_distance = 200,
  lock_on_ground = 1,
  forbid_collision = 0,
  not_turn_face = 0,
  npc_interact_type = "IT_MANUAL",
  respond_distance = 0,
  interactable_feature = {},
  throwing_interact_type = "TIT_NORMAL",
  option_id = {},
  reward_drop_type = "RNT_CREATE",
  monster_fightflee_type = "FFT_FLEE",
  monster_hit_type = "",
  item_quality = 0,
  trace_icon_offset = 0,
  behavior_tree = "",
  mf_behavior_tree = "",
  ai_perform_group = "",
  enable_server_ai = false,
  battle_ai = "",
  ai_group_param = {},
  nightmare_ai_group = "",
  ai_group_role_id = {},
  is_ai_loading_high_priority = 0,
  ai_random_pool_id = "",
  reset_npc = "RE_NONE",
  reset_interval = 0,
  reset_in_view = 0,
  auto_escape = "",
  escape_params = {},
  escape_dialogue = 0,
  overtime_action = {},
  npc_skill = {},
  aoi_distance = "",
  aoi_weight = 0,
  can_hide_in_sequence = 0,
  dont_hide_in_battle = 0,
  can_hide_in_player_condition = 0,
  can_hide_in_minigame = 0,
  can_hide_in_pvp = 0,
  world_hide = "",
  world_hide_param = {},
  aura_id = {},
  is_clean_ani = 0,
  traverse_data_type = "",
  traverse_data_param = {},
  npc_group_id = 0,
  is_levelup_manual = 0,
  LocationTag = "",
  act = "",
  npc_act_type = "",
  world_nature = "",
  mimic_target = 0,
  mimic_skill = 0,
  is_pve_npc_around = 0,
  special_audio_tag = {},
  freeze_movement_when_spawn = false,
  npc_trampling_lawn_comp = "",
  npc_role_type = "",
  opacity_rate = "",
  fresnel_color = "",
  fresnel_intensity = "",
  fresnel_exponent = "",
  creator = "jaunwang",
  last_author = "jaunwang",
  comments = {}
}
TestData.NPC_REFRESH_CONTENT_CONF = {
  id = 7300001,
  editor_name = {
    "\229\156\163\229\133\137\232\191\170\232\142\171",
    "jaunwang",
    "\229\156\176\231\188\150\232\135\170\229\138\168\231\148\159\230\136\144"
  },
  npc_id = 730004,
  disable = "",
  version = "",
  refresh_type = "RFT_AREA",
  refresh_param = 731030001,
  refresh_rule = "RRC_REWARD_NO_RESET",
  refresh_update_type = "",
  refresh_delaytime = "",
  max_num = 1,
  storage_num = 1,
  specify_area_number = {},
  online_is_clear = "",
  relogin_refresh_point = "",
  refresher_type = "",
  overlap_processing_type = "",
  Application_type = "",
  affiliated_object = "",
  bb_input_id = "",
  ClientHidden = "",
  patrol_belong_type = "",
  patrol_param = 0,
  npc_option_type = "",
  npc_option_ids = {},
  time_random = {},
  survive_time = "",
  offline_remove = "",
  npc_level_script = "NLS_ROLE_STAR_CONFIG",
  level_param = {3, 1},
  LocationTag = "",
  local_point = {},
  adjust_dir = "",
  is_reroll_npc_position = "",
  lock_on_ground = 1,
  model_scale = 100,
  Close_Condition_Type = "",
  Close_Condition_param = {},
  npc_initial_status = "",
  init_status = {},
  init_property_types = {},
  init_option_available = "",
  glass_limit_type = "GLT_WILD_MONSTER",
  chaos_limit_type = "CAS_WILD_MONSTER",
  shining_prob = "",
  chaos_prob = {
    1,
    0,
    2,
    3500,
    3,
    0
  },
  glass_prob = 90,
  nature_rand = {30},
  proportion_male = "",
  worldnature_prob = "",
  worldnature_prob_direction = "WND_RANDOM",
  belong_camp = "",
  npc_pendant_id = {},
  disappear_animation = "",
  ai_group_param = {
    {
      ai_group = "",
      ai_group_role = "",
      ai_group_role_id = {},
      ai_group_priority = ""
    },
    {
      ai_group = "",
      ai_group_role = "",
      ai_group_role_id = {},
      ai_group_priority = ""
    },
    {
      ai_group = "",
      ai_group_role = "",
      ai_group_role_id = {},
      ai_group_priority = ""
    },
    {
      ai_group = "",
      ai_group_role = "",
      ai_group_role_id = {},
      ai_group_priority = ""
    },
    {
      ai_group = 100001,
      ai_group_role = "GART_INTIMATE",
      ai_group_role_id = {14, 77},
      ai_group_priority = ""
    }
  },
  pet_habitat_group = "",
  show_habitat = "",
  mf_behavior_tree = "",
  ai_perform_group = "",
  world_hide = "",
  world_hide_param = {},
  mimic_target = "",
  cannot_be_seen = "",
  visible_during_perception = "",
  visible_during_nightmare = "",
  voice_percent = {0, 100},
  Light_BP = "",
  not_destroy_by_1vn = "",
  team_battle_not_delete = "",
  is_forbid_track = "",
  emerge_skill = "",
  is_can_exhausted = "",
  is_questgiver = "",
  creator = "jaunwang",
  last_author = "jaunwang",
  comments = {}
}

function PGCModuleData:GetAreaConf()
  return TestData.AREA_CONF
end

function PGCModuleData:GetNpcConf()
  return TestData.NPC_CONF
end

function PGCModuleData:GetRefreshConf()
  return TestData.NPC_REFRESH_CONTENT_CONF
end

function PGCModuleData:GetDataList(dataType)
  if dataType == _G.PGCModuleEnum.DataType.NPCType then
    return {
      {
        id = 10001,
        name = "\230\157\145\233\149\191\232\128\129\231\136\183\231\136\183",
        client_npc_type = Enum.ClientNpcType.CNT_NPC,
        npc_type = Enum.NPCType.NPC_INTERACTIVE,
        description = "\230\157\145\229\186\132\231\154\132\233\149\191\232\128\133\239\188\140\229\143\175\228\187\165\229\175\185\232\175\157\228\186\164\228\186\146",
        res_id = 30001,
        icon = "UI/Icons/NPC/npc_elder.png",
        level = 1,
        name_type = Enum.NpcNameType.NNT_INTERACTIVE,
        bulky_size_type = Enum.NpcBulkySizeType.NBST_NORMAL,
        guide_icon = Enum.NpcGuideIcon.GD_NONE
      },
      {
        id = 10002,
        name = "\231\165\158\231\167\152\229\174\157\231\174\177",
        client_npc_type = Enum.ClientNpcType.CNT_CHEST,
        npc_type = Enum.NPCType.NPC_INTERACTIVE,
        description = "\229\143\175\228\187\165\230\137\147\229\188\128\232\142\183\229\143\150\229\165\150\229\138\177\231\154\132\229\174\157\231\174\177",
        res_id = 30102,
        icon = "UI/Icons/NPC/chest_normal.png",
        level = 1,
        name_type = Enum.NpcNameType.NNT_INTERACTIVE,
        bulky_size_type = Enum.NpcBulkySizeType.NBST_SMALL,
        guide_icon = Enum.NpcGuideIcon.GD_REWARD
      },
      {
        id = 20001,
        name = "\231\129\171\231\132\176\233\184\159",
        client_npc_type = Enum.ClientNpcType.CNT_NPC,
        npc_type = Enum.NPCType.NPC_SCENE,
        pet_role_type = Enum.PetRoleTypeInNPCConf.PRTINC_WILD,
        description = "\233\135\142\231\148\159\231\178\190\231\129\181\239\188\140\229\143\175\228\187\165\230\136\152\230\150\151\229\146\140\230\141\149\230\141\137",
        res_id = 30201,
        icon = "UI/Icons/Pet/pet_firebird.png",
        level = 15,
        name_type = Enum.NpcNameType.NNT_NONE,
        bulky_size_type = Enum.NpcBulkySizeType.NBST_SMALL,
        guide_icon = Enum.NpcGuideIcon.GD_COMBAT,
        aim_display_type = Enum.NPC_AIM_DISPLAY.NAD_WILD_PET
      }
    }
  elseif dataType == _G.PGCModuleEnum.DataType.NPCInstance then
    return {
      {
        id = 100001,
        typeId = 10001,
        name = "\230\157\145\233\149\191\232\128\129\231\136\183\231\136\183\194\183\230\157\142",
        location = "\230\150\176\230\137\139\230\157\145\229\185\191\229\156\186",
        scene_id = 1001,
        position = {
          x = 1000,
          y = 2000,
          z = 100
        },
        rotation = {
          pitch = 0,
          yaw = 90,
          roll = 0
        },
        level = 1,
        state = "idle",
        ai_id = 0
      },
      {
        id = 100002,
        typeId = 10002,
        name = "\231\165\158\231\167\152\229\174\157\231\174\177\194\183A01",
        location = "\230\163\174\230\158\151\229\133\165\229\143\163",
        scene_id = 1001,
        position = {
          x = 1500,
          y = 2500,
          z = 100
        },
        rotation = {
          pitch = 0,
          yaw = 0,
          roll = 0
        },
        level = 1,
        state = "closed",
        reward_id = 70001
      },
      {
        id = 200001,
        typeId = 20001,
        name = "\231\129\171\231\132\176\233\184\159\194\183\233\135\142\231\148\159",
        location = "\231\129\171\229\177\177\229\156\176\229\184\166",
        scene_id = 1002,
        position = {
          x = 2000,
          y = 3000,
          z = 150
        },
        rotation = {
          pitch = 0,
          yaw = 180,
          roll = 0
        },
        level = 15,
        state = "wander",
        ai_id = 10001,
        auto_escape_type = Enum.NPCAutoEscapeType.NAET_KILL_PET_IMMEDIATLY
      }
    }
  end
end

function PGCModuleData:SetCurrentEditData(dataType, dataIndex)
  self.CurrentEditDataInfo.DataType = dataType
  self.CurrentEditDataInfo.DataIndex = dataIndex
end

function PGCModuleData:AddNPCType(data)
end

function PGCModuleData:RemoveNPCType(dataId)
end

function PGCModuleData:ModifyNPCType(dataId, newData)
end

return PGCModuleData
