require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local BP_TrailFX_C = Base:Extend("BP_TrailFX_C")

function BP_TrailFX_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
end

function BP_TrailFX_C:Init()
  Base.Init(self)
end

function BP_TrailFX_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

function BP_TrailFX_C:Play(Target, caller, finishCallback, delayTime)
  self.rotSpeedMin = 1
  self.rotSpeedMax = 100
  self.moveSpeedMin = 800
  self.moveSpeedMax = 5000
  self.distMax = 2000
  self.distMin = 300
  self.randRange = math.rand(100, 200)
  self.Target = Target
  self.isPlaying = true
  self.caller = caller
  self.finishCallback = finishCallback
  self.delayTime = delayTime
  self.activateTimer = 0
  self.centerPointReached = true
  local theta = math.random(0, 360)
  local randX = math.sin(math.rad(theta))
  local randY = math.cos(math.rad(theta))
  self.centerPointPosition = self.Target.viewObj:K2_GetActorLocation() + UE4.FVector(randX * self.randRange, randY * self.randRange, 0)
  _G.UpdateManager:Register(self)
end

function BP_TrailFX_C:OnTick(DeltaTime)
  if Base.ReceiveTick then
    Base.ReceiveTick(self, DeltaTime)
  end
  if self.delayTime > 0 then
    self.delayTime = self.delayTime - DeltaTime
    return
  end
  self:RefreshTargetPositionInfo()
  if not self.isPlaying then
    self:Finish()
    return
  elseif not self.Target then
    self:Finish()
    return
  elseif self.centerPointReached then
    if not self:DistanceCheckValid() then
      self:Finish()
      return
    end
  elseif not self:DistanceCheckValid() then
    self.centerPointReached = true
  end
  self:RefreshTargetPositionInfo()
  self.activateTimer = self.activateTimer + DeltaTime
  self:RotateToTarget(DeltaTime)
  self:MoveForward(DeltaTime)
end

function BP_TrailFX_C:RefreshTargetPositionInfo()
  if not self.centerPointReached then
    self.TargetPosition = self.centerPointPosition
  else
    self.TargetPosition = self.Target.viewObj:K2_GetActorLocation()
  end
end

function BP_TrailFX_C:RotateToTarget(DeltaTime)
  if self.TargetPosition then
    local source = self:K2_GetActorLocation()
    local direction = self.TargetPosition - source
    direction:Normalize()
    local TargetRotation = direction:ToRotator()
    local cur = self:K2_GetActorRotation()
    local distance = self:GetTargetDistance()
    local rotSpeed = self.rotSpeedMin
    local alpha = self.centerPointReached and (distance - self.distMin) / (self.distMax - self.distMin) or 0.5
    alpha = math.clamp(alpha, 0, 1)
    rotSpeed = UE4.UKismetMathLibrary.Lerp(self.rotSpeedMax, self.rotSpeedMin, alpha)
    local newRotation = UE4.UKismetMathLibrary.RInterpTo(cur, TargetRotation, DeltaTime, rotSpeed)
    self:K2_SetActorRotation(newRotation, false)
  end
end

function BP_TrailFX_C:MoveForward(DeltaTime)
  if self.TargetPosition then
    local Forward = self:K2_GetActorRotation():ToVector()
    local moveSpeed = self.moveSpeedMin
    local distance = self:GetTargetDistance()
    local alpha = self.centerPointReached and (distance - self.distMin) / (self.distMax - self.distMin) or 1
    alpha = math.clamp(alpha, 0, 1)
    moveSpeed = UE4.UKismetMathLibrary.Lerp(self.moveSpeedMin, self.moveSpeedMax, alpha) * (self.activateTimer / 60 + 1)
    local forwardMovement = Forward * moveSpeed * DeltaTime
    self:K2_SetActorLocation(self:K2_GetActorLocation() + forwardMovement, false, nil, false)
    if self.Effect then
      self.Effect:Abs_K2_SetWorldLocation(self:Abs_K2_GetActorLocation(), false, nil, false)
    end
  end
end

function BP_TrailFX_C:GetTargetDistance()
  local source = self:K2_GetActorLocation()
  local distance = UE4.FVector.Dist(self.TargetPosition, source)
  return distance
end

function BP_TrailFX_C:DistanceCheckValid()
  if not self.Target or not self.TargetPosition then
    return false
  end
  local distance = self:GetTargetDistance()
  if distance < 30 then
    return false
  end
  return true
end

function BP_TrailFX_C:Finish()
  if self.isFinish then
    return
  end
  _G.UpdateManager:UnRegister(self)
  self.isPlaying = false
  if self.caller and self.finishCallback then
    self.finishCallback(self.caller)
  end
  self.isFinish = true
  self:K2_DestroyActor()
end

return BP_TrailFX_C
