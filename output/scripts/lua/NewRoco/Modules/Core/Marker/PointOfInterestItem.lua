local EventDispatcher = require("Common.EventDispatcher")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local MarkerUtils = require("NewRoco.Modules.Core.Marker.MarkerUtils")
local PointOfInterestItem = Class("PointOfInterestItem")

function PointOfInterestItem:Ctor(pos, Source)
  EventDispatcher():Attach(self)
  self.Position = UE4.FVector(pos.X, pos.Y, pos.Z)
  self.Valid = true
  self.Source = Source
end

function PointOfInterestItem:Destroy()
end

function PointOfInterestItem:DistSquared2D(a, b)
  if not a or not b then
    return math.maxinteger
  end
  local X = (a.X or a.x) - (b.X or b.x)
  local Y = (a.Y or a.y) - (b.Y or b.y)
  return X * X + Y * Y
end

function PointOfInterestItem:GetPosition()
  if self.Valid then
    return self.Position
  else
    return nil
  end
end

function PointOfInterestItem:DrawFlipbook(Canvas, Flipbook, Position, Color, Rotation, DeltaTime)
  if self.AnimIndex < 0 then
    return
  end
  if self.AnimIndex >= Flipbook:GetTotalDuration() then
    self.AnimIndex = -1
    return
  end
  local Sprite = Flipbook:GetSpriteAtTime(self.AnimIndex)
  if not Sprite then
    return
  end
  if not Sprite.SourceTexture then
    return
  end
  local Texture = Sprite.SourceTexture:Get()
  if Texture then
    local TextureSize = UE4.FVector2D(Texture:Blueprint_GetSizeX(), Texture:Blueprint_GetSizeY())
    local Size = Sprite.SourceDimension
    local CoordPos = Sprite.SourceUV / TextureSize
    local CoordSize = Sprite.SourceDimension / TextureSize
    Canvas:K2_DrawTexture(Texture, Position - Size / 2, Size, CoordPos, CoordSize, Color, 2, Rotation)
  end
  self.AnimIndex = self.AnimIndex + DeltaTime
end

return PointOfInterestItem
