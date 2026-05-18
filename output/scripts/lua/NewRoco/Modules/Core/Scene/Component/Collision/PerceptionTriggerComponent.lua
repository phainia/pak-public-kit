local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local ActorComponent = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local Base = ActorComponent
local PerceptionTriggerComponent = Base:Extend("PerceptionTriggerComponent")
local PerceptionTakeReasonEnum = {
  Option = 1,
  Reveal = 2,
  Visible = 3
}

function PerceptionTriggerComponent:Attach(owner)
  Base.Attach(self, owner)
  self.OverlappedActors = {}
  self.OverlappedReasons = {}
  self.perceptionStarted = false
  self.perceptionUpdateCountDownConst = 3
  self.perceptionUpdateCountDown = self.perceptionUpdateCountDownConst
  self.perceptionType = 0
  self.CustomReason = "perceptionTrigger"
end

function PerceptionTriggerComponent:DeAttach()
  self:StopPerception()
  Base.DeAttach(self)
end

function PerceptionTriggerComponent:StartPerception(PetGID, PetBaseId, CustomReason)
  self.OverlappedActors = {}
  self.OverlappedReasons = {}
  self.perceptionStarted = true
  self.PetGID = PetGID
  self.PetBaseId = PetBaseId
  if CustomReason then
    self.CustomReason = CustomReason
  end
  self:PreparePet()
  self:SyncPerceiveState(true)
  self.perceptionUpdateCountDown = self.perceptionUpdateCountDownConst
  self:UpdatePetPerception(true)
  if next(self.OverlappedActors) == nil then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.Ganzhi_Not_Found)
  end
  self:OnPerceptionInit(self.OverlappedActors, self.OverlappedReasons)
end

function PerceptionTriggerComponent:StopPerception()
  if not self.SensingConf then
    self.perceptionStarted = false
    return
  end
  if not self.perceptionStarted then
    return
  end
  self.perceptionStarted = false
  self:OnPerceptionFinish(self.OverlappedActors, self.OverlappedReasons)
  self:SyncPerceiveState(false)
  self:ClearActors()
end

function PerceptionTriggerComponent:UpdatePetPerception(bIsInit)
  for key, value in pairs(self.OverlappedActors) do
    self.OverlappedActors[key] = false
  end
  local newNpcList = {}
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  local sourceLocation = self.owner.viewObj:K2_GetActorLocation()
  for _, Character in pairs(NPCModule._npcIterDic) do
    local shouldTakeFlag = self:ShouldTake(Character, sourceLocation)
    if 0 ~= shouldTakeFlag then
      if self.OverlappedActors[Character] ~= nil then
        self.OverlappedActors[Character] = true
      else
        self.OverlappedActors[Character] = true
        self.OverlappedReasons[Character] = shouldTakeFlag
        table.insert(newNpcList, Character)
        self:OnPerceptionActorEnter(Character, shouldTakeFlag)
      end
    end
  end
  if #newNpcList > 0 then
    local Req = _G.ProtoMessage:newZoneScenePerceivingNpcReq()
    for i, npc in ipairs(newNpcList) do
      if npc then
        local shouldTakeByReveal = self:CheckPerceptionFlag(self.OverlappedReasons[npc], PerceptionTakeReasonEnum.Reveal)
        if shouldTakeByReveal and npc.serverData and npc.serverData.base then
          table.insert(Req.npc_ids, npc.serverData.base.actor_id)
        end
      end
    end
    if #Req.npc_ids > 0 then
      _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_SCENE_PERCEIVING_NPC_REQ, Req, self, self.OnPerceivingNpcRsp, false, false)
    end
  end
  local removedActors = {}
  for key, value in pairs(self.OverlappedActors) do
    if not value then
      table.insert(removedActors, key)
    end
  end
  for i, npc in ipairs(removedActors) do
    local shouldTakeFlag = self.OverlappedReasons[npc]
    self.OverlappedActors[npc] = nil
    self.OverlappedReasons[npc] = nil
    self:OnPerceptionActorLeave(npc, shouldTakeFlag)
  end
  table.clear(removedActors)
end

function PerceptionTriggerComponent:OnPerceivingNpcRsp(rsp)
  if 0 ~= rsp.ret_info.ret_code then
    Log.Error("PerceptionTriggerComponent:OnPerceivingNpcRsp", table.tostring(rsp))
  end
