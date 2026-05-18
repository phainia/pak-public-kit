local LandTraceExtent = 300.0
local MakeSurePointUnderGround = 10
local ViewNPCBase = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local Base = ViewNPCBase
local BP_NPCPerception_JiaoYin_C = Base:Extend("BP_NPCPerception_JiaoYin_C")

function BP_NPCPerception_JiaoYin_C:OnVisible()
  Base.OnVisible(self)
  self:StickToGround(self.FootPrint1)
  self:StickToGround(self.FootPrint2)
  self:StickToGround(self.FootPrint3)
  self:SetActorHiddenInGame(false)
end

function BP_NPCPerception_JiaoYin_C:StickToGround(targetMeshComponent)
  local componentLocation = targetMeshComponent:K2_GetComponentLocation()
  local targetDirection = self.Arrow:GetForwardVector()
  local currentRecord = self:GetStickInfo(componentLocation, componentLocation, targetDirection)
  if not currentRecord then
    return
  end
  local newLocation = currentRecord.location
  newLocation.Z = newLocation.Z + self.GroundOffset
  local newRotator = currentRecord.rotation
  newRotator.Roll = newRotator.Pitch
  newRotator.Pitch = 0.0
  newRotator.Yaw = targetMeshComponent:K2_GetComponentRotation().Yaw
  targetMeshComponent:K2_SetWorldLocationAndRotation(newLocation, newRotator, false, nil, false)
end

function BP_NPCPerception_JiaoYin_C:GetStickInfo(testLocation, center, targetDirection)
  local startLocation = UE.FVector(testLocation.X, testLocation.Y, testLocation.Z + LandTraceExtent)
  local endLocation = UE.FVector(testLocation.X, testLocation.Y, testLocation.Z - LandTraceExtent)
  local hitResult, bSuccess = UE4.UKismetSystemLibrary.LineTraceSingle(_G.UE4Helper.GetCurrentWorld(), startLocation, endLocation, UE.ETraceTypeQuery.Land, false, nil, 0)
  if bSuccess then
    local groundPoint = UE4.FVector(hitResult.ImpactPoint.X, hitResult.ImpactPoint.Y, hitResult.ImpactPoint.Z)
    local groundNormal = UE4.FVector(hitResult.ImpactNormal.X, hitResult.ImpactNormal.Y, hitResult.ImpactNormal.Z)
    local newLocation = UE4.UKismetMathLibrary.ProjectPointOnToPlane(center, groundPoint, groundNormal)
    newLocation = newLocation - groundNormal * MakeSurePointUnderGround
    local newDirection = UE4.UKismetMathLibrary.ProjectVectorOnToPlane(targetDirection, groundNormal)
    local newRotator = UE4.UKismetMathLibrary.Conv_VectorToRotator(newDirection)
    return {location = newLocation, rotation = newRotator}
  end
  return nil
end

return BP_NPCPerception_JiaoYin_C
