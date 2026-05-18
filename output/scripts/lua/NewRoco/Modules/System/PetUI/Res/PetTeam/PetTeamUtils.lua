local PetTeamUtils = {}
PetTeamUtils.CanInTeamNumMap = {
  [0] = 6,
  [_G.Enum.PlayerTeamType.PTT_PVP_BATTLE_5] = 3
}

function PetTeamUtils.IsShowFriendTeamEntrance(TeamType)
  if not TeamType then
    Log.Error("PetTeamUtils.IsShowFriendTeamEntrance: TeamType is nil")
    return false
  end
  local modeConfig = _G.DataConfigManager:GetGlobalConfigByKey("share_pet_playerteamtype")
  if not modeConfig then
    return false
  end
  local modeList = modeConfig.numList
  if not modeList or #modeList <= 0 then
    return false
  end
  for _, v in ipairs(modeList) do
    if v == TeamType then
      return true
    end
  end
  return false
end

function PetTeamUtils.GetCanInPetNum(TeamType)
  if PetTeamUtils.CanInTeamNumMap[TeamType] then
    return PetTeamUtils.CanInTeamNumMap[TeamType]
  else
    return PetTeamUtils.CanInTeamNumMap[0]
  end
end

function PetTeamUtils.GetSharedPetInfoFromFriendTeamInfo(petData, PetSkillEquipInfoList)
  if not petData or not PetSkillEquipInfoList then
    return nil
  end
  local sharedPetInfo = {}
  sharedPetInfo.hp_talent = petData.attribute_info.hp.talent_add_value
  sharedPetInfo.attack_talent = petData.attribute_info.attack.talent_add_value
  sharedPetInfo.special_attack_talent = petData.attribute_info.special_attack.talent_add_value
  sharedPetInfo.defense_talent = petData.attribute_info.defense.talent_add_value
  sharedPetInfo.special_defense_talent = petData.attribute_info.special_defense.talent_add_value
  sharedPetInfo.speed_talent = petData.attribute_info.speed.talent_add_value
  sharedPetInfo.base_conf_id = petData.base_conf_id
  sharedPetInfo.nature = petData.nature
  sharedPetInfo.blood_id = petData.blood_id
  sharedPetInfo.skills = PetSkillEquipInfoList
  sharedPetInfo.changed_nature_pos_attr_type = petData.changed_nature_pos_attr_type
  sharedPetInfo.changed_nature_neg_attr_type = petData.changed_nature_neg_attr_type
  return sharedPetInfo
end

function PetTeamUtils.GetMirrorTeamNumByTeamType(TeamType)
  local teamInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerPetTeamInfoByTeamType(TeamType)
  local MaxMirrorNum = 0
  if TeamType == _G.Enum.PlayerTeamType.PTT_PVP_BATTLE_4 then
    local limit_rank = _G.DataConfigManager:GetGlobalConfigByKey("share_pet_upper_limit_rank")
    MaxMirrorNum = limit_rank and limit_rank.num or 3
  elseif TeamType == _G.Enum.PlayerTeamType.PTT_PVP_BATTLE_5 then
    local limit_rank = _G.DataConfigManager:GetGlobalConfigByKey("share_pet_upper_limit_3v3")
    MaxMirrorNum = limit_rank and limit_rank.num or 3
  else
    local limit_rank = _G.DataConfigManager:GetGlobalConfigByKey("share_pet_upper_limit_friend")
    MaxMirrorNum = limit_rank and limit_rank.num or 3
  end
  local curMirrorNum = 0
  for i, v in ipairs(teamInfo.teams) do
    if v.is_mirror then
      curMirrorNum = curMirrorNum + 1
    end
  end
  return curMirrorNum, MaxMirrorNum
end

return PetTeamUtils