end

function PerceptionTriggerComponent:SetPerceptionFlag(Flag, Offset)
  if nil == Flag then
    Flag = 0
  end
  return Flag | 1 << Offset
end

function PerceptionTriggerComponent:CheckPerceptionFlag(Flag, Offset)
  return 0 ~= Flag & 1 << Offset
end

function PerceptionTriggerComponent:ShouldTake(npc, sourceLocation)
  local ShouldTakeFlag = 0
  if not npc then
    return ShouldTakeFlag
  end
  if self.owner == npc then
    return ShouldTakeFlag
  end
  if not npc.config then
    return ShouldTakeFlag
  end
  if not self.SensingConf then
    return ShouldTakeFlag
  end
  if npc.AIComponent and npc.AIComponent:HasControlFlags(Enum.SceneAiControlFlags.SACF_DISABLE_PET_GANZHI) then
    return ShouldTakeFlag
  end
  local targetLocation
  if npc and npc.viewObj and UE4.UObject.IsValid(npc.viewObj) and npc.viewObj.K2_GetActorLocation then
    targetLocation = npc.viewObj:K2_GetActorLocation()
  end
  local distance = 100000000
  if sourceLocation and targetLocation then
    distance = UE4.FVector.DistSquared(sourceLocation, targetLocation)
  end
  local canPerceptionByType = self:CanPerceptionByType(npc)
  if not table.contains(self.SensingConf.npc_id, npc.config.id) and not canPerceptionByType and not table.contains(self.SensingConf.model_id or {}, npc.config.model_conf) then
    return ShouldTakeFlag
  end
  if canPerceptionByType or self:ShouldTakeOption(npc, distance) then
    ShouldTakeFlag = self:SetPerceptionFlag(ShouldTakeFlag, PerceptionTakeReasonEnum.Option)
  end
  if self:ShouldTakeByReveal(npc, distance) then
    ShouldTakeFlag = self:SetPerceptionFlag(ShouldTakeFlag, PerceptionTakeReasonEnum.Reveal)
  end
  if self:ShouldTakeByVisible(npc, distance) then
    ShouldTakeFlag = self:SetPerceptionFlag(ShouldTakeFlag, PerceptionTakeReasonEnum.Visible)
  end
  return ShouldTakeFlag
end

function PerceptionTriggerComponent:ShouldTakeOption(npc, distance)
  if not self.SensingConf then
    return false
  end
  if distance > self.SensingRange then
    return false
  end
  local InteractionComponent = npc.InteractionComponent
  if not InteractionComponent then
    return false
  end
  local MainAction = InteractionComponent:GetMainAction()
  if MainAction then
    if not MainAction:IsOptionEnable() then
      Log.Debug("ShouldTake", self.SensingConf.name, "Option\230\132\159\231\159\165(\228\184\187\228\186\164\228\186\146\228\184\141\229\143\175\231\148\168)", npc.config.name, "\229\144\166")
      return false
    end
  else
    Log.Debug("ShouldTake", self.SensingConf.name, "Option\230\132\159\231\159\165(\230\178\161\230\156\137\228\184\187\228\186\164\228\186\146)", npc.config.name, "\229\144\166")
    return false
  end
  return true
end

function PerceptionTriggerComponent:ShouldTakeByVisible(npc, distance)
  if self:IsVisibleDuringPerception(npc) then
    return true
  end
  return false
end

function PerceptionTriggerComponent:ShouldTakeByReveal(npc, distance)
  if self:IsCannotBeSeen(npc) then
    return true
  end
  return false
end

function PerceptionTriggerComponent:IsVisibleDuringPerception(npc)
  if not npc.serverData then
    return false
  end
  local npc_refresh_id = npc.serverData.npc_base.npc_content_cfg_id
  if not npc_refresh_id or 0 == npc_refresh_id then
    return false
  end
  local npc_refresh_conf = _G.DataConfigManager:GetNpcRefreshContentConf(npc_refresh_id)
  if not npc_refresh_conf then
    return false
  end
  local perception_visible = npc_refresh_conf.visible_during_perception
  if perception_visible then
    return true
  end
  return false
