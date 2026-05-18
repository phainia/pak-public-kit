require("UnLuaEx")
local BP_RocoCameraSplineManger_C = NRCClass()

function BP_RocoCameraSplineManger_C:AreaPosToTransforms(AreaConf)
  local ResultTable = UE4.TArray(UE4.FVector)
  local idx = 1
  if AreaConf and AreaConf.pos and #AreaConf.pos > 0 then
    while idx <= #AreaConf.pos do
      local Location = AreaConf.pos[idx].position_xyz
      local ResultLocation = UE4.FVector()
      ResultLocation = UE4.FVector(Location[1], Location[2], Location[3])
      ResultTable:Add(ResultLocation)
      idx = idx + 1
    end
  end
  self.ProgressMultiplier = idx - 1 or 1
  return ResultTable
end

function BP_RocoCameraSplineManger_C:CreateSplineFromArea(AreaConfig)
  self.CurrentAreaId = AreaConfig.id
  self.Spline = self.Spline
  self.Spline:ClearSplinePoints(true)
  local Locations = self:AreaPosToTransforms(AreaConfig)
  self.Spline:SetSplinePoints(Locations, UE.ESplineCoordinateSpace.World, true)
end

function BP_RocoCameraSplineManger_C:HasSpline()
  if not UE.UObject.IsValid(self) then
    return false
  end
  if not UE.UObject.IsValid(self.Spline) then
    return false
  end
  if not self.Spline then
    return false
  end
  return true
end

function BP_RocoCameraSplineManger_C:GetNextLocationByCameraPath(PathConfig, Progress)
  if not (PathConfig and self.Spline) or not UE.UObject.IsValid(self.Spline) then
    Log.Error("no spline")
    return
  end
  if self.CurrentAreaId ~= PathConfig.id then
    self.Spline = self.Spline
    self.Spline:ClearSplinePoints(true)
    self.SplinePoints = table.clone(PathConfig.spline_point)
    UE.UNRCStatics.FillSpline(self.Spline, "CAMERA_PATH", PathConfig.id)
    self.ProgressMultiplier = #PathConfig.spline_point - 1 or 1
  end
  local result = self.Spline:GetLocationAtSplineInputKey(Progress * self.ProgressMultiplier, UE.ESplineCoordinateSpace.Local)
  local Dir = self.Spline:GetDirectionAtSplineInputKey(Progress * self.ProgressMultiplier, UE.ESplineCoordinateSpace.World):ToRotator()
  result.X = result.X + PathConfig.position[1]
  result.Y = result.Y + PathConfig.position[2]
  result.Z = result.Z + PathConfig.position[3]
  return result, Dir
end

function BP_RocoCameraSplineManger_C:GetNextLocation(AreaConfig, Progress)
  if not AreaConfig then
    return
  end
  if self.CurrentAreaId ~= AreaConfig.id then
    self:CreateSplineFromArea(AreaConfig)
  end
  local result = self.Spline:GetLocationAtSplineInputKey(Progress * self.ProgressMultiplier, UE.ESplineCoordinateSpace.World)
  local Dir = self.Spline:GetDirectionAtSplineInputKey(Progress * self.ProgressMultiplier, UE.ESplineCoordinateSpace.World):ToRotator()
  return result, Dir
end

return BP_RocoCameraSplineManger_C
