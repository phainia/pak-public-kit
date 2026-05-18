local Delegate = require("Utils.Delegate")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local Base = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local StunFxPaths = {
  [1] = "NiagaraSystem'/Game/ArtRes/Effects/Particle/Common/Perception/com_Stun_fx.com_Stun_fx'",
  [2] = "NiagaraSystem'/Game/ArtRes/Effects/Particle/Scene/BossBattle/NS_Scene_BossBattle_XuanYun01.NS_Scene_BossBattle_XuanYun01'"
}
local StunComponent = Base:Extend("StunComponent")

function StunComponent:Attach(owner)
  Base.Attach(self, owner)
  SceneUtils.RegisterNPCVisibilityNotify(self)
  self.StunState = false
  self.StunEndTimeStamp = 0
  self.StunLevel = 1
  self.StunFxComp = nil
  self.StunEndDelegate = Delegate()
  self.d_HitAnim = nil
  self.d_Stun = nil
  self.skipHit = false
  self.reg_ApplicationForeground = false
  if owner and owner.config and owner.config.genre == Enum.ClientNpcType.CNT_PETBOSS then
    owner:AddEventListener(self, NPCModuleEvent.OnLogicStatusUpdated, self.OnLogicStatusChanged)
  end
end

function StunComponent:DeAttach()
  SceneUtils.UnregisterNPCVisibilityNotify(self)
  self:UnregisterApplicationForegroundEvent()
  self.StunState = false
  self:RemoveStunFx()
  self.StunEndDelegate:Clear()
  if self.d_Stun then
    _G.DelayManager:CancelDelayById(self.d_Stun)
    self.d_Stun = nil
  end
  local owner = self.owner
  if owner and owner.config and owner.config.genre == Enum.ClientNpcType.CNT_PETBOSS then
    owner:RemoveEventListener(self, NPCModuleEvent.OnLogicStatusUpdated, self.OnLogicStatusChanged)
  end
end

function StunComponent:OnVisible()
  self:InternalUpdateView()
  if self.StunState then
    local rate = 2 == self.StunLevel and 0.5 or 1
    self.owner:PlayAnim("Stun", rate, 0, 0.11, 0, -1)
  end
end

function StunComponent:OnInvisible()
  self:RemoveStunFx()
end

function StunComponent:Stun(seconds, caller, callback)
  self.StunEndTimeStamp = ZoneServer:GetServerTime() / 1000 + seconds
  if callback then
    self.StunEndDelegate:Add(caller, callback)
  end
  if self.d_Stun then
    DelayManager:CancelDelayById(self.d_Stun)
  end
  self.d_Stun = DelayManager:DelaySeconds(seconds, self.OnStunEnd, self)
  self:SetAILocker(true)
  self.StunState = true
  self:HandleStunFlyFalling()
  self:PlayStunAnimation()
  self:InternalUpdateView()
end

function StunComponent:OnResourceLoaded()
  self:PlayStunAnimation()
end

local HiddenComponent

function StunComponent:ShouldPlayHit()
  if self.skipHit then
    return false
  end
  if not HiddenComponent then
    HiddenComponent = require("NewRoco.Modules.Core.Scene.Component.Hidden.HiddenComponent")
  end
  local HideComp = self.owner:GetComponent(HiddenComponent)
  local SkipForHideReason = false
  if HideComp then
    SkipForHideReason = HideComp:IsHidden()
  end
  local isNightMare = self.owner:IsLogicStatus(Enum.SpaceActorLogicStatus.SALS_NIGHTMARE_ELITE)
  return (_G.GlobalConfig.bPlayHitWhenStun or 2 == self.StunLevel) and not SkipForHideReason and not isNightMare
end

function StunComponent:PlayStunAnimation()
  if not self.StunState then
    return
  end
  if self.d_HitAnim == nil then
    if self:ShouldPlayHit() then
      local len = self.owner:PlayAnim("Hit3")
      if 0 ~= len then
        self:TryHitAway()
        if len > 1 then
          len = len - 1
        end
        self.d_HitAnim = DelayManager:DelaySeconds(len, function()
          self.d_HitAnim = nil
          if self.StunState then
            local rate = 2 == self.StunLevel and 0.5 or 1
            self.owner:PlayAnim("Stun", rate, 0, 0.11, 0, -1)
          end
        end)
      end
    else
      self.owner:PlayAnim("Stun", 1, 0, 0.11, 0, -1)
    end
  end
end

function StunComponent:TryHitAway()
  local AIComp = self.owner.AIComponent
  if AIComp and not AIComp.isServerAI and 1 == AIComp.lastHitBy then
    local source = self.owner.module.SceneAIManager._cachedLastThrowStarSource
    if source then
      self.owner:HitAway(source, 100)
    end
  end
end

function StunComponent:StopStunAnimation()
  if self.d_HitAnim then
    DelayManager:CancelDelayById(self.d_HitAnim)
    self.d_HitAnim = nil
  end
  self.owner:StopAnim("Stun", 0.2)
end