end

function PerceptionTriggerComponent:IsCannotBeSeen(npc)
  if npc.serverData and npc.serverData.misc_info.cannot_be_seen then
    return true
  end
  return false
end

function PerceptionTriggerComponent:GetPetBaseConf(npc)
  local Comp = npc.PetStatusComponent
  if Comp and Comp.CurrentPetData then
    return _G.DataConfigManager:GetPetbaseConf(Comp.CurrentPetData.base_conf_id)
  end
  if npc.config.traverse_data_type ~= _G.Enum.Traverse_Data_Type.TDT_PETBASE then
    return nil
  end
  local PetBaseConfID = npc.config.traverse_data_param[1]
  if not PetBaseConfID then
    return nil
  end
  return _G.DataConfigManager:GetPetbaseConf(PetBaseConfID)
end

function PerceptionTriggerComponent:HasCommon(Part1, Part2)
  if not Part1 or not Part2 then
    return
  end
  for _, Sub1 in ipairs(Part1) do
    for _, Sub2 in ipairs(Part2) do
      if Sub1 == Sub2 then
        return true
      end
    end
  end
  return false
end

function PerceptionTriggerComponent:CanPerceptionByType(npc)
  local InteractionComponent = npc.InteractionComponent
  if not InteractionComponent then
    return false
  end
  local Other = self:GetPetBaseConf(npc)
  if Other then
    local HasCommonType = self:HasCommon(Other.unit_type, self.SensingConf.add_status)
    if not HasCommonType then
      Log.Debug("ShouldTake", self.SensingConf.name, "\231\179\187\229\136\171\230\132\159\231\159\165", Other.name, HasCommonType and "\230\152\175" or "\229\144\166")
    end
    local HasBattleAction = InteractionComponent:GetActiveBattleAction() and true or false
    return HasCommonType and HasBattleAction
  end
  return false
end

function PerceptionTriggerComponent:PreparePet()
  self.PetData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.PetGID)
  if self.PetData then
    self.PetBaseId = self.PetData.base_conf_id
  end
  if not self.PetBaseId then
    return false
  end
  self.PetBaseConf = _G.DataConfigManager:GetPetbaseConf(self.PetBaseId)
  if not self.PetBaseConf then
    return false
  end
  self.SensingConf = _G.DataConfigManager:GetPetSceneAbilityGanzhi(self.PetBaseConf.id, true)
  if self.SensingConf then
    self.SensingRange = self.SensingConf.pet_ability_distance * self.SensingConf.pet_ability_distance
    return true
  else
    Log.Error(string.format("PetBaseId\228\184\186%d\231\154\132\231\178\190\231\129\181\230\178\161\230\156\137\230\132\159\231\159\165\233\133\141\231\189\174\239\188\140\232\175\183\231\173\150\229\136\146\229\184\174\229\191\153\231\156\139\231\156\139\230\141\143", self.PetBaseConf.id))
    return false
  end
end

function PerceptionTriggerComponent:OnDistanceOptimize(distance, viewDotValue, bulkyVisible, distanceRatio)
  self:Update()
end

function PerceptionTriggerComponent:Update()
  if self.perceptionStarted then
    self.perceptionUpdateCountDown = self.perceptionUpdateCountDown - 1
    if self.perceptionUpdateCountDown <= 0 then
      self:UpdatePetPerception(false)
      self.perceptionUpdateCountDown = self.perceptionUpdateCountDownConst
    end
  end
end

function PerceptionTriggerComponent:ClearActors()
  table.clear(self.OverlappedActors)
  table.clear(self.OverlappedReasons)
end

function PerceptionTriggerComponent:UpdateData(ServerData, isReconnect)
  if isReconnect then
  end
end

function PerceptionTriggerComponent:Destroy()
  self:StopPerception()
  Base.Destroy(self)
end

function PerceptionTriggerComponent:OnDisConnect()
end

function PerceptionTriggerComponent:OnReConnect()
end

