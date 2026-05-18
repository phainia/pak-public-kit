local PetMutationUtils = require("NewRoco.Utils.PetMutationUtils")
PSOPetTest = {}

function PSOPetTest:InitPlayer(enable)
  self.player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not self.player or not self.player.ueController then
    Log.Error("Failed to get local player")
    return
  end
  self.player:SetViewVisible(true, true)
  self.player.ueController.PlayerCameraManager.bEnableMainUICamera = true
  self.StartRunPos = self.player:GetActorLocation()
end

function PSOPetTest:DisableOcclusion()
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(UE4Helper.GetCurrentWorld(), "r.AllowPrecomputedVisibility 0")
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(UE4Helper.GetCurrentWorld(), "r.Mobile.AllowSoftwareOcclusion 1")
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(UE4Helper.GetCurrentWorld(), "r.Mobile.AllowSDOC 0")
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(UE4Helper.GetCurrentWorld(), "r.HZBOcclusion 0")
end

function PSOPetTest:generate_point_grid(start_pos, forward, right, up, rows, cols, distance, spacing)
  local grid = {}
  local center = start_pos + forward * distance
  for row = 1, rows do
    for col = 1, cols do
      local x_offset = (col - (cols + 1) * 0.5) * spacing
      local y_offset = (row - (rows + 1) * 0.5) * spacing
      local tempPos = center + right * x_offset + forward * y_offset
      table.insert(grid, tempPos)
    end
  end
  return grid
end

function PSOPetTest:LoadBigworldLevel(level_path, postLoaded_callback)
  NRCEventCenter:RegisterEvent("LoadBigWorldLevel", self, NRCGlobalEvent.PostLoadMapWithWorld, postLoaded_callback)
  NRCModeManager:ActiveMode("LocalMode")
  NRCModuleManager:DoCmd(PlayerModuleCmd.CLEAR_ALL)
  self.player = nil
  LevelHelper:OpenLevel(level_path)
  _G.NRCModeManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 1)
  Log.Debug("PSOPetTest:LoadBigworldLevel: OpenLevel ", level_path)
end

local EmptyLevl = "/Game/ArtRes/Level/Performance/BigWorldEnvForPetTest"

function PSOPetTest:Scan_PetColorful()
  local suffixes = {"by"}
  for idx = 0, 9 do
    table.insert(suffixes, string.format("by%d", idx))
  end
  self.MutationType = suffixes
  self.Callback = self.GlassySwitch
  self:LoadBigworldLevel(EmptyLevl, self.OnPostLoadPetLevel)
end

function PSOPetTest:Scan_PetShining()
  self.MutationType = _G.Enum.MutationDiffType.MDT_SHINING
  self.Callback = self.DoMutation
  self:LoadBigworldLevel(EmptyLevl, self.OnPostLoadPetLevel)
end

function PSOPetTest:Scan_PetGlass()
  self.MutationType = _G.Enum.MutationDiffType.MDT_GLASS
  self.Callback = self.DoMutation
  self:LoadBigworldLevel(EmptyLevl, self.OnPostLoadPetLevel)
end

function PSOPetTest:Scan_PetChaos()
  self.MutationType = _G.Enum.MutationDiffType.MDT_CHAOS
  self.Callback = self.DoMutation
  self:LoadBigworldLevel(EmptyLevl, self.OnPostLoadPetLevel)
end

function PSOPetTest:Scan_PetChaos2()
  self.MutationType = _G.Enum.MutationDiffType.MDT_CHAOS_TWO
  self.Callback = self.DoMutation
  self:LoadBigworldLevel(EmptyLevl, self.OnPostLoadPetLevel)
end

function PSOPetTest:OnPostLoadPetLevel()
  NRCEventCenter:UnRegisterEvent(self, NRCGlobalEvent.PostLoadMapWithWorld, self.OnPostLoadPetLevel)
  _G.DelayManager:DelaySeconds(3, function()
    self:InitPlayer(true)
    self:GeneratePets(true)
  end)
end

