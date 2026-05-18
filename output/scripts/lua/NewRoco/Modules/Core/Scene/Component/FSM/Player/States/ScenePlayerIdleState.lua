local Base = require("NewRoco.Modules.Core.Scene.Component.FSM.Player.States.ScenePlayerStateBase")
local FVector2DUtils = require("NewRoco.Utils.FVector2DUtils")
local ScenePlayerIdleState = Base:Extend("ScenePlayerIdleState")

function ScenePlayerIdleState:Ctor()
  Base.Ctor(self)
  self._lastPerforms = Array()
end

function ScenePlayerIdleState:CanEnter(preState)
  if not preState then
    return true
  end
  if preState.stateID ~= self.stateID and not self.Player:HasMoveInput() then
    return true
  end
  return false
end

function ScenePlayerIdleState:OnEnter()
  local playerBP = self.Player.viewObj
  self.triggerPerformTime = playerBP.PerformParams.IdleTriggerPerformTime
  self._targetDir = playerBP:GetActorForwardVector()
end

function ScenePlayerIdleState:CanExit(nextState)
  return not self._isTurning
end

function ScenePlayerIdleState:OnExit()
  local playerBP = self.Player.viewObj
  if self.triggerPerformTime > playerBP.PerformParams.IdleTriggerPerformTime then
    playerBP.AnimComponent:StopAnimByName(self._curAnimName)
  end
  self._lastPerforms:Clear()
end

function ScenePlayerIdleState:OnTick(deltaTime)
  self:DoTurn(deltaTime)
end

function ScenePlayerIdleState:DoTurn(deltaTime)
  local playerPawn = self.Player.viewObj
  local lastInputVector = self.Player.movementComponent:ConsumeInput()
  if UE4Helper.IsZeroVector(lastInputVector) then
    self._isTurning = false
    self._targetDir = playerPawn:GetActorForwardVector()
    playerPawn.TurnMode = 0
    return
  else
    self._targetDir = lastInputVector
  end
  local ueController = self.Player.ueController
  if ueController and ueController.Pawn ~= playerPawn then
    local axis = lastInputVector:Size()
    lastInputVector:Normalize()
    ueController.Pawn:AddMovementInput(lastInputVector, axis)
    return
  end
  self.Player.movementComponent:ApplyMoveInputVector(lastInputVector)
end

function ScenePlayerIdleState:CheckIdlePerform(deltaTime)
  local playerBP = self.Player.viewObj
  self.triggerPerformTime = self.triggerPerformTime - deltaTime
  if self.triggerPerformTime <= 0 and not self._isTurning then
    local canTrigger = math.random() < playerBP.PerformParams.IdleTriggerPerformProbability
    local maxLastPerformCount = playerBP.PerformParams.IdleSeriesPerformThreshold
    if maxLastPerformCount > 0 then
      local curPerformCount = self._lastPerforms:Size()
      if maxLastPerformCount <= curPerformCount then
        local first = self._lastPerforms:Get(1)
        local allSame = true
        for i = 1, curPerformCount do
          local cur = self._lastPerforms:Get(i)
          if cur ~= first then
            allSame = false
            break
          end
        end
        if allSame and canTrigger == first then
          canTrigger = not canTrigger
          self._lastPerforms:Clear()
        else
          self._lastPerforms:RemoveAt(1)
        end
      end
      self._lastPerforms:Add(canTrigger)
    end
    if canTrigger then
      if self.Player.statusComponent:HasStatus(Enum.WorldPlayerStatusType.WPST_RIDING) then
        self._curAnimName = "RideRelax"
        local animationLength = playerBP.AnimComponent:PlayAnimByName(self._curAnimName, 1)
        self.triggerPerformTime = animationLength + playerBP.PerformParams.IdleTriggerPerformTime
      else
        local animations = playerBP.PerformParams.IdlePerformAnimations
        local randIndex = math.random(1, animations:Length())
        self._curAnimName = animations:Get(randIndex)
        local animationLength = playerBP.AnimComponent:PlayAnimByName(self._curAnimName, 1)
        self.triggerPerformTime = animationLength + playerBP.PerformParams.IdleTriggerPerformTime
      end
    else
      self.triggerPerformTime = playerBP.PerformParams.IdleTriggerPerformTime
    end
  end
end

return ScenePlayerIdleState
