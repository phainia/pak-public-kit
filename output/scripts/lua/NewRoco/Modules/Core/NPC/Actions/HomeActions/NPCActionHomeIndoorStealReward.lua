local Base = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local PetUtils = require("NewRoco.Utils.PetUtils")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local HomePetAttributeComponent = require("NewRoco.Modules.System.Home.HomePetFeed.HomePetAttributeComponent")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local NPCActionHomeIndoorStealReward = Base:Extend("NPCActionHomeIndoorStealReward")

function NPCActionHomeIndoorStealReward:Ctor(owner, config, info)
  Base.Ctor(self, owner, config, info)
end

local ATTACK_BEHAVIOR

local function GetAttackBehavior()
  if ATTACK_BEHAVIOR then
    return ATTACK_BEHAVIOR
  end
  local conf = _G.DataConfigManager:GetNpcGlobalConfig("home_steal_attack_behavior_group", true)
  ATTACK_BEHAVIOR = conf and conf.num or 0
  return ATTACK_BEHAVIOR
end

local function CheckIfCouldExecute()
  local svrTime = math.floor(_G.ZoneServer:GetServerTime() / 1000)
  local timeTable = os.date("*t", svrTime)
  local configInterval = _G.DataConfigManager:GetHomeGlobalConfig("pet_steal_forbidding_time").numList
  if configInterval and 2 == #configInterval and timeTable.hour and timeTable.hour >= configInterval[1] and timeTable.hour < configInterval[2] then
    return false
  end
  return true
end

local HOME_STEAL_FIX_VALUE_FRIEND, HOME_STEAL_FIX_VALUE_GUEST

local function InitStealFixValue()
  if HOME_STEAL_FIX_VALUE_FRIEND then
    return
  end
  local conf_friend = _G.DataConfigManager:GetHomeGlobalConfig("home_steal_fix_value_friend")
  HOME_STEAL_FIX_VALUE_FRIEND = conf_friend and conf_friend.num or 15
  local conf_guest = _G.DataConfigManager:GetHomeGlobalConfig("home_steal_fix_value_guest")
  HOME_STEAL_FIX_VALUE_GUEST = conf_guest and conf_guest.num or 30
end

function NPCActionHomeIndoorStealReward:DecreaseFriendliness(npc, player)
  if not npc or not player then
    return
  end
  InitStealFixValue()
  local fixVal
  if _G.HomeIndoorSandbox.Utils.ShouldAiTreatLikeFriendByPlayer(player) then
    fixVal = HOME_STEAL_FIX_VALUE_FRIEND
  else
    fixVal = HOME_STEAL_FIX_VALUE_GUEST
  end
  local AttrComp = npc:EnsureComponent(HomePetAttributeComponent)
  if AttrComp then
    Log.DebugFormat("NPCActionHomeIndoorStealReward: %s\230\128\146\228\186\134\239\188\129\230\137\163\233\153\164\229\143\139\229\165\189\229\186\166 %d", npc.config.name, fixVal)
    local targetPlayerId = player:GetServerId()
    AttrComp:ModifyFriendliness(targetPlayerId, -fixVal)
    AttrComp:SetJustTriedAttack(targetPlayerId)
  end
end

function NPCActionHomeIndoorStealReward:QueryCouldSteal()
  local req = ProtoMessage:newZoneHomePetCanStealReq()
  local npc = self.Owner.owner
  req.npc_obj_id = npc.serverData.base.actor_id
  req.pet_gid = npc.serverData.home_pet.home_pet_info.pet_gid
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_HOME_PET_CAN_STEAL_REQ, req, self, self.QueryStealRsp, false, true)
end

function NPCActionHomeIndoorStealReward:QueryStealRsp(rsp)
  Log.Dump(rsp, 3, "NPCActionHomeIndoorStealReward QueryStealRsp")
  if rsp.ret_info and 0 == rsp.ret_info.ret_code then
    if not rsp.can_steal then
      self:OnErrTips(rsp.reason)
      self:Finish(false)
    else
      self:RequestSteal()
    end
  else
    self:OnErrTips(rsp.ret_info.ret_code)
    self:Finish(false)
  end
end

function NPCActionHomeIndoorStealReward:RequestSteal()
  local player = self:GetPlayer()
  local npc = self.Owner.owner
  local bAttack = PetUtils.CheckIfPetCounterattack(npc, player)
  if bAttack then
    self:OnErrTips(-1)
    local AIComp = npc.AIComponent
    if AIComp then
      AIComp:OverrideBehavior(GetAttackBehavior(), _G.Enum.BehaviorOverridePriority.BOP_B)
      AIComp:NotifyDotsWorldEvent(_G.Enum.DotsAIWorldEventType.DAWET_HOME_STEAL_REWARD, 1)
    end
    self:DecreaseFriendliness(npc, player)
    self:Finish(true)
  else
    local req = ProtoMessage:newZoneHomePetStealReq()
    req.npc_obj_id = npc.serverData.base.actor_id
    req.pet_gid = npc.serverData.home_pet.home_pet_info.pet_gid
    _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_HOME_PET_STEAL_REQ, req, self, self.OnStealRsp, false, true)
  end
