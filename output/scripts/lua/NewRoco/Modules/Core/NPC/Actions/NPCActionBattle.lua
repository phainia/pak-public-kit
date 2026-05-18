local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleField = require("NewRoco.Modules.Core.Battle.Common.BattleField")
local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local ActionUtils = require("NewRoco.Modules.Core.NPC.Actions.ActionUtils")
local Base = NPCActionBase
local CD2Conf = _G.DataConfigManager:GetBattleGlobalConfig("touch_battle_min_cd")
local CD2 = 3
if CD2Conf and CD2Conf.num then
  CD2 = CD2Conf.num
end
local BlockHitAIStatus = _G.DataConfigManager:GetBattleGlobalConfig("block_hit_animation_battle_ai_status").numList
local NPCHitPlayerAnim = _G.DataConfigManager:GetBattleGlobalConfig("npc_hit_player_world_animation").str
local PlayerHitNPCAnim = _G.DataConfigManager:GetBattleGlobalConfig("player_hit_npc_world_animation").str
local NPCCollideAnim = _G.DataConfigManager:GetBattleGlobalConfig("each_hit_npc_world_animation").str
local PlayerCollideAnim = _G.DataConfigManager:GetBattleGlobalConfig("each_hit_player_world_animation").str
local NPCActionBattle = Base:Extend("NPCActionBattle")

function NPCActionBattle:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
  self.PlayerPursue = false
  self.NPCPursue = false
  self.IsRideBeforeBattle = false
  self.bIsTouchBattle = not string.IsNilOrEmpty(self.Config.action_param4)
end

local traceChannel = UE4.UNRCStatics.ConvertToTraceChannel(UE4.ECollisionChannel.ECC_GameTraceChannel5)

function NPCActionBattle:OnNpcAction()
  if not Base.OnNpcAction(self) then
    return false
  end
  if _G.BattleManager:IsInBattle() then
    Log.Debug("NPCActionBattle:OnNpcAction, \230\173\163\229\156\168\230\136\152\230\150\151\228\184\173\239\188\140\229\143\150\230\182\136\230\143\144\228\186\164")
    return false
  elseif _G.BattleManager.isSendWaiting then
    Log.Debug("NPCActionBattle:OnNpcAction, \230\173\163\229\156\168\231\148\179\232\175\183\232\191\155\229\133\165\230\136\152\230\150\151\231\173\137\229\190\133\228\184\173\239\188\140\229\143\150\230\182\136\230\143\144\228\186\164")
    return false
  end
  if _G.GlobalConfig.DisableBattle then
    Log.Debug("NPCActionBattle:OnNpcAction DisableBattle")
    return false
  end
  if #_G.BattleManager.battleNetManager.cachedBattleNotify > 0 then
    Log.Debug("NPCActionBattle:OnNpcAction, \230\156\137\229\190\133\229\164\132\231\144\134\231\154\132\230\136\152\230\150\151\229\141\143\232\174\174\239\188\140\229\143\150\230\182\136\230\143\144\228\186\164")
    return false
  end
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not localPlayer then
    return false
  end
  if localPlayer.PlayerThrowInteractionComponent and localPlayer.PlayerThrowInteractionComponent:IsPlaying() then
    Log.Debug("\230\173\163\229\156\168\229\135\134\229\164\135\232\191\155\230\136\152\230\150\151...")
    return false
  end
  if _G.DialogueModuleCmd and _G.NRCModuleManager:DoCmd(_G.DialogueModuleCmd.HasDialogue) then
    return false
  end
  local owner = self.Owner.owner
  if owner.LogicStatusComponent then
    local Status, _, _ = owner.LogicStatusComponent:GetStatus(_G.ProtoEnum.SpaceActorLogicStatus.SALS_FIGHTING)
    if Status then
      Log.Debug("\231\155\174\230\160\135NPC\229\183\178\231\187\143\229\156\168\230\136\152\230\150\151\228\184\173\228\186\134")
      return false
    end
  end
  if self.bIsTouchBattle then
    if localPlayer.viewObj and localPlayer.viewObj.BP_RideComponent and localPlayer.viewObj.BP_RideComponent.bIsDoubleRide2p then
      Log.Debug("NPCActionBattle:OnNpcAction, \229\143\140\228\186\186\233\170\145\228\185\152\231\154\1322p\232\167\166\229\143\145\231\154\132\239\188\140\229\143\150\230\182\136\230\143\144\228\186\164\239\188\140\232\174\1691p\229\142\187\232\167\166\229\143\145")
      return false
    end
    if GlobalConfig.DisableTouchBattle then
      return false
    end
    local Comp = owner and owner.AIComponent
    if Comp and Comp:HasControlFlags(Enum.SceneAiControlFlags.SACF_DISABLE_TOUCH_BATTLE) then
      return false
    end
    local Ban, Msg = _G.FunctionBanManager:GetFunctionState(Enum.PlayerFunctionBanType.PFBT_TOUCH_BATTLE, false, false, CD2)
    if Ban then
      Log.Debug("\228\186\146\230\150\165\231\179\187\231\187\159\230\139\166\230\136\170,CD", Msg)
      return false
    end
    local PlayerPursue, NPCPursue = ActionUtils.CalcPursue(self)
    self.PlayerPursue = PlayerPursue
    self.NPCPursue = NPCPursue
    if not PlayerPursue and not NPCPursue then
      return false
    end
    local selfPos = owner:GetActorLocation()
    local playerPos = localPlayer:GetActorLocation()
    local hitResults, isHit = UE4.UKismetSystemLibrary.Abs_LineTraceMulti(owner.viewObj, selfPos, playerPos, traceChannel, false, nil, 0, nil, true)
    if isHit and GlobalConfig.DisableTouchBattleIfTraceBlocked then
      return false
    end
    local _, isRiding = localPlayer.movementComponent:GetActiveMovement()
    self.IsRideBeforeBattle = isRiding
  end
  if owner.AIComponent then
    self.aiStatus = owner.AIComponent.battleState
    self.preAttackTag = owner.AIComponent.PreAttackTag
    self.preAttackCount = owner.AIComponent.PreAttackCount
    owner.AIComponent:LockForBattleReason()
  end
  owner:Stop()
  local actDir = owner:GetActorLocation() - localPlayer:GetActorLocation()
  actDir:Normalize()
  self.isBack = SceneUtils.TriggerBackwardBattle(owner, actDir, 2)
  if localPlayer:IsInTogetherMove() and localPlayer.viewObj then
    local rideComp = localPlayer.viewObj.BP_RideComponent
    if rideComp and rideComp:TryChangeToLink() then
      localPlayer:StopRide(true, nil)
    end
  end
  if not self.aiStatus or 0 == self.aiStatus & 1 << Enum.BattleAIStatus.BAS_SLEEP then
    if self.isBack then
      self:LookBehind(owner, localPlayer)
    else
      owner:SetHeadLookAtActor(localPlayer.viewObj)
      self:LookAt(owner, localPlayer)
    end
  end
  self:LookAt(localPlayer, owner)
  self:FreezePlayer()
  return true