function PSOPetTest:GeneratePets(Confirm)
  if not Confirm then
    return
  end
  local ListOfAssets = UE.TArray("")
  UE.UNRCStatics.ListFolder("/Game/ArtRes/BP/Pets", ListOfAssets, true)
  local AllBP = {}
  if false then
    table.insert(AllBP, "/Game/ArtRes/BP/Pets/Com_SongShu1_001/BP_Com_SongShu1_001.BP_Com_SongShu1_001")
  else
    for _, Path in tpairs(ListOfAssets) do
      local Segs = string.split(Path, "/")
      if 7 == #Segs and string.StartsWith(Segs[7], "BP_") and "/Game/ArtRes/BP/Pets/Fir_HuoYu3_001/BP_NewRide_HuoYu.BP_NewRide_HuoYu" ~= Path then
        table.insert(AllBP, Path)
      end
    end
  end
  self.Pets = {}
  local rows = 1
  local cols = 5
  local spacing = 180
  local distance = 50
  local viewObj = self.player.viewObj
  local playerLocation = viewObj:Abs_K2_GetActorLocation()
  local forward = viewObj:GetActorForwardVector()
  local right = viewObj:GetActorRightVector()
  local up = viewObj:GetActorUpVector()
  self.grids = self:generate_point_grid(playerLocation, forward, right, up, rows, cols, distance, spacing)
  self.max_grid_id = rows * cols
  self.half_grid_id = math.floor(self.max_grid_id * 0.5)
  self.cur_grid_id = 1
  self.player:SetViewVisible(false, true)
  Log.Warning("PSOPetTest: Total Pets: ", #AllBP)
  self:SpawnPet(AllBP, 1, playerLocation, 0)
end

function PSOPetTest:SpawnPet(All, Index, Center, Angle)
  if Index <= 0 then
    return
  end
  if Index > #All then
    return
  end
  local Radius = 200 + Index * 20
  Angle = Angle + 500 / Radius / math.pi
  local Klass = _G.NRCResourceManager:LoadForDebugOnly(All[Index])
  local suffixes = {"by"}
  for idx = 0, 9 do
    table.insert(suffixes, string.format("by%d", idx))
  end
  if Klass then
    local DX = Radius * math.cos(Angle)
    local DY = Radius * math.sin(Angle)
    local Transform = UE4.FTransform(UE4.FQuat(), UE.FVector(Center.X + DX, Center.Y + DY, Center.Z + 500))
    local World = _G.UE4Helper.GetCurrentWorld()
    local Actor = World:SpawnActor(Klass, Transform, UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn, nil, nil)
    local grid_id = (Index - 1) % self.max_grid_id + 1
    if #self.Pets > 0 and self.Pets[grid_id] ~= nil then
      local prevActor = self.Pets[grid_id]
      prevActor:SetActorHiddenInGame(true)
      Log.DebugFormat("PSOPetTest: RemovePet[%d-%d]: %s", grid_id, Index, prevActor:GetName())
      prevActor:K2_DestroyActor()
      self.Pets[grid_id] = nil
    end
    local actor_pos = self.grids[grid_id]
    Actor:Abs_K2_SetActorLocation_WithoutHit(UE.FVector(actor_pos.X, actor_pos.Y, actor_pos.Z + 100))
    if Actor and Actor.InitOutSceneAsync then
      Actor:InitOutSceneAsync(self, function()
        self:Callback(Actor, self.MutationType)
      end)
      local Root = Actor:K2_GetRootComponent()
      Root.bHiddenInGame = false
      Actor:SetActorEnableCollision(false)
      local Location = Actor:GetNearLandLocation()
      if not Location then
        Log.Error("\231\148\159\230\136\144\229\174\160\231\137\169\228\184\173\230\150\173\228\186\134!!")
        _G.DelayManager:DelaySeconds(1, self.SpawnPet, self, All, Index + 1, Center, Angle)
        return
      end
      Location.Z = Location.Z + Actor:GetHalfHeight()
      Actor:SetActorLocation(Location)
      local LookAt = Center - Location
      LookAt.Z = 0
      Actor:K2_SetActorRotation(LookAt:ToRotator():Clamp(), true)
      self.Pets[grid_id] = Actor
    else
      Log.Error("Actor\231\148\159\230\136\144\229\164\177\232\180\165", All[Index])
    end
  else
    Log.Error("Class\229\138\160\232\189\189\229\164\177\232\180\165", All[Index])
  end
  if Index + 1 >= #All then
    self:InitPlayer(true)
    Log.Error("\229\174\140\230\136\144\230\137\128\230\156\137\231\154\132\229\174\160\231\137\169\231\148\159\230\136\144", Index)
    return
  end
  _G.DelayManager:DelaySeconds(1, self.SpawnPet, self, All, Index + 1, Center, Angle)
end

function PSOPetTest:DoMutation(Character, MutationDiffType)
  Log.Warning("DoMutation: ", MutationDiffType)
  PetMutationUtils.DoMutationForTest(Character, MutationDiffType)
end

function PSOPetTest:GlassySwitch(Character, suffixes)
  local shineColorInfo = {}
  shineColorInfo.particle = 3
  local particle
  particle = PetMutationUtils.GetShineParticle(shineColorInfo.particle)
  local mesh = Character.mesh
  local materials = Character.RocoMaterial:GetMaterialsBySuffixesAsMID(mesh, suffixes)
  for _, mat in tpairs(materials) do
    if mat then
      mat:SetSwitchParameterValue("GlassySwitch", true, mesh, false)
      local colorA = UE.FLinearColor(0, 0, 1, 0.6)
      if nil ~= colorA then
        mat:SetVectorParameterValue("RedChannel", colorA)
      end
      if nil ~= particle then
        mat:SetTextureParameterValue("StarStickTex", particle)
      end
      mat:SetVectorParameterValue("MutationRimColor", UE.FLinearColor(1, 1, 1, 0.6))
      for _, additionalMat in tpairs(mat.AdditionalMaterials) do
        if UE4.UObject.IsValid(additionalMat) then
          additionalMat:SetSwitchParameterValue("GlassySwitch", true, mesh, false)
          if nil ~= colorA then
            additionalMat:SetVectorParameterValue("RedChannel", colorA)
          end
        end
      end
    end
  end
end

return PSOPetTest
