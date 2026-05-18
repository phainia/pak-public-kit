require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityBase")
local AbilityID = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityID")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local AbilityErrorCode = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityErrorCode")
local AbilityEvent = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityEvent")
local ABEnum = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityEnum")
local ScenePlayerFsmEnum = require("NewRoco.Modules.Core.Scene.Component.FSM.Player.PlayerFsmEnum")
local FVector2DUtils = require("NewRoco.Utils.FVector2DUtils")
local NPCModuleCmd = require("NewRoco.Modules.Core.NPC.NPCModuleCmd")
local BP_FastThrowBall_C = Base:Extend("BP_FastThrowBall_C")

function BP_FastThrowBall_C:Start(OnFinished, ID, Strength)
  Base.Start(self, OnFinished)
  Log.DebugFormat("BP_FastThrowBall_C Start")
  local pawn = self.caster.viewObj
  local speed = pawn.CharacterMovement.Velocity:Size2D()
  self.IsRunThrow = speed > 0
  if not self.IsRunThrow then
    self.caster.inputComponent:SetInputEnable(self, false)
  end
  self.Caster = pawn
  self.Target = self:AutoFindTarget()
  local strength = Strength or self.Strength
  self.Overridden.Start(self, strength)
  self:EnterState(ABEnum.AbilityState.Casting)
end

function BP_FastThrowBall_C:Tick(DeltaTime)
  if self:IsCasting() then
    self:TurnToTarget()
  end
end

function BP_FastThrowBall_C:TurnToTarget()
  local target = self.Target
  if target then
    local casterPawn = self.caster.viewObj
    local casterForward = self.caster.viewObj:GetActorForwardVector()
    local targetDirection = target:Abs_K2_GetActorLocation() - casterPawn:Abs_K2_GetActorLocation()
    self.Direction = targetDirection
    local angle = FVector2DUtils.AngleBetweenRelative(casterForward, targetDirection)
    casterPawn:SetUpperBodyTurnAngle(angle)
  end
end

function BP_FastThrowBall_C:Interrupt()
  self:Finish()
end

function BP_FastThrowBall_C:Finish()
  Base.Finish(self)
  self.caster.inputComponent:SetInputEnable(self, true)
  local casterPawn = self.caster.viewObj
  casterPawn:SetUpperBodyTurnAngle(0)
  self.Caster = nil
  self.Ball = nil
end

function BP_FastThrowBall_C:CreateBall()
  local petBall = NRCModuleManager:DoCmd(NPCModuleCmd.CreateThrowPetBall, nil, self.caster:GetServerId())
  local viewObj = petBall.viewObj
  local xfm = self.Caster.Mesh:GetSocketTransform("locator_right_hand", UE4.ERelativeTransformSpace.RTS_World)
  xfm.Translation.Z = xfm.Translation.Z + 50
  petBall.viewObj:SetActorLocation(xfm.Translation)
  self.Ball = petBall.viewObj
  return petBall.viewObj
end

function BP_FastThrowBall_C:OnThrow()
  local petBall = self.Ball.sceneCharacter
  petBall:OnThrowStart()
end

function BP_FastThrowBall_C:AutoFindTarget()
  local npcs = NRCModuleManager:DoCmd(NPCModuleCmd.GetThrowAimNpcs, self, self.FindTargetBetweenAngle)
  if npcs and #npcs > 0 then
    return npcs[1]
  end
end

function BP_FastThrowBall_C:FindTargetBetweenAngle(Npc)
  local actor = Npc.viewObj
  if actor then
    local playerPos = self.caster.viewObj:Abs_K2_GetActorLocation()
    local targetPos = actor:Abs_K2_GetActorLocation()
    local distance = UE4.FVector.Dist(playerPos, targetPos)
    if distance < self.MaxAutoFindTargetDistance then
      local rotation = UE4.UKismetMathLibrary.FindLookAtRotation(playerPos, targetPos)
      if rotation.Yaw < self.MaxAutoFIndTargetAngle then
        return true
      end
    end
  end
  return false
end

return BP_FastThrowBall_C
