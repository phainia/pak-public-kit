local JsonUtils = require("Common.JsonUtils")
local DebugTabPlayerCamera = require("NewRoco.Modules.System.Debug.Tabs.DebugTabPlayerCamera")
local CachePsoAutomation = {}
local configFileName = "CachePSO"
local RotateSpeed = 360
local SwitchInterval = 4

function CachePsoAutomation:Reset()
  if self.cacheAssetList == nil then
    self:InitAssetList()
  end
  self.spawnNiagara = false
  self.currentAssetIndex = 1
  self.player = nil
  self.assetActors = {}
  self.rows = 2
  self.cols = 3
  self.spacing = 200
  self.scaleFix = 0.5
end

function CachePsoAutomation:generate_point_grid(centerX, centerY, rows, cols, spacing)
  local grid = {}
  local startX = centerX - (cols - 1) * spacing / 2
  local startY = centerY - (rows - 1) * spacing / 2
  for i = 1, rows do
    for j = 1, cols do
      local x = startX + (j - 1) * spacing
      local y = startY + (i - 1) * spacing
      table.insert(grid, {x = x, y = y})
    end
  end
  return grid
end

function CachePsoAutomation:InitAssetList()
  local config = JsonUtils.LoadSaved(configFileName)
  if not config then
    Log.Error("Failed to load CachePSO config file")
    return
  end
  self.cacheAssetList = {}
  self.cacheAssetList = config.AssetList
end

function CachePsoAutomation:InitActors()
  self.player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not self.player then
    Log.Error("Failed to get local player")
    return
  end
  self.player:SetViewVisible(false, true)
  self.player.ueController.PlayerCameraManager.bEnableMainUICamera = true
  local playerLocation = self.player:GetActorLocation()
  local relativeTransform = self.player.viewObj.Mesh:GetRelativeTransform()
  local grids = self:generate_point_grid(playerLocation.x, playerLocation.y, self.rows, self.cols, self.spacing)
  for _, grid in ipairs(grids) do
    local offset = UE4.FVector(grid.x, grid.y, relativeTransform.Translation.z + playerLocation.z)
    local offsetTransform = UE4.FTransform(UE4.FQuat(), offset, UE4.FVector(1, 1, 1))
    local actor = self.player.viewObj:GetWorld():Abs_SpawnActor(self.spawnNiagara and UE4.ANiagaraActor or UE4.AStaticMeshActor, offsetTransform, UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn)
    if self.spawnNiagara then
      local niagaraComponent = actor:GetComponentByClass(UE4.UNiagaraComponent)
      niagaraComponent:SetCollisionEnabled(UE.ECollisionEnabled.NoCollision)
    else
      local meshComponent = actor:GetComponentByClass(UE4.UStaticMeshComponent)
      meshComponent:SetMobility(UE4.EComponentMobility.Movable)
      meshComponent:SetCollisionEnabled(UE.ECollisionEnabled.NoCollision)
    end
    table.insert(self.assetActors, actor)
  end
end

function CachePsoAutomation:ProcessAsset()
  if self.currentAssetIndex == #self.cacheAssetList + 1 then
    self:OnProcessEnd()
    return
  end
  local maxLodNum = 0
  Log.Debug(string.format("[PSO] \229\189\147\229\137\141\232\191\155\229\186\166 \227\128\144%d/%d\227\128\145", self.currentAssetIndex, #self.cacheAssetList))
  for _, actor in ipairs(self.assetActors) do
    if self.currentAssetIndex == #self.cacheAssetList + 1 then
      break
    end
    local res = self.cacheAssetList[self.currentAssetIndex]
    self.currentAssetIndex = self.currentAssetIndex + 1
    if self.spawnNiagara then
      local niagaraSystem = LoadObject(res)
      if niagaraSystem then
        Log.Info("[PSO] Load res: " .. res)
        local niagaraComponent = actor:GetComponentByClass(UE4.UNiagaraComponent)
        niagaraComponent:SetAsset(niagaraSystem)
        niagaraComponent:SetAutoDestroy(false)
        niagaraComponent:SetCollisionEnabled(UE.ECollisionEnabled.NoCollision)
      else
        Log.Warning("[PSO] Failed to load res: " .. res)
      end
    else
      local meshObject = LoadObject(res)
      if meshObject then
        Log.Info("[PSO] Load res: " .. res)
        local meshComponent = actor:GetComponentByClass(UE4.UStaticMeshComponent)
        meshComponent:SetStaticMesh(meshObject)
        meshComponent:SetCollisionEnabled(UE.ECollisionEnabled.NoCollision)
        local origin = UE4.FVector(0, 0, 0)
        local static_mesh_extent = UE4.FVector(0, 0, 0)
        local player_mesh_extent = UE4.FVector(0, 0, 0)
        local radius = 0
        actor:SetActorScale3D(UE4.FVector(1, 1, 1))
        UE4.UKismetSystemLibrary.GetComponentBounds(meshComponent, origin, static_mesh_extent, radius)
        UE4.UKismetSystemLibrary.GetComponentBounds(self.player.viewObj.Mesh, origin, player_mesh_extent, radius)
        actor:SetActorScale3D(UE4.FVector(self.scaleFix * player_mesh_extent.x / static_mesh_extent.x, self.scaleFix * player_mesh_extent.y / static_mesh_extent.y, self.scaleFix * player_mesh_extent.z / static_mesh_extent.z))
        local lodNum = meshObject:GetNumBasePassLODs()
        if maxLodNum < lodNum then
          maxLodNum = lodNum
        end
      else
        Log.Warning("[PSO] Failed to load res: " .. res)
      end
    end
  end
  if not self.spawnNiagara and 0 ~= maxLodNum then
    local SwitchLodInterval = SwitchInterval / maxLodNum
    for i = 0, maxLodNum - 1 do
      _G.DelayManager:DelaySeconds(SwitchLodInterval * i, function()
        UE4.UKismetSystemLibrary.ExecuteConsoleCommand(UE4Helper.GetCurrentWorld(), string.format("r.ForceLOD %d", i))
      end)
    end
  end
  _G.DelayManager:DelaySeconds(SwitchInterval, function()
    self:ProcessAsset()
  end)
end

function CachePsoAutomation:Start(bSpawnNiagara)
  self:Reset()
  self.spawnNiagara = bSpawnNiagara
  _G.UpdateManager:Register(self)
  DebugTabPlayerCamera:SwitchCustomCamera(nil, nil)
  self:InitActors()
  local CameraInstance = self.player.ueController.PlayerCameraManager:GetCameraAnimInstance()
  CameraInstance.GM_CameraOffset_X = -2000
  self:ProcessAsset()
end

function CachePsoAutomation:OnProcessEnd()
  DebugTabPlayerCamera:SwitchCustomCamera(nil, nil)
  _G.UpdateManager:UnRegister(self)
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(UE4Helper.GetCurrentWorld(), "r.ForceLOD -1")
end

function CachePsoAutomation:OnTick(dt)
  if self.assetActors then
    if not self.player then
      return
    end
    self.player.ueController.Pawn:AddControllerYawInput(dt * 90)
  else
    for i, actor in ipairs(self.assetActors) do
      local Rot = UE4.FRotator(0, dt * RotateSpeed, 0)
      local hit = UE.FHitResult()
      actor:K2_AddActorWorldRotation(Rot, false, hit, false)
    end
  end
end

return CachePsoAutomation
