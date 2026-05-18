local SIGHT_Z = 200
local Base = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local RectSight = Class()

function RectSight:Init(width, height)
  self.width = width
  self.height = height
  self.halfWidth = self.width / 2
end

function RectSight:CheckInSight(srcNpc, target)
  if srcNpc.model then
    local npcTransform = srcNpc.model:Abs_GetTransform()
    local localPos = UE4.UKismetMathLibrary.InverseTransformLocation(npcTransform, target:GetActorLocation())
    if localPos.Z > SIGHT_Z or localPos.Z < -SIGHT_Z then
      return false
    end
    return localPos.Y > -self.halfWidth and localPos.X > 0 and localPos.X < self.height and localPos.Y < self.halfWidth
  end
  return false
end

local SectorSight = Class()

function SectorSight:Init(radial, angle)
  self.radial = radial
  self.angle = angle
  self.sqrRadial = radial * radial
  self.cosValue = math.cos(math.rad(angle / 2))
end

function SectorSight:CheckInSight(srcNpc, target)
  local srcVec = srcNpc:GetActorLocation()
  local tarVec = target:GetActorLocation()
  local sqrDis = UE4.FVector.DistSquared2D(srcVec, tarVec)
  local deltaZ = tarVec.Z - srcVec.Z
  if deltaZ > SIGHT_Z or deltaZ < -SIGHT_Z then
    return false
  end
  if sqrDis < self.sqrRadial then
    if self.angle < 360 then
      local dir = target:GetActorLocation() - srcNpc:GetActorLocation()
      dir:Normalize()
      local cosValue = UE4.FVector.Dot(dir, srcNpc:GetForwardVector())
      if cosValue > self.cosValue then
        return true
      end
    else
      return true
    end
  end
  return false
end

local function CreateSight(sType, width, length)
  if length > 0 then
    if 0 == sType then
      local sight = RectSight()
      sight:Init(width, length)
      return sight
    elseif 1 == sType then
      local sight = SectorSight()
      sight:Init(length, width)
      return sight
    end
  end
  return nil
end

local SightComponent = Base:Extend("SightComponent")
SightComponent.curLv = 0

function SightComponent:Update()
  local area = self.owner:GetArea()
  if area and area:OuterContainsPoint(self.owner.sceneContext.localPlayer:GetActorLocationFrameCache()) == false then
    self:UpdateSightLevel(0)
    return
  end
  if self.strongSight and self.strongSight:CheckInSight(self.owner, self.target) then
    self:UpdateSightLevel(2)
    return
  end
  if self.weakSight and self.weakSight:CheckInSight(self.owner, self.target) then
    self:UpdateSightLevel(1)
  else
    self:UpdateSightLevel(0)
  end
end

function SightComponent:SetSightTarget(target)
  self.target = target
end

function SightComponent:InitWeakSight(sType, width, length)
  self.weakSight = CreateSight(sType, width, length)
end

function SightComponent:InitStrongSight(sType, width, length)
  self.strongSight = CreateSight(sType, width, length)
end

function SightComponent:UpdateSightLevel(lv)
  if self.curLv ~= lv then
    self.curLv = lv
    if self.sightChangedCallback then
      self.sightChangedCallback(lv)
    end
  end
end

function SightComponent:SetOnSightChanged(callback)
  self.sightChangedCallback = callback
end

return SightComponent
