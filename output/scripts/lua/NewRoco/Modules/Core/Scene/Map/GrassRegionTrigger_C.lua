require("UnLuaEx")
local GrassRegionTrigger_C = Class()
GrassRegionTrigger_C.InstanceID = 0

function GrassRegionTrigger_C.GetID()
  GrassRegionTrigger_C.InstanceID = GrassRegionTrigger_C.InstanceID + 1
  return GrassRegionTrigger_C.InstanceID
end

function GrassRegionTrigger_C:Ctor()
  self.conf = nil
  self.id = GrassRegionTrigger_C.GetID()
end

function GrassRegionTrigger_C:Init(AreaConf, Index)
  if AreaConf then
    self.conf = AreaConf
    self:InitConvex(AreaConf, Index)
  end
end

function GrassRegionTrigger_C:InitConvex(AreaConf, Index)
  local bottomVertexs = UE4.TArray(UE4.FVector)
  local minX = math.maxinteger
  local minY = math.maxinteger
  local minZ = math.maxinteger
  local maxX = math.mininteger
  local maxY = math.mininteger
  local maxZ = math.mininteger
  for i, v in pairs(AreaConf.pos) do
    local pos = v
    local uePos = UE4.FVector(pos.position_xyz[1], pos.position_xyz[2], pos.position_xyz[3])
    self.PolygonPoints:Add(uePos)
    self.PolygonPoints2D:Add(uePos)
    if minX > pos.position_xyz[1] then
      minX = pos.position_xyz[1]
    end
    if maxX < pos.position_xyz[1] then
      maxX = pos.position_xyz[1]
    end
    if minY > pos.position_xyz[2] then
      minY = pos.position_xyz[2]
    end
    if maxY < pos.position_xyz[2] then
      maxY = pos.position_xyz[2]
    end
    if minZ > pos.position_xyz[3] then
      minZ = pos.position_xyz[3]
    end
    if maxZ < pos.position_xyz[3] then
      maxZ = pos.position_xyz[3]
    end
  end
  local centerPos = UE4.FVector((minX + maxX) / 2.0, (minY + maxY) / 2.0, (minZ + maxZ) / 2.0)
  local extent = UE4.FVector((maxX - minX) / 2.0, (maxY - minY) / 2.0, (maxZ - minZ) / 2.0 + 100)
  self:Abs_K2_SetActorLocation_WithoutHit(centerPos, false)
  self.Box:SetBoxExtent(extent, true)
end

function GrassRegionTrigger_C:TestInitConvex()
  local bottomVertexs = UE4.TArray(UE4.FVector)
  local upVertexs = UE4.TArray(UE4.FVector)
  local offset = UE4.FVector(0, 0, 100)
  for i, v in pairs(AreaConf.pos) do
    local pos = v
    local uePos = UE4.FVector(pos.position_xyz[1], pos.position_xyz[2], pos.position_xyz[3])
    bottomVertexs:Add(uePos)
    upVertexs:Add(uePos + offset)
  end
  for i = 1, bottomVertexs:Length() do
    local curConvex = UE4.TArray(UE4.FVector)
    if i < bottomVertexs:Length() then
      curConvex:Add(bottomVertexs:Get(i))
      curConvex:Add(bottomVertexs:Get(i + 1))
      curConvex:Add(upVertexs:Get(i))
      curConvex:Add(upVertexs:Get(i + 1))
    else
      curConvex:Add(bottomVertexs:Get(i))
      curConvex:Add(bottomVertexs:Get(1))
      curConvex:Add(upVertexs:Get(i))
      curConvex:Add(upVertexs:Get(1))
    end
    self.ProceduralMesh:AddCollisionConvexMesh(curConvex)
  end
end

function GrassRegionTrigger_C:TestInitCollision()
  local triAngle = UE4.TArray(0)
  triAngle:Add(0)
  triAngle:Add(1)
  triAngle:Add(2)
  triAngle:Add(0)
  triAngle:Add(2)
  triAngle:Add(3)
  for i = 1, triAngle:Length() do
    print(string.format("Triangle %f", triAngle:Get(i)))
  end
  local edgeLen = 400
  local halfEdgeLen = edgeLen * 0.5
  local curConvex1 = UE4.TArray(UE4.FVector)
  curConvex1:Add(UE4.FVector(0, 0, 0))
  curConvex1:Add(UE4.FVector(0, 0, 100))
  curConvex1:Add(UE4.FVector(0, edgeLen, 100))
  curConvex1:Add(UE4.FVector(0, edgeLen, 0))
  self.ProceduralMesh:CreateMeshSection_LinearColor(0, curConvex1, triAngle)
  local curConvex5 = UE4.TArray(UE4.FVector)
  curConvex5:Add(UE4.FVector(0, edgeLen, 0))
  curConvex5:Add(UE4.FVector(0, edgeLen, 100))
  curConvex5:Add(UE4.FVector(halfEdgeLen, halfEdgeLen, 100))
  curConvex5:Add(UE4.FVector(halfEdgeLen, halfEdgeLen, 0))
  self.ProceduralMesh:CreateMeshSection_LinearColor(1, curConvex5, triAngle)
  local curConvex6 = UE4.TArray(UE4.FVector)
  curConvex6:Add(UE4.FVector(halfEdgeLen, halfEdgeLen, 0))
  curConvex6:Add(UE4.FVector(halfEdgeLen, halfEdgeLen, 100))
  curConvex6:Add(UE4.FVector(edgeLen, edgeLen, 100))
  curConvex6:Add(UE4.FVector(edgeLen, edgeLen, 0))
  self.ProceduralMesh:CreateMeshSection_LinearColor(2, curConvex6, triAngle)
  local curConvex3 = UE4.TArray(UE4.FVector)
  curConvex3:Add(UE4.FVector(edgeLen, edgeLen, 0))
  curConvex3:Add(UE4.FVector(edgeLen, edgeLen, 100))
  curConvex3:Add(UE4.FVector(edgeLen, 0, 100))
  curConvex3:Add(UE4.FVector(edgeLen, 0, 0))
  self.ProceduralMesh:CreateMeshSection_LinearColor(3, curConvex3, triAngle)
  local curConvex4 = UE4.TArray(UE4.FVector)
  curConvex4:Add(UE4.FVector(edgeLen, 0, 0))
  curConvex4:Add(UE4.FVector(edgeLen, 0, 100))
  curConvex4:Add(UE4.FVector(0, 0, 100))
  curConvex4:Add(UE4.FVector(0, 0, 0))
  self.ProceduralMesh:CreateMeshSection_LinearColor(4, curConvex4, triAngle)
end

function GrassRegionTrigger_C:ReceiveActorBeginOverlap(OtherActor)
  local player = OtherActor.sceneCharacter
  if player and player.isLocal then
    player.CrouchComponent:AddOverlappedGrass(self)
  end
end

function GrassRegionTrigger_C:ReceiveActorEndOverlap(OtherActor)
  local player = OtherActor.sceneCharacter
  if player and player.isLocal then
    player.CrouchComponent:OnExitGrass()
    player.CrouchComponent:RemoveOverlappedGrass(self)
  end
end

return GrassRegionTrigger_C
