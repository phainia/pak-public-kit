require("UnLuaEx")
local BP_Spliny_C = NRCClass()

function BP_Spliny_C:UserConstructionScript()
  self.DistNeeded = DataConfigManager:GetMapGlobalConfig("navigation_showline_max_distance").num
  self.DistOver = DataConfigManager:GetMapGlobalConfig("navigation_showline_min_distance").num
  self.Overridden.UserConstructionScript(self)
end

function BP_Spliny_C:ReceiveBeginPlay()
  self.DistMax = DataConfigManager:GetMapGlobalConfig("navigation_to_target_max_distance").num
  self.DistMin = DataConfigManager:GetMapGlobalConfig("navigation_to_target_min_distance").num
  self.Viz = true
  self.VizOut = true
end

function BP_Spliny_C:InnerTick(DeltaSeconds)
  if self.Target then
    local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
    if not player then
      return
    end
    self.VizOut = self.Target >= self.DistMin * self.DistMin and self.Target <= self.DistMax * self.DistMax
  end
  self:SetVisible(true)
end

function BP_Spliny_C:SetVisible(boolViz)
  self.Niagara:SetVisibility(boolViz and self.Viz)
end

function BP_Spliny_C:DistSquared2D(a, b)
  if not a or not b then
    return math.maxinteger
  end
  local X = (a.X or a.x) - (b.X or b.x)
  local Y = (a.Y or a.y) - (b.Y or b.y)
  return X * X + Y * Y
end

return BP_Spliny_C
