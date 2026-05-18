local Class = _G.MakeSimpleClass
local MapRegionArea = Class("MapRegionArea")

function MapRegionArea:Init(inArea, outArea)
  self.inArea = inArea
  self.outArea = outArea
  if self.inArea then
    self._inRegion, self._inRegionMaxHeight = self:_InitArea(inArea)
    if self._inRegion then
      self._inRegionRef = UnLua.Ref(self._inRegion)
    end
  end
  if self.outArea then
    self._outRegion, self._outRegionMaxHeight = self:_InitArea(outArea)
    if self._outRegion then
      self._outRegionRef = UnLua.Ref(self._outRegion)
    end
  end
end

function MapRegionArea:_InitArea(area)
  local maxHeight, region = UE4.UNRCStatics.BuildRegion(UE4Helper.GetCurrentWorld(), nil, area)
  return region, maxHeight
end

function MapRegionArea:PostInit()
  if UE.UObject.IsValid(self._inRegion) then
    self._inRegion:Visualize("Area_" .. self.inArea.id)
  end
end

function MapRegionArea:RandomPointInInner()
  if UE.UObject.IsValid(self._inRegion) then
    local point = self._inRegion:GenerateRandomPoint()
    if self._inRegionMaxHeight ~= nil then
      point.Z = self._inRegionMaxHeight
    end
    return point
  end
  return UE4.FVector()
end

function MapRegionArea:RandomPointInOuter()
  if UE.UObject.IsValid(self._outRegion) then
    local point = self._outRegion:GenerateRandomPoint()
    if self._outRegionMaxHeight ~= nil then
      point.Z = self._outRegionMaxHeight
    end
    return point
  end
  return UE4.FVector()
end

function MapRegionArea:InnerContainsPoint(pos)
  if UE.UObject.IsValid(self._inRegion) then
    return self._inRegion:ContainPoint(pos)
  end
  return false
end

function MapRegionArea:OuterContainsPoint(pos)
  if UE.UObject.IsValid(self._outRegion) then
    return self._outRegion:ContainPoint(pos)
  end
  return false
end

function MapRegionArea:GetInRegionPointNum()
  if UE.UObject.IsValid(self._inRegion) then
    return self._inRegion.MainRegion.Vertices:Length()
  end
  return 0
end

function MapRegionArea:GetOutRegionPointNum()
  if UE.UObject.IsValid(self._outRegion) then
    return self._outRegion.MainRegion.Vertices:Length()
  end
  return 0
end

function MapRegionArea:Destroy()
  self._inRegion = nil
  self._inRegionRef = nil
  self._outRegion = nil
  self._outRegionRef = nil
end

return MapRegionArea