end

function NPCActionBattle:Execute(playerId, needSendReq)
  Base.Execute(self, playerId, needSendReq)
  if not self.bIsTouchBattle then
    return
  end
  if not self.aiStatus then
    return
  end
  if self.IsRideBeforeBattle then
    return
  end
  local blockAIStatus = BlockHitAIStatus
  for _, status in ipairs(blockAIStatus) do
    if 0 ~= self.aiStatus & 1 << status then
      return
    end
  end
  if self.NPCPursue and not self.PlayerPursue then
    self:GetPlayer():PlayAnim(NPCHitPlayerAnim, 1, 0, 0, 0, 1, 1)
  elseif not self.NPCPursue and self.PlayerPursue then
    local NPC = self:GetOwnerNPC()
    if NPC then
      NPC:SetRootMotionMode(UE.ERootMotionMode.IgnoreRootMotion)
      NPC:PlayAnim(PlayerHitNPCAnim, 1, 0, 0, 0, 1, 1)
    end
  else
    local NPC = self:GetOwnerNPC()
    if NPC then
      NPC:SetRootMotionMode(UE.ERootMotionMode.IgnoreRootMotion)
      NPC:PlayAnim(NPCCollideAnim, 1, 0, 0, 0.25, 1, 1)
    end
    self:GetPlayer():PlayAnim(PlayerCollideAnim, 1, 0, 0, 0.25, 1, 1)
  end
end

function NPCActionBattle:Submit()
  BattleUtils.ToggleInput(false)
  self:RegisterNetWorkEvent()
  _G.BattleManager.isSendWaiting = true
  Base.Submit(self)
end

function NPCActionBattle:OnSubmit(rsp)
  _G.BattleManager.isSendWaiting = false
  BattleUtils.ToggleInput(true)
  self:RemoveNetWorkEvent()
  Base.OnSubmit(self, rsp)
  if 0 ~= rsp.ret_info.ret_code then
    self:UnregisterThisActionToPlayer()
    local owner = self.Owner.owner
    if owner.AIComponent then
      owner.AIComponent:UnlockForBattleReason()
    end
    local NPC = self:GetOwnerNPC()
    if NPC then
      NPC:SetRootMotionMode(UE.ERootMotionMode.RootMotionFromMontagesOnly)
    end
    return
  end
  if _G.BattleManager:IsInBattle() then
    self:UnregisterThisActionToPlayer()
    return
  end
  self:WaitBattleEvents()
end

function NPCActionBattle:RegisterNetWorkEvent()
  _G.NRCEventCenter:RegisterEvent(self.name, self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReconnect)
