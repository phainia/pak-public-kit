local Base = require("NewRoco.Modules.Core.Scene.Component.Buff.ScenePlayerBuff")
local StatType = require("NewRoco.Modules.Core.Scene.Component.Stat.StatType")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local AbilityID = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityID")
local ScenePlayerPet = require("NewRoco.Modules.Core.Scene.Actor.ScenePlayerPet")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local ScenePlayerRideFriendPetBuff = Base:Extend("ScenePlayerRideFriendPetBuff")
ScenePlayerRideFriendPetBuff.BuffName = "RideFriendPetBuff"

function ScenePlayerRideFriendPetBuff:OnBegin(owner, npc, petData)
  self.owner = owner
  local localPlayer = self.owner
  local petId = npc:GetPetbaseId()
  local petGid = npc.serverData.pet_info.gid
  local ridePetGid = petGid
  local petServerId = npc:GetServerId()
  local minePet = self:GetMinePet(petGid, petServerId)
  if minePet then
    self.ridePet = minePet
    self.isMine = true
  else
    local playerModule = NRCModuleManager:GetModule("PlayerModule")
    local gid = -ProtoEnum.SceneRideAllCustomGid.SRCG_Friend
    ridePetGid = gid
    local filteredPetData = self:FilterPetTalent(petData)
    local friendPet = ScenePlayerPet(playerModule, petId, gid, localPlayer, filteredPetData)
    friendPet.npcId = petServerId
    self.ridePet = friendPet
  end
  self:RequestRideFriendPet(npc, petId, petGid, ridePetGid, petServerId, self.ridePet)
end

function ScenePlayerRideFriendPetBuff:RequestRideFriendPet(npc, petId, petGid, ridePetGid, npcId, petData)
  local req = ProtoMessage:newZoneSceneSyncPlayerStatusPreCheckReq()
  local sync_status_info = ProtoMessage.newPlayerStatusSyncInfo()
  sync_status_info.status = ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL
  sync_status_info.op_code = ProtoEnum.WPST_OpCode.WPST_OPCODE_ADD
  sync_status_info.sub_status = 1
  local ridePetParam = ProtoMessage:newPlayerRideStatusParams()
  ridePetParam.ride_pet_id = petId
  ridePetParam.ride_npc_id = npcId
  ridePetParam.mutation_type = _G.Enum.MutationDiffType.MDT_NONE
  ridePetParam.relative_emotion = 0
  ridePetParam.ride_load_finish = false
  ridePetParam.ride_pet_gid = ridePetGid
  ridePetParam.owner_id = npc:GetOwnerId()
  if petData then
    ridePetParam.mutation_type = petData.mutation_type
    ridePetParam.relative_emotion = petData.nature
    ridePetParam.glass_info = petData.glass_info
    ridePetParam.pet_voice = petData.voice
    ridePetParam.pet_gid = petGid
  end
  local customParams = {ride_param = ridePetParam}
  sync_status_info.custom_status_param = customParams
  req.sync_status_info = sync_status_info
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_SCENE_SYNC_PLAYER_STATUS_PRE_CHECK_REQ, req, self, self.OnRequestRideFriendPetRsp, false, true)
end

function ScenePlayerRideFriendPetBuff:OnRequestRideFriendPetRsp(rsp)
  if 0 ~= rsp.ret_info.ret_code then
    Log.Error("ScenePlayerRideFriendPetBuff RequestRideFriendPet Failed")
    self.owner.buffComponent:RemoveBuff(ScenePlayerRideFriendPetBuff.BuffName)
    local BusyTip = _G.LuaText.intercationtree_touch_head_busy
    local PetData = _G.NRCModuleManager:DoCmd(RelationTreeCmd.GetPetInfoData)
    local PetName = PetData and PetData.name or ""
    local TipContent = string.format(BusyTip, PetName)
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, TipContent)
    return
  end
  self:RideFriendPet()
end

