local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local DebugTabScenePublic = require("NewRoco.Modules.System.Debug.Tabs.DebugTabScenePublic")
PSONPCTest = {}
local EmptyLevl = "/Game/ArtRes/Level/Performance/BigWorldEnvForPetTest"

function PSONPCTest:GenarateGrid()
  local rows = 1
  local cols = 5
  local spacing = 160
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
  self.playerLocation = playerLocation
end

function PSONPCTest:generate_point_grid(start_pos, forward, right, up, rows, cols, distance, spacing)
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

function PSONPCTest:InitPlayer(enable)
  self.player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not self.player or not self.player.ueController then
    Log.Error("Failed to get local player")
    return
  end
  self.playerHalfHeight = self.player:GetHalfHeight()
  self.player:SetViewVisible(true, true)
  self.player.ueController.PlayerCameraManager.bEnableMainUICamera = true
  self.StartRunPos = self.player:GetActorLocation()
end

function PSONPCTest:Init()
  self.Npcs = {}
  self.NpcModels = {}
  self.NpcIds = {}
  _G.UpdateManager:Register(self)
  self:LoadLevel(EmptyLevl, self.OnPostLoadLevel)
end

function PSONPCTest:LoadLevel(level_path, postLoaded_callback)
  NRCEventCenter:RegisterEvent("LoadEmptyLevel", self, NRCGlobalEvent.PostLoadMapWithWorld, postLoaded_callback)
  NRCModeManager:ActiveMode("LocalMode")
  NRCModuleManager:DoCmd(PlayerModuleCmd.CLEAR_ALL)
  self.player = nil
  LevelHelper:OpenLevel(level_path)
  _G.NRCModeManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 1)
  Log.Debug("PSONPCTest:LoadEmptyLevel: OpenLevel ", level_path)
end

function PSONPCTest:OnPostLoadLevel()
  NRCEventCenter:UnRegisterEvent(self, NRCGlobalEvent.PostLoadMapWithWorld, self.OnPostLoadLevel)
  _G.DelayManager:DelaySeconds(3, function()
    self:InitPlayer(true)
    DebugTabScenePublic:GhostMode()
    self:GenarateGrid()
    self:ScanConf()
  end)
end

