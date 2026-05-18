local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local NightmareNSPath = "NiagaraSystem'/Game/ArtRes/Effects/Particle/Scene/BossBattle/NMBoss/NS_Scene_NSBoss_PM.NS_Scene_NSBoss_PM'"
local DefaultVisualMaterialPath = "/Game/ArtRes/Effects/Texture/Noise/Material/MI_Noise_ZY_014_A.MI_Noise_ZY_014_A"
local DefaultDebugBlockMaterial = "/Game/ArtRes/Temp/RegionEditorTest/M_RegionLineColor.M_RegionLineColor"
local AirWallModule = NRCModuleBase:Extend("AirWallModule")

function AirWallModule:OnConstruct()
  _G.AirWallModuleCmd = reload("NewRoco.Modules.System.AirWall.AirWallModuleCmd")
  self.MapLoading = false
  self.AirWalls = {}
  self.ServerWall = {}
  self.AirWallsRef = {}
  self.VisualWalls = {}
end

function AirWallModule:OnActive()
  _G.NRCEventCenter:RegisterEvent(self.name, self, _G.SceneEvent.LoadMapStart, self.LoadMapStart)
  _G.NRCEventCenter:RegisterEvent(self.name, self, _G.SceneEvent.LoadMapFinish, self.OnMapLoaded)
  _G.NRCEventCenter:RegisterEvent(self.name, self, _G.SceneEvent.OnEnterSceneFinishNtyAckEnd, self.OnEnterSceneFinish)
end

function AirWallModule:GetPlayer()
  local Player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  return Player
end

function AirWallModule:GetPlayerAirWall()
  local Player = self:GetPlayer()
  if not Player then
    return
  end
  local ServerData = Player.serverData
  if not ServerData then
    return
  end
  local AirWall = ServerData.air_wall
  if not AirWall then
    return
  end
  local Info = AirWall.air_wall_info
  if Info then
    return Info.air_wall_ids
  end
end

function AirWallModule:OnEnterSceneFinish(notify, isReconnecting, isEnteringCell, preMapId, mapID)
  local Walls = self:GetPlayerAirWall()
  if Walls then
    self:CreateOrDestroyWalls(Walls)
  end
end

function AirWallModule:OnServerAirWallChange(action)
  local AirWallIDs = self:GetPlayerAirWall()
  if action.add_list then
    for _, ID in ipairs(action.add_list) do
      if not table.contains(AirWallIDs, ID) then
        table.insert(AirWallIDs, ID)
      end
    end
  end
  if action.sub_list then
    for _, ID in ipairs(action.sub_list) do
      if table.contains(AirWallIDs, ID) then
        table.removeValue(AirWallIDs, ID)
      end
    end
  end
  self:CreateOrDestroyWalls(AirWallIDs)
end

function AirWallModule:CreateOrDestroyWalls(IDs)
  if not IDs then
    return
  end
  for ID, _ in pairs(self.AirWalls) do
    if self.ServerWall[ID] and not table.contains(IDs, ID) then
      self:OnDestroyWall(ID, false)
      self.ServerWall[ID] = false
    end
  end
  for _, ID in ipairs(IDs) do
    if not self.AirWalls[ID] then
      self:OnCreateWall(ID, false)
      self.ServerWall[ID] = true
    end
  end
end

function AirWallModule:LoadMapStart(SameScene)
  if SameScene then
    return
  end
  self.MapLoading = true
  self:DestroyAll()
  self:ClearVisualWalls()
end

function AirWallModule:OnMapLoaded()
  self.MapLoading = false
  local SceneID = SceneUtils.GetSceneID()
  local SceneConf = _G.DataConfigManager:GetSceneConf(SceneID)
  if not SceneConf then
    return
  end
  if SceneConf.block_ids and #SceneConf.block_ids > 0 then
    for _, ID in ipairs(SceneConf.block_ids) do
      self:OnCreateWall(ID, false)
    end
  end
end

