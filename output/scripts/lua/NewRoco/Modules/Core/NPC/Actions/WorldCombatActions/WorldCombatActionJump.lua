local WorldCombatActionBase = require("NewRoco.Modules.Core.NPC.Actions.WorldCombatActions.WorldCombatActionBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local WorldCombatSkillComponent = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatSkillComponent")
local WorldCombatSkillEvent = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatSkillEvent")
local OverlapAwareVisibilityComponent = require("NewRoco.Modules.Core.Scene.Component.Visibility.OverlapAwareVisibilityComponent")
local NPCModuleEnum = require("NewRoco.Modules.Core.NPC.NPCModuleEnum")
local Base = WorldCombatActionBase
local WorldCombatActionJump = Base:Extend("WorldCombatActionJump")

function WorldCombatActionJump:Ctor(Runner, SkillId, ActionType, ServerInfo)
  Base.Ctor(self, Runner, SkillId, ActionType, ServerInfo)
  self.pastTime = 0
end

function WorldCombatActionJump:CheckNeedTick()
  return true
end

function WorldCombatActionJump:PreExecute()
  Base.PreExecute(self)
  if not self.Runner or not self.Runner.viewObj then
    return
  end
  self.actionType = WorldCombatActionBase.EActionType.duration
  self.moveComp = self.Runner.viewObj:GetComponentByClass(UE4.UCharacterNavMovementComponent)
  self.needTick = true
  self.finishControlBySelf = true
  self.pastTime = 0
  self.jumpAction = self:GetSkillActionByGuid(self.ServerInfo.GUID)
  if not self.jumpAction then
    Log.Error("WorldCombatActionJump:PreExecute failed, cannot get valid jumpAction from G6Skill by server guid!!!")
    return
  end
  self.actionDuration = self.jumpAction:GetActionLength()
end

function WorldCombatActionJump:OnSkillActionPrepared(actionGuid)
end

function WorldCombatActionJump:InternalExecute()
  Base.InternalExecute(self)
  if not (self.Runner and self.ServerInfo) or not self.ServerInfo.skill_id then
    return
  end
  if not self.moveComp or not self.Owner then
    return
  end
  local skillObj = self.Owner.skillObj
  if not skillObj then
    return
  end
  self.capsuleComp = self.Runner.viewObj:K2_GetRootComponent()
  if not self.capsuleComp then
    return
  end
  local halfHeight = self.Runner:GetScaledHalfHeight()
  self.startPos = self.Runner:GetActorLocation()
  if self.ServerInfo.target_pos then
    self.endPos = SceneUtils.ServerPos2ClientPos(self.ServerInfo.target_pos)
    self.endPos.Z = self.endPos.Z + halfHeight
  else
    local target = self.Runner:EnsureComponent(WorldCombatSkillComponent).currentContext.target
    if target then
      self.endPos = target:GetActorLocation()
    end
  end
  self.apexPos = SceneUtils.ServerPos2ClientPos(self.ServerInfo.apex_pos)
  self.apexPos.Z = self.apexPos.Z + halfHeight
  Log.Debug("WorldCombatActionJump Start", self.Runner:GetServerId(), self.startPos, self.Runner:GetActorLocation(), self.apexPos, self.endPos)
  if not self.endPos or not self.apexPos then
    Log.Error("WorldCombatActionJump:InternalExecute, cannot get valid pos from server!!!", self.endPos, self.apexPos)
    return
  end
  self:DisableMovement()
  if not self.jumpAction then
    Log.Error("WorldCombatActionJump:InternalExecute failed, jumpAction not prepared or server GUID invalid!!!")
    return
  else
    self.jumpAction:GenerateSkillJumpSpline(self.startPos, self.endPos, self.apexPos)
  end
  self.Runner:SetCollisionDisable(true, NPCModuleEnum.NpcReasonFlags.WORLD_COMBAT_HIDDEN)
  if _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.GetCanDrawDebug) then
    UE.UKismetSystemLibrary.Abs_DrawDebugArrow(_G.UE4Helper.GetCurrentWorld(), self.startPos, self.apexPos, 5, UE.FLinearColor(1, 0.2, 0, 0), self.jumpAction:GetActionLength() + 5.0, 3)
    UE.UKismetSystemLibrary.Abs_DrawDebugArrow(_G.UE4Helper.GetCurrentWorld(), self.apexPos, self.endPos, 5, UE.FLinearColor(1, 0.6, 0, 0), self.jumpAction:GetActionLength() + 5.0, 3)
  end
end

