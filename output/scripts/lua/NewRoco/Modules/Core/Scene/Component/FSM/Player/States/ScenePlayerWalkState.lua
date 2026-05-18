local Base = require("NewRoco.Modules.Core.Scene.Component.FSM.Player.States.ScenePlayerStateBase")
local FVector2DUtils = require("NewRoco.Utils.FVector2DUtils")
local PlayerFsmEnum = require("NewRoco.Modules.Core.Scene.Component.FSM.Player.PlayerFsmEnum")
local ScenePlayerWalkState = Base:Extend("ScenePlayerWalkState")

function ScenePlayerWalkState:CanEnter(preState)
  if not preState or preState.stateID ~= self.stateID then
    return self.Player:HasMoveInput()
  end
  return false
end

function ScenePlayerWalkState:OnEnter()
  self._isTurning = false
  local pawn = self.Player.viewObj
  if self.Player.movementComponent then
    self.Player.movementComponent:ClearMoveInput()
  end
end

function ScenePlayerWalkState:CanExit(nextState)
  return not self._isTurning
end

function ScenePlayerWalkState:OnExit()
  if self.Player.movementComponent then
    self.Player.movementComponent:ClearMoveInput()
  end
end

function ScenePlayerWalkState:OnTick(deltaTime)
  self:HandleInput(deltaTime)
  local pawn = self.Player.viewObj
  local speed = pawn:GetVelocity():Size()
  if speed <= 300 then
    self.Player.fsmComponent:SetSubState(PlayerFsmEnum.ScenePlayerStateType.SlowWalk)
  else
    self.Player.fsmComponent:SetSubState(PlayerFsmEnum.ScenePlayerStateType.Run)
  end
end

function ScenePlayerWalkState:HandleInput(deltaTime)
  local inputVector = self.Player.movementComponent:ConsumeInput()
  if not inputVector then
    return
  end
  local playerPawn = self.Player.viewObj
  local ueController = self.Player.ueController
  if ueController and ueController.Pawn ~= playerPawn then
    local axis = inputVector:Size()
    inputVector:Normalize()
    ueController.Pawn:AddMovementInput(inputVector, axis)
    return
  end
  if UE4Helper.IsZeroVector(inputVector) then
    self._isTurning = false
    playerPawn.TurnMode = 0
    self._targetDir = playerPawn:GetActorForwardVector()
    return
  end
  if playerPawn.CharacterMovement:IsGliding() then
    self.Player.movementComponent:SimpleMove(inputVector)
    return
  end
  self.Player.movementComponent:SimpleMove(inputVector)
end

function ScenePlayerWalkState:DoTurn(deltaTime)
  local playerPawn = self.Player.viewObj
  if playerPawn.CharacterMovement:IsFalling() then
    self._isTurning = false
    playerPawn.TurnMode = 0
    return
  end
  local curDir = playerPawn:GetActorForwardVector()
  local deltaAngle = FVector2DUtils.AngleBetweenRelative(curDir, self._targetDir)
  local turnSpeed = playerPawn.PerformParams.turnSpeed * deltaTime
  local rot = playerPawn.CharacterMovement.UpdatedComponent:K2_GetComponentRotation()
  local speed = playerPawn:GetVelocity():Size2D()
  local turnThreshold = speed <= 0 and 0.1 or playerPawn.PerformParams.TurnThreshold
  if not self._isTurning and turnThreshold < math.abs(deltaAngle) then
    if not self._isTurning then
      self._isTurning = true
      if deltaAngle > 0 then
        playerPawn.TurnMode = 2
      else
        playerPawn.TurnMode = 1
      end
    end
  else
    playerPawn.TurnMode = 0
  end
  if self._isTurning then
    if turnSpeed >= math.abs(deltaAngle) then
      rot.Yaw = rot.Yaw + deltaAngle
      playerPawn.CharacterMovement.UpdatedComponent:K2_SetWorldRotation(rot, false, nil, false)
      self._isTurning = false
    else
      if deltaAngle > 0 then
        rot.Yaw = rot.Yaw + turnSpeed
      else
        rot.Yaw = rot.Yaw - turnSpeed
      end
      playerPawn.CharacterMovement.UpdatedComponent:K2_SetWorldRotation(rot, false, nil, false)
    end
  end
end

return ScenePlayerWalkState
