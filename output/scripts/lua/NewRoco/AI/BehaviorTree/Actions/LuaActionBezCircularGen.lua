local a = require("Common.Coroutine.async")
local AIDefines = require("NewRoco.AI.AIDefines")
local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionBezCircularGen = Base:Extend("LuaActionBezCircularGen")
local OffsetAngle = 0
local Step = 120

function LuaActionBezCircularGen:OnStart(AIController, ...)
  local args = {
    ...
  }
  local owner = AIController
  local Radius = self.Radius:GetValue(owner)
  local VaryingRadius = self.VaryingRadius:GetValue(owner)
  local ResetCenter = self.ResetCenter:GetValue(owner)
  local IsClockWise = self.IsClockWise:GetValue(owner)
  local MaxCircularHeight = self.MaxCircularHeight and self.MaxCircularHeight:GetValue(owner) or 5000
  self.flyMilestone = 0
  self.needInterrupt = false
  a.task(function()
    local bezComp = owner.Npc.BezierFlyComponent
    bezComp:ContinuousFly(true)
    local _, centerPos = a.wait(a.wrap(bezComp.GenCircularPos)(bezComp, Radius, VaryingRadius, MaxCircularHeight, ResetCenter, self))
    if not owner.Npc then
      return
    end
    if not bezComp:IsCircularSuccess() then
      self:Finish(false)
      return
    end
    local ScaleRatio = bezComp:GetCircularRadiusScale()
    Radius = Radius * ScaleRatio
    local CurPos = owner.Npc:GetActorLocation()
    if math.abs(CurPos.Z - (centerPos.Z - VaryingRadius)) > 5000 then
      self:Finish(false)
      return
    end
    self:CalcBez(centerPos, Radius, VaryingRadius, IsClockWise)
    owner.Npc:Stop()
    local result = AIDefines.ActionResult.Failed
    do
      local StartFly = a.wrap(bezComp.StartFly)
      if not self.needInterrupt and owner.Npc then
        _, _ = a.wait(StartFly(bezComp, owner.Npc:GetForwardVector(), CurPos, self.ConP01_1, self.ConP01_2, self.CPos1, 20, self))
        if not self.needInterrupt and owner.Npc then
          _, _ = a.wait(StartFly(bezComp, owner.Npc:GetForwardVector(), self.CPos1, self.ConP12_1, self.ConP12_2, self.CPos2, 20, self))
          if not self.needInterrupt and owner.Npc then
            _, result = a.wait(StartFly(bezComp, owner.Npc:GetForwardVector(), self.CPos2, self.ConP23_1, self.ConP23_2, self.CPos3, 20, self))
          end
        end
      end
    end
    self:CleanUp()
    if not self.needInterrupt then
      self:Finish(result == AIDefines.ActionResult.Success)
    end
  end)()
end

function LuaActionBezCircularGen:OnInterrupt(AIController, Finalize, ...)
  local owner = AIController
  local bezComp = owner.Npc.BezierFlyComponent
  self.needInterrupt = true
  if bezComp then
    bezComp:ContinuousFly(false)
    bezComp:FinishFly(AIDefines.ActionResult.Aborted)
  end
end

function LuaActionBezCircularGen:CalcBez(centerPos, Radius, VaryingRadius, IsClockWise)
  local sign = 1
  if IsClockWise then
    sign = -1
  end
  local CPos1 = centerPos + UE4.FVector(Radius * math.cos(math.rad(0 + OffsetAngle)), Radius * math.sin(math.rad(0 + OffsetAngle)), 0)
  local CPos2 = centerPos + UE4.FVector(Radius * math.cos(math.rad(sign * Step + OffsetAngle)), Radius * math.sin(math.rad(sign * Step + OffsetAngle)), 0)
  local CPos3 = centerPos + UE4.FVector(Radius * math.cos(math.rad(2 * sign * Step + OffsetAngle)), Radius * math.sin(math.rad(2 * sign * Step + OffsetAngle)), 0)
  if _G.GlobalConfig.DebugLuaBTree then
    UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(UE4Helper.GetCurrentWorld(), CPos1, VaryingRadius, 20, UE4.FLinearColor(0.2, 1.0, 0.2, 1), 10, 2)
    UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(UE4Helper.GetCurrentWorld(), CPos2, VaryingRadius, 20, UE4.FLinearColor(0.0, 1.0, 0.0, 1), 10, 2)
    UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(UE4Helper.GetCurrentWorld(), CPos3, VaryingRadius, 20, UE4.FLinearColor(0.0, 1.0, 0.0, 1), 10, 2)
    UE4.UKismetSystemLibrary.Abs_DrawDebugCylinder(UE4Helper.GetCurrentWorld(), centerPos + UE4.FVector(0, 0, -VaryingRadius), centerPos + UE4.FVector(0, 0, VaryingRadius), Radius, 20, UE4.FLinearColor(0.2, 1, 0.8, 1), 10, 2)
  end
  CPos1 = CPos1 + self.GetRandVarying(VaryingRadius)
  self.CPos1 = CPos1
  CPos2 = CPos2 + self.GetRandVarying(VaryingRadius)
  self.CPos2 = CPos2
  CPos3 = CPos3 + self.GetRandVarying(VaryingRadius)
  self.CPos3 = CPos3
  if _G.GlobalConfig.DebugLuaBTree then
    UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(UE4Helper.GetCurrentWorld(), CPos1, 20, 5, UE4.FLinearColor(1.0, 1.0, 0.2, 1), 10, 5)
    UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(UE4Helper.GetCurrentWorld(), CPos2, 20, 5, UE4.FLinearColor(1.0, 0.0, 0.0, 1), 10, 5)
    UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(UE4Helper.GetCurrentWorld(), CPos3, 20, 5, UE4.FLinearColor(1.0, 0.0, 0.0, 1), 10, 5)
  end
  self.ConP01_1 = CPos3 + (CPos1 - CPos2) * (0.35 + math.random() * 0.35)
  self.ConP01_2 = CPos1 + (CPos3 - CPos2) * (0.35 + math.random() * 0.35)
  self.ConP12_1 = CPos1 + (CPos2 - CPos3) * (0.35 + math.random() * 0.35)
  self.ConP12_2 = CPos2 + (CPos1 - CPos3) * (0.35 + math.random() * 0.35)
  self.ConP23_1 = CPos2 + (CPos3 - CPos1) * (0.35 + math.random() * 0.35)
  self.ConP23_2 = CPos3 + (CPos2 - CPos1) * (0.35 + math.random() * 0.35)
end

function LuaActionBezCircularGen.GetRandVarying(randRad)
  local rnd = UE4.FVector(math.random(), math.random(), math.random())
  rnd:Normalize()
  return rnd * (math.random() * randRad)
end

function LuaActionBezCircularGen:CleanUp()
  self.CPos1 = nil
  self.CPos2 = nil
  self.CPos3 = nil
  self.ConP01_1 = nil
  self.ConP01_2 = nil
  self.ConP12_1 = nil
  self.ConP12_2 = nil
  self.ConP23_1 = nil
  self.ConP23_2 = nil
end

return LuaActionBezCircularGen
