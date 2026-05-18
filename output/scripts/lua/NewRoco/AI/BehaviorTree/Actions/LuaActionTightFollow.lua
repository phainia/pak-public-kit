local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionTightFollow = Base:Extend("LuaActionTightFollow")

function LuaActionTightFollow:OnStart(AIController, ...)
  local followTarget = self.FollowTarget and self.FollowTarget:GetValue(AIController)
  if not followTarget then
    self:Finish(false)
    return
  end
  local targetActor = followTarget.viewObj
  if not targetActor then
    self:Finish(false)
    return
  end
  local pawn = AIController and AIController:K2_GetPawn()
  if not pawn then
    self:Finish(false)
    return
  end
  local moveComp = pawn.CharacterMovement
  if moveComp and moveComp:IsA(UE.UCharacterNavMovementComponent) then
    moveComp:SetOverridenMoveAnim(2, 0)
  end
  local comp = pawn:GetComponentByClass(UE.URocoTightFollowComponent)
  comp = comp or pawn:AddComponentByClass(UE.URocoTightFollowComponent, false, UE4.FTransform(), false)
  local followRadiusValue = self.FollowRadius and 0 ~= self.FollowRadius:GetValue(AIController) and self.FollowRadius:GetValue(AIController) or 300.0
  comp.FollowRadius = followRadiusValue
  local maxFollowSpeedValue = self.MaxFollowSpeed and 0 ~= self.MaxFollowSpeed:GetValue(AIController) and self.MaxFollowSpeed:GetValue(AIController) or 600.0
  comp.MaxFollowSpeed = maxFollowSpeedValue
  local minFollowerSpacingValue = self.MinFollowerSpacing and 0 ~= self.MinFollowerSpacing:GetValue(AIController) and self.MinFollowerSpacing:GetValue(AIController) or 100.0
  comp.MinFollowerSpacing = minFollowerSpacingValue
  local maxFollowDistanceValue = self.MaxFollowDistance and self.MaxFollowDistance:GetValue(AIController) > 0 and self.MaxFollowDistance:GetValue(AIController) or 1000.0
  comp.MaxFollowDistance = maxFollowDistanceValue
  local useDirectMovementValue = self.UseDirectMovement and self.UseDirectMovement:GetValue(AIController) or false
  comp.bUseDirectMovement = useDirectMovementValue
  local boundaries = comp.QuadrantBoundaries
  local firstFourthBoundaryValue = self.FirstFourthBoundary and 0 ~= self.FirstFourthBoundary:GetValue(AIController) and self.FirstFourthBoundary:GetValue(AIController) or 90.0
  boundaries.FirstFourthBoundary = firstFourthBoundaryValue
  local secondThirdBoundaryValue = self.SecondThirdBoundary and 0 ~= self.SecondThirdBoundary:GetValue(AIController) and self.SecondThirdBoundary:GetValue(AIController) or 270.0
  boundaries.SecondThirdBoundary = secondThirdBoundaryValue
  local toleranceValue = self.Tolerance and 0 ~= self.Tolerance:GetValue(AIController) and self.Tolerance:GetValue(AIController) or 15.0
  boundaries.Tolerance = toleranceValue
  comp.QuadrantBoundaries = boundaries
  local useChainModeValue = self.UseChainMode and self.UseChainMode:GetValue(AIController) or false
  comp.FollowMode = useChainModeValue and 1 or 0
  comp.MaxChainLength = self.MaxChainLength and self.MaxChainLength:GetValue(AIController) > 0 and self.MaxChainLength:GetValue(AIController) or 4
  comp:StartFollowing(targetActor)
  if not comp:IsFollowing() then
    return self:Finish(false)
  end
  local targetComp = UE.URocoTightFollowComponent.GetOrCreateFollowTargetComponent(targetActor)
  if targetComp then
    local shouldOverride = true
    if self.OverrideExistedSettings then
      shouldOverride = self.OverrideExistedSettings:GetValue(AIController)
    end
    if shouldOverride or not targetComp:HasFollowers() then
      targetComp.DefaultFollowRadius = followRadiusValue
      targetComp.DefaultMaxFollowSpeed = maxFollowSpeedValue
      targetComp.DefaultMinFollowerSpacing = minFollowerSpacingValue
      local defaultBoundaries = targetComp.DefaultQuadrantBoundaries
      defaultBoundaries.FirstFourthBoundary = firstFourthBoundaryValue
      defaultBoundaries.SecondThirdBoundary = secondThirdBoundaryValue
      defaultBoundaries.Tolerance = toleranceValue
      targetComp.DefaultQuadrantBoundaries = defaultBoundaries
      local angularVelocityThresholdValue = self.AngularVelocityThreshold and 0 ~= self.AngularVelocityThreshold:GetValue(AIController) and self.AngularVelocityThreshold:GetValue(AIController) or 45.0
      targetComp.AngularVelocityThreshold = angularVelocityThresholdValue
    end
  end
  local enableAttach = self.EnableTryAttachAtSpecifiedPosition and self.EnableTryAttachAtSpecifiedPosition:GetValue(AIController) or false
  if enableAttach then
    local desiredQuadrant = self.DesiredQuadrant and self.DesiredQuadrant:GetValue(AIController) or 0
    local forceReplace = self.ForceReplaceOnAttach and self.ForceReplaceOnAttach:GetValue(AIController) or false
    local replaceBehavior = self.ReplaceBehavior and self.ReplaceBehavior:GetValue(AIController) or 0
    local exitOnAttachFail = self.ExitOnAttachFail and self.ExitOnAttachFail:GetValue(AIController) or false
    if desiredQuadrant >= 1 and desiredQuadrant <= 4 then
      if exitOnAttachFail and not forceReplace and targetComp and targetComp:IsQuadrantOccupied(desiredQuadrant) then
        comp:StopFollowing()
        if pawn then
          comp:Destroy()
        end
        self:Finish(false)
        return
      end
      local ok = comp:TryAttachAtSpecifiedPosition(targetActor, desiredQuadrant, forceReplace, replaceBehavior)
      if not ok and exitOnAttachFail and not forceReplace then
        comp:StopFollowing()
        if pawn then
          comp:Destroy()
        end
        self:Finish(false)
        return
      end
    end
  end
  self.__followComp = comp
  self.myPawn = pawn
  self.distanceCheckTimer = 0
  self.checkInterval = 1.0
end

function LuaActionTightFollow:CleanupComponent()
  if self.__followComp then
    if self.__followComp:IsFollowing() then
      self.__followComp:StopFollowing()
    end
    if self.myPawn then
      self.__followComp:Destroy()
    end
    self.__followComp = nil
  end
end

function LuaActionTightFollow:OnUpdate(AIController, DeltaTime)
  if not self.__followComp or not self.__followComp:IsFollowing() then
    self:CleanupComponent()
    self:Finish(false)
    return
  end
  self.distanceCheckTimer = self.distanceCheckTimer + DeltaTime
  if self.distanceCheckTimer >= self.checkInterval then
    self.distanceCheckTimer = 0
    local currentDistance = self.__followComp:GetDistanceToDirectTarget()
    local maxDistance = self.__followComp.MaxFollowDistance
    if currentDistance > maxDistance then
      self:Finish(false)
      return
    end
  end
end

function LuaActionTightFollow:OnInterrupt(Owner, Finalized)
  self:CleanupComponent()
end

function LuaActionTightFollow:OnEnd(AIController, ...)
  self:CleanupComponent()
end

return LuaActionTightFollow
