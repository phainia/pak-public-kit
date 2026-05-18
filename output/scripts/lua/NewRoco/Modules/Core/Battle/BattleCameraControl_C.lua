local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleCameraControl_C = _G.NRCPanelBase:Extend("BattleCameraControl_C")

function BattleCameraControl_C:Initialize()
end

function BattleCameraControl_C:Construct()
end

function BattleCameraControl_C:Destruct()
end

function BattleCameraControl_C:OnTouchStarted(MyGeometry, InTouchEvent)
  local FingerNumber = self:GetTouchScaleInfo()
  if 1 ~= FingerNumber and 2 ~= FingerNumber then
    return UE4.UWidgetBlueprintLibrary.Unhandled()
  end
  local screenPos = UE4.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InTouchEvent)
  self.Position = screenPos
  self.NewPos = screenPos
  self:TouchStarted()
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end

function BattleCameraControl_C:TouchStarted()
  self:ClearTouchData()
  self.bTouching = true
  self.ScreenSize = UE4.UWidgetLayoutLibrary.GetViewportSize(UE4Helper.GetCurrentWorld())
  self.DiagonalLength = math.sqrt(self.ScreenSize.X * self.ScreenSize.X + self.ScreenSize.Y * self.ScreenSize.Y)
  if _G.BattleManager.vBattleField then
    local battleCraneCamera = _G.BattleManager.vBattleField.battleCraneCamera
    if battleCraneCamera and battleCraneCamera:IsCanRotate() then
      battleCraneCamera:ChangeCamParent(true)
    end
  end
end

function BattleCameraControl_C:HandleScreenClick()
  if self.Position then
    _G.NRCEventCenter:DispatchEvent(NRCGlobalEvent.BattleScreenClick, self.Position)
  end
end

function BattleCameraControl_C:OnTouchEnded(MyGeometry, InTouchEvent)
  self:HandleScreenClick()
  self:TouchEnd()
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end

function BattleCameraControl_C:TouchEnd()
  self.NewPos = UE4.FVector2D(0, 0)
  self.Position = UE4.FVector2D(0, 0)
  self:ClearTouchData()
  self.bTouching = false
  local battleCraneCamera = _G.BattleManager.vBattleField.battleCraneCamera
  if battleCraneCamera and battleCraneCamera:IsCanRotate() then
    battleCraneCamera:ChangeCamParent(false)
  end
end

function BattleCameraControl_C:ClearOneFingerTouchInfo()
  self.NewPos = UE4.FVector2D(0, 0)
  self.Position = UE4.FVector2D(0, 0)
  local battleCraneCamera = _G.BattleManager.vBattleField.battleCraneCamera
  if battleCraneCamera and battleCraneCamera:IsCanRotate() then
    battleCraneCamera:ChangeCamParent(false)
  end
end

function BattleCameraControl_C:OnTouchMoved(MyGeometry, InTouchEvent)
  if not self.bTouching then
    return UE4.UWidgetBlueprintLibrary.Unhandled()
  end
  local FingerNumber, touchDistance = self:GetTouchScaleInfo()
  if 1 ~= FingerNumber and 2 ~= FingerNumber then
    self:ClearTouchData()
    return UE4.UWidgetBlueprintLibrary.Unhandled()
  end
  if 1 == FingerNumber then
    if self.bIsTwoFinger then
      self:ClearTouchData()
      return UE4.UWidgetBlueprintLibrary.Unhandled()
    end
    self.bIsOneFinger = true
    local screenPos = UE4.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InTouchEvent)
    self.NewPos = screenPos
    self:ChangeCamera()
    self.Position = screenPos
  else
    self.bIsTwoFinger = true
    self.bIsOneFinger = nil
    local DiffDistance
    self:ClearOneFingerTouchInfo()
    if not self.touchDistance then
      DiffDistance = 0
    else
      DiffDistance = touchDistance - self.touchDistance
    end
    local battleCraneCamera = _G.BattleManager.vBattleField.battleCraneCamera
    if battleCraneCamera and battleCraneCamera:IsCanRotate() then
      DiffDistance = DiffDistance * _G.BattleConst.BattleZoomPhoneSpeed
      DiffDistance = DiffDistance / self.DiagonalLength
      battleCraneCamera:UpdateCamBattleZoom(-DiffDistance)
    end
    self.touchDistance = touchDistance
  end
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end

function BattleCameraControl_C:ChangeCamera()
  local battleCraneCamera = _G.BattleManager.vBattleField.battleCraneCamera
  if battleCraneCamera and battleCraneCamera:IsCanRotate() then
    local cameraFreedom = battleCraneCamera:GetCameraFreedom()
    local PitchX = cameraFreedom.PitchX
    local PitchY = cameraFreedom.PitchY
    local YawX = cameraFreedom.YawX
    local YawY = cameraFreedom.YawY
    local XSpeed = cameraFreedom.XSpeed
    local YSpeed = cameraFreedom.YSpeed
    if battleCraneCamera then
      local difference = self.NewPos - self.Position
      local ScreenSize = UE4.UWidgetLayoutLibrary.GetViewportSize(UE4Helper.GetCurrentWorld())
      local DeltaXScaled = difference.X / (ScreenSize.X / XSpeed)
      local DeltaYScaled = difference.Y / (ScreenSize.Y / YSpeed)
      local TXOff = battleCraneCamera.SpringArmXOffset or 0
      local TYOff = battleCraneCamera.SpringArmYOffset or 0
      TXOff = (TXOff + DeltaXScaled + 180) % 360 - 180
      TYOff = (TYOff + DeltaYScaled + 180) % 360 - 180
      TYOff = math.min(TYOff, PitchY)
      TYOff = math.max(TYOff, -PitchX)
      battleCraneCamera:ModifySpringArmRotation(TXOff, TYOff, TXOff - battleCraneCamera.SpringArmXOffset, TYOff - battleCraneCamera.SpringArmYOffset)
    end
  end
end

function BattleCameraControl_C:OnMouseWheel(MyGeometry, InTouchEvent)
  local wheelData = UE4.UKismetInputLibrary.PointerEvent_GetWheelDelta(InTouchEvent)
  wheelData = wheelData * _G.BattleConst.BattleZoomDefaultSpeed
  local battleCraneCamera = _G.BattleManager.vBattleField.battleCraneCamera
  if battleCraneCamera and battleCraneCamera:IsCanRotate() then
    battleCraneCamera:UpdateCamBattleZoom(-wheelData)
  end
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end

function BattleCameraControl_C:GetTouchScaleInfo()
  local locationX0, locationY0, bPressed0 = UE.UNRCStatics.GetTouchStateFromRocoPreInputProcessor(0)
  local locationX1, locationY1, bPressed1 = UE.UNRCStatics.GetTouchStateFromRocoPreInputProcessor(1)
  local locationX2, locationY2, bPressed2 = UE.UNRCStatics.GetTouchStateFromRocoPreInputProcessor(2)
  if bPressed0 and bPressed1 and bPressed2 then
    return 3, 0
  elseif bPressed0 and bPressed1 then
    local p0 = UE.FVector2D(locationX0, locationY0)
    local p1 = UE.FVector2D(locationX1, locationY1)
    return 2, (p1 - p0):Size()
  elseif bPressed0 then
    return 1, 0
  else
    return 0, 0
  end
end

function BattleCameraControl_C:ClearTouchData()
  self.bIsTwoFinger = nil
  self.bIsOneFinger = nil
  self.bTouching = nil
  self.touchDistance = nil
end

return BattleCameraControl_C