function ScenePlayerRideFriendPetBuff:RideFriendPet()
  local localPlayer = self.owner
  if self.isMine then
    local minePet = self.ridePet
    localPlayer:SendEvent(PlayerModuleEvent.ON_RELATION_RIDE_PET, minePet, true)
    local helper = AbilityHelperManager.GetHelper(AbilityID.RIDE_ALL)
    if helper then
      helper:HandleStatus(localPlayer, minePet)
    end
  else
    local friendPet = self.ridePet
    localPlayer:SendEvent(PlayerModuleEvent.ON_RELATION_RIDE_PET, friendPet, false)
    local helper = AbilityHelperManager.GetHelper(AbilityID.RIDE_ALL)
    if helper then
      helper:HandleStatus(localPlayer, friendPet)
    end
  end
  self.ridePet:AddEventListener(self, PlayerModuleEvent.ON_STATUS_CHANGED, self.OnPetStatusChanged)
  _G.ZoneServer:AddProtocolListener(self, ProtoCMD.ZoneSvrCmd.ZONE_SCENE_FRIEND_RIDE_NOTIFY, self.OnFriendRideNty)
end

function ScenePlayerRideFriendPetBuff:FilterPetTalent(petData)
  if not petData or not petData.real_speciality_ids then
    return petData
  end
  local filteredPetData = table.deepCopy(petData)
  local speciality_ids = {}
  for _, v in pairs(petData.real_speciality_ids) do
    local TalentConf = DataConfigManager:GetPetTalentConf(v, true)
    if TalentConf and TalentConf.effect_group then
      for _, Effect in pairs(TalentConf.effect_group) do
        if Effect.effect == ProtoEnum.PetTalentEffect.PTE_TWO_PLAYER_MOUNT then
          table.insert(speciality_ids, v)
          break
        end
      end
    end
  end
  filteredPetData.real_speciality_ids = speciality_ids
  return filteredPetData
end

function ScenePlayerRideFriendPetBuff:OnReActive(owner, npc, petData)
  self:OnFinish()
  self:OnBegin(owner, npc, petData)
end

function ScenePlayerRideFriendPetBuff:OnFriendRideNty(nty)
  Log.DebugFormat("[DebugRideFriendPet] OnFriendRideNty")
  Log.Dump(nty, 2, "ZoneSceneFriendRideNotify:")
  local localPlayer = self.owner
  localPlayer.statusComponent:ClearStatus(ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL)
end

function ScenePlayerRideFriendPetBuff:OnPetStatusChanged(status, value, pet)
  local petStatus = pet:GetStatus()
  if petStatus ~= ProtoEnum.WorldPlayerPetStatusType.WPPST_IN_RIDE then
    self.owner.buffComponent:RemoveBuff(ScenePlayerRideFriendPetBuff.BuffName)
  end
end

function ScenePlayerRideFriendPetBuff:GetMinePet(petID, serverID)
  local teamInfo = DataModelMgr.PlayerDataModel:GetPlayerPetTeamInfo()
  if not teamInfo or #teamInfo.teams < 1 then
    return nil
  end
  local mainTeam = teamInfo.teams[teamInfo.main_team_idx + 1]
  if mainTeam and mainTeam.pet_infos then
    for _, petInfo in pairs(mainTeam.pet_infos) do
      if petInfo.pet_gid == petID then
        local pet = self.owner:GetPetByGid(petID)
        if pet then
          local session = pet:FindThrowSession()
          if session and session.NPC and session.NPC:GetServerId() == serverID then
            return pet
          end
        end
      end
    end
  end
  return nil
end

function ScenePlayerRideFriendPetBuff:OnFinish(param)
  Log.ErrorFormat("ScenePlayerRideFriendPetBuff:OnFinish")
  _G.ZoneServer:RemoveProtocolListener(self, ProtoCMD.ZoneSvrCmd.ZONE_SCENE_FRIEND_RIDE_NOTIFY, self.OnFriendRideNty)
  self.ridePet:RemoveEventListener(self, PlayerModuleEvent.ON_STATUS_CHANGED, self.OnPetStatusChanged)
  self.ridePet = nil
  self.owner = nil
end

return ScenePlayerRideFriendPetBuff
