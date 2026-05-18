local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local CivilCalculator = Class()
local DebugCalculation = false
local LocalCache = {}
local SegSize = 32

function CivilCalculator:Ctor()
  self.MapConfig = nil
  self.SceneResConf = nil
end

function CivilCalculator:InitMapConfig()
  local World = _G.UE4Helper.GetCurrentWorld()
  if not World then
    return
  end
  local WorldName = World:GetName()
  self.MapConfig = require(string.format("Data.Map.%s.MapConfig", WorldName))
end

function CivilCalculator:GetTileFileName(WorldName, X, Y)
  return string.format("Data.Map.%s.Heightmap_x%d_y%d", WorldName, X, Y)
end

function CivilCalculator:GetTileData(WorldName, X, Y)
  if not self.MapConfig then
    return nil
  end
  local Columns = self.MapConfig[Y]
  if not Columns then
    return nil
  end
  if not Columns[X] then
    return nil
  end
  return require(self:GetTileFileName(WorldName, X, Y))
end

function CivilCalculator:GetLevelIndex(X, Y)
  return X + Y * SegSize
end

function CivilCalculator:GatherLevelIndices(WorldName, PlayerX, PlayerY)
  if not self.SceneResConf or WorldName ~= self.SceneResConf.main_source then
    self.SceneResConf = _G.DataConfigManager:GetSceneResConfByName(WorldName)
  end
  if not self.SceneResConf then
    return nil, nil
  end
  local TileSize = self.SceneResConf.tile_size
  local TileOffsetX = self.SceneResConf.offset_x
  local TileOffsetY = self.SceneResConf.offset_y
  local CenterX = math.floor((PlayerX - TileOffsetX) / TileSize)
  local CenterY = math.floor((PlayerY - TileOffsetY) / TileSize)
  return CenterX, CenterY
end

function CivilCalculator:Calculate()
  local Player = SceneUtils.GetPlayer()
  if not Player then
    return -1
  end
  local PlayerPos = Player:GetActorLocation()
  if not Player then
    return -1
  end
  local PlayerX = PlayerPos.X
  local PlayerY = PlayerPos.Y
  local PlayerZ = PlayerPos.Z
  local World = _G.UE4Helper.GetCurrentWorld()
  if not World then
    return -1
  end
  local WorldName = World:GetName()
  local CenterX, CenterY = self:GatherLevelIndices(WorldName, PlayerX, PlayerY)
  if nil == CenterX or nil == CenterY then
    return -1
  end
  if DebugCalculation then
    table.clear(LocalCache)
    table.insert(LocalCache, {
      WorldName,
      CenterX,
      CenterY
    })
  end
  local Civil = 0.0
  local TileData = self:GetTileData(WorldName, CenterX, CenterY)
  if TileData then
    local HasMatch = false
    for Name, Entry in pairs(TileData) do
      local EX = Entry[1]
      local EY = Entry[2]
      local EZ = Entry[3]
      local R = Entry[4]
      local Scale = Entry[5] or 1
      R = R * R
      local DX = PlayerX - EX
      local DY = PlayerY - EY
      local DZ = PlayerZ - EZ
      local Dist = DX * DX + DY * DY + DZ * DZ
      if R >= Dist then
        local Val = (1 - math.sqrt(Dist / R)) * Scale
        Civil = Civil + Val
        if DebugCalculation then
          table.insert(LocalCache, {
            Name,
            CenterX,
            CenterY,
            math.sqrt(Dist),
            math.sqrt(R),
            Scale,
            Val
          })
        end
        HasMatch = true
        if Civil >= 1 then
          Civil = 1
          break
        end
      end
    end
    if DebugCalculation and not HasMatch then
      table.insert(LocalCache, {
        WorldName,
        "no match",
        CenterX,
        CenterY
      })
    end
  elseif DebugCalculation then
    table.insert(LocalCache, {
      WorldName,
      "no tile",
      CenterX,
      CenterY
    })
  end
  if DebugCalculation and _G.AppMain:HasDebug() then
    _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.ShowTable, LocalCache, "Civil Value")
  end
  return Civil
end

function CivilCalculator.ToggleDebug(Enable)
  DebugCalculation = Enable
end

return CivilCalculator