function PSONPCTest:ScanConf()
  local Confs = _G.DataConfigManager:GetAllByName("NPC_CONF")
  local Models = {}
  local blacklist = {}
  local invalidActor = {
    "BP_NPCBloodItem",
    "BP_NPCStone.BP_NPCStone_C",
    "BP_Battle_",
    "BP_ShelterBush",
    "BP_CompassHalo",
    "BP_Scene_Ripple_01",
    "BP_Gho_YeMo3_001",
    "BP_DuoduoFantansy_MaomaoBP",
    "BP_NPCELFAltar",
    "BP_NPCLandAltar",
    "BP_NPCMiNiGame_",
    "BP_NPC_Block",
    "BP_NPCCampBonfireBase",
    "BP_NPCParticle",
    "BP_NPCItemStar",
    "BP_NPCSM_StlmtUn_barrels_FANGSHUIKOU",
    "BP_LearnMagic_Ruin",
    "BP_BossSkill_HKFH_ChongZhenZD"
  }
  for k, conf in pairs(Confs) do
    local NPC_CONF = conf
    local model_Cfg_id = NPC_CONF.model_conf
    if model_Cfg_id and 0 ~= model_Cfg_id then
      local modelConf = _G.DataConfigManager:GetModelConf(model_Cfg_id)
      if modelConf then
        if Models[modelConf.path] == nil then
          local Segs = string.split(modelConf.path, "/")
          local isValid = true
          for _, actor in ipairs(invalidActor) do
            if string.StartsWith(Segs[#Segs], actor) then
              blacklist[modelConf.path] = conf
              isValid = false
              break
            end
          end
          if isValid then
            Models[modelConf.path] = conf
            table.insert(self.NpcModels, modelConf.path)
            table.insert(self.NpcIds, k)
          end
        end
      else
        Log.ErrorFormat("PSONPCTest NPC\233\133\141\231\189\174\231\154\132ModelCfg\228\184\186\231\169\186 %d", model_Cfg_id)
      end
    end
  end
  self.player:SetViewVisible(false, true)
  self.NpcIndex = 0
  self:SpawnNPC(self.NpcIds, 1)
  Log.DebugFormat("PSONPCTest: NpcIds = %d, NpcModels = %d, Npcs = %d, blacklist = %d", #self.NpcIds, #self.NpcModels, #self.Npcs, #blacklist)
end

function PSONPCTest:SpawnNPC(All, Index)
  if Index <= 0 then
    self:NPCEnd()
  end
  if Index > #All then
    self:NPCEnd()
  end
  self.NpcIndex = Index
  local grid_id = (Index - 1) % self.max_grid_id + 1
  if #self.Npcs > 0 and self.Npcs[grid_id] ~= nil then
    local prevActor = self.Npcs[grid_id]
    if prevActor.viewObj then
      Log.DebugFormat("PSONPCTest: RemovePet: [%d] = %s, gridId = %d, npcId = %d", Index, prevActor.viewObj:GetName(), grid_id, self.NpcIds[Index])
      prevActor.viewObj:SetActorHiddenInGame(true)
      prevActor:SetNotDestroyFlag(false)
      local npcModule = NRCModuleManager:GetModule("NPCModule")
      npcModule:RemoveNpc(self.Npcs[grid_id]:GetServerId(), true)
      self.Npcs[grid_id] = nil
    end
  end
  local actor_pos = self.grids[grid_id]
  local npcId = All[Index]
  Log.DebugFormat("PSONPCTest:CreateLocalNPC [%d]: gridId = %d, npcId = %d", Index, grid_id, npcId)
  local npc = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.CreateLocalNPC, npcId, actor_pos, nil, nil, PriorityEnum.Passive_World_NPC_Close_BP)
  self.Npcs[grid_id] = npc
  if Index >= #All then
    self:NPCEnd()
    Log.Error("\229\174\140\230\136\144\230\137\128\230\156\137\231\154\132\229\174\160\231\137\169\231\148\159\230\136\144", Index)
    return
  end
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  NPCModule:RegisterEvent(self, NPCModuleEvent.OnViewVisible, function()
    self:OnViewVisiable()
  end)
end

function PSONPCTest:OnViewVisiable()
  local grid_id = (self.NpcIndex - 1) % self.max_grid_id + 1
  local Actor = self.Npcs[grid_id].viewObj
  if Actor then
    Log.DebugFormat("PSONPCTest: OnViewVisiable: [%d] = %s, gridId = %d, npcId = %d", self.NpcIndex, Actor:GetName(), grid_id, self.NpcIds[self.NpcIndex])
    local Root = Actor:K2_GetRootComponent()
    Root.bHiddenInGame = false
    Actor:SetActorEnableCollision(true)
    local Location = Actor:GetNearLandLocation()
    if Location then
      Location.Z = Location.Z + self.playerHalfHeight
      Actor:SetActorLocation(Location)
      local LookAt = self.playerLocation - Location
      LookAt.Z = 0
      Actor:K2_SetActorRotation(LookAt:ToRotator():Clamp(), true)
    else
      Log.Error("PSONPCTest: GetNearLandLocation nil !!")
    end
  end
  _G.DelayManager:DelaySeconds(0.1, self.SpawnNPC, self, self.NpcIds, self.NpcIndex + 1)
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  NPCModule:UnRegisterEvent(self, NPCModuleEvent.OnViewVisible)
end

function PSONPCTest:OnPostLoadLevel_1()
  NRCEventCenter:UnRegisterEvent(self, NRCGlobalEvent.PostLoadMapWithWorld, self.OnPostLoadLevel_1)
  _G.DelayManager:DelaySeconds(3, function()
    self:InitPlayer(true)
    DebugTabScenePublic:GhostMode()
    self:GenarateGrid()
    self:ScanModelConf()
  end)
end

function PSONPCTest:StartModel()
  self.NpcModels = {}
  self.GridModels = {}
  _G.UpdateManager:Register(self)
  self:LoadLevel(EmptyLevl, self.OnPostLoadLevel_1)
end

function PSONPCTest:ScanModelConf()
  local Confs = _G.DataConfigManager:GetAllByName("NPC_CONF")
  local Models = {}
  local blacklist = {}
  local invalidActor = {
    "15068",
    "15069",
    "15070",
    "1010064",
    "15122",
    "20056",
    "20055",
    "1010053",
    "1010054"
  }
  for k, conf in pairs(Confs) do
    local NPC_CONF = conf
    local model_Cfg_id = NPC_CONF.model_conf
    if model_Cfg_id and 0 ~= model_Cfg_id then
      local modelConf = _G.DataConfigManager:GetModelConf(model_Cfg_id)
      if modelConf then
        if Models[modelConf.path] == nil then
          local isValid = true
          for _, actor in ipairs(invalidActor) do
            if actor == tostring(model_Cfg_id) then
              blacklist[modelConf.path] = conf
              isValid = false
              break
            end
          end
          if isValid then
            Models[modelConf.path] = conf
            table.insert(self.NpcModels, modelConf.path)
          end
        end
      else
        Log.ErrorFormat("PSONPCTest NPC\233\133\141\231\189\174\231\154\132ModelCfg\228\184\186\231\169\186 %d", model_Cfg_id)
      end
    end
  end
  self.player:SetViewVisible(false, true)
  Log.DebugFormat("PSONPCTest: Total Models = %d", #self.NpcModels)
  self.ModelIndex = 0
  self:SpawnModel(self.NpcModels, 1)
  Log.DebugFormat("PSONPCTest: NpcModels = %d", #self.NpcModels)
end

function PSONPCTest:SpawnModel(All, Index)
  if Index <= 0 then
    return
  end
  if Index > #All then
    return
  end
  local Center = self.playerLocation
  local DX = 100
  local DY = 100
  local Klass = _G.NRCResourceManager:LoadForDebugOnly(All[Index])
  if Klass then
    local Transform = UE4.FTransform(UE4.FQuat(), UE.FVector(Center.X + DX, Center.Y + DY, Center.Z + 500))
    local World = _G.UE4Helper.GetCurrentWorld()
    local Actor = World:SpawnActor(Klass, Transform, UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn, nil, nil)
    local grid_id = (Index - 1) % self.max_grid_id + 1
    Log.DebugFormat("PSONPCTest: SpawnModel[%d], gridId = %d, path = %s", Index, grid_id, All[Index])
    if #self.GridModels > 0 and self.GridModels[grid_id] ~= nil then
      local prevActor = self.GridModels[grid_id]
      prevActor:SetActorHiddenInGame(true)
      if prevActor.sceneCharacter then
        Log.DebugFormat("PSONPCTest: RemoveNPC[%d-%d]: %s", grid_id, Index, prevActor:GetName())
      end
      prevActor:K2_DestroyActor()
      self.GridModels[grid_id] = nil
    end
    local actor_pos = self.grids[grid_id]
    Actor:Abs_K2_SetActorLocation_WithoutHit(UE.FVector(actor_pos.X, actor_pos.Y, actor_pos.Z))
    if Actor and Actor.InitOutSceneAsync then
      if Actor.sceneCharacter then
        Log.DebugFormat("PSONPCTest: sceneCharacter: %s, Index = %d, path = %s", Actor:GetName(), Index, All[Index])
      end
      Actor:InitOutSceneAsync(self, function()
      end)
      local Root = Actor:K2_GetRootComponent()
      Root.bHiddenInGame = false
      Actor:SetActorEnableCollision(true)
      local Location = Actor:GetNearLandLocation()
      if not Location then
        Log.Error("\231\148\159\230\136\144 NPC \228\184\173\230\150\173\228\186\134!!")
        _G.DelayManager:DelaySeconds(0.3, self.SpawnModel, self, All, Index + 1)
        return
      end
      if Actor.GetHalfHeight then
        Location.Z = Location.Z + Actor:GetHalfHeight()
      end
      Actor:SetActorLocation(Location)
      local LookAt = Center - Location
      LookAt.Z = 0
      Actor:K2_SetActorRotation(LookAt:ToRotator():Clamp(), true)
      self.GridModels[grid_id] = Actor
    else
      Log.Error("Actor\231\148\159\230\136\144\229\164\177\232\180\165", All[Index])
    end
  else
    Log.Error("Class\229\138\160\232\189\189\229\164\177\232\180\165", All[Index])
  end
  if Index >= #All then
    self:InitPlayer(true)
    Log.Error("\229\174\140\230\136\144\230\137\128\230\156\137\231\154\132 NPC \231\148\159\230\136\144", Index)
    return
  end
  _G.DelayManager:DelaySeconds(0.3, self.SpawnModel, self, All, Index + 1)
end

function PSONPCTest:NPCEnd()
  for _, Actor in ipairs(self.GridModels) do
    Actor:SetActorHiddenInGame(true)
    if Actor.sceneCharacter then
      Log.DebugFormat("PSONPCTest: RemovePet[%d-%d]: %s", grid_id, Index, Actor:GetName())
    end
    Actor:K2_DestroyActor()
    self.GridModels[grid_id] = nil
  end
  self:InitPlayer(true)
  self:End()
end

function PSONPCTest:Start()
  self:Init()
end

function PSONPCTest:End()
  _G.UpdateManager:UnRegister(self)
  self.player = nil
  Log.Debug("PSONPCTest End")
end

Speed = 100
local currentYaw = 0

function PSONPCTest:OnTick(dt)
  if self.Npcs then
    for i, Actor in ipairs(self.Npcs) do
      if Actor.viewObj then
        currentYaw = (currentYaw + Speed * dt) % 360
        Actor.viewObj:K2_SetActorRotation(UE4.FRotator(0, currentYaw, 0), true)
      end
    end
  end
end

return PSONPCTest