function AirWallModule:OnCreateWall(ID, bNightmare)
  if self.MapLoading then
    Log.Debug("\229\156\186\230\153\175\229\136\135\230\141\162\228\184\173..........\231\169\186\230\176\148\229\162\153\228\184\141\231\159\165\233\129\147\232\175\165\228\184\141\232\175\165\229\136\155\229\187\186")
  end
  if not ID or 0 == ID then
    return
  end
  Log.Debug("AirWallModule:OnCreateWall", ID, bNightmare)
  local AirWallActor = self.AirWalls[ID]
  if AirWallActor then
    if bNightmare then
      AirWallActor.bNightmare = bNightmare
    end
    Log.Debug("\233\135\141\229\164\141\229\136\155\229\187\186\231\169\186\230\176\148\229\162\153", ID, bNightmare)
    return
  end
  self.AirWalls[ID] = nil
  self.AirWallsRef[ID] = nil
  if AirWallActor then
    AirWallActor:K2_DestroyActor()
  end
  AirWallActor = nil
  local BlockConf = _G.DataConfigManager:GetBlockConf(ID)
  if not BlockConf then
    Log.Error("\230\159\165\230\137\190\228\184\141\229\136\176\231\169\186\230\176\148\229\162\153\233\133\141\231\189\174\239\188\140\232\175\183\230\163\128\230\159\165BLOCK_CONF", ID)
    return
  end
  if 0 == #BlockConf.spline_point then
    Log.Error("\231\169\186\230\176\148\229\162\153\233\133\141\231\189\174\233\135\140\233\157\162\230\178\161\230\156\137Spline\230\155\178\231\186\191\230\149\176\230\141\174\239\188\140\232\175\183\230\163\128\230\159\165BLOCK_CONF", ID)
    return
  end
  local Klass = _G.NRCBigWorldPreloader:Get("AirWall")
  if not Klass then
    Log.Error("AirWall Preload Failed... \231\169\186\230\176\148\229\162\153\233\162\132\229\138\160\232\189\189\230\156\137\233\151\174\233\162\152\239\188\140\232\175\183\230\163\128\230\159\165\233\162\132\229\138\160\232\189\189\230\151\182\229\186\143")
    return
  end
  local World = _G.UE4Helper.GetCurrentWorld()
  local Pos = UE.FVector(BlockConf.position[1], BlockConf.position[2], BlockConf.position[3])
  local Scale = UE.FVector(BlockConf.scale[1], BlockConf.scale[2], BlockConf.scale[3])
  local Rot = UE.FRotator(BlockConf.rotation[2], BlockConf.rotation[3], BlockConf.rotation[1])
  local Transform = UE.FTransform(Rot:ToQuat(), Pos, Scale)
  local Always = UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn
  local AirWall = World:Abs_SpawnActor(Klass, Transform, Always, nil, nil, nil, BlockConf)
  if AirWall and UE4.UObject.IsValid(AirWall) then
    if RocoEnv.IS_EDITOR then
      AirWall:SetActorLabelNoFlush(string.format("Airwall_%d", ID), false)
    end
    AirWall.bNightmare = bNightmare
    self.AirWalls[ID] = AirWall
    self.AirWallsRef[ID] = UnLua.Ref(AirWall)
    if bNightmare then
      local NightmareNSComponent = AirWall:AddComponentByClass(UE.UNRCNiagaraSystemComponent, false, UE.FTransform(), true)
      if NightmareNSComponent and UE4.UObject.IsValid(NightmareNSComponent) then
        NightmareNSComponent:SetAutoActivate(true)
        NightmareNSComponent:SetAbsolute(false, false, true)
        NightmareNSComponent:SetPath(NightmareNSPath)
        AirWall:FinishAddComponent(NightmareNSComponent, true, UE.FTransform())
        NightmareNSComponent:K2_AttachToComponent(AirWall.RootComponent, "", UE.EAttachmentRule.KeepWorld, UE.EAttachmentRule.KeepWorld, UE.EAttachmentRule.KeepWorld, false)
      end
    end
  end
end

function AirWallModule:OnDestroyWall(ID, bNightmare)
  if not ID then
    Log.Error("Try to destroy wall with nil ID!!!")
    return
  end
  Log.Debug("AirWallModule:OnDestroyWall", ID, bNightmare)
  local AirWallActor = self.AirWalls[ID]
  if AirWallActor then
    if AirWallActor.bNightmare and not bNightmare then
      return
    end
    AirWallActor:K2_DestroyActor()
  end
  self.AirWalls[ID] = nil
  self.AirWallsRef[ID] = nil
  AirWallActor = nil
end

function AirWallModule:DestroyAll()
  self:Log("destroy all air walls")
  for _, Actor in pairs(self.AirWalls) do
    if Actor then
      Actor:K2_DestroyActor()
    end
  end
  table.clear(self.AirWalls)
  table.clear(self.AirWallsRef)
end

function AirWallModule:GetAirWall(AirWallID)
  return self.AirWalls[AirWallID]
end

function AirWallModule:OnRelogin()
end

function AirWallModule:OnDeactive()
  _G.NRCEventCenter:UnRegisterEvent(self, _G.SceneEvent.LoadMapStart, self.LoadMapStart)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.SceneEvent.LoadMapFinish, self.OnMapLoaded)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.SceneEvent.OnEnterSceneFinishNtyAckEnd, self.OnEnterSceneFinish)
end

function AirWallModule:OnDestruct()
  self:DestroyAll()
end

function AirWallModule:DisplayVisualWall(areaID, material, extent, bIncludeEmpty)
  if nil == material then
    material = DefaultVisualMaterialPath
  end
  if type(material) == "string" then
    local function onLoadSuccess(caller, req, asset)
      local material = asset
      
      self:DisplayVisualWallInternal(areaID, material, extent, bIncludeEmpty)
    end
    
    local function onLoadFailed(req, message)
      Log.Warning("material Load Failed", material, message)
      self:DisplayVisualWallInternal(areaID, nil, extent, bIncludeEmpty)
    end
    
    _G.NRCResourceManager:LoadResAsync(self, material, 1, 0, onLoadSuccess, onLoadFailed, nil)
    return
  end
  self:DisplayVisualWallInternal(areaID, material, extent, bIncludeEmpty)