function PerceptionTriggerComponent:NpcEnterPerception(actor, shouldTakeFlag, bInit)
  local shouldTakeByOption = self:CheckPerceptionFlag(shouldTakeFlag, PerceptionTakeReasonEnum.Option)
  local shouldTakeByReveal = self:CheckPerceptionFlag(shouldTakeFlag, PerceptionTakeReasonEnum.Reveal)
  local shouldTakeByVisible = self:CheckPerceptionFlag(shouldTakeFlag, PerceptionTakeReasonEnum.Visible)
  if shouldTakeByVisible or shouldTakeByReveal then
    actor:SetCustomDepth(10, self.CustomReason)
  elseif shouldTakeByOption then
    actor:SetCustomDepth(5, self.CustomReason)
  end
  if shouldTakeByVisible then
    actor:SetVisibleForPerceptionReason(true)
  end
  actor:MarkPerception(true)
end

function PerceptionTriggerComponent:NpcExitPerception(actor, shouldTakeFlag)
  local shouldTakeByVisible = self:CheckPerceptionFlag(shouldTakeFlag, PerceptionTakeReasonEnum.Visible)
  actor:SetCustomDepth(nil, self.CustomReason)
  if shouldTakeByVisible then
    actor:SetVisibleForPerceptionReason(false)
  end
  actor:MarkPerception(false)
end

function PerceptionTriggerComponent:OnPerceptionInit(overlappedActors, OverlappedReasons)
  local RevealNpcList = {}
  for actor, _ in pairs(overlappedActors) do
    if actor then
      self:NpcEnterPerception(actor, OverlappedReasons[actor], true)
      local shouldTakeByReveal = self:CheckPerceptionFlag(OverlappedReasons[actor], PerceptionTakeReasonEnum.Reveal)
      if shouldTakeByReveal then
        table.insert(RevealNpcList, actor.serverData.base.actor_id)
      end
    end
  end
  if #RevealNpcList > 0 then
    local Req = _G.ProtoMessage:newZoneScenePerceivingNpcReq()
    Req.npc_ids = RevealNpcList
  end
end

function PerceptionTriggerComponent:OnRsp(rsp)
end

function PerceptionTriggerComponent:OnPerceptionActorEnter(actor, shouldTakeFlag)
  if actor then
    self:NpcEnterPerception(actor, shouldTakeFlag, false)
  end
end

function PerceptionTriggerComponent:OnPerceptionActorLeave(actor, shouldTakeFlag)
  if actor then
    self:NpcExitPerception(actor, shouldTakeFlag)
  end
end

function PerceptionTriggerComponent:OnPerceptionFinish(overlappedActors, OverlappedReasons)
  for actor, _ in pairs(overlappedActors) do
    if actor then
      self:NpcExitPerception(actor, OverlappedReasons[actor])
    end
  end
  if self.owner then
    self.owner:SetCustomDepth(nil, self.CustomReason)
  end
end

function PerceptionTriggerComponent:GetClosest()
  if not self.owner then
    return nil
  end
  if not self.OverlappedActors then
    return nil
  end
  local actor, dist
  for npc, _ in pairs(self.OverlappedActors) do
    if npc ~= self.owner then
      local shouldTakeByOption = self:CheckPerceptionFlag(self.OverlappedReasons[npc], PerceptionTakeReasonEnum.Option)
      if shouldTakeByOption and (nil == dist or dist > npc.squaredDis2Local) then
        dist = npc.squaredDis2Local
        actor = npc
      end
    end
  end
  return actor
end

function PerceptionTriggerComponent:SyncPerceiveState(Open)
  if not self.PetGID then
    Log.Error("\233\128\154\231\159\165\229\144\142\229\143\176\229\143\150\230\182\136\230\132\159\231\159\165\230\151\182Session\229\183\178\231\187\143\228\184\141\229\173\152\229\156\168\228\186\134", Open)
    return
  end
  local Req = _G.ProtoMessage:newZonePetPerceivingReq()
  Req.gid = self.PetGID
  Req.is_begin = Open
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_PET_PERCEIVING_REQ, Req, self, self.OnSendPerceive, false, false)
end

function PerceptionTriggerComponent:OnSendPerceive(rsp)
  if 0 ~= rsp.ret_info.ret_code then
    Log.Error("\233\128\154\231\159\165\229\144\142\229\143\176\230\132\159\231\159\165\231\138\182\230\128\129\229\135\186\233\148\153\228\186\134", rsp.ret_info.ret_code)
  end
end

return PerceptionTriggerComponent
