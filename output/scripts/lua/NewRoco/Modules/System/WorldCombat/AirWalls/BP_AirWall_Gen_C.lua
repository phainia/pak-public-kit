local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local BoundaryUpHeight = 300
local BoundaryDownHeight = 150
local BP_AirWall_Gen_C = NRCClass("BP_AirWall_Gen_C")

function BP_AirWall_Gen_C:Initialize(Conf)
  self.Conf = Conf
  self.PointArray = nil
  self.bNightmare = false
end

local CollisionProfiles = {
  [Enum.WorldCombatBlockType.WCBT_BLOCK] = "AirWallBlock_Block",
  [Enum.WorldCombatBlockType.WCBT_BOUNDARY] = "AirWallBlock_Boundary",
  [Enum.WorldCombatBlockType.WCBT_INVISIBLE] = "AirWallBlock_Invisible",
  [Enum.WorldCombatBlockType.WCBT_NIGHTMARE] = "AirWallBlock_Nightmare"
}

function BP_AirWall_Gen_C:ReceiveBeginPlay()
  self.Tags:AddUnique("Airwall")
  self.TriggerSwitch = self.Conf.block_type == Enum.WorldCombatBlockType.WCBT_BLOCK
  self.Overridden.ReceiveBeginPlay(self)
  UE.UNRCStatics.FillSpline(self.Spline, "BLOCK_CONF", self.Conf.id)
  local bBlockCharacter = true
  local airWallMat = self.BlockMat
  local bTileUV = false
  local CustomUpHeight = self.Conf.block_up_height
  local CustomDownHeight = self.Conf.block_down_height
  local CustomStep = 200
  if self.Conf.block_type == Enum.WorldCombatBlockType.WCBT_BOUNDARY then
    bBlockCharacter = false
    airWallMat = self.BoundaryMat
    CustomDownHeight = BoundaryDownHeight
    CustomUpHeight = BoundaryUpHeight
    CustomStep = 200
  elseif self.Conf.block_type == Enum.WorldCombatBlockType.WCBT_NIGHTMARE then
    airWallMat = self.NightmareMat
  end
  local Resolution = self:GetResolution()
  local Thickness = self:GetThickness()
  local ReverseFace = false
  if self.Conf.reverse_face then
    ReverseFace = self.Conf.reverse_face > 0
  end
  UE.UAirWallStatics.BuildThickWall(self.Spline, self.Block, airWallMat, CustomUpHeight, CustomDownHeight, Thickness, CustomStep, bBlockCharacter, bTileUV, Resolution, ReverseFace)
  if self.Conf.block_type == Enum.WorldCombatBlockType.WCBT_BOUNDARY then
    UE.UAirWallStatics.BuildWall(self.Spline, self.Disable, self.DisableMat, 2, CustomUpHeight, CustomDownHeight, 100, CustomStep, bBlockCharacter, Resolution)
    UE.UAirWallStatics.BuildWall(self.Spline, self.Enable, self.EnableMat, 1, CustomUpHeight, CustomDownHeight, -100, CustomStep, bBlockCharacter, Resolution)
  end
  if self.Conf.block_type == Enum.WorldCombatBlockType.WCBT_NIGHTMARE then
    self.Block:SetHiddenInGame(false, true)
  elseif self.Conf.block_type == Enum.WorldCombatBlockType.WCBT_BOUNDARY then
    self.Block:SetHiddenInGame(false, true)
  else
    self.bBoundary = bTileUV
    self:SetAirWallMaterialParams()
  end
  local CollisionProfile = CollisionProfiles[self.Conf.block_type]
  if CollisionProfile then
    self.Block:SetCollisionProfileName(CollisionProfile)
  end
  if self.Conf.block_type == Enum.WorldCombatBlockType.WCBT_INVISIBLE then
    self:SetActorHiddenInGame(true)
    self:SetActorTickEnabled(false)
    self:SetActorEnableCollision(true)
  end
  self.Disable.OnComponentBeginOverlap:Add(self, self.OnDisableBeginOverlap)
  self.Enable.OnComponentBeginOverlap:Add(self, self.OnEnableBeginOverlap)
  self.Block.OnComponentHit:Add(self, self.OnBlockHit)
end

function BP_AirWall_Gen_C:ReceiveEndPlay(EndPlayReason)
  self.Disable.OnComponentBeginOverlap:Remove(self, self.OnDisableBeginOverlap)
  self.Enable.OnComponentBeginOverlap:Remove(self, self.OnEnableBeginOverlap)
  self.Block.OnComponentHit:Remove(self, self.OnBlockHit)
end

function BP_AirWall_Gen_C:MakeDebugWall()
  if RocoEnv.IS_SHIPPING then
    return
  end
  self.DebugWall = self:AddComponentByClass(UE.UProceduralMeshComponent, false, UE.FTransform(), false)
  self.DebugWall:SetCollisionProfileName("NoCollision")
  local Resolution = self:GetResolution()
  local Thickness = self:GetThickness()
  local ReverseFace = self.Conf.reverse_face > 0
  UE.UAirWallStatics.BuildThickWall(self.Spline, self.DebugWall, self.DebugMat, self.Conf.block_up_height, self.Conf.block_down_height, Thickness, 200, true, false, Resolution, ReverseFace)
end

