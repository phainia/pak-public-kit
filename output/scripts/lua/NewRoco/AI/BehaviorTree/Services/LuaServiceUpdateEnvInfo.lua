local Base = require("NewRoco.AI.BehaviorTree.LuaServiceBase")
local LuaServiceUpdateEnvInfo = Base:Extend("LuaServiceUpdateEnvInfo")

function LuaServiceUpdateEnvInfo:OnStart(OwnerController, ...)
  self.UGameplayStatics = UE4.UGameplayStatics
  self._lastIsInRelaxRange = false
end

function LuaServiceUpdateEnvInfo:OnUpdateService(OwnerController, DeltaTime, ...)
  local aiController = OwnerController
  local player = aiController:GetBlackboardValue("LocalPlayer")
  local playerPos = player:GetActorLocation()
  local selfPos = aiController.Npc:GetActorLocation()
  local delta = playerPos - selfPos
  local distance = delta:Size()
  self.DistanceToPlayer:SetValue(aiController, distance)
  local relaxRange = self.RelaxRange:GetValue(aiController)
  local isInRelaxRange = distance <= relaxRange
  self.IsInRelaxRange:SetValue(aiController, isInRelaxRange)
  if self.LastIsInRelaxRange:GetValue(aiController) ~= self._lastIsInRelaxRange then
    self.LastIsInRelaxRange:SetValue(aiController, self._lastIsInRelaxRange)
  end
  self._lastIsInRelaxRange = isInRelaxRange
  local deltaTime = self.UGameplayStatics.GetWorldDeltaSeconds(aiController:GetWorld())
  if self.DeltaTime then
    self.DeltaTime:SetValue(aiController, deltaTime)
  end
end

function LuaServiceUpdateEnvInfo:OnEnd(...)
  self.UGameplayStatics = nil
end

return LuaServiceUpdateEnvInfo