end

function AirWallModule:DisplayVisualWallInternal(areaID, material, extent, bIncludeEmpty)
  if nil == areaID then
    return
  end
  local AirWallActors = self.VisualWalls[areaID]
  if nil ~= AirWallActors then
    for _, wall in pairs(AirWallActors) do
      wall:SetActorHiddenInGame(false)
    end
    return
  end
  local AreaConf = _G.DataConfigManager:GetAreaConf(areaID)
  if not AreaConf then
    Log.Error("\230\159\165\230\137\190\228\184\141\229\136\176AreaConf", areaID)
    return
  end
  if AreaConf.area_type ~= Enum.AreaType.AREAT_POLYGON then
    Log.Error("area_type\228\184\141\230\152\175AREAT_POLYGON", areaID)
    return
  end
  
  local function getPoints(positions)
    local points = UE4.TArray(UE4.FVector)
    for _, pos in pairs(positions) do
      local pos_xyz = pos.position_xyz
      local point = UE4.FVector(pos_xyz[1], pos_xyz[2], pos_xyz[3])
      points:Add(point)
    end
    return points
  end
  
  if nil == extent then
    extent = 1000.0
  end
  local world = _G.UE4Helper.GetCurrentWorld()
  local wall = UE4.UAirWallStatics.BuildVisualWall(world, getPoints(AreaConf.pos), material, extent)
  if nil ~= wall and UE4.UObject.IsValid(wall) == true then
    local walls = {}
    table.insert(walls, wall)
    if RocoEnv.IS_EDITOR then
      wall:SetActorLabelNoFlush(string.format("VisualWall_%d", areaID), false)
    end
    if true == bIncludeEmpty then
      local emptyWall = UE4.UAirWallStatics.BuildVisualWall(world, getPoints(AreaConf.pos_empty), material, extent)
      if nil ~= emptyWall and UE4.UObject.IsValid(emptyWall) == true then
        if RocoEnv.IS_EDITOR then
          emptyWall:SetActorLabelNoFlush(string.format("VisualWall_%d_Empty", areaID), false)
        end
        table.insert(walls, emptyWall)
      end
    end
    self.VisualWalls[areaID] = walls
  end
end

function AirWallModule:HideVisualWall(areaID)
  if nil == areaID then
    return
  end
  local walls = self.VisualWalls[areaID]
  if nil == walls then
    return
  end
  for _, wall in pairs(walls) do
    wall:SetActorHiddenInGame(true)
  end
end

function AirWallModule:DeleteVisualWall(areaID)
  if nil == areaID then
    return
  end
  local walls = self.VisualWalls[areaID]
  if nil == walls then
    return
  end
  for _, wall in pairs(walls) do
    wall:K2_DestroyActor()
  end
  table.removeKey(self.VisualWalls, areaID)
end

function AirWallModule:ClearVisualWalls()
  for _, walls in pairs(self.VisualWalls) do
    for _, wall in pairs(walls) do
      wall:K2_DestroyActor()
    end
  end
  table.clear(self.VisualWalls)
end

function AirWallModule:CreateDebugBlock(blockID, label, color, extent)
  if nil == blockID then
    return nil
  end
  local BlockConf = _G.DataConfigManager:GetBlockConf(blockID)
  if BlockConf then
    local centerX = BlockConf.position[1]
    local centerY = BlockConf.position[2]
    
    local function getPoints(positions)
      local points = UE4.TArray(UE4.FVector)
      for _, pos in pairs(positions) do
        local pos_xyz = pos.Position
        local point = UE4.FVector(pos_xyz[1] + centerX, pos_xyz[2] + centerY, pos_xyz[3])
        points:Add(point)
      end
      return points
    end
    
    local world = _G.UE4Helper.GetCurrentWorld()
    local template = LoadObject(DefaultDebugBlockMaterial)
    local mat = UE4.UKismetMaterialLibrary.CreateDynamicMaterialInstance(world, template)
    if mat then
      if nil == color then
        color = UE.FLinearColor(1, 0, 0, 0.2)
      end
      mat:SetVectorParameterValue("Color", color)
    end
    if nil == extent then
      extent = BlockConf.block_up_height
    end
    local wall = UE4.UAirWallStatics.BuildVisualWall(world, getPoints(BlockConf.spline_point), mat, extent)
    if nil ~= wall and UE4.UObject.IsValid(wall) == true and RocoEnv.IS_EDITOR then
      if nil == label then
        label = "Block"
      end
      wall:SetActorLabelNoFlush(string.format("%s-%d", label, blockID), false)
    end
    local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    if localPlayer then
      local playerLocation = localPlayer:GetActorLocation()
      local wallLocation = wall:Abs_K2_GetActorLocation()
      wallLocation.Z = playerLocation.Z
      wall:Abs_K2_SetActorLocation(wallLocation, true, nil, true)
    end
    return wall
  end
  return nil
end

return AirWallModule