function WorldCombatActionJump:Finish(endPos, isCancel)
  if not (self.Runner and not self.isFinished and self.Runner.viewObj) or not self.endPos then
    Base.Finish(self)
    return
  end
  if self.jumpAction then
    self.jumpAction:ClearSplinePoints(false)
  end
  if endPos then
    self.endPos = endPos
  end
  if isCancel then
  end
  Log.Debug("WorldCombatActionJump Finish", self.Runner:GetServerId(), self.endPos, self.Runner:GetActorLocation())
  self.Runner:SetCollisionDisable(false, NPCModuleEnum.NpcReasonFlags.WORLD_COMBAT_HIDDEN)
  self.Runner:EnsureComponent(OverlapAwareVisibilityComponent):CheckInBoundAndMarkHidden(true, true, false, -5, true)
  self.jumpAction = nil
  self.pastTime = 0
  self.Runner:RemoveEventListener(self, WorldCombatSkillEvent.SKILL_JUMP_END, self.Finish)
  self:EnableMovement()
  Base.Finish(self)
end

function WorldCombatActionJump:OnTick(DeltaTime)
  self.pastTime = self.pastTime + DeltaTime
  if not self.Runner or not self.Runner.viewObj then
    return
  end
  if not self.jumpAction then
    self.jumpAction = self:GetSkillActionByGuid(self.ServerInfo.GUID)
    if self.jumpAction then
      self.actionDuration = self.jumpAction:GetActionLength()
      self.jumpAction:GenerateSkillJumpSpline(self.startPos, self.endPos, self.apexPos)
    end
  end
  if not self.jumpAction or not self.Runner then
    return
  end
  if not self.startPos or not self.endPos then
    return
  end
  local newPos = self.jumpAction:EvalLocationByKey(self.pastTime)
  coroutine.resume(coroutine.create(self.MoveRunner), self, newPos, DeltaTime)
  Log.Debug("WorldCombatActionJump Tick", self.Runner:GetServerId(), self.startPos, self.endPos, newPos, self.Runner:GetActorLocation(), self.pastTime, DeltaTime)
  if self.jumpAction.bDrawDebugSpline then
    UE.UKismetSystemLibrary.DrawDebugBox(self.Runner.viewObj, self.startPos, UE4.FVector(30, 30, 30), UE4.FColor(0, 255, 0, 255), self.Runner:GetActorRotation(), 0.03, 2)
    UE.UKismetSystemLibrary.DrawDebugBox(self.Runner.viewObj, self.apexPos, UE4.FVector(20, 20, 20), UE4.FColor(0, 255, 0, 255), self.Runner:GetActorRotation(), 0.03, 2)
    UE.UKismetSystemLibrary.DrawDebugBox(self.Runner.viewObj, self.endPos, UE4.FVector(10, 10, 10), UE4.FColor(0, 255, 0, 255), self.Runner:GetActorRotation(), 0.03, 2)
  end
end

function WorldCombatActionJump:MoveRunner(newPos, DeltaTime)
  self.Runner:SetActorLocation(newPos)
end

function WorldCombatActionJump:PostExecute()
  Base.PostExecute(self)
  self.Runner:AddEventListener(self, WorldCombatSkillEvent.SKILL_JUMP_END, self.Finish)
end

function WorldCombatActionJump:ToggleCollisionBlockToCharacter(IsBlock)
  if self.Runner == nil then
    return
  end
  local caster = self.Runner.viewObj
  if not caster then
    return
  end
  local capsuleComp = caster:K2_GetRootComponent()
  local colResp = UE.ECollisionResponse.ECR_Block
  if not IsBlock then
    colResp = UE.ECollisionResponse.ECR_Ignore
  end
  capsuleComp:SetCollisionResponseToChannel(UE.ECollisionChannel.ECC_GameTraceChannel7, colResp)
  self.capsuleComp:SetCollisionResponseToChannel(UE.ECollisionChannel.ECC_Pawn, UE.ECollisionResponse.ECR_Ignore)
end

function WorldCombatActionJump:ProcessPerformOnReConnect(skillId, actionData)
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
  local newPos = SceneUtils.ServerPos2ClientPos(actionData.jump_snapshoot.begin_pos)
  self.Runner:SetActorLocation(newPos)
  local jumpInfo = _G.ProtoMessage:newWorldCombatDotsSkillJumpInfo()
  jumpInfo.GUID = actionData.GUID
  jumpInfo.skill_id = skillId
  jumpInfo.target_pos = actionData.jump_snapshoot.target_pos
  jumpInfo.apex_pos = actionData.jump_snapshoot.apex_pos
  self.ServerInfo = jumpInfo
  self.pastTime = actionData.skill_begin_time
  Log.Dump(jumpInfo, 1, "WorldCombatActionJump:ProcessPerformOnReConnect")
  self:Execute(worldCombatModule)
end

function WorldCombatActionJump:DisableMovement()
  if UE.UObject.IsValid(self.moveComp) then
    self.moveComp:SetComponentTickEnabled(false)
    self.moveComp:SetMovementMode(UE.EMovementMode.MOVE_None)
    self.moveComp:DisableMovement()
  end
end

function WorldCombatActionJump:EnableMovement()
  if UE.UObject.IsValid(self.moveComp) then
    self.moveComp:SetComponentTickEnabled(true)
    self.moveComp:SetMovementMode(UE.EMovementMode.MOVE_Falling, 0)
  end
end

return WorldCombatActionJump
