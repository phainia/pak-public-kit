local Class = _G.MakeSimpleClass
local SceneModule = NRCModuleManager:GetModule("SceneModule")
local MapRegionArea = require("NewRoco.Modules.Core.Scene.Map.MapRegionArea")
local MapRegionAreaUtil = Class("MapRegionAreaUtil")

function MapRegionAreaUtil:GetMapArea(areaId)
  if self._cachedArea == nil then
    self._cachedArea = {}
  else
    local CachedArea = self._cachedArea[areaId]
    if CachedArea and UE.UObject.IsValid(CachedArea._inRegion) then
      return self._cachedArea[areaId]
    end
  end
  local areaConf = DataConfigManager:GetAreaConf(areaId)
  local mapArea = MapRegionArea()
  mapArea:Init(areaConf, nil)
  self._cachedArea[areaId] = mapArea
  return mapArea
end

function MapRegionAreaUtil.BuildRegion(area)
  local region = NewObject(UE4.URegion, SceneModule.localPlayer.viewObj)
  for i, v in ipairs(area.pos) do
    region.MainRegion.Vertices:Add(UE4.FVector(v.position_xyz[1], v.position_xyz[2], v.position_xyz[3]))
  end
  local subRegion = UE4.FRawRegion()
  for i, v in ipairs(area.pos_empty) do
    subRegion.Vertices:Add(UE4.FVector(v.position_xyz[1], v.position_xyz[2], v.position_xyz[3]))
  end
  region.SubRegions:Add(subRegion)
  if area.area_type == Enum.AreaType.AREAT_POLYGON then
    region:BuildGrids(UE4.FVector2D(100, 100))
  end
  return region
end

function MapRegionAreaUtil:ClearMapRegion()
  self._cachedArea = nil
end

return MapRegionAreaUtil
