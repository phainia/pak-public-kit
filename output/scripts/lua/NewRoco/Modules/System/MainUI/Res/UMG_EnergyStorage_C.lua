local UMG_EnergyStorage_C = _G.NRCViewBase:Extend("UMG_EnergyStorage_C")

function UMG_EnergyStorage_C:OnActive()
  if self.runningTime == nil then
    self.runningTime = 0
  end
  if nil == self.maxTime then
    self.maxTime = 0
  end
end

function UMG_EnergyStorage_C:OnDeactive()
end

function UMG_EnergyStorage_C:OnAddEventListener()
  self.module:RegisterEvent(self, MainUIModuleEvent.PowerDashChargingStart, self.PowerDashChargingStart)
  self.module:RegisterEvent(self, MainUIModuleEvent.PowerDashChargingEnd, self.PowerDashChargingEnd)
end

function UMG_EnergyStorage_C:OnTick(InDeltaTime)
  if 0 == self.maxTime then
    return
  end
  if self.runningTime == nil or nil == self.progressStartTime or nil == self.aniTime then
    return
  end
  local startTime = self.progressStartTime + self.runningTime / self.maxTime * self.aniTime
  self.runningTime = self.runningTime + InDeltaTime
  local endTime = self.progressStartTime + self.runningTime / self.maxTime * self.aniTime
  self:PlayAnimationTimeRange(self.Progress_bar, startTime, endTime)
  if self.runningTime >= self.maxTime then
    self:PlayAnimation(self.Shine)
    self.maxTime = 0
  end
end

function UMG_EnergyStorage_C:OnConstruct()
  self.maxTime = 0
  local ani = self.Progress_bar
  self.progressStartTime = ani:GetStartTime()
  self.progressEndTime = ani:GetEndTime()
  self.aniTime = self.progressEndTime - self.progressStartTime
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_EnergyStorage_C:OnDestruct()
end

function UMG_EnergyStorage_C:OnAnimationFinished(anim)
end

function UMG_EnergyStorage_C:PowerDashChargingStart(maxTime)
  self:SetVisibility(UE4.ESlateVisibility.Visible)
  self.maxTime = maxTime
  self.runningTime = 0
  local ani = self.Progress_bar
  self:PlayAnimationTimeRange(ani, ani:GetStartTime(), ani:GetStartTime())
end

function UMG_EnergyStorage_C:PowerDashChargingEnd()
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.maxTime = 0
  self.runningTime = 0
  self:StopAllAnimations()
end

return UMG_EnergyStorage_C
