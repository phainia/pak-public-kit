local WorldCombatActionBase = require("NewRoco.Modules.Core.NPC.Actions.WorldCombatActions.WorldCombatActionBase")
local WorldCombatSkillEvent = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatSkillEvent")
local SceneModule = require("NewRoco.Modules.Core.Scene.SceneModule")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local OverlapAwareVisibilityComponent = require("NewRoco.Modules.Core.Scene.Component.Visibility.OverlapAwareVisibilityComponent")
local NPCModuleEnum = require("NewRoco.Modules.Core.NPC.NPCModuleEnum")
local Base = WorldCombatActionBase
local WorldCombatActionCrush = Base:Extend("WorldCombatActionCrush")

function WorldCombatActionCrush:Ctor(Runner, SkillId, ActionType, ServerInfo)
  Base.Ctor(self, Runner, SkillId, ActionType, ServerInfo)
end

function WorldCombatActionCrush:PreExecute()
  Base.PreExecute(self)
  self.pastTime = 0
  if not self.Runner or not self.Runner.viewObj then
    return
  end
  self.moveComp = self.Runner.viewObj:GetComponentByClass(UE.UCharacterNavMovementComponent)
  self.capsuleComp = self.Runner.viewObj:K2_GetRootComponent()
  self.needTick = true
  self.actionType = WorldCombatActionBase.EActionType.duration
  self.actionDuration = self.ServerInfo.crush_duration
  self.finishControlBySelf = true
  self.notSync = false
  self.startPos = self.Runner:GetActorLocation()
  local halfHeight = self.Runner:GetScaledHalfHeight()
  self.targetPos = SceneUtils.ServerPos2ClientPos(self.ServerInfo.crush_final_pos) + UE.FVector(0, 0, halfHeight)
  Log.Debug("WorldCombatActionCrush:PreExecute, server Pos", self.Runner:GetActorLocation(), self.targetPos)
  self.crushDir = self.targetPos - self.startPos
  self.crushDir:Normalize()
  self.Runner:SetActorRotation(self.crushDir:ToRotator())
  self.crushAction = self:GetSkillActionByGuid(self.ServerInfo.GUID)
  if _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.GetCanDrawDebug) then
    UE.UKismetSystemLibrary.Abs_DrawDebugArrow(_G.UE4Helper.GetCurrentWorld(), self.startPos, self.targetPos, 10, UE.FLinearColor(0, 1, 0, 1), self.ServerInfo.crush_duration + 10.0, 10)
  end
  if self.crushAction and not self.crushAction.IsNotForceFixToFloor then
    self.targetPos = SceneUtils.WorldCombatGetPosInLand(self.targetPos, self.Runner)
    Log.Debug("WorldCombatActionCrush:PreExecute, FixToFloor Pos", self.Runner:GetActorLocation(), self.targetPos)
  end
  if _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.GetCanDrawDebug) then
    UE.UKismetSystemLibrary.Abs_DrawDebugArrow(_G.UE4Helper.GetCurrentWorld(), self.startPos, self.targetPos, 7, UE.FLinearColor(0, 0, 1, 1), self.ServerInfo.crush_duration + 10.0, 5)
  end
end

function WorldCombatActionCrush:InternalExecute()
  Base.InternalExecute(self)
  if not (self.Runner and self.ServerInfo) or not self.ServerInfo.skill_id then
    return
  end
  local crushAction = self:GetSkillActionByGuid(self.ServerInfo.GUID)
  if not crushAction then
    Log.Error("WorldCombatActionCrush:InternalExecute failed, jumpAction not prepared or server GUID invalid!!!", self.ServerInfo.GUID)
    return
  end
  self:DisableMovement()
  local crushDistance = crushAction.CrushDistance
  self.verticalSpeed = crushDistance / self.ServerInfo.crush_duration
  local AnimComp = self.Runner:GetAnimComponent()
  if AnimComp and crushAction.CrushAnim then
    self.crushMontage = AnimComp:PrepareMontageByName(crushAction.CrushAnim, "DefaultSlot", 0.1, 0.0, -1)
    AnimComp:StopAllMontage(0)
    local length = AnimComp:PlayAnim(self.crushMontage, 1, 0, 0.1, 0.0, -1)
    Log.Debug("WorldCombatActionCrush:InternalExecute, crushMontage", crushAction.CrushAnim, self.crushMontage, length)
  end
  self.Runner:SetCollisionDisable(true, NPCModuleEnum.NpcReasonFlags.WORLD_COMBAT_HIDDEN)
  Log.Debug("WorldCombatActionCrush:InternalExecute, current Pos", self.Runner:GetServerId(), self.Runner:GetActorLocation(), self.targetPos, self.crushDir, crushAction.CrushDistance, crushDistance)
