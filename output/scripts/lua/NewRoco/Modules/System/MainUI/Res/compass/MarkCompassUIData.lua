local CompassUIData = require("NewRoco.Modules.System.MainUI.Res.compass.CompassUIData")
local Base = CompassUIData
local MarkCompassUIData = Base:Extend("MarkCompassUIData")

function MarkCompassUIData:InitData(Info, worldMap, ViewField)
  Base.InitData(self, Info, worldMap, ViewField)
  self.NpcAngleLimit = ViewField
  self.layer_id = Info.layer_id
  self:EnableDistanceLevel()
  self.CurState = CompassUIData.MapAreaState.MARK
end

function MarkCompassUIData:SetIcon()
  if self.CompWidget and self.WorldMapConfig then
    self.CompWidget:SetIcon(self.WorldMapConfig.compass_markicon)
  end
end

return MarkCompassUIData
