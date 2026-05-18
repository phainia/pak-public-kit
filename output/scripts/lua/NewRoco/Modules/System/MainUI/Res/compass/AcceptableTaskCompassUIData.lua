local CompassUIData = require("NewRoco.Modules.System.MainUI.Res.compass.CompassUIData")
local Base = CompassUIData
local AcceptableTaskCompassUIData = Base:Extend("AcceptableTaskCompassUIData")

function AcceptableTaskCompassUIData:InitData(Info, worldMap, ViewField)
  Base.InitData(self, Info, worldMap, ViewField)
  self.NpcAngleLimit = ViewField
  self:EnableDistanceLevel()
  self.CurState = CompassUIData.MapAreaState.TASK
end

function AcceptableTaskCompassUIData:SetIcon()
  if not self.CompWidget then
    return
  end
  if self.WorldMapConfig and self.WorldMapConfig.compass_markicon then
    self.CompWidget:SetIcon(self.WorldMapConfig.compass_markicon)
  else
    Log.DebugFormat("AcceptableTaskCompassUIData:SetIcon: No compass_taskicon found for world map ID %d", self.WorldMapConfig and self.WorldMapConfig.id or 0)
  end
end

return AcceptableTaskCompassUIData