end

function WorldCombatActionCrush:OnSkillActionPrepared(actionGuid)
end

function WorldCombatActionCrush:OnHit(victim)
  if SceneModule:CheckIsNpc(victim.serverData.base.actor_id) and not victim:IsAThrownPet() then
    return
  end
  self:Finish()
end

function WorldCombatActionCrush:Finish(endPos, actionTime)
  if not (self.Runner and UE.UObject.IsValid(self.Runner.viewObj)) or self.isFinished then
    self:ResetState()
    Base.Finish(self)
    return
  end
  Log.Debug("WorldCombatActionCrush:Finish, current Pos", self.Runner:GetServerId(), endPos, self.targetPos, self.Runner:GetActorLocation())
  if endPos and _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.GetCanDrawDebug) then
    UE.UKismetSystemLibrary.Abs_DrawDebugArrow(_G.UE4Helper.GetCurrentWorld(), endPos, self.targetPos, 10, UE.FLinearColor(0, 1, 1, 1), 10.0, 5)
  end
  if not endPos then
    self:ResetState()
    Base.Finish(self)
    return
  end
  self:ResetState()
  if self.crushAction and not self.crushAction.IsNotForceFixToFloor then
    endPos = SceneUtils.WorldCombatGetPosInLand(endPos, self.Runner)
  end
  if endPos then
    self.Runner:SetActorLocation(endPos)
  end
  Base.Finish(self)
end

function WorldCombatActionCrush:ResetState()
  self.pastTime = 0
  local AnimComp = self.Runner:GetAnimComponent()
  if AnimComp and UE.UObject.IsValid(AnimComp) then
    AnimComp:StopAnim(self.crushMontage)
  end
  self.Runner:SetCollisionDisable(false, NPCModuleEnum.NpcReasonFlags.WORLD_COMBAT_HIDDEN)
  self.Runner:EnsureComponent(OverlapAwareVisibilityComponent):CheckInBoundAndMarkHidden(true, true, false, -5, true)
  self.Runner:RemoveEventListener(self, WorldCombatSkillEvent.SKILL_CRUSH_END, self.Finish)
  self:EnableMovement()
end

function WorldCombatActionCrush:CheckNeedTick()
  return true
end

function WorldCombatActionCrush:OnTick(DeltaTime)
  Base.OnTick(self, DeltaTime)
  self.pastTime = self.pastTime + DeltaTime
  if not (self.Runner and self.Runner.viewObj) or not self.crushAction then
    Log.Debug("WorldCombatActionCrush:OnTick, not valid", self.Runner, self.Runner and self.Runner.viewObj or nil, self.crushAction)
    return
  end
  if not self.verticalSpeed then
    self.notSync = true
    return
  end
  local nextPos = self.Runner:GetActorLocation() + self.crushDir * (self.verticalSpeed * DeltaTime)
  if self.notSync then
    nextPos = self.startPos + self.crushDir * (self.verticalSpeed * self.pastTime)
    self.notSync = false
  end
  local landPos = SceneUtils.WorldCombatGetPosInLand(nextPos, self.Runner)
  Log.Debug("WorldCombatActionCrush:OnTick, current Pos", self.Runner:GetServerId(), self.crushDir, self.Runner:GetActorRotation():ToVector(), nextPos, SceneUtils.WorldCombatGetPosInLand(nextPos, self.Runner), self.Runner:GetActorLocation(), landPos)
  if self.crushAction.IsNotForceFixToFloor then
  elseif landPos then
    Log.Debug("WorldCombatActionCrush:OnTick, landPos", self.Runner:GetServerId(), landPos, nextPos, self.targetPos)
    local moveComp = self.Runner.viewObj.GetMovementComponent and self.Runner.viewObj:GetMovementComponent() or nil
    if moveComp and moveComp:IsHovering() then
      nextPos = landPos + UE.FVector(0, 0, moveComp.HoverHeightTarget)
    else
      nextPos = landPos
    end
  end
  self.Runner:SetActorLocation(nextPos)
  Log.Debug("WorldCombatActionCrush:OnTick2, real Pos", self.Runner:GetServerId(), nextPos, self.Runner:GetActorLocation())