function BP_AirWall_Gen_C:GetResolution()
  local Resolution = 10
  local Length = self.Spline:GetSplineLength()
  if Length < 50000.0 then
    Resolution = 0
  end
  return Resolution
end

function BP_AirWall_Gen_C:GetThickness()
  local Thickness = 40
  if self.Conf.is_block_reversed and 1 == self.Conf.is_block_reversed then
    Thickness = -40
  end
  return Thickness
end

function BP_AirWall_Gen_C:ContainsPointIn2D(Point)
  if not self.PointArray then
    self.PointArray = UE.TArray(UE.FVector2D)
    local Location = SceneUtils.ConvertRelativeToAbsolute(self:K2_GetActorLocation())
    for _, SplinePoint in ipairs(self.Conf.spline_point) do
      local Pos = SplinePoint.Position
      self.PointArray:Add(UE.FVector2D((Pos[1] or 0) + Location.X, (Pos[2] or 0) + Location.Y))
    end
  end
  return UE.UNewRocoHelperLibrary.PointInPolygon(Point, self.PointArray)
end

function BP_AirWall_Gen_C:CheckIsLocalPlayer(otherActor, otherComp)
  if not otherActor or not UE4.UObject.IsValid(otherActor) then
    return false
  end
  if not otherActor:IsA(UE4.ARocoLocalPlayer) then
    return false
  end
  if otherActor.bHidden then
    return false
  end
  return true
end

function BP_AirWall_Gen_C:CheckIsPlayerRide(otherActor, otherComp)
  if not otherActor or not UE4.UObject.IsValid(otherActor) then
    return false
  end
  if not otherActor:IsA(UE4.ARocoVehicleCharacter) then
    return false
  end
  if otherActor.bHidden then
    return false
  end
  return true
end

function BP_AirWall_Gen_C:OnDisableBeginOverlap(selfComp, otherActor, otherComp, otherBodyIndex, bFromSweep, sweepResult)
  if not self.TriggerSwitch then
    return
  end
  if not self:CheckIsLocalPlayer(otherActor, otherComp) then
    return
  end
  self:ToggleTick(false)
  self.EnableUpdateProperty = false
  self.SpawnAccumulation = 0
  self.SpawnSeconds = 0
end

function BP_AirWall_Gen_C:OnEnableBeginOverlap(selfComp, otherActor, otherComp, otherBodyIndex, bFromSweep, sweepResult)
  if not self.TriggerSwitch then
    return
  end
  if not self:CheckIsLocalPlayer(otherActor, otherComp) and not self:CheckIsPlayerRide(otherActor, otherComp) then
    return
  end
  self.EnableUpdateProperty = true
  self.SpawnAccumulation = 0
  self.SpawnSeconds = 0
end

function BP_AirWall_Gen_C:OnBlockHit(selfComp, otherActor, otherComp, impulse, hitResult)
  if not self.TriggerSwitch then
    return
  end
  if not hitResult or not hitResult.bBlockingHit then
    return
  end
  if not self:CheckIsLocalPlayer(otherActor, otherComp) and not self:CheckIsPlayerRide(otherActor, otherComp) then
    return
  end
  if 0 == self.SpawnAccumulation then
    self.SpawnAccumulation = 1
    self.SpawnSeconds = self.SpawnInterval
    self:SpawnNiagara(hitResult.ImpactPoint, hitResult.ImpactNormal)
  elseif self.SpawnSeconds <= 0 then
    self.SpawnAccumulation = 0
  end
end

local TraceDelta = UE4.FVector(0.1, 0.1, 0.1)

function BP_AirWall_Gen_C:HideAirWallBasedOnCharacterTrace()
  self.bTranceHitOnBlock = false
  local player = self:GetPC()
  if not player or not UE4.UObject.IsValid(player) then
    return
  end
  local playerLocation = player:K2_GetActorLocation()
  local drawDebugType = UE4.EDrawDebugTrace.None
  local traceColor, traceHitColor
  local drawTime = 0
  if not _G.RocoEnv.IS_SHIPPING and self.bDebugTrace then
    drawDebugType = UE4.EDrawDebugTrace.ForDuration
    traceColor = UE4.FLinearColor(0.6, 1, 0, 1)
    traceHitColor = UE4.FLinearColor(0.2, 0.7, 0.2, 1)
    drawTime = self.DebugTraceDrawTime
  end
  local hitResults, _ = UE4.UKismetSystemLibrary.SphereTraceMulti(self, playerLocation - TraceDelta, playerLocation + TraceDelta, self.DetectDistance, UE4.ETraceTypeQuery.Airwall, false, nil, drawDebugType, nil, false, traceColor, traceHitColor, drawTime)
  if not hitResults then
    return
  end
  for _, hitResult in tpairs(hitResults) do
    if not hitResult or not hitResult.bBlockingHit then
    elseif hitResult.Actor ~= self then
    else
      local otherComp = hitResult.Component
      if otherComp ~= self.Block and otherComp ~= self.Disable then
      else
        self.bTranceHitOnBlock = true
      end
    end
  end
  if self.bTranceHitOnBlock then
    self:ToggleTick(true)
    self.EnableUpdateProperty = true
  else
    self:ToggleTick(false)
    self.EnableUpdateProperty = false
    self.SpawnAccumulation = 0
    self.SpawnSeconds = 0
  end
end

return BP_AirWall_Gen_C
