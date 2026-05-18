local UIUtils = require("NewRoco.Modules.System.TipsModule.Utils.UIUtils")
PSOAvatarTest = {}
local EmptyLevl = "/Game/ArtRes/Level/Performance/BigWorldEnvForPetTest"

function PSOAvatarTest:generate_point_grid(start_pos, forward, right, up, rows, cols, distance, spacing)
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

function PSOAvatarTest:InitPlayer(enable)
  self.player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not self.player or not self.player.ueController then
    Log.Error("Failed to get local player")
    return
  end
  self.player:SetViewVisible(true, true)
  self.player.ueController.PlayerCameraManager.bEnableMainUICamera = true
  self.StartRunPos = self.player:GetActorLocation()
end

function PSOAvatarTest:Init()
  _G.UpdateManager:Register(self)
  self:LoadLevel(EmptyLevl, self.OnPostLoadLevel)
end

function PSOAvatarTest:LoadLevel(level_path, postLoaded_callback)
  NRCEventCenter:RegisterEvent("LoadEmptyLevel", self, NRCGlobalEvent.PostLoadMapWithWorld, postLoaded_callback)
  NRCModeManager:ActiveMode("LocalMode")
  NRCModuleManager:DoCmd(PlayerModuleCmd.CLEAR_ALL)
  self.player = nil
  LevelHelper:OpenLevel(level_path)
  _G.NRCModeManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 1)
  Log.Debug("PSOAvatarTest:LoadEmptyLevel: OpenLevel ", level_path)
end

function PSOAvatarTest:OnPostLoadLevel()
  NRCEventCenter:UnRegisterEvent(self, NRCGlobalEvent.PostLoadMapWithWorld, self.OnPostLoadLevel)
  _G.DelayManager:DelaySeconds(3, function()
    self:InitPlayer(true)
    self:ScanConf()
  end)
end

function PSOAvatarTest:ScanConf()
  self:SpawnNPC()
  self.player:SetViewVisible(false, true)
  self.FashionSuitData = {}
  self.FashionData = {}
  self.SalonData = {}
  local Enum = _G.Enum
  local FashionSuitsConf = _G.DataConfigManager:GetAllByName("FASHION_SUITS_CONF")
  for k, v in pairs(FashionSuitsConf) do
    Log.DebugFormat("PSOAvatarTest GT_FASHION_SUITS [%d] = %s", k, v.name)
    self:SetFashionSuitData(v)
  end
  local FashionConf = _G.DataConfigManager:GetAllByName("FASHION_ITEM_CONF")
  for k, v in pairs(FashionConf) do
    Log.DebugFormat("PSOAvatarTest GT_FASHION [%d] = %s", k, v.name)
    self:SetFashionData(v)
  end
  local SalonConf = _G.DataConfigManager:GetAllByName("SALON_ITEM_CONF")
  for k, v in pairs(SalonConf) do
    Log.DebugFormat("PSOAvatarTest GT_SALON [%d] = %s", k, v.name)
    self:SetSalonData(v)
  end
  if false then
    self:DebugAvata()
  elseif #self.FashionSuitData > 0 then
    self.FashionSuitIndex = 1
    self:ScanFashionSuit(self.FashionSuitData, 1)
  end
end

function PSOAvatarTest:SetFashionSuitData(conf)
  if conf then
    table.insert(self.FashionSuitData, {
      gender = conf.gender,
      item_id = conf.item_id
    })
  end
end

function PSOAvatarTest:SetFashionData(conf)
  if conf then
    table.insert(self.FashionData, {
      gender = conf.gender,
      id = conf.id
    })
  end
end

function PSOAvatarTest:SetSalonData(conf)
  if conf then
    table.insert(self.SalonData, {
      id = conf.id,
      gender = conf.gender,
      avatar_id = conf.avatar_id,
      texture_id = conf.texture_id
    })
  end
end

function PSOAvatarTest:ScanFashionSuit(All, Index)
  if Index <= 0 then
    return
  end
  if Index > #All then
    return
  end
  self.FashionSuitIndex = Index
  local conf = All[Index]
  local item_ids = conf.item_id
  local gender = conf.gender
  self:SetDefaultSuit(gender, item_ids, nil, true)
  if Index >= #All then
    self:FashionSuitEnd()
    Log.Error("\229\174\140\230\136\144\230\137\128\230\156\137\231\154\132 FashionSuit \231\148\159\230\136\144", Index)
    return
  end
end

function PSOAvatarTest:DebugAvata()
  self:End()
  do
    local item_ids = {
      {item_wear_id = 58, color_wear_id = 1}
    }
    self:SetDefaultSuit(1, nil, item_ids, true)
  end
  goto lbl_28
  do
    local item_id = {21200101, 32401301}
    self:SetDefaultSuit(2, item_id, nil, true)
  end
  ::lbl_28::
end