end

function WorldCombatActionCrush:ToggleCollisionBlockToCharacter(isBlockToPlayer)
  if not self.capsuleComp then
    return
  end
  local ColResp = UE.ECollisionResponse.ECR_Block
  if not isBlockToPlayer then
    ColResp = UE.ECollisionResponse.ECR_Ignore
  end
  self.capsuleComp:SetCollisionResponseToChannel(UE.ECollisionChannel.ECC_GameTraceChannel7, ColResp)
  self.capsuleComp:SetCollisionResponseToChannel(UE.ECollisionChannel.ECC_Pawn, UE.ECollisionResponse.ECR_Ignore)
end

function WorldCombatActionCrush:PostExecute()
  Base.PostExecute(self)
  self.Runner:AddEventListener(self, WorldCombatSkillEvent.SKILL_CRUSH_END, self.Finish)
end

function WorldCombatActionCrush:ProcessPerformOnReConnect(skillId, actionData)
  local worldCombatModule = _G.NRCModuleManager:GetModule("WorldCombatModule")
  if not worldCombatModule then
    return
  end
  if not self.Runner or not self.Runner.viewObj then
    return
  end
  local actionObj = self:GetSkillActionByGuid(actionData.GUID)
  if not UE.UObject.IsValid(actionObj) then
    return
  end
  local newPos = SceneUtils.ServerPos2ClientPos(actionData.crush_snapshoot.begin_pos)
  self.Runner:SetActorLocation(newPos)
  local crushInfo = _G.ProtoMessage:newWorldCombatDotsSkillCrushInfo()
  crushInfo.GUID = actionData.GUID
  crushInfo.skill_id = skillId
  crushInfo.crush_final_pos = actionData.crush_snapshoot.target_pos
  crushInfo.crush_duration = actionObj:GetActionLength() - actionData.skill_begin_time
  self.ServerInfo = crushInfo
  Log.Dump(crushInfo, 1, "WorldCombatActionCrush:ProcessPerformOnReConnect")
  self:Execute(worldCombatModule)
end

function WorldCombatActionCrush:DisableMovement()
  if UE.UObject.IsValid(self.moveComp) then
    self.initMovementMode = self.moveComp.MovementMode
    self.CustomMovementMode = self.moveComp.CustomMovementMode
    self.moveComp:SetComponentTickEnabled(false)
    if self.initMovementMode == UE.EMovementMode.MOVE_None then
      Log.PrintScreenMsg("WorldCombatActionCrush:DisableMovement, initMovementMode is MOVE_None")
    end
    self.moveComp:SetMovementMode(UE.EMovementMode.MOVE_None)
    self.moveComp:DisableMovement()
  end
end

function WorldCombatActionCrush:EnableMovement()
  if UE.UObject.IsValid(self.moveComp) then
    self.moveComp:SetComponentTickEnabled(true)
    if self.initMovementMode == UE.EMovementMode.MOVE_None then
      Log.PrintScreenMsg("WorldCombatActionCrush:EnableMovement, initMovementMode is MOVE_None")
    end
    self.moveComp:SetMovementMode(self.initMovementMode or UE.EMovementMode.MOVE_Falling, self.CustomMovementMode or 0)
  end
end

return WorldCombatActionCrush