function StunComponent:StopStun(notCancelAnim)
  notCancelAnim = notCancelAnim or false
  if self.d_Stun then
    DelayManager:CancelDelayById(self.d_Stun)
    self.d_Stun = nil
  end
  self:OnStunEnd(notCancelAnim)
end

function StunComponent:GetDelegate()
  return self.StunEndDelegate
end

function StunComponent:OnStunEnd(notCancelAnim)
  self.d_Stun = nil
  if not notCancelAnim then
    self:StopStunAnimation()
  end
  self:SetAILocker(false, notCancelAnim)
  self.StunState = false
  self.StunEndDelegate:Invoke(self)
  self.StunEndDelegate:Clear()
  self:InternalUpdateView()
end

function StunComponent:InternalUpdateView()
  if self.StunState then
    self:AttachStunFx()
    self:UpdateStunLevel()
    if self.audioSessionId then
      UE4.UNRCAudioManager.Get():ReleaseSession(self.audioSessionId, true, "StunComponent")
    end
    self.audioSessionId = UE4.UNRCAudioManager.Get():PlaySound3DWithActorAuto(100201, self.owner.viewObj, "StunComponent")
  else
    self:RemoveStunFx()
    if self.audioSessionId then
      UE4.UNRCAudioManager.Get():ReleaseSession(self.audioSessionId, true, "StunComponent")
      self.audioSessionId = nil
    end
  end
end

local bIsCircleTimeSet = false
local BuffTime1 = 60.0
local BuffTime2 = 45.0
local BuffTime3 = 30.0
local BuffTime4 = 15.0

function StunComponent.InitCircleTime()
  if not bIsCircleTimeSet then
    bIsCircleTimeSet = true
    local config = _G.DataConfigManager:GetNpcGlobalConfig("worldcombat_stun_buff")
    if 4 ~= #config.numList then
      Log.Error("[StunComponent] Failed read 'NPC_GLOBAL_CONFIG.worldcombat_stun_buff', use default")
    else
      BuffTime1 = _G.DataConfigManager:GetWorldBuffConf(config.numList[1]).time_out_duration / 1000.0
      BuffTime2 = _G.DataConfigManager:GetWorldBuffConf(config.numList[2]).time_out_duration / 1000.0
      BuffTime3 = _G.DataConfigManager:GetWorldBuffConf(config.numList[3]).time_out_duration / 1000.0
      BuffTime4 = _G.DataConfigManager:GetWorldBuffConf(config.numList[4]).time_out_duration / 1000.0
    end
    Log.DebugFormat("[StunComponent] Successfully read stun duration from WORLD_BUFF configuration. Time1=%.2f, Time2=%.2f, Time3=%.2f, Time4=%.2f", BuffTime1, BuffTime2, BuffTime3, BuffTime4)
  end
end

function StunComponent:AttachStunFx()
  local View = self.owner.viewObj
  if not View then
    return Log.Error("[StunComponent] AttachStunFx failed, cant find viewObj", self.owner.config.name)
  end
  if self.StunFxComp == nil then
    local trans = self:GetStunEffectTransform()
    self.StunFxComp = View:AddComponentByClass(UE.UNRCNiagaraSystemComponent, false, trans, true)
    self.StunFxComp:SetAutoActivate(false)
    self.StunFxComp:SetAbsolute(false, false, true)
    View:FinishAddComponent(self.StunFxComp, true, trans)
    self.StunFxComp:K2_AttachToComponent(View:GetComponentByClass(UE.USkeletalMeshComponent), "locator_head", UE.EAttachmentRule.SnapToTarget, UE.EAttachmentRule.SnapToTarget, UE.EAttachmentRule.KeepWorld, false)
  end
  self.StunFxComp:SetPath(StunFxPaths[self.StunLevel])
  if 2 == self.StunLevel then
    StunComponent.InitCircleTime()
    self:RegisterApplicationForegroundEvent()
    self:PrepareStunParams()
  else
    Log.DebugFormat("[StunComponent] AttachStunFx to npc=%d with level=1", self.owner.config.id)
  end
end

function StunComponent:RegisterApplicationForegroundEvent()
  if not self.reg_ApplicationForeground then
    _G.NRCEventCenter:RegisterEvent("StunComponent", self, _G.NRCGlobalEvent.OnApplicationHasEnteredForeground, self.OnApplicationForeground)
    _G.NRCEventCenter:RegisterEvent("StunComponent", self, _G.NRCGlobalEvent.OnApplicationHasReactivated, self.OnApplicationHasReactivated)
    self.reg_ApplicationForeground = true
  end
end

function StunComponent:UnregisterApplicationForegroundEvent()
  if self.reg_ApplicationForeground then
    _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.OnApplicationHasEnteredForeground, self.OnApplicationForeground)
    _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.OnApplicationHasReactivated, self.OnApplicationHasReactivated)
    self.reg_ApplicationForeground = false
  end
end

function StunComponent:OnApplicationForeground()
  if self.StunState and 2 == self.StunLevel then
    if self.StunFxComp then
      self.StunFxComp:ClearAll()
      self.StunFxComp:SetPath(StunFxPaths[2])
    end
    self:PrepareStunParams()
  end
end