function PSOAvatarTest:ScanFashion(All, Index)
  if Index <= 0 then
    return
  end
  if Index > #All then
    return
  end
  self.FashionIndex = Index
  local conf = All[Index]
  local item_id = conf.id
  local gender = conf.gender
  Log.DebugFormat("PSOAvatarTest: ScanFashion: item = %s", item_id)
  self:SetDefaultSuit(gender, {item_id}, nil, true)
  if Index >= #All then
    self:FashionEnd()
    Log.Error("\229\174\140\230\136\144\230\137\128\230\156\137\231\154\132 Fashion \231\148\159\230\136\144", Index)
    return
  end
end

function PSOAvatarTest:ScanSalon(All, Index)
  if Index <= 0 then
    return
  end
  if Index > #All then
    return
  end
  self.SalonIndex = Index
  local salonConf = All[Index]
  local gender = salonConf.gender
  Log.DebugFormat("PSOAvatarTest: ScanSalon: item = %d", salonConf.id)
  self:SetDefaultSuit(gender, nil, {salonConf}, true)
  if Index >= #All then
    self:SalonEnd()
    Log.Error("\229\174\140\230\136\144\230\137\128\230\156\137\231\154\132 Salon \231\148\159\230\136\144", Index)
    return
  end
end

function PSOAvatarTest:FashionSuitEnd()
  self.FashionSuitIndex = nil
  for i, Actor in ipairs(self.NPCs) do
    if Actor then
      local Location = Actor:Abs_K2_GetActorLocation()
      local viewObj = self.player.viewObj
      local playerLocation = viewObj:Abs_K2_GetActorLocation()
      local LookAt = playerLocation - Location
      LookAt.Z = 0
      Actor:K2_SetActorRotation(LookAt:ToRotator():Clamp(), true)
    end
  end
  self:ScanFashion(self.FashionData, 1)
end

function PSOAvatarTest:FashionEnd()
  self.FashionIndex = nil
  _G.UpdateManager:UnRegister(self)
  for i, Actor in ipairs(self.NPCs) do
    if Actor then
      local Location = Actor:Abs_K2_GetActorLocation()
      local viewObj = self.player.viewObj
      local playerLocation = viewObj:Abs_K2_GetActorLocation()
      local LookAt = playerLocation - Location
      LookAt.Z = 0
      Actor:K2_SetActorRotation(LookAt:ToRotator():Clamp(), true)
    end
  end
  self:ScanSalon(self.SalonData, 1)
end

function PSOAvatarTest:SalonEnd()
  self:End()
  self:InitPlayer(true)
  self.player:SetViewVisible(true, true)
  self.SalonIndex = nil
  for i, Actor in ipairs(self.NPCs) do
    if Actor then
      local Location = Actor:Abs_K2_GetActorLocation()
      local viewObj = self.player.viewObj
      local playerLocation = viewObj:Abs_K2_GetActorLocation()
      local LookAt = playerLocation - Location
      LookAt.Z = 0
      Actor:K2_SetActorRotation(LookAt:ToRotator():Clamp(), true)
    end
  end
end

function PSOAvatarTest:SetDefaultSuit(gender, fashionIds, salonConfs, callback, bShowTips)
  local defaultSuitClass
  if gender == _G.Enum.ESexValue.SEX_MALE then
    defaultSuitClass = _G.NRCBigWorldPreloader:Get(UEPath.DEFAULT_AVATAR_SUIT_MALE)
  elseif gender == _G.Enum.ESexValue.SEX_FEMALE then
    defaultSuitClass = _G.NRCBigWorldPreloader:Get(UEPath.DEFAULT_AVATAR_SUIT_FEMALE)
  else
    gender = _G.Enum.ESexValue.SEX_MALE
    defaultSuitClass = _G.NRCBigWorldPreloader:Get(UEPath.DEFAULT_AVATAR_SUIT_MALE)
  end
  local defaultSuitObj = NewObject(defaultSuitClass, _G.UE4Helper.GetCurrentWorld())
  defaultSuitObj.Gender = gender
  if salonConfs and #salonConfs > 0 then
    local salonWearIds = {}
    for k, salonItemConf in ipairs(salonConfs) do
      local fullSalonId = self:GetFullSalonId(salonItemConf.avatar_id, salonItemConf.texture_id)
      table.insert(salonWearIds, fullSalonId)
    end
    defaultSuitObj:SetSalons(salonWearIds)
  end
  if fashionIds and #fashionIds > 0 then
    for k, v in ipairs(fashionIds) do
      if 0 ~= v then
        local fashionItemConf = _G.DataConfigManager:GetFashionItemConf(v)
        if fashionItemConf then
          local bBodyType, avatarEnum = UIUtils.GetAvatarEnumByConfigEnumFashion(fashionItemConf.type)
          if bBodyType then
            defaultSuitObj:SetBody(v, 0)
          end
          goto lbl_130
          local fashionPath = self.NumberPathMap[tostring(v)]
          for _, value1 in pairs(fashionPath) do
            defaultSuitObj:SetBodyPath(avatarEnum, value1)
            Log.DebugFormat("PSOAvatarTest: ========== Enum = %d, SetBodyPath: %s", avatarEnum, value1)
          end
        else
          Log.Error("fashion\228\184\141\229\173\152\229\156\168")
        end
      end
      ::lbl_130::
    end
  end
  self.avatarSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(UE4Helper.GetCurrentWorld(), UE.UAvatarSubsystem)
  if not self.OnAvatarCompleteFunction then
    function self.OnAvatarCompleteFunction(system, ID)
      self:OnAvatarCallback(ID)
    end
  end
  if callback then
    self.avatarSystem.OnSwitchAvatarSuitComplete:Add(self.avatarSystem, self.OnAvatarCompleteFunction)
  end
  local NPC = self.NPCs[1]
  local Mesh = NPC:GetComponentByClass(UE4.USkeletalMeshComponent)
  self.taskId = self.avatarSystem:StartSwitchAvatarSuit(Mesh, defaultSuitObj)
  Log.DebugFormat("PSOAvatarTest: StartSwitchAvatarSuit: TaskId = %d", self.taskId)
