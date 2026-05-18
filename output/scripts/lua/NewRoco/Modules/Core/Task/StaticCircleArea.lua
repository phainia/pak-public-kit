local StaticAreaBase = require("NewRoco.Modules.Core.Scene.Common.StaticAreaBase")
local Base = StaticAreaBase
local StaticCircleArea = Base:Extend("StaticCircleArea")

function StaticCircleArea.MakePoint2D(UniqueName, SceneID, CenterX, CenterY, Radius, RadiusOffset, Caller, EnterCallback, LeaveCallback)
  local NewArea = StaticCircleArea()
  NewArea.UniqueName = UniqueName
  NewArea.SceneID = SceneID
  NewArea.X = CenterX or 0
  NewArea.Y = CenterY or 0
  NewArea.Z = 0
  NewArea.R = math.abs(Radius or 0)
  NewArea.RadiusOffset = RadiusOffset or 0
  NewArea.bIs2D = true
  NewArea.CallbackPackage.Caller = Caller
  NewArea.CallbackPackage.EnterCallback = EnterCallback
  NewArea.CallbackPackage.LeaveCallback = LeaveCallback
  return NewArea
end

function StaticCircleArea.MakePoint3D(UniqueName, SceneID, CenterX, CenterY, CenterZ, Radius, RadiusOffset, Caller, EnterCallback, LeaveCallback)
  local NewArea = StaticCircleArea()
  NewArea.UniqueName = UniqueName
  NewArea.SceneID = SceneID
  NewArea.X = CenterX or 0
  NewArea.Y = CenterY or 0
  NewArea.Z = CenterZ or 0
  NewArea.R = math.abs(Radius or 0)
  NewArea.RadiusOffset = RadiusOffset or 0
  NewArea.bIs2D = false
  NewArea.CallbackPackage.Caller = Caller
  NewArea.CallbackPackage.EnterCallback = EnterCallback
  NewArea.CallbackPackage.LeaveCallback = LeaveCallback
  return NewArea
end

function StaticCircleArea.MakeCylinder(UniqueName, SceneID, CenterX, CenterY, Radius, RadiusOffset, HalfHeight, HalfHeightOffset, Caller, EnterCallback, LeaveCallback)
  local NewArea = StaticCircleArea()
  NewArea.UniqueName = UniqueName
  NewArea.SceneID = SceneID
  NewArea.X = CenterX or 0
  NewArea.Y = CenterY or 0
  NewArea.Z = 0
  NewArea.R = math.abs(Radius or 0)
  NewArea.RadiusOffset = RadiusOffset or 0
  NewArea.HalfHeight = math.abs(HalfHeight or 0)
  NewArea.HalfHeightOffset = HalfHeightOffset or 0
  NewArea.bIs2D = false
  NewArea.bIsCylinder = true
  NewArea.CallbackPackage.Caller = Caller
  NewArea.CallbackPackage.EnterCallback = EnterCallback
  NewArea.CallbackPackage.LeaveCallback = LeaveCallback
  return NewArea
end

function StaticCircleArea:Ctor()
  Base.Ctor(self)
  self.X = 0
  self.Y = 0
  self.Z = 0
  self.R = 0
  self.RadiusOffset = 0
  self.HalfHeight = 0
  self.HalfHeightOffset = 0
  self.bIs2D = false
  self.bIsCylinder = false
  self.CallbackPackage = _G.MakeWeakTable({}, "v")
end

function StaticCircleArea:BroadCheck(X, Y, Z, PlayerRadius, PlayerHalfHeight)
  local R = self.R
  if self.bPreviouslyInArea then
    R = R + self.RadiusOffset
  else
    R = R - self.RadiusOffset
  end
  if self.X > X + R then
    return false
  end
  if self.X < X - R then
    return false
  end
  if self.Y > Y + R then
    return false
  end
  if self.Y < Y - R then
    return false
  end
  if self.bIs2D then
    return true
  end
  local ZR = R
  if self.bIsCylinder then
    if self.bPreviouslyInArea then
      ZR = self.HalfHeight + self.HalfHeightOffset
    else
      ZR = self.HalfHeight - self.HalfHeightOffset
    end
  end
  if self.Z > Z + ZR then
    return false
  end
  if self.Z < Z - ZR then
    return false
  end
  return true
end

function StaticCircleArea:FineCheck(X, Y, Z, PlayerRadius, PlayerHalfHeight)
  local DX = X - self.X
  local DY = Y - self.Y
  local DZ = (self.bIs2D or self.bIsCylinder) and 0 or Z - self.Z
  local D = DX * DX + DY * DY + DZ * DZ
  local R = self.R
  if self.bPreviouslyInArea then
    R = R + self.RadiusOffset
  else
    R = R - self.RadiusOffset
  end
  return D <= R * R
end

function StaticCircleArea:OnPlayerEnter(X, Y, Z, PlayerRadius, PlayerHalfHeight)
  Base.OnPlayerEnter(self, X, Y, Z, PlayerRadius, PlayerHalfHeight)
  local Callback = self.CallbackPackage.EnterCallback
  local Caller = self.CallbackPackage.Caller
  if Callback then
    Callback(Caller, self, X, Y, Z, PlayerRadius, PlayerHalfHeight)
  end
end

function StaticCircleArea:OnPlayerLeave(X, Y, Z, PlayerRadius, PlayerHalfHeight)
  Base.OnPlayerLeave(self, X, Y, Z, PlayerRadius, PlayerHalfHeight)
  local Callback = self.CallbackPackage.LeaveCallback
  local Caller = self.CallbackPackage.Caller
  if Callback then
    Callback(Caller, self, X, Y, Z, PlayerRadius, PlayerHalfHeight)
  end
end

function StaticCircleArea:Destroy()
  table.clear(self.CallbackPackage)
  Base.Destroy(self)
end

return StaticCircleArea
