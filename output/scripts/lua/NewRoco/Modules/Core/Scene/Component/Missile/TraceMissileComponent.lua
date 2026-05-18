local MissileComponent = require("NewRoco.Modules.Core.Scene.Component.Missile.MissileComponent")
local MissileUtils = require("NewRoco.Modules.Core.Missile.MissileUtils")
local Base = MissileComponent
local TraceMissileComponent = Base:Extend("TraceMissileComponent")
MissileUtils:RegisterComponent(Enum.MissileType.TRACE_TARGET, TraceMissileComponent)
MissileUtils:RegisterComponent(Enum.MissileType.AIM_AT_TARGET_POS, TraceMissileComponent)

function TraceMissileComponent:Ctor()
  Base.Ctor(self)
end

function TraceMissileComponent:InitMissileData(caster, target, targetPos, skillId, actionIdx, data, initPos, initDir)
  Base.InitMissileData(self, caster, target, targetPos, skillId, actionIdx, data, initPos, initDir)
  local MissileBase = self:GetMissileHeight()
  self.logicPos.Z = MissileBase.Z + self.initHeight
end

function TraceMissileComponent:OnLaunch()
  Base.OnLaunch(self)
  if _G.WorldCombatModuleCmd and not _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.IsInOfflineMode) then
    return
  end
  if self.data.TraceTime and self.data.TraceTime > 0 then
    table.insert(self.timerIds, DelayManager:DelaySeconds(self.data.TraceTime, function()
      self.isStraight = true
    end, self))
  end
end

function TraceMissileComponent:ApplyOwnerPos(velocity, deltaTime)
  self.logicPos = self.logicPos + velocity
  if self.data.IsKeepLandHeight then
    self.logicPos.Z = self.nextLandHeight
    self.logicDir = UE.UKismetMathLibrary.Normal(velocity, 0.01)
    velocity = self.logicPos - self.owner.viewObj:Abs_K2_GetActorLocation()
  end
  coroutine.resume(coroutine.create(MissileComponent.DelayMoveComponent), self, velocity, deltaTime)
end

function TraceMissileComponent:Update(deltaTime)
  Base.Update(self, deltaTime)
  local ownerPos = self:GetOwnerLocation()
  local moveDir = self.targetPos - self:GetOwnerLocation()
  if UE.UKismetMathLibrary.Vector_IsNearlyZero(moveDir) or self.isArrived then
    self:Arrived()
    return
  end
  self:CalcCurrentSpeed(deltaTime)
  self:SphericalSinterp(deltaTime)
  self.logicDir = UE.UKismetMathLibrary.Normal(self.logicDir, 0.01)
  local velocity = self.logicDir * self.speed * deltaTime
  if self.data.IsKeepLandHeight then
    self:CorrectDirectionWithLandHeight(velocity)
  end
  self:ApplyOwnerPos(velocity, deltaTime)
  if self.data.CancelTraceDist > 0 and moveDir:SizeSquared() <= self.data.CancelTraceDist * self.data.CancelTraceDist then
    self.isStraight = true
  end
  if not self.target then
    local innerAngle = LuaMathUtils.AngleBetweenVectors(moveDir, self.logicDir)
    if innerAngle <= 5 then
      self.isStraight = true
    end
  end
  if self.NextStepExceedStepHeight then
    self:Destroy(Enum.MissileDestroyReason.MDR_HIT_OBSTACLE)
  end
end

return TraceMissileComponent