end

function PSOAvatarTest:GetFullSalonId(configId, colorIndex)
  if colorIndex > 0 then
    colorIndex = colorIndex - 1
  end
  local fullSalonId = configId * 100 + colorIndex
  return fullSalonId
end

function PSOAvatarTest:FashionSuitCompleteFunction(ID)
  PSOAvatarTest:OnAvatarCallback(ID)
end

function PSOAvatarTest:OnAvatarCallback(ID)
  if self.FashionSuitIndex then
    _G.DelayManager:DelayFrames(10, self.ScanFashionSuit, self, self.FashionSuitData, self.FashionSuitIndex + 1)
  elseif self.FashionIndex then
    _G.DelayManager:DelayFrames(10, self.ScanFashion, self, self.FashionData, self.FashionIndex + 1)
  elseif self.SalonIndex then
    _G.DelayManager:DelayFrames(10, self.ScanSalon, self, self.SalonData, self.SalonIndex + 1)
  else
    self.avatarSystem.OnSwitchAvatarSuitComplete:Remove(self.avatarSystem, self.OnAvatarCompleteFunction)
  end
end

function PSOAvatarTest:Start()
  self.NpcIDs = {}
  self.NPCs = {}
  self:Init()
end

function PSOAvatarTest:GenarateGrid()
  local rows = 1
  local cols = 1
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
  self.playerLocation = playerLocation
end

function PSOAvatarTest:SpawnNPC()
  local path = "Blueprint'/Game/ArtRes/BP/Scene/NPC_00901/BP_Scene_NPC_00901.BP_Scene_NPC_00901_C'"
  local Klass = _G.NRCResourceManager:LoadForDebugOnly(path)
  self:GenarateGrid()
  local Center = self.playerLocation
  local DX = 100
  local DY = 100
  Index = 0
  if Klass then
    local Transform = UE4.FTransform(UE4.FQuat(), UE.FVector(Center.X + DX, Center.Y + DY, Center.Z + 500))
    local World = _G.UE4Helper.GetCurrentWorld()
    local Actor = World:SpawnActor(Klass, Transform, UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn, nil, nil)
    local AvatartComp = Actor:AddComponentByClass(UE4.UAvatarComponent, false, Transform, false)
    local grid_id = (Index - 1) % self.max_grid_id + 1
    local actor_pos = self.grids[grid_id]
    Actor:Abs_K2_SetActorLocation_WithoutHit(UE.FVector(actor_pos.X, actor_pos.Y, actor_pos.Z + 100))
    if Actor and Actor.InitOutSceneAsync then
      Actor:InitOutSceneAsync(self, function()
      end)
      local Root = Actor:K2_GetRootComponent()
      Root.bHiddenInGame = false
      Actor:SetActorEnableCollision(false)
      local Location = Actor:GetNearLandLocation()
      if not Location then
        Log.Error("\231\148\159\230\136\144\229\174\160\231\137\169\228\184\173\230\150\173\228\186\134!!")
        return
      end
      Location.Z = Location.Z + Actor:GetHalfHeight()
      Actor:SetActorLocation(Location)
      local LookAt = Center - Location
      LookAt.Z = 0
      Actor:K2_SetActorRotation(LookAt:ToRotator():Clamp(), true)
      self.NPCs[grid_id] = Actor
    else
      Log.Error("Actor\231\148\159\230\136\144\229\164\177\232\180\165", All[Index])
    end
  else
    Log.Error("Class\229\138\160\232\189\189\229\164\177\232\180\165", All[Index])
  end
end

function PSOAvatarTest:End()
  _G.UpdateManager:UnRegister(self)
  self.player = nil
  Log.Debug("PSOAvatarTest End")
end

Speed = 360
local currentYaw = 0

function PSOAvatarTest:OnTick(dt)
  for i, Actor in ipairs(self.NPCs) do
    if Actor then
      currentYaw = (currentYaw + Speed * dt) % 360
      Actor:K2_SetActorRotation(UE4.FRotator(0, currentYaw, 0), true)
    end
  end
end

return PSOAvatarTest
