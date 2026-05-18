local CameraAdditiveParamStatus = Class("CameraAdditiveParamStatus")
local ZeroVector = UE4.FVector(0, 0, 0)

function CameraAdditiveParamStatus:Ctor(Length, CameraOffsetCurve, RotationOffsetCurve)
  self.isActive = false
  self.CameraOffsetCurve = CameraOffsetCurve
  self.RotationOffsetCurve = RotationOffsetCurve
  self.timeLength = Length or -1
  self.curTime = 0
end

function CameraAdditiveParamStatus:UpdateData(deltaTime)
  if self.timeLength < 0 then
    return
  end
  self.curTime = self.curTime + deltaTime
  if self.curTime >= self.timeLength then
    self:SetStatusActive(false)
  end
end

function CameraAdditiveParamStatus:SetStatusActive(isActive)
  if self.isActive ~= isActive then
    self:SetStatusReActive(isActive)
  end
end

function CameraAdditiveParamStatus:SetStatusReActive(isActive)
  self.isActive = isActive
  self.curTime = 0
end

function CameraAdditiveParamStatus:GetCameraOffset(needNormalize)
  if self.CameraOffsetCurve == nil then
    return ZeroVector
  end
  if needNormalize then
    local scaleTime = self.curTime / self.timeLength
    local ret = self.CameraOffsetCurve:GetVectorValue(scaleTime) * 6
    return ret
  else
    return self.CameraOffsetCurve:GetVectorValue(self.curTime)
  end
end

function CameraAdditiveParamStatus:GetRotationOffset(needNormalize)
  if self.RotationOffsetCurve == nil then
    return ZeroVector
  end
  if needNormalize then
    local scaleTime = self.curTime / self.timeLength
    local ret = self.RotationOffsetCurve:GetVectorValue(scaleTime) * 6
    return ret
  else
    return self.RotationOffsetCurve:GetVectorValue(self.curTime)
  end
end

return CameraAdditiveParamStatus
