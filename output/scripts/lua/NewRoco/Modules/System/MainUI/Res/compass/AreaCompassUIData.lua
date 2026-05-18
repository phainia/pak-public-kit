local CompassUIData = require("NewRoco.Modules.System.MainUI.Res.compass.CompassUIData")
local Base = CompassUIData
local AreaCompassUIData = Base:Extend("AreaCompassUIData")

function AreaCompassUIData:CtorCtor(fatherLayer, compass, Space, LevelArray)
  Base.Ctor(self, fatherLayer, compass, Space, LevelArray)
  self.UpdateData = AreaCompassUIData.UpdateData
  self.MapAreaState = CompassUIData.MapAreaState
end

function AreaCompassUIData:InitData(Info, worldMap, ViewField)
  Base.InitData(self, Info, worldMap, ViewField)
  self:EnableDistanceLevel()
  self.NpcAngleLimit = ViewField
  self.NPC_level = Info.NPC_Level
  self.CurState = CompassUIData.MapAreaState.MAP_AREA
end

function AreaCompassUIData:UpdateData(Info, worldMap, ViewField)
  self:SetPos(Info.Position)
  self.WorldMapConfig = worldMap
  self.IsUnLock = Info.IsUnLock
  self.NpcConfig = Info.NpcConfig
  self.NPC_level = Info.NPC_Level
  if self.CurState == CompassUIData.MapAreaState.MAP_AREA or self.CurState == CompassUIData.MapAreaState.MAP_NPC then
    self:SetIcon()
  end
end

return AreaCompassUIData