function StunComponent:OnApplicationHasReactivated()
  if self.StunState and 2 == self.StunLevel then
    if self.StunFxComp then
      self.StunFxComp:ClearAll()
      self.StunFxComp:SetPath(StunFxPaths[2])
    end
    self:PrepareStunParams()
  end
end

function StunComponent:PrepareStunParams()
  if not self.StunFxComp then
    return
  end
  local CurrentTime = _G.ZoneServer:GetServerTime() / 1000.0
  local LifeTime1 = math.max(self.StunEndTimeStamp - CurrentTime, 0)
  local LifeTime2 = math.max(self.StunEndTimeStamp - CurrentTime - BuffTime4, 0)
  local LifeTime3 = math.max(self.StunEndTimeStamp - CurrentTime - BuffTime3, 0)
  local LifeTime4 = math.max(self.StunEndTimeStamp - CurrentTime - BuffTime2, 0)
  self.StunFxComp:SetFloatParameter("Time01", LifeTime1)
  self.StunFxComp:SetFloatParameter("Time02", LifeTime2)
  self.StunFxComp:SetFloatParameter("Time03", LifeTime3)
  self.StunFxComp:SetFloatParameter("Time04", LifeTime4)
  Log.DebugFormat("[StunComponent] AttachStunFx to npc=%d with level=2, each star remains for (=%.2f, =%.2f, =%.2f, =%.2f) seconds", self.owner.config.id, LifeTime1, LifeTime2, LifeTime3, LifeTime4)
end

function StunComponent:SetStunLevel(inLevel)
  self.StunLevel = inLevel
  return self
end

function StunComponent:SetSkipHit(skip)
  self.skipHit = skip
  return self
end

function StunComponent:SetAILocker(lock, delayForAWhile)
  local AiComp = self.owner.AIComponent
  if AiComp then
    if delayForAWhile then
      AiComp:ForceLockForReasonDelay(lock, true, AIDefines.LockReason.STUN, 3)
    else
      AiComp:ForceLockForReason(lock, true, AIDefines.LockReason.STUN)
    end
  end
  local view = self.owner.viewObj
  local moveComp = view and view:GetComponentByClass(UE.UCharacterNavMovementComponent)
  if moveComp then
    moveComp.bDisabledImmergeWaterChecking = lock
  end
end

function StunComponent:GetStunLevel()
  return self.StunLevel
end

function StunComponent:RemoveStunFx()
  local View = self.owner.viewObj
  if not View or not UE.UObject.IsValid(View) then
    return
  end
  if self.StunFxComp then
    View:K2_DestroyComponent(self.StunFxComp)
    self.StunFxComp = nil
  end
end

function StunComponent:UpdateStunLevel()
  if self.StunFxComp == nil then
    return
  end
  local level = self:GetStunLevel()
  self.StunFxComp:SetPath(StunFxPaths[level])
end

local BossStunFxRadius = 120

function StunComponent:GetStunEffectTransform()
  if 2 == self.StunLevel then
    local t = UE.FTransform()
    local r = self.owner:GetScaledRadius()
    if r > 0 and r < BossStunFxRadius then
      local ratio = r / BossStunFxRadius
      t.Scale3D.X = ratio
      t.Scale3D.Y = ratio
      t.Scale3D.Z = ratio
    end
    return t
  else
    return UE.FTransform()
  end
end

function StunComponent:SetHidden(Visible)
  if self.StunFxComp then
    self.StunFxComp:SetHiddenInGame(Visible)
  end
end

function StunComponent:OnLogicStatusChanged(owner, ChangeInfo)
  if not ChangeInfo or not ChangeInfo.changed_status.status then
    return
  end
  local status = ChangeInfo.changed_status.status
  local opType = ChangeInfo.op_type
  if status == ProtoEnum.SpaceActorLogicStatus.SALS_FIGHTING and (opType == ProtoEnum.LogicStatusOpType.LSOT_REMOVE or opType == ProtoEnum.LogicStatusOpType.LSOT_REMOVE_ALL) then
    self.StunState = false
    self:StopStunAnimation()
  end
end

function StunComponent:LeaveBattle()
  local owner = self.owner
  if owner then
    local config = owner.config
    if config and config.genre == Enum.ClientNpcType.CNT_PETBOSS and self.owner:IsLogicStatus(ProtoEnum.SpaceActorLogicStatus.SALS_FIGHTING) then
      self.StunState = true
      local skipHit = self.skipHit
      self.skipHit = true
      self:PlayStunAnimation()
      self.skipHit = skipHit
      return
    end
  end
  self:StopStunAnimation()
end

function StunComponent:HandleStunFlyFalling()
  local moveComp = self.owner.viewObj.GetMovementComponent and self.owner.viewObj:GetMovementComponent() or nil
  if moveComp and (moveComp:IsHovering() or moveComp:IsFlying()) then
    moveComp:SetMovementMode(UE4.EMovementMode.MOVE_Falling)
    if moveComp:IsA(UE.UCharacterNavMovementComponent) then
      moveComp:ReqCloseFallingResist()
      moveComp:ReqCloseFallingMaxSpeedLimit()
    end
  end
end

return StunComponent
