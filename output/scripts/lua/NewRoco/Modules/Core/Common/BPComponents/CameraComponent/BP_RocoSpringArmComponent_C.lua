require("UnLuaEx")
local LuaMathUtils = require("NewRoco.Utils.LuaMathUtils")
local DialogueUtils = require("NewRoco.Modules.System.Dialogue.DialogueUtils")
local DialogueConst = require("NewRoco.Modules.System.Dialogue.DialogueConst")
local BP_RocoSpringArmComponent_C = NRCClass()
local Zero = UE4.FVector(0, 0, 0)

function BP_RocoSpringArmComponent_C:ReceiveBeginPlay()
  self._lerpRatio = 2
  self._lerpMinSpeed = 60
  self._lerpOffsetRatio = 8
  self._lerpTargetOffset = nil
  self._LerpStartSpringArm = 0
  self._LerpStartTargetOffset = nil
  self._LerpTotalTime = 0
  self._LerpRemainTime = 0
  self._LerpEaseType = LuaMathUtils.Ease.Cubic
  self.isDialogCamera = false
end

function BP_RocoSpringArmComponent_C:SetArmLerpSetting(Ratio, MinSpeed)
  self._lerpRatio = Ratio
  self._lerpMinSpeed = MinSpeed
end

function BP_RocoSpringArmComponent_C:SetArmLength(ArmLength, Immediately)
  ArmLength = math.max(10, ArmLength)
  if Immediately then
    self._lerpTargetArmLength = nil
    self.TargetArmLength = ArmLength
  else
    self._lerpTargetArmLength = ArmLength
  end
end

function BP_RocoSpringArmComponent_C:SetTargetOffset(Offset, Immediately)
  if not Offset then
    return
  end
  if Immediately then
    self._lerpTargetOffset = nil
    self.TargetOffset = Offset
  else
    self._lerpTargetOffset = Offset
  end
end

function BP_RocoSpringArmComponent_C:SetRotateSpeed(Speed)
  self.CameraRotationLagSpeed = Speed
end

function BP_RocoSpringArmComponent_C:ReceiveTick(DeltaSeconds)
  if self._LerpTotalTime and self._LerpRemainTime and self._LerpTotalTime + self._LerpRemainTime > 0 then
    self._LerpRemainTime = math.clamp(self._LerpRemainTime - DeltaSeconds, 0, self._LerpTotalTime)
    local PassedPercent = 1.0 - self._LerpRemainTime / self._LerpTotalTime
    if self._lerpTargetOffset and self._lerpTargetArmLength then
      local EaseFunc = LuaMathUtils[self._LerpEaseType]
      local EasePercent = EaseFunc and EaseFunc(PassedPercent) or PassedPercent
      self.TargetArmLength = self._LerpStartSpringArm * (1 - EasePercent) + self._lerpTargetArmLength * EasePercent
      self.TargetOffset = self._LerpStartTargetOffset * (1 - EasePercent) + self._lerpTargetOffset * EasePercent
    end
    if PassedPercent >= 1.0 then
      self._LerpTotalTime = 0
      self._LerpRemainTime = 0
      self._LerpStartTargetOffset = nil
      self._LerpStartSpringArm = 0
      if DialogueUtils.CheckEndDialogStatus() then
        self.bDoDialogCollisionTest = false
      end
    end
  else
    if self.isDialogCamera then
      if DialogueConst.DrawDebugLines then
        self.bDrawDebugLagMarkers = true
      else
        self.bDrawDebugLagMarkers = false
      end
    end
    if self._lerpTargetArmLength and math.abs(self.TargetArmLength - self._lerpTargetArmLength) > 1 then
      self.TargetArmLength = LuaMathUtils.LerpWithMin(self.TargetArmLength, self._lerpTargetArmLength, self._lerpMinSpeed, self._lerpRatio * DeltaSeconds)
    end
    if self._lerpTargetOffset then
      if UE4.FVector.DistSquared(self._lerpTargetOffset, Zero) > 1.0E-6 then
        self.TargetOffset = LuaMathUtils.LerpVector(self.TargetOffset, self._lerpTargetOffset, self._lerpOffsetRatio * DeltaSeconds)
      else
        self.TargetOffset = self._lerpTargetOffset
      end
    end
  end
  if self.Overridden then
    self.Overridden.ReceiveTick(self, DeltaSeconds)
  end
end

function BP_RocoSpringArmComponent_C:SetFinalTargetOffset(Offset)
  if not Offset then
    return
  end
  self.FinalTargetOffset = Offset
end

function BP_RocoSpringArmComponent_C:SetFinalSpringArmLength(Length)
  if not Length then
    return
  end
  self.FinalSpringArmLength = Length
end

function BP_RocoSpringArmComponent_C:SetLerpTime(TotalTime, EaseType)
  TotalTime = TotalTime or 0
  self._LerpTotalTime = TotalTime
  self._LerpRemainTime = TotalTime
  self._LerpStartTargetOffset = self.TargetOffset
  self._LerpStartSpringArm = self.TargetArmLength
  self._LerpEaseType = EaseType
end

return BP_RocoSpringArmComponent_C