end

function NPCActionHomeIndoorStealReward:Execute()
  Base.Execute(self)
  local homeOwnerId = _G.HomeIndoorSandbox and _G.HomeIndoorSandbox.Server and _G.HomeIndoorSandbox.Server.MasterId
  if not homeOwnerId or not _G.DataModelMgr.PlayerDataModel:IsFriend(homeOwnerId) then
    self:OnErrTips(50314)
    self:Finish(false)
    return
  end
  if not CheckIfCouldExecute() then
    self:OnErrTips(-2)
    self:Finish(false)
    return
  end
  local player = self:GetPlayer()
  local npc = self.Owner.owner
  if not player or not npc then
    Log.Error("NPCActionHomeIndoorStealReward with invalid player and npc")
    self:Finish(false)
    return
  end
  self:QueryCouldSteal()
end

function NPCActionHomeIndoorStealReward:OnStealRsp(rsp)
  Log.Dump(rsp, 3, "OnStealRsp")
  if 0 == rsp.ret_info.ret_code then
    if rsp.pet_gid then
      local stealPet = _G.NRCModuleManager:DoCmd(_G.HomeModuleCmd.GetHomePetInfo, rsp.pet_gid)
      _G.NRCModuleManager:DoCmd(_G.BigMapModuleCmd.SetHomePetNpcData, stealPet, _G.Enum.MapModuleDataUpdateReason.HOME_PET_TRIGGER_NUM_LIMIT)
      _G.DataModelMgr.PlayerDataModel:UpdateStealHomePetInfo(rsp.pet_gid)
      _G.NRCEventCenter:DispatchEvent(NPCModuleEvent.OnHomePetInfoChanged, nil)
    end
    local stealGoods = rsp.ret_info.goods_change_info
    local skillPath = ""
    local player = self:GetPlayer()
    local pet = self:GetOwnerNPC()
    local petView = self:GetOwnerNPCView()
    if not pet or not petView then
      self:Finish(false)
    end
    local npc = self.Owner.owner
    local AIComp = pet.AIComponent
    if AIComp then
      AIComp:NotifyDotsWorldEvent(_G.Enum.DotsAIWorldEventType.DAWET_HOME_STEAL_REWARD, 2)
    end
    self:DecreaseFriendliness(npc, player)
    player:FaceTo(pet)
    local playerMesh = player.viewObj:GetComponentByClass(UE4.USkeletalMeshComponent)
    local headLocation = playerMesh:GetSocketLocation("locator_Head")
    local playerHeadZ = headLocation.Z
    local capsuleComp = petView:GetComponentByClass(UE4.UCapsuleComponent)
    local capsuleLocation = petView:Abs_K2_GetActorLocation()
    local capsuleHalfHeight = capsuleComp:GetScaledCapsuleHalfHeight()
    local petHeight = capsuleLocation.Z + capsuleHalfHeight * 0.3
    local heightType = playerHeadZ > petHeight and "Low" or "Normal"
    local skillComp = player.viewObj.RocoSkill
    skillPath = string.format("/Game/ArtRes/Effects/G6Skill/Home/G6_Home_Touch_%s_Alert.G6_Home_Touch_%s_Alert", heightType, heightType)
    local skill = RocoSkillProxy.Create(skillPath, skillComp)
    if not skill then
      self:Finish(false)
      return
    end
    pet:LockAIForReason(true, true, _G.AIDefines.LockReason.ACTION_PROCESS)
    skill:SetCaster(player.viewObj)
    skill:SetTargets({petView})
    skill:RegisterEventCallback("End", self, self.OnPlaySkillEnd):RegisterEventCallback("ActivateFailed", self, self.OnPlaySkillEnd):RegisterEventCallback("Interrupt", self, self.OnPlaySkillEnd)
    skill:SetPassive(false)
    skill:PlaySkill()
  else
    self:OnErrTips(rsp.ret_info.ret_code)
    self:Finish(false)
  end
end

function NPCActionHomeIndoorStealReward:OnErrTips(errorCode)
  local tips = ""
  if -1 == errorCode then
    tips = string.format(LuaText.home_kanban_guest_steal_fail)
  elseif -2 == errorCode then
    tips = LuaText.home_pet_steal_forbid_time
  else
    local tipsKey = string.format("Error_Code_%d", errorCode)
    tips = LuaText[tipsKey]
    if not tips then
      self:Finish(false)
      return
    end
  end
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, tips)
end

function NPCActionHomeIndoorStealReward:OnPlaySkillEnd()
  local pet = self:GetOwnerNPC()
  if pet then
    pet:LockAIForReason(false, true, _G.AIDefines.LockReason.ACTION_PROCESS)
  end
  self:Finish(true)
end

return NPCActionHomeIndoorStealReward
