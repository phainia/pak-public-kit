local UMG_DigitRoll_C = _G.NRCPanelBase:Extend("UMG_DigitRoll_C")

function UMG_DigitRoll_C:InitSpeed(speed)
  self.speed = speed
end

function UMG_DigitRoll_C:OnActive()
end

function UMG_DigitRoll_C:OnDeactive()
end

function UMG_DigitRoll_C:OnAddEventListener()
end

function UMG_DigitRoll_C:OnTick()
end

function UMG_DigitRoll_C:OnLogin()
end

function UMG_DigitRoll_C:OnConstruct()
end

function UMG_DigitRoll_C:OnDestruct()
end

function UMG_DigitRoll_C:OnAnimationFinished(anim)
  if anim == self.RollAnim then
    self.curValue = self.targetValue
    self:SetFirstNumber(self.curValue)
    if self.endValue ~= self.curValue then
      self:Play(self.endValue)
    end
  end
end

function UMG_DigitRoll_C:SetFirstNumber(value)
  self.curValue = value
  self.Text1:SetText(value)
end

function UMG_DigitRoll_C:SetSecondNumber(value)
  self.Text2:SetText(value)
end

function UMG_DigitRoll_C:Play(targetValue)
  self.endValue = targetValue
  if self.curValue == targetValue then
    return
  end
  if self:IsAnimationPlaying(self.RollAnim) then
    return
  end
  self.targetValue = targetValue
  self:SetSecondNumber(targetValue)
  self:PlayAnimation(self.RollAnim, 0, 1, 0, self.speed)
end

function UMG_DigitRoll_C:GetRollAnimTotalTime()
  local rawLength = self.RollAnim:GetEndTime() - self.RollAnim:GetStartTime()
  return rawLength
end

return UMG_DigitRoll_C