end

function NPCActionBattle:RemoveNetWorkEvent()
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReconnect)
end

function NPCActionBattle:WaitBattleEvents()
  _G.NRCEventCenter:RegisterEvent(self.name, self, _G.TaskModuleEvent.BattleOver, self.OnBattleEvent)
  _G.NRCEventCenter:RegisterEvent(self.name, self, _G.TaskModuleEvent.BattleStart, self.OnBattleEvent)
  self.BattleEventTimeoutHandler = _G.DelayManager:DelaySeconds(30, self.OnBattleEvent, self)
end

function NPCActionBattle:OnBattleEvent()
  self:UnregisterThisActionToPlayer()
  _G.NRCEventCenter:UnRegisterEvent(self, _G.TaskModuleEvent.BattleOver, self.OnBattleEvent)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.TaskModuleEvent.BattleStart, self.OnBattleEvent)
  _G.DelayManager:CancelDelayById(self.BattleEventTimeoutHandler)
  self.BattleEventTimeoutHandler = -1
end

function NPCActionBattle:OnReconnect()
  BattleUtils.ToggleInput(true)
  self:RemoveNetWorkEvent()
end

function NPCActionBattle:HasLocalPerform()
  return true
end

function NPCActionBattle:FillRequest(req)
  BattleProfiler:CheckPoint(BattleProfilerCheckPoint.NPCActionBattle)
  if self.Owner and self.Owner.owner then
    req.npc_pt = self.Owner.owner:GetServerPoint()
  end
  local localPlayer = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if localPlayer then
    req.avatar_pt = localPlayer:GetServerPoint()
    local PlayerView = localPlayer.viewObj
    local RideComp = PlayerView and PlayerView.BP_RideComponent
    local Pet = RideComp and RideComp.ScenePet
    if Pet then
      req.ride_id = Pet.gid
    end
  end
  req.data1 = _G.BattleConst.Define.BattleFieldRange
  if self.isBack then
    self.aiStatus = self.aiStatus | 1 << Enum.BattleAIStatus.BAS_BACK_OF_HEAD
  end
  self.is1VN = false
  req.npc_ai_blackboard.ai_status = self.aiStatus
  req.npc_ai_blackboard.back_of_head = self.isBack
  req.npc_ai_blackboard.pre_act_tag = self.preAttackTag
  req.npc_ai_blackboard.pre_act_param = self.preAttackCount
  if SceneUtils.EnableBattleExtraMemberFetching then
    local npcModule = self.Owner.owner.module
    local specialBattle = npcModule.SceneAIManager:FillBattleExtraMemberData(req.cheer_monster_init_info, req.onlooker_obj_id, self.Owner.owner, 2)
    if specialBattle then
      req.battle_type = specialBattle
      if specialBattle == Enum.BattleType.BT_1VN then
        self.is1VN = true
      end
    end
  end
  local EnvSystem = _G.NRCModuleManager:GetModule("EnvSystemModule")
  local envTod = 0
  if EnvSystem then
    envTod = math.floor(EnvSystem:GetCurrentTime() / 3600.0)
  else
    Log.Error("EnvSystem\232\142\183\229\143\150\229\164\177\232\180\165\239\188\140\230\136\152\230\150\151tod\229\183\178\231\166\129\231\148\168")
  end
  req.npc_ai_blackboard.tod = envTod
  req.npc_ai_blackboard.new_skill = nil
end

function NPCActionBattle:GetDirection(a, b, ignoreZ)
  if not a or not b then
    return nil
  end
  local aPos = a:GetActorLocation()
  local bPos = b:GetActorLocation()
  local dir = bPos - aPos
  if ignoreZ then
    dir.Z = 0
  end
  return dir:ToRotator()
end

function NPCActionBattle:GetBehindDirection(a, b, ignoreZ)
  if not a or not b then
    return nil
  end
  local aPos = a:GetActorLocation()
  local bPos = b:GetActorLocation()
  local dir = aPos - bPos
  if ignoreZ then
    dir.Z = 0
  end
  return dir:ToRotator()
end

function NPCActionBattle:LookAt(a, b)
  if not a or not b then
    return
  end
  Log.DebugFormat("NPCActionBattle LookAt Make %s Look at %s", tostring(a), tostring(b))
  local Rot = self:GetDirection(a, b, true)
  if Rot then
    a:SetActorRotation(Rot)
  end
end

function NPCActionBattle:LookBehind(a, b)
  if not a or not b then
    return
  end
  Log.DebugFormat("NPCActionBattle LookAt Make %s Look at %s", tostring(a), tostring(b))
  local Rot = self:GetBehindDirection(a, b, true)
  if Rot then
    a:SetActorRotation(Rot)
  end
end

function NPCActionBattle:IsNeedCloseDialogueUI()
  return true
end

return NPCActionBattle
