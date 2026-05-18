local JsonUtils = require("Common.JsonUtils")
local StarLightPhotoEditor_C = _G.NRCPanelBase:Extend("StarLightPhotoEditor_C")

function StarLightPhotoEditor_C:OnActive()
  self:InitSlots()
  self:ChangeCamera()
  self:InitDataStructure()
  self:OnAddEventListener()
  self:UpdateComboBoxSkyUI()
  self:LoadFileFromJson()
  self:SetTeamData()
end

function StarLightPhotoEditor_C:OnDeactive()
end

function StarLightPhotoEditor_C:InitDataStructure()
  self.PetAnim = {}
  self.PetAnimLengthMap = {}
  self.PetAnimPercent = {}
  self.Body = {}
  self.petList = {}
  self.petHalfHeight = {}
  self.SliderLength = 0
  self.loadedCount = 0
  self.nameTextUI = {
    self.TextBlock_3,
    self.TextBlock_1,
    self.TextBlock_33,
    self.TextBlock_42,
    self.TextBlock_51,
    self.TextBlock_60
  }
  self.IDTextUI = {
    self.EditableText_3,
    self.EditableText_1,
    self.EditableText_30,
    self.EditableText_38,
    self.EditableText_47,
    self.EditableText_55
  }
  self.SliderList = {
    self.Slider,
    self.Slider_1,
    self.Slider_2,
    self.Slider_3,
    self.Slider_4,
    self.Slider_5,
    self.Slider_6
  }
  self.BodyText = {
    self.EditableText_10,
    self.EditableText_14,
    self.EditableText_31,
    self.EditableText_39,
    self.EditableText_48,
    self.EditableText_56
  }
  self.ComboBox = {
    self.ComboBoxString_68,
    self.ComboBoxString_1,
    self.ComboBoxString_2,
    self.ComboBoxString_3,
    self.ComboBoxString_4,
    self.ComboBoxString_5,
    self.ComboBoxString
  }
  self.ComboBoxSky = {
    self.ComboBoxString_6,
    self.ComboBoxString_7,
    self.ComboBoxString_8,
    self.ComboBoxString_9,
    self.ComboBoxString_10,
    self.ComboBoxString_11
  }
  self.SaveJsonPath = "PhotoEditorJson"
  self.LoadJsonPath = self.EditableText_63:GetText() or "PhotoEditorJson"
  local BGActorsList = UE4.UGameplayStatics.GetAllActorsOfClassWithTag(self.previewWorld, UE4.AActor, "BGAsset"):ToTable()
  self.BGAsset = BGActorsList[1]
  local BGAnimPath = "/Game/ArtRes/Asset/Environment/Interator/Curtain/Animation/World_Loop.World_Loop"
  self.BGAnim = _G.NRCResourceManager:LoadResAsync(self, BGAnimPath, -1, -1, self.LoadBGAnimOver)
  local petDatas = {}
  self.petAnimFrame = {}
  for i = 1, 6 do
    petDatas[i] = 3000 + i
  end
  self.petDatas = petDatas
end

function StarLightPhotoEditor_C:LoadBGAnimOver(resRequest, BgClass)
  local skMesh = self.BGAsset:GetComponentByClass(UE4.USkeletalMeshComponent)
end

function StarLightPhotoEditor_C:ChangePet(i, ID)
  self.petDatas[i] = ID
  if self.petList[i].actor then
    self.petList[i].actor:K2_DestroyActor()
  end
  self.petList[i].actor = self:AddPetToScene(self.petDatas[i], self.slotActors[i], i)
end

function StarLightPhotoEditor_C:ResetCameraButton()
end

function StarLightPhotoEditor_C:OnBGTextCommitted()
  Log.Error("111")
end

function StarLightPhotoEditor_C:InitSlots()
  self.previewWorld = UE4Helper.GetCurrentWorld()
  local slotActors = {}
  self.slotActors = slotActors
  local SlotActorsList = UE4.UGameplayStatics.GetAllActorsOfClassWithTag(self.previewWorld, UE4.AActor, "SlotActor"):ToTable()
  for i, SlotActor in ipairs(SlotActorsList) do
    slotActors[i] = SlotActor
    local meshComponent = slotActors[i]:GetComponentByClass(UE4.UStaticMeshComponent)
    meshComponent:SetMobility(UE4.EComponentMobility.Movable)
  end
  local Slot_NPCs = UE4.UGameplayStatics.GetAllActorsOfClassWithTag(self.previewWorld, UE4.AActor, "Slot_NPC"):ToTable()
  self.Slot_NPC = Slot_NPCs[1]
  self.slotActors[7] = self.Slot_NPC
  local meshComponent = self.Slot_NPC:GetComponentByClass(UE4.UStaticMeshComponent)
  meshComponent:SetMobility(UE4.EComponentMobility.Movable)
  local EnvSpotLightActorListTable = UE4.UGameplayStatics.GetAllActorsOfClassWithTag(self.previewWorld, UE4.AActor, "EnvSpotLightConfigableActor"):ToTable()
  self.EnvSpotLightActorList = {}
  for i, EnvSpotLightActor in ipairs(EnvSpotLightActorListTable) do
    self.EnvSpotLightActorList[i] = EnvSpotLightActor
  end
end

function StarLightPhotoEditor_C:ChangeCamera()
  local Controller = UE4.UGameplayStatics.GetPlayerController(UE4Helper.GetCurrentWorld(), 0)
  local TheCameras = UE4.UGameplayStatics.GetAllActorsOfClassWithTag(self.previewWorld, UE4.AActor, "MainCamera"):ToTable()
  local CameraActor = TheCameras[1]
  self.CameraActor = CameraActor
  Controller:SetViewTargetWithBlend(CameraActor, 0)
end

function StarLightPhotoEditor_C:SetTeamData(forceUpdate)
  self:UpdateSlotActors(forceUpdate)
end

function StarLightPhotoEditor_C:OnTick()
end

function StarLightPhotoEditor_C:UpdateComboBoxSkyUI()
  for i = 1, 6 do
    self.ComboBoxSky[i]:AddOption("ground")
    self.ComboBoxSky[i]:AddOption("air")
  end
end

function StarLightPhotoEditor_C:UpdateSlotActors(forceUpdate)
  local petDatas = self.petDatas
  local slotActors = self.slotActors
  for i = 1, #slotActors do
    if petDatas[i] then
      if self.petList == nil then
        self.petList = {}
      end
      if self.petList[i] == nil then
        self.petList[i] = {}
      end
      if self.petList[i].actor then
        self.petList[i].actor:K2_DestroyActor()
      end
      self.petList[i].actor = self:AddPetToScene(petDatas[i], slotActors[i], i)
    elseif nil == petDatas[i] and self.petList[i] then
      self.petList[i].actor:K2_DestroyActor()
      self.petList[i] = nil
    end
  end
end

function StarLightPhotoEditor_C:CreateNPC(NPCID)
  if self.NPCActor then
    self.NPCActor:K2_DestroyActor()
  end
  local NpcConf = _G.DataConfigManager:GetNpcConf(NPCID)
  self.NPCID = NPCID
  if not NPCID then
    Log.Error("\232\175\165\230\136\152\230\150\151\230\178\161\230\156\137NPC")
  end
  self.EditableText_2:SetText(self.NPCID)
  local modelCfgID = NpcConf.model_conf
  local modelCfg = _G.DataConfigManager:GetModelConf(modelCfgID)
  local modelClass = UE4.UClass.Load(modelCfg.path)
  self.petHalfHeight[7] = self:GetModelHalfHeight(modelCfgID)
  if not modelClass then
    Log.ErrorFormat("UMG_PetTeamImage_C:AddPetToScene \230\168\161\229\158\139\232\183\175\229\190\132\233\148\153\232\175\175 [%s].", modelCfg.path or "")
  end
  local transform = self.Slot_NPC:GetTransform()
  local newLocation = UE4.FVector(transform.Translation.X, transform.Translation.Y, transform.Translation.Z + self.petHalfHeight[7])
  local actor = self.previewWorld:Abs_SpawnActor(modelClass, transform, UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn)
  actor:InitOutSceneAsync(nil, function(actor)
    self:OnActorLoaded(actor, 7, newLocation)
  end)
  local Transform = actor:GetTransform()
  actor:SetIKEnable(false)
  local mesh = actor:GetComponentByClass(UE4.USkeletalMeshComponent)
  actor.CharacterMovement.GravityScale = 0
  self.NPCActor = actor
  mesh.bForceMipStreaming = true
  mesh:SetSimulatePhysics(false)
  mesh:SetEnableGravity(false)
end

function StarLightPhotoEditor_C:RecalcActorRealLocation(slotIndex)
  local halfHeight = self.petHalfHeight[slotIndex] or 0
  local actor = self.slotActors[slotIndex]
  local Transform = actor:GetTransform()
  local newLocation = UE4.FVector(Transform.Translation.X, Transform.Translation.Y, Transform.Translation.Z + halfHeight)
  Transform.Translation = newLocation
  return Transform
end

function StarLightPhotoEditor_C:GetModelHalfHeight(modelCfgID)
  local modelConf = _G.DataConfigManager:GetModelConf(modelCfgID)
  local modelScale1 = math.clamp((modelConf.model_scale or 100) / 100, 0.001, 100.0)
  local modelScale = 1
  local modelHalfHeight = (modelConf.capsule_halfheight or 1000) / 1000
  return modelScale * modelHalfHeight
end

function StarLightPhotoEditor_C:LoadBattleConf(battleID)
  local BattleConf = DataConfigManager:GetBattleConf(battleID)
  self.EditableText:SetText(battleID)
  local battle_model = BattleConf.npc_battle_list[1].battle_model_1st
  self:CreateNPC(battle_model)
  local monster1ID = BattleConf.npc_battle_list[1].pos1_1st[1]
  if monster1ID then
    local monsterConf = _G.DataConfigManager:GetMonsterConf(monster1ID)
    local petBaseID = monsterConf.base_id
    self.petDatas[1] = petBaseID
  end
  local monster2ID = BattleConf.npc_battle_list[1].pos2_1st[1]
  if monster2ID then
    local monsterConf = _G.DataConfigManager:GetMonsterConf(monster2ID)
    local petBaseID = monsterConf.base_id
    self.petDatas[2] = petBaseID
  end
  local monster3ID = BattleConf.npc_battle_list[1].pos3_1st[1]
  if monster3ID then
    local monsterConf = _G.DataConfigManager:GetMonsterConf(monster3ID)
    local petBaseID = monsterConf.base_id
    self.petDatas[3] = petBaseID
  end
  local monster4ID = BattleConf.npc_battle_list[1].pos4_1st[1]
  if monster4ID then
    local monsterConf = _G.DataConfigManager:GetMonsterConf(monster4ID)
    local petBaseID = monsterConf.base_id
    self.petDatas[4] = petBaseID
  end
  local monster5ID = BattleConf.npc_battle_list[1].pos5_1st[1]
  if monster5ID then
    local monsterConf = _G.DataConfigManager:GetMonsterConf(monster5ID)
    local petBaseID = monsterConf.base_id
    self.petDatas[5] = petBaseID
  end
  local monster6ID = BattleConf.npc_battle_list[1].pos6_1st[1]
  if monster6ID then
    local monsterConf = _G.DataConfigManager:GetMonsterConf(monster6ID)
    local petBaseID = monsterConf.base_id
    self.petDatas[6] = petBaseID
  end
  self:UpdateSlotActors()
end

function StarLightPhotoEditor_C:AddPetToScene(petId, slotActor, slotId, petGid)
  local petbaseConf = _G.DataConfigManager:GetPetbaseConf(petId)
  if not petbaseConf then
    Log.Error("\229\174\160\231\137\169\233\133\141\231\189\174\228\184\141\229\175\185\239\188\140\232\175\183\233\135\141\230\150\176\232\190\147\229\133\165")
    return
  end
  self.nameTextUI[slotId]:SetText(slotId .. "\229\143\183:" .. petbaseConf.name)
  self.IDTextUI[slotId]:SetText(petId)
  local modelCfg = _G.DataConfigManager:GetModelConf(petbaseConf.model_conf)
  local modelScale = petbaseConf.formation_ui_scale
  self.petHalfHeight[slotId] = self:GetModelHalfHeight(petbaseConf.model_conf)
  local newTransform = self:RecalcActorRealLocation(slotId)
  local modelClass = UE4.UClass.Load(modelCfg.path)
  if not modelClass then
    Log.ErrorFormat("UMG_PetTeamImage_C:AddPetToScene \230\168\161\229\158\139\232\183\175\229\190\132\233\148\153\232\175\175 [%s].", modelCfg.path or "")
    self:ForceContinue()
    return
  end
  local actor = self.previewWorld:Abs_SpawnActor(modelClass, newTransform, UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn)
  if not actor then
    Log.ErrorFormat("UMG_PetTeamImage_C:SpawnActor \229\136\155\229\187\186Actor\229\164\177\232\180\165.", modelCfg.path or "")
    self:ForceContinue()
    return
  end
  actor:SetIKEnable(false)
  local mesh = actor:GetComponentByClass(UE4.USkeletalMeshComponent)
  mesh.bForceMipStreaming = true
  actor.scale = modelScale * mesh.RelativeScale3D.Z * (modelCfg.model_scale / 100)
  actor.mesh = mesh
  actor:InitOutSceneAsync(nil, function(actor)
    self:OnActorLoaded(actor, slotId)
  end)
  return actor
end

function StarLightPhotoEditor_C:OnActorLoaded(actor, index, newTransform)
  if newTransform then
    actor:Abs_K2_SetActorLocation_WithoutHit(newTransform)
  end
  self.ComboBox[index]:ClearOptions()
  local AnimNameLengthMap = actor:GetAnimNameLengthMap()
  self.PetAnimLengthMap[index] = {}
  for AnimName, AnimLength in pairs(AnimNameLengthMap) do
    self.PetAnimLengthMap[index][AnimName] = AnimLength
    self.ComboBox[index]:AddOption(AnimName)
  end
  if 7 ~= index then
    self:ChangeActorPlayAnim(actor, self.PetAnim[index] or "Idle", index)
    if self.petAnimFrame[index] then
      self.SliderList[index]:SetValue(self.petAnimFrame[index] / 1000)
      self:PetAnimStopFrame(index, self.petAnimFrame[index] / 1000)
    end
  else
    self:ChangeActorPlayAnim(actor, self.NPCAnim or "Idle", index)
    if self.NPCAnimFrame then
      self.SliderList[index]:SetValue(self.NPCAnimFrame / 1000)
      self:PetAnimStopFrame(index, self.NPCAnimFrame / 1000 or 0)
    end
  end
  self.loadedCount = self.loadedCount + 1
  if self.loadedCount >= 7 then
    self.initComplete = true
  end
end

function StarLightPhotoEditor_C:ChangeActorPlayAnim(actor, anim, index)
  if not actor then
    if self.petList[index] and self.petList[index].actor then
      actor = self.petList[index].actor
    else
      return
    end
  end
  anim = anim or self.PetAnim[index]
  local curAnimLength = self.PetAnimLengthMap[index][anim]
  curAnimLength = curAnimLength or 0
  local curAnimPos = self.SliderLength % curAnimLength
  local percent = curAnimPos / curAnimLength
  self.PetAnimPercent[index] = percent
  actor:PlayAnimByName(anim, 0, curAnimPos, 0, 0, -1, 0)
  if 7 ~= index then
    self.PetAnim[index] = anim
  else
    self.NPCAnim = anim
    self.PetAnim[index] = anim
  end
  local AnimIndex = self.ComboBox[index]:FindOptionIndex(anim)
  self.ComboBox[index]:SetSelectedIndex(AnimIndex)
end

function StarLightPhotoEditor_C:CheckIsSky(petIndex)
  if petIndex > 6 then
    return
  end
  local petID = self.petDatas[petIndex]
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petID)
  local type = petBaseConf.move_type
  local isGroundPet = true
  if type and "\230\181\174\230\184\184" == type then
    isGroundPet = false
  end
  local isInSky = false
  local SelectItem = self.ComboBoxSky[petIndex]:GetSelectedOption()
  if "\231\169\186\228\184\173" == SelectItem then
    isInSky = true
  end
  if isGroundPet and isInSky and self.PetAnimLengthMap[petIndex] and self.PetAnimLengthMap[petIndex].JumpFall then
    local AnimIndex = self.ComboBox[petIndex]:FindOptionIndex("JumpFall")
    self.ComboBox[petIndex]:SetSelectedIndex(AnimIndex)
  end
end

function StarLightPhotoEditor_C:SaveFileToJson()
  local SaveJsonInfoList = {}
  local GlobalInfo = {}
  table.insert(GlobalInfo, self.EditableText:GetText())
  table.insert(GlobalInfo, self.EditableText_46:GetText())
  table.insert(GlobalInfo, self.SliderLength)
  local BGPos = self.BGAsset:Abs_K2_GetActorLocation()
  table.insert(GlobalInfo, math.floor(BGPos.x))
  table.insert(GlobalInfo, math.floor(BGPos.y))
  table.insert(GlobalInfo, math.floor(BGPos.z))
  local BGRot = self.BGAsset:K2_GetActorRotation()
  table.insert(GlobalInfo, math.floor(BGRot.Roll))
  table.insert(GlobalInfo, math.floor(BGRot.Pitch))
  table.insert(GlobalInfo, math.floor(BGRot.Yaw))
  table.insert(SaveJsonInfoList, GlobalInfo)
  local CameraInfo = {}
  local camPos = self.CameraActor:Abs_K2_GetActorLocation()
  table.insert(CameraInfo, math.floor(camPos.x))
  table.insert(CameraInfo, math.floor(camPos.y))
  table.insert(CameraInfo, math.floor(camPos.z))
  local camRot = self.CameraActor:K2_GetActorRotation()
  table.insert(CameraInfo, math.floor(camRot.Roll))
  table.insert(CameraInfo, math.floor(camRot.Pitch))
  table.insert(CameraInfo, math.floor(camRot.Yaw))
  local CameraComponent = self.CameraActor:GetComponentByClass(UE4.UCameraComponent)
  local fov = CameraComponent.FieldOfView
  table.insert(CameraInfo, fov)
  table.insert(SaveJsonInfoList, CameraInfo)
  local NPCInfo = {}
  local npcPos = self.NPCActor:Abs_K2_GetActorLocation()
  table.insert(NPCInfo, math.floor(self.EditableText_2:GetText()))
  table.insert(NPCInfo, self.NPCAnim or "Idle")
  table.insert(NPCInfo, math.floor(npcPos.x))
  table.insert(NPCInfo, math.floor(npcPos.y))
  table.insert(NPCInfo, math.floor(npcPos.z - self.petHalfHeight[7]))
  local npcRot = self.NPCActor:K2_GetActorRotation()
  table.insert(NPCInfo, math.floor(npcRot.Roll))
  table.insert(NPCInfo, math.floor(npcRot.Pitch))
  table.insert(NPCInfo, math.floor(npcRot.Yaw))
  local NPCFrame = math.floor(self.PetAnimPercent[7] * 1000)
  table.insert(NPCInfo, NPCFrame or 0)
  table.insert(SaveJsonInfoList, NPCInfo)
  for i, pet in ipairs(self.petList) do
    local petInfo = {}
    table.insert(petInfo, math.floor(self.petDatas[i]))
    table.insert(petInfo, self.PetAnim[i] or "Idle")
    table.insert(petInfo, math.floor(self.Body[i] or 0))
    if pet.actor then
      local pos = pet.actor:Abs_K2_GetActorLocation()
      table.insert(petInfo, math.floor(pos.x))
      table.insert(petInfo, math.floor(pos.y))
      table.insert(petInfo, math.floor(pos.z - self.petHalfHeight[i]))
      local rot = pet.actor:K2_GetActorRotation()
      table.insert(petInfo, math.floor(rot.Roll))
      table.insert(petInfo, math.floor(rot.Pitch))
      table.insert(petInfo, math.floor(rot.Yaw))
      local AnimFrame = math.floor(self.PetAnimPercent[i] * 1000)
      table.insert(petInfo, AnimFrame or 0)
      petInfo[11] = self.ComboBoxSky[i]:GetSelectedOption()
      table.insert(petInfo, "isPetInfo")
    end
    table.insert(SaveJsonInfoList, petInfo)
  end
  for i, EnvSpotLightActor in ipairs(self.EnvSpotLightActorList) do
    local LightInfo = {}
    local pos = EnvSpotLightActor:Abs_K2_GetActorLocation()
    table.insert(LightInfo, math.floor(pos.x))
    table.insert(LightInfo, math.floor(pos.y))
    table.insert(LightInfo, math.floor(pos.z))
    local rot = EnvSpotLightActor:K2_GetActorRotation()
    table.insert(LightInfo, math.floor(rot.Roll))
    table.insert(LightInfo, math.floor(rot.Pitch))
    table.insert(LightInfo, math.floor(rot.Yaw))
    local Intensity = EnvSpotLightActor:GetIntensity()
    table.insert(LightInfo, Intensity)
    local LightColor = EnvSpotLightActor:GetLightColor()
    table.insert(LightInfo, LightColor.R)
    table.insert(LightInfo, LightColor.G)
    table.insert(LightInfo, LightColor.B)
    table.insert(LightInfo, LightColor.A)
    local AttenuationRadius = EnvSpotLightActor:GetAttenuationRadius()
    table.insert(LightInfo, AttenuationRadius)
    local InnerConeAngle = EnvSpotLightActor:GetInnerConeAngle()
    table.insert(LightInfo, InnerConeAngle)
    local OuterConeAngle = EnvSpotLightActor:GetOuterConeAngle()
    table.insert(LightInfo, OuterConeAngle)
    local UseInverseSquaredFalloff = EnvSpotLightActor:GetUseInverseSquaredFalloff()
    if UseInverseSquaredFalloff then
      table.insert(LightInfo, "true")
    else
      table.insert(LightInfo, "false")
    end
    local LightFalloffExponent = EnvSpotLightActor:GetLightFalloffExponent()
    table.insert(LightInfo, LightFalloffExponent)
    table.insert(SaveJsonInfoList, LightInfo)
  end
  JsonUtils.DumpStarLightSaved(self.SaveJsonPath, SaveJsonInfoList)
end

function StarLightPhotoEditor_C:LoadFileFromJson()
  local SaveJsonInfoList = JsonUtils.LoadSavedFromStarLight(self.LoadJsonPath, {})
  if 0 == #SaveJsonInfoList then
    print("No saved data found")
    return
  end
  self.EditableText_64:SetText(self.LoadJsonPath)
  self.SaveJsonPath = self.LoadJsonPath
  if #SaveJsonInfoList > 0 then
    local GlobalInfo = SaveJsonInfoList[1]
    if GlobalInfo and #GlobalInfo >= 2 then
      self.BattleID = tonumber(GlobalInfo[1])
      self.BGPath = GlobalInfo[2]
      self.SliderLength = GlobalInfo[3] or 0
      self.Slider_0:SetValue(self.SliderLength)
      self.EditableText_46:SetText(self.BGPath)
      self:ChangeBgPath(self.BGPath)
      print("Loaded global info: BattleID=" .. tostring(self.BattleID) .. ", BGPath=" .. tostring(self.BGPath))
    end
    if GlobalInfo and #GlobalInfo >= 9 then
      local BGPos = UE4.FVector(GlobalInfo[4], GlobalInfo[5], GlobalInfo[6])
      local BGRot = UE4.FRotator(GlobalInfo[8], GlobalInfo[9], GlobalInfo[7])
      self.BGAsset:K2_GetRootComponent():SetMobility(UE4.EComponentMobility.Movable)
      self.BGAsset:Abs_K2_SetActorLocation_WithoutHit(BGPos)
      self.BGAsset:K2_SetActorRotation(BGRot, false)
    end
  end
  if #SaveJsonInfoList > 1 then
    local CameraInfo = SaveJsonInfoList[2]
    if CameraInfo and #CameraInfo >= 6 then
      local cameraPos = UE4.FVector(CameraInfo[1], CameraInfo[2], CameraInfo[3])
      self.CameraActor:Abs_K2_SetActorLocation_WithoutHit(cameraPos)
      local cameraRot = UE4.FRotator(CameraInfo[5], CameraInfo[6], CameraInfo[4])
      self.CameraActor:K2_SetActorRotation(cameraRot, false)
      if CameraInfo[7] then
        local CameraComponent = self.CameraActor:GetComponentByClass(UE4.UCameraComponent)
        CameraComponent:SetFieldOfView(CameraInfo[7])
      end
      print("Loaded camera position and rotation")
    end
  end
  if #SaveJsonInfoList > 2 then
    local NPCInfo = SaveJsonInfoList[3]
    if NPCInfo and #NPCInfo >= 8 then
      self.NPCID = NPCInfo[1]
      self.NPCAnim = NPCInfo[2]
      self.PetAnim[7] = self.NPCAnim
      local NpcConf = _G.DataConfigManager:GetNpcConf(self.NPCID)
      local modelCfgID = NpcConf.model_conf
      self.petHalfHeight[7] = self:GetModelHalfHeight(modelCfgID)
      local slotPos = UE4.FVector(NPCInfo[3], NPCInfo[4], NPCInfo[5])
      local npcPos = UE4.FVector(NPCInfo[3], NPCInfo[4], NPCInfo[5] + self.petHalfHeight[7])
      if self.NPCActor then
        self.Slot_NPC:Abs_K2_SetActorLocation_WithoutHit(slotPos)
      else
        self.Slot_NPC:Abs_K2_SetActorLocation_WithoutHit(slotPos)
      end
      local npcRot = UE4.FRotator(NPCInfo[7], NPCInfo[8], NPCInfo[6])
      if self.NPCActor then
        self.NPCActor:K2_SetActorRotation(npcRot, false)
        self.Slot_NPC:K2_SetActorRotation(npcRot, false)
      else
        self.Slot_NPC:K2_SetActorRotation(npcRot, false)
      end
      self.NPCAnimFrame = NPCInfo[9]
      print("Loaded NPC data: ID=" .. tostring(self.NPCID) .. ", Anim=" .. tostring(self.NPCAnim))
    end
  end
  local lightInfoIndex = 10
  for i = 4, #SaveJsonInfoList do
    local petInfo = SaveJsonInfoList[i]
    if petInfo[12] and "isPetInfo" ~= petInfo[12] then
      lightInfoIndex = i
      break
    end
    if petInfo and #petInfo >= 3 then
      local petIndex = i - 3
      if self.petDatas and petIndex <= #self.petDatas then
        self.petDatas[petIndex] = petInfo[1]
        local petbaseConf = _G.DataConfigManager:GetPetbaseConf(petInfo[1])
        self.petHalfHeight[petIndex] = self:GetModelHalfHeight(petbaseConf.model_conf)
      end
      if self.petList[petIndex] then
        self:ChangeActorPlayAnim(self.petList[petIndex].actor, petInfo[2], petIndex)
      else
        self.PetAnim[petIndex] = petInfo[2]
      end
      self.Body[petIndex] = petInfo[3]
      self.BodyText[petIndex]:SetText(self.Body[petIndex])
      local slotPos = UE4.FVector(petInfo[4], petInfo[5], petInfo[6])
      local petPos = UE4.FVector(petInfo[4], petInfo[5], petInfo[6] + self.petHalfHeight[petIndex])
      local petRot = UE4.FRotator(petInfo[8], petInfo[9], petInfo[7])
      if #petInfo >= 9 then
        if self.petList[petIndex] then
          local pet = self.petList[petIndex]
          if pet and pet.actor then
            pet.actor:Abs_K2_SetActorLocation_WithoutHit(petPos)
            pet.actor:K2_SetActorRotation(petRot, false)
            self.slotActors[petIndex]:Abs_K2_SetActorLocation_WithoutHit(slotPos)
            self.slotActors[petIndex]:K2_SetActorRotation(petRot, false)
            print("Loaded pet data for index " .. tostring(petIndex))
          end
        else
          self.slotActors[petIndex]:Abs_K2_SetActorLocation_WithoutHit(slotPos)
          self.slotActors[petIndex]:K2_SetActorRotation(petRot, false)
        end
        self.petAnimFrame[petIndex] = petInfo[10]
        local skyInfo = petInfo[11]
        if skyInfo then
          local AnimIndex = self.ComboBoxSky[petIndex]:FindOptionIndex(skyInfo)
          self.ComboBoxSky[petIndex]:SetSelectedIndex(AnimIndex)
        end
      end
    end
  end
  for i = lightInfoIndex, #SaveJsonInfoList do
    local lightIndex = i - lightInfoIndex + 1
    if not self.EnvSpotLightActorList[lightIndex] then
      break
    end
    local LightInfo = SaveJsonInfoList[i]
    local LightPos = UE4.FVector(LightInfo[1], LightInfo[2], LightInfo[3])
    local LightRot = UE4.FRotator(LightInfo[5], LightInfo[6], LightInfo[4])
    self.EnvSpotLightActorList[lightIndex]:Abs_K2_SetActorLocation_WithoutHit(LightPos)
    self.EnvSpotLightActorList[lightIndex]:K2_SetActorRotation(LightRot, false)
    local Intensity = LightInfo[7]
    self.EnvSpotLightActorList[lightIndex]:SetIntensity(Intensity)
    local LightColor = UE.FColor(LightInfo[8], LightInfo[9], LightInfo[10], LightInfo[11])
    self.EnvSpotLightActorList[lightIndex]:SetLightColor(LightColor)
    local AttenuationRadius = LightInfo[12]
    self.EnvSpotLightActorList[lightIndex]:SetAttenuationRadius(AttenuationRadius)
    local InnerConeAngle = LightInfo[13]
    self.EnvSpotLightActorList[lightIndex]:SetInnerConeAngle(InnerConeAngle)
    local OuterConeAngle = LightInfo[14]
    self.EnvSpotLightActorList[lightIndex]:SetOuterConeAngle(OuterConeAngle)
    local UseInverseSquaredFalloff
    if "true" == LightInfo[15] then
      UseInverseSquaredFalloff = true
    else
      UseInverseSquaredFalloff = false
    end
    self.EnvSpotLightActorList[lightIndex]:SetUseInverseSquaredFalloff(UseInverseSquaredFalloff)
    local LightFalloffExponent = LightInfo[16]
    self.EnvSpotLightActorList[lightIndex]:SetLightFalloffExponent(LightFalloffExponent)
  end
  self:LoadBattleConf(self.BattleID)
  print("Successfully loaded photo editor data")
  return true
end

function StarLightPhotoEditor_C:PetAnimStopFrame(petIndex, percent)
  if 7 ~= petIndex then
    if self.petList[petIndex].actor then
      self.petList[petIndex].actor:PlayAnimByNameUsePercent(self.PetAnim[petIndex] or "Idle", 0, percent, 0, 0, -1, 0)
    end
  elseif self.NPCActor then
    self.NPCActor:PlayAnimByNameUsePercent(self.NPCAnim or "Idle", 0, percent, 0, 0, -1, 0)
  end
end

function StarLightPhotoEditor_C:PetAnim1StopFrame(value)
  self:PetAnimStopFrame(1, value)
end

function StarLightPhotoEditor_C:PetAnim2StopFrame(value)
  self:PetAnimStopFrame(2, value)
end

function StarLightPhotoEditor_C:PetAnim3StopFrame(value)
  self:PetAnimStopFrame(3, value)
end

function StarLightPhotoEditor_C:PetAnim4StopFrame(value)
  self:PetAnimStopFrame(4, value)
end

function StarLightPhotoEditor_C:PetAnim5StopFrame(value)
  self:PetAnimStopFrame(5, value)
end

function StarLightPhotoEditor_C:PetAnim6StopFrame(value)
  self:PetAnimStopFrame(6, value)
end

function StarLightPhotoEditor_C:NPCAnimStopFrame(value)
  self:PetAnimStopFrame(7, value)
end

function StarLightPhotoEditor_C:AllPetAnimStopFrame(value)
  self.SliderLength = value
  for i, pet in ipairs(self.petList) do
    if pet.actor then
      self:ChangeActorPlayAnim(pet.actor, nil, i)
    end
  end
  self:ChangeActorPlayAnim(self.NPCActor, nil, 7)
end

function StarLightPhotoEditor_C:OnAddEventListener()
  self:AddButtonListener(self.LoadBtn, self.LoadFileFromJson)
  self:AddButtonListener(self.SaveBtn, self.SaveFileToJson)
  for i, comboBox in ipairs(self.ComboBoxSky) do
    local function CreateSelectionHandler(index)
      return function()
        self:ChangeActorPlayAnim(nil, nil, index)
      end
    end
    
    local handler = CreateSelectionHandler(i)
    comboBox.OnSelectionChanged:Add(self, handler)
  end
  self.EditableText_63.OnTextCommitted:Add(self, self.ChangeLoadJsonPath)
  self.EditableText_64.OnTextCommitted:Add(self, self.ChangeSaveJsonPath)
  self.EditableText.OnTextCommitted:Add(self, self.ChangeBattleID)
  self.EditableText_46.OnTextCommitted:Add(self, self.ChangeBgPath)
  self.Slider_0.OnValueChanged:Add(self, self.AllPetAnimStopFrame)
  self.Slider.OnValueChanged:Add(self, self.PetAnim1StopFrame)
  self.Slider_1.OnValueChanged:Add(self, self.PetAnim2StopFrame)
  self.Slider_2.OnValueChanged:Add(self, self.PetAnim3StopFrame)
  self.Slider_3.OnValueChanged:Add(self, self.PetAnim4StopFrame)
  self.Slider_4.OnValueChanged:Add(self, self.PetAnim5StopFrame)
  self.Slider_5.OnValueChanged:Add(self, self.PetAnim6StopFrame)
  self.Slider_6.OnValueChanged:Add(self, self.NPCAnimStopFrame)
  self.ComboBoxString_68.OnSelectionChanged:Add(self, self.OnPet1AnimChange)
  self.ComboBoxString_1.OnSelectionChanged:Add(self, self.OnPet2AnimChange)
  self.ComboBoxString_2.OnSelectionChanged:Add(self, self.OnPet3AnimChange)
  self.ComboBoxString_3.OnSelectionChanged:Add(self, self.OnPet4AnimChange)
  self.ComboBoxString_4.OnSelectionChanged:Add(self, self.OnPet5AnimChange)
  self.ComboBoxString_5.OnSelectionChanged:Add(self, self.OnPet6AnimChange)
  self.ComboBoxString.OnSelectionChanged:Add(self, self.OnNPCAnimChange)
  self.EditableText_2.OnTextCommitted:Add(self, self.ChangeNPCID)
  self.EditableText_11.OnTextCommitted:Add(self, self.ChangeNPCPosX)
  self.EditableText_12.OnTextCommitted:Add(self, self.ChangeNPCPosY)
  self.EditableText_13.OnTextCommitted:Add(self, self.ChangeNPCPosZ)
  self.EditableText_15.OnTextCommitted:Add(self, self.ChangeNPCRotX)
  self.EditableText_16.OnTextCommitted:Add(self, self.ChangeNPCRotY)
  self.EditableText_17.OnTextCommitted:Add(self, self.ChangeNPCRotZ)
  self.EditableText_18.OnTextCommitted:Add(self, self.ChangeCameraPosX)
  self.EditableText_19.OnTextCommitted:Add(self, self.ChangeCameraPosY)
  self.EditableText_20.OnTextCommitted:Add(self, self.ChangeCameraPosZ)
  self.EditableText_22.OnTextCommitted:Add(self, self.ChangeCameraRotX)
  self.EditableText_23.OnTextCommitted:Add(self, self.ChangeCameraRotY)
  self.EditableText_24.OnTextCommitted:Add(self, self.ChangeCameraRotZ)
  self.EditableText_3.OnTextCommitted:Add(self, self.ChangePet1ID)
  self.EditableText_10.OnTextCommitted:Add(self, self.ChangePet1Body)
  self.EditableText_4.OnTextCommitted:Add(self, self.ChangePet1PosX)
  self.EditableText_4.OnTextCommitted:Add(self, self.ChangePet1PosX)
  self.EditableText_5.OnTextCommitted:Add(self, self.ChangePet1PosY)
  self.EditableText_6.OnTextCommitted:Add(self, self.ChangePet1PosZ)
  self.EditableText_7.OnTextCommitted:Add(self, self.ChangePet1RotX)
  self.EditableText_8.OnTextCommitted:Add(self, self.ChangePet1RotY)
  self.EditableText_9.OnTextCommitted:Add(self, self.ChangePet1RotZ)
  self.EditableText_1.OnTextCommitted:Add(self, self.ChangePet2ID)
  self.EditableText_14.OnTextCommitted:Add(self, self.ChangePet2Body)
  self.EditableText_21.OnTextCommitted:Add(self, self.ChangePet2PosX)
  self.EditableText_25.OnTextCommitted:Add(self, self.ChangePet2PosY)
  self.EditableText_26.OnTextCommitted:Add(self, self.ChangePet2PosZ)
  self.EditableText_27.OnTextCommitted:Add(self, self.ChangePet2RotX)
  self.EditableText_28.OnTextCommitted:Add(self, self.ChangePet2RotY)
  self.EditableText_29.OnTextCommitted:Add(self, self.ChangePet2RotZ)
  self.EditableText_30.OnTextCommitted:Add(self, self.ChangePet3ID)
  self.EditableText_31.OnTextCommitted:Add(self, self.ChangePet3Body)
  self.EditableText_32.OnTextCommitted:Add(self, self.ChangePet3PosX)
  self.EditableText_33.OnTextCommitted:Add(self, self.ChangePet3PosY)
  self.EditableText_34.OnTextCommitted:Add(self, self.ChangePet3PosZ)
  self.EditableText_35.OnTextCommitted:Add(self, self.ChangePet3RotX)
  self.EditableText_36.OnTextCommitted:Add(self, self.ChangePet3RotY)
  self.EditableText_37.OnTextCommitted:Add(self, self.ChangePet3RotZ)
  self.EditableText_38.OnTextCommitted:Add(self, self.ChangePet4ID)
  self.EditableText_39.OnTextCommitted:Add(self, self.ChangePet4Body)
  self.EditableText_40.OnTextCommitted:Add(self, self.ChangePet4PosX)
  self.EditableText_41.OnTextCommitted:Add(self, self.ChangePet4PosY)
  self.EditableText_42.OnTextCommitted:Add(self, self.ChangePet4PosZ)
  self.EditableText_43.OnTextCommitted:Add(self, self.ChangePet4RotX)
  self.EditableText_44.OnTextCommitted:Add(self, self.ChangePet4RotY)
  self.EditableText_45.OnTextCommitted:Add(self, self.ChangePet4RotZ)
  self.EditableText_47.OnTextCommitted:Add(self, self.ChangePet5ID)
  self.EditableText_48.OnTextCommitted:Add(self, self.ChangePet5Body)
  self.EditableText_49.OnTextCommitted:Add(self, self.ChangePet5PosX)
  self.EditableText_50.OnTextCommitted:Add(self, self.ChangePet5PosY)
  self.EditableText_51.OnTextCommitted:Add(self, self.ChangePet5PosZ)
  self.EditableText_52.OnTextCommitted:Add(self, self.ChangePet5RotX)
  self.EditableText_53.OnTextCommitted:Add(self, self.ChangePet5RotY)
  self.EditableText_54.OnTextCommitted:Add(self, self.ChangePet5RotZ)
  self.EditableText_55.OnTextCommitted:Add(self, self.ChangePet6ID)
  self.EditableText_56.OnTextCommitted:Add(self, self.ChangePet6Body)
  self.EditableText_57.OnTextCommitted:Add(self, self.ChangePet6PosX)
  self.EditableText_58.OnTextCommitted:Add(self, self.ChangePet6PosY)
  self.EditableText_59.OnTextCommitted:Add(self, self.ChangePet6PosZ)
  self.EditableText_60.OnTextCommitted:Add(self, self.ChangePet6RotX)
  self.EditableText_61.OnTextCommitted:Add(self, self.ChangePet6RotY)
  self.EditableText_62.OnTextCommitted:Add(self, self.ChangePet6RotZ)
end

function StarLightPhotoEditor_C:ChangeLoadJsonPath(text, CommitMethod)
  if text then
    self.LoadJsonPath = text
  end
end

function StarLightPhotoEditor_C:ChangeSaveJsonPath(text, CommitMethod)
  if text then
    self.SaveJsonPath = text
  end
end

function StarLightPhotoEditor_C:OnPet1AnimChange(SelectedItem, SelectionType)
  if -1 == self.ComboBoxString_68:GetSelectedIndex() then
    return
  end
  self:ChangeActorPlayAnim(self.petList[1].actor, SelectedItem, 1)
end

function StarLightPhotoEditor_C:OnPet2AnimChange(SelectedItem, SelectionType)
  if -1 == self.ComboBoxString_1:GetSelectedIndex() then
    return
  end
  self:ChangeActorPlayAnim(self.petList[2].actor, SelectedItem, 2)
end

function StarLightPhotoEditor_C:OnPet3AnimChange(SelectedItem, SelectionType)
  if -1 == self.ComboBoxString_2:GetSelectedIndex() then
    return
  end
  self:ChangeActorPlayAnim(self.petList[3].actor, SelectedItem, 3)
end

function StarLightPhotoEditor_C:OnPet4AnimChange(SelectedItem, SelectionType)
  if -1 == self.ComboBoxString_3:GetSelectedIndex() then
    return
  end
  self:ChangeActorPlayAnim(self.petList[4].actor, SelectedItem, 4)
end

function StarLightPhotoEditor_C:OnPet5AnimChange(SelectedItem, SelectionType)
  if -1 == self.ComboBoxString_4:GetSelectedIndex() then
    return
  end
  self:ChangeActorPlayAnim(self.petList[5].actor, SelectedItem, 5)
end

function StarLightPhotoEditor_C:OnPet6AnimChange(SelectedItem, SelectionType)
  if -1 == self.ComboBoxString_5:GetSelectedIndex() then
    return
  end
  self:ChangeActorPlayAnim(self.petList[6].actor, SelectedItem, 6)
end

function StarLightPhotoEditor_C:OnNPCAnimChange(SelectedItem, SelectionType)
  if -1 == self.ComboBoxString:GetSelectedIndex() then
    return
  end
  self:ChangeActorPlayAnim(self.NPCActor, SelectedItem, 7)
end

function StarLightPhotoEditor_C:ChangeCameraPosX(text, CommitMethod)
  local x = tonumber(text)
  if x and CommitMethod == UE4.ETextCommit.OnEnter then
    local pos = self.CameraActor:Abs_K2_GetActorLocation()
    if self.CameraActor then
      self.CameraActor:Abs_K2_SetActorLocation_WithoutHit(UE4.FVector(x, pos.y, pos.z))
    end
  end
end

function StarLightPhotoEditor_C:ChangeCameraPosY(text, CommitMethod)
  local y = tonumber(text)
  if y and CommitMethod == UE4.ETextCommit.OnEnter then
    local pos = self.CameraActor:Abs_K2_GetActorLocation()
    if self.CameraActor then
      self.CameraActor:Abs_K2_SetActorLocation_WithoutHit(UE4.FVector(pos.x, y, pos.z))
    end
  end
end

function StarLightPhotoEditor_C:ChangeCameraPosZ(text, CommitMethod)
  local z = tonumber(text)
  if z and CommitMethod == UE4.ETextCommit.OnEnter then
    local pos = self.CameraActor:Abs_K2_GetActorLocation()
    if self.CameraActor then
      self.CameraActor:Abs_K2_SetActorLocation_WithoutHit(UE4.FVector(pos.x, pos.y, z))
    end
  end
end

function StarLightPhotoEditor_C:ChangeCameraRotX(text, CommitMethod)
  local x = tonumber(text)
  if x and CommitMethod == UE4.ETextCommit.OnEnter then
    local rot = self.CameraActor:K2_GetActorRotation()
    local y = rot.Pitch
    local z = rot.Yaw
    self.CameraActor:K2_SetActorRotation(UE4.FRotator(y, z, x), false)
  end
end

function StarLightPhotoEditor_C:ChangeCameraRotY(text, CommitMethod)
  local y = tonumber(text)
  if y and CommitMethod == UE4.ETextCommit.OnEnter then
    local rot = self.CameraActor:K2_GetActorRotation()
    local z = rot.Yaw
    local x = rot.Roll
    self.CameraActor:K2_SetActorRotation(UE4.FRotator(y, z, x), false)
  end
end

function StarLightPhotoEditor_C:ChangeCameraRotZ(text, CommitMethod)
  local z = tonumber(text)
  if z and CommitMethod == UE4.ETextCommit.OnEnter then
    local rot = self.CameraActor:K2_GetActorRotation()
    local y = rot.Pitch
    local x = rot.Roll
    self.CameraActor:K2_SetActorRotation(UE4.FRotator(y, z, x), false)
  end
end

function StarLightPhotoEditor_C:ChangeNPCID(text, CommitMethod)
  local ID = tonumber(text)
  if ID and CommitMethod == UE4.ETextCommit.OnEnter then
    self:CreateNPC(ID)
  end
end

function StarLightPhotoEditor_C:ChangeNPCPosX(text, CommitMethod)
  local x = tonumber(text)
  if x and CommitMethod == UE4.ETextCommit.OnEnter then
    local pos = self.NPCActor:Abs_K2_GetActorLocation()
    if self.NPCActor then
      self.NPCActor:Abs_K2_SetActorLocation_WithoutHit(UE4.FVector(x, pos.y, pos.z))
    end
  end
end

function StarLightPhotoEditor_C:ChangeNPCPosY(text, CommitMethod)
  local y = tonumber(text)
  if y and CommitMethod == UE4.ETextCommit.OnEnter then
    local pos = self.NPCActor:Abs_K2_GetActorLocation()
    if self.NPCActor then
      self.NPCActor:Abs_K2_SetActorLocation_WithoutHit(UE4.FVector(pos.x, y, pos.z))
    end
  end
end

function StarLightPhotoEditor_C:ChangeNPCPosZ(text, CommitMethod)
  local z = tonumber(text)
  if z and CommitMethod == UE4.ETextCommit.OnEnter then
    local pos = self.NPCActor:Abs_K2_GetActorLocation()
    if self.NPCActor then
      self.NPCActor:Abs_K2_SetActorLocation_WithoutHit(UE4.FVector(pos.x, pos.y, z))
    end
  end
end

function StarLightPhotoEditor_C:ChangeNPCRotX(text, CommitMethod)
  local x = tonumber(text)
  if x and CommitMethod == UE4.ETextCommit.OnEnter then
    local rot = self.NPCActor:K2_GetActorRotation()
    local y = rot.Pitch
    local z = rot.Yaw
    self.NPCActor:K2_SetActorRotation(UE4.FRotator(y, z, x), false)
  end
end

function StarLightPhotoEditor_C:ChangeNPCRotY(text, CommitMethod)
  local y = tonumber(text)
  if y and CommitMethod == UE4.ETextCommit.OnEnter then
    local rot = self.NPCActor:K2_GetActorRotation()
    local z = rot.Yaw
    local x = rot.Roll
    self.NPCActor:K2_SetActorRotation(UE4.FRotator(y, z, x), false)
  end
end

function StarLightPhotoEditor_C:ChangeNPCRotZ(text, CommitMethod)
  local z = tonumber(text)
  if z and CommitMethod == UE4.ETextCommit.OnEnter then
    local rot = self.NPCActor:K2_GetActorRotation()
    local y = rot.Pitch
    local x = rot.Roll
    self.NPCActor:K2_SetActorRotation(UE4.FRotator(y, z, x), false)
  end
end

function StarLightPhotoEditor_C:ChangePet1ID(text, CommitMethod)
  local ID = tonumber(text)
  if ID and CommitMethod == UE4.ETextCommit.OnEnter then
    self:ChangePet(1, ID)
  end
end

function StarLightPhotoEditor_C:ChangePet1PosX(text, CommitMethod)
  local x = tonumber(text)
  if x and CommitMethod == UE4.ETextCommit.OnEnter then
    local pos = self.petList[1].actor:Abs_K2_GetActorLocation()
    if self.petList[1].actor then
      self.petList[1].actor:Abs_K2_SetActorLocation_WithoutHit(UE4.FVector(x, pos.y, pos.z))
    end
  end
end

function StarLightPhotoEditor_C:ChangePet1PosY(text, CommitMethod)
  local y = tonumber(text)
  if y and CommitMethod == UE4.ETextCommit.OnEnter then
    local pos = self.petList[1].actor:Abs_K2_GetActorLocation()
    if self.petList[1].actor then
      self.petList[1].actor:Abs_K2_SetActorLocation_WithoutHit(UE4.FVector(pos.x, y, pos.z))
    end
  end
end

function StarLightPhotoEditor_C:ChangePet1PosZ(text, CommitMethod)
  local z = tonumber(text)
  if z and CommitMethod == UE4.ETextCommit.OnEnter then
    local pos = self.petList[1].actor:Abs_K2_GetActorLocation()
    if self.petList[1].actor then
      self.petList[1].actor:Abs_K2_SetActorLocation_WithoutHit(UE4.FVector(pos.x, pos.y, z))
    end
  end
end

function StarLightPhotoEditor_C:ChangePet1RotX(text, CommitMethod)
  local x = tonumber(text)
  if x and CommitMethod == UE4.ETextCommit.OnEnter then
    local rot = self.petList[1].actor:K2_GetActorRotation()
    local y = rot.Pitch
    local z = rot.Yaw
    self.petList[1].actor:K2_SetActorRotation(UE4.FRotator(y, z, x), false)
  end
end

function StarLightPhotoEditor_C:ChangePet1RotY(text, CommitMethod)
  local y = tonumber(text)
  if y and CommitMethod == UE4.ETextCommit.OnEnter then
    local rot = self.petList[1].actor:K2_GetActorRotation()
    local z = rot.Yaw
    local x = rot.Roll
    self.petList[1].actor:K2_SetActorRotation(UE4.FRotator(y, z, x), false)
  end
end

function StarLightPhotoEditor_C:ChangePet1RotZ(text, CommitMethod)
  local z = tonumber(text)
  if z and CommitMethod == UE4.ETextCommit.OnEnter then
    local rot = self.petList[1].actor:K2_GetActorRotation()
    local y = rot.Pitch
    local x = rot.Roll
    self.petList[1].actor:K2_SetActorRotation(UE4.FRotator(y, z, x), false)
  end
end

function StarLightPhotoEditor_C:ChangePet1Body(text, CommitMethod)
  local body = tonumber(text)
  if body then
    self.Body[1] = body
  end
end

function StarLightPhotoEditor_C:ChangePet2Body(text, CommitMethod)
  local body = tonumber(text)
  if body then
    self.Body[2] = body
  end
end

function StarLightPhotoEditor_C:ChangePet3Body(text, CommitMethod)
  local body = tonumber(text)
  if body then
    self.Body[3] = body
  end
end

function StarLightPhotoEditor_C:ChangePet4Body(text, CommitMethod)
  local body = tonumber(text)
  if body then
    self.Body[4] = body
  end
end

function StarLightPhotoEditor_C:ChangePet5Body(text, CommitMethod)
  local body = tonumber(text)
  if body then
    self.Body[5] = body
  end
end

function StarLightPhotoEditor_C:ChangePet6Body(text, CommitMethod)
  local body = tonumber(text)
  if body then
    self.Body[6] = body
  end
end

function StarLightPhotoEditor_C:ChangeBattleID(text, CommitMethod)
  local ID = tonumber(text)
  if ID and CommitMethod == UE4.ETextCommit.OnEnter then
    self.BattleID = ID
    self:LoadBattleConf(ID)
  end
end

function StarLightPhotoEditor_C:ChangeBgPath(text, CommitMethod)
  local BGPath = text
  if BGPath then
    local FilePath = "/Game/ArtRes/Asset/Environment/Interator/Curtain/TEX/"
    local FullPath = FilePath .. BGPath .. "." .. BGPath
    local Material = LoadObject(FullPath)
    self.BGPath = BGPath
    local meshComponent = self.BGAsset:GetComponentByClass(UE4.USkeletalMeshComponent)
    meshComponent:SetMaterial(0, Material)
  end
end

function StarLightPhotoEditor_C:ChangePet2ID(text, CommitMethod)
  local ID = tonumber(text)
  if ID and CommitMethod == UE4.ETextCommit.OnEnter then
    self:ChangePet(2, ID)
  end
end

function StarLightPhotoEditor_C:ChangePet2PosX(text, CommitMethod)
  local x = tonumber(text)
  if x and CommitMethod == UE4.ETextCommit.OnEnter then
    local pos = self.petList[2].actor:Abs_K2_GetActorLocation()
    if self.petList[2].actor then
      self.petList[2].actor:Abs_K2_SetActorLocation_WithoutHit(UE4.FVector(x, pos.y, pos.z))
    end
  end
end

function StarLightPhotoEditor_C:ChangePet2PosY(text, CommitMethod)
  local y = tonumber(text)
  if y and CommitMethod == UE4.ETextCommit.OnEnter then
    local pos = self.petList[2].actor:Abs_K2_GetActorLocation()
    if self.petList[2].actor then
      self.petList[2].actor:Abs_K2_SetActorLocation_WithoutHit(UE4.FVector(pos.x, y, pos.z))
    end
  end
end

function StarLightPhotoEditor_C:ChangePet2PosZ(text, CommitMethod)
  local z = tonumber(text)
  if z and CommitMethod == UE4.ETextCommit.OnEnter then
    local pos = self.petList[2].actor:Abs_K2_GetActorLocation()
    if self.petList[2].actor then
      self.petList[2].actor:Abs_K2_SetActorLocation_WithoutHit(UE4.FVector(pos.x, pos.y, z))
    end
  end
end

function StarLightPhotoEditor_C:ChangePet2RotX(text, CommitMethod)
  local x = tonumber(text)
  if x and CommitMethod == UE4.ETextCommit.OnEnter then
    local rot = self.petList[2].actor:K2_GetActorRotation()
    local y = rot.Pitch
    local z = rot.Yaw
    self.petList[2].actor:K2_SetActorRotation(UE4.FRotator(y, z, x), false)
  end
end

function StarLightPhotoEditor_C:ChangePet2RotY(text, CommitMethod)
  local y = tonumber(text)
  if y and CommitMethod == UE4.ETextCommit.OnEnter then
    local rot = self.petList[2].actor:K2_GetActorRotation()
    local z = rot.Yaw
    local x = rot.Roll
    self.petList[2].actor:K2_SetActorRotation(UE4.FRotator(y, z, x), false)
  end
end

function StarLightPhotoEditor_C:ChangePet2RotZ(text, CommitMethod)
  local z = tonumber(text)
  if z and CommitMethod == UE4.ETextCommit.OnEnter then
    local rot = self.petList[2].actor:K2_GetActorRotation()
    local y = rot.Pitch
    local x = rot.Roll
    self.petList[2].actor:K2_SetActorRotation(UE4.FRotator(y, z, x), false)
  end
end

function StarLightPhotoEditor_C:ChangePet2Body(text, CommitMethod)
  local body = tonumber(text)
  if body then
    self.Body[2] = body
  end
end

function StarLightPhotoEditor_C:ChangePet3ID(text, CommitMethod)
  local ID = tonumber(text)
  if ID and CommitMethod == UE4.ETextCommit.OnEnter then
    self:ChangePet(3, ID)
  end
end

function StarLightPhotoEditor_C:ChangePet3PosX(text, CommitMethod)
  local x = tonumber(text)
  if x and CommitMethod == UE4.ETextCommit.OnEnter then
    local pos = self.petList[3].actor:Abs_K2_GetActorLocation()
    if self.petList[3].actor then
      self.petList[3].actor:Abs_K2_SetActorLocation_WithoutHit(UE4.FVector(x, pos.y, pos.z))
    end
  end
end

function StarLightPhotoEditor_C:ChangePet3PosY(text, CommitMethod)
  local y = tonumber(text)
  if y and CommitMethod == UE4.ETextCommit.OnEnter then
    local pos = self.petList[3].actor:Abs_K2_GetActorLocation()
    if self.petList[3].actor then
      self.petList[3].actor:Abs_K2_SetActorLocation_WithoutHit(UE4.FVector(pos.x, y, pos.z))
    end
  end
end

function StarLightPhotoEditor_C:ChangePet3PosZ(text, CommitMethod)
  local z = tonumber(text)
  if z and CommitMethod == UE4.ETextCommit.OnEnter then
    local pos = self.petList[3].actor:Abs_K2_GetActorLocation()
    if self.petList[3].actor then
      self.petList[3].actor:Abs_K2_SetActorLocation_WithoutHit(UE4.FVector(pos.x, pos.y, z))
    end
  end
end

function StarLightPhotoEditor_C:ChangePet3RotX(text, CommitMethod)
  local x = tonumber(text)
  if x and CommitMethod == UE4.ETextCommit.OnEnter then
    local rot = self.petList[3].actor:K2_GetActorRotation()
    local y = rot.Pitch
    local z = rot.Yaw
    self.petList[3].actor:K2_SetActorRotation(UE4.FRotator(y, z, x), false)
  end
end

function StarLightPhotoEditor_C:ChangePet3RotY(text, CommitMethod)
  local y = tonumber(text)
  if y and CommitMethod == UE4.ETextCommit.OnEnter then
    local rot = self.petList[3].actor:K2_GetActorRotation()
    local z = rot.Yaw
    local x = rot.Roll
    self.petList[3].actor:K2_SetActorRotation(UE4.FRotator(y, z, x), false)
  end
end

function StarLightPhotoEditor_C:ChangePet3RotZ(text, CommitMethod)
  local z = tonumber(text)
  if z and CommitMethod == UE4.ETextCommit.OnEnter then
    local rot = self.petList[3].actor:K2_GetActorRotation()
    local y = rot.Pitch
    local x = rot.Roll
    self.petList[3].actor:K2_SetActorRotation(UE4.FRotator(y, z, x), false)
  end
end

function StarLightPhotoEditor_C:ChangePet3Body(text, CommitMethod)
  local body = tonumber(text)
  if body then
    self.Body[3] = body
  end
end

function StarLightPhotoEditor_C:ChangePet4ID(text, CommitMethod)
  local ID = tonumber(text)
  if ID and CommitMethod == UE4.ETextCommit.OnEnter then
    self:ChangePet(4, ID)
  end
end

function StarLightPhotoEditor_C:ChangePet4PosX(text, CommitMethod)
  local x = tonumber(text)
  if x and CommitMethod == UE4.ETextCommit.OnEnter then
    local pos = self.petList[4].actor:Abs_K2_GetActorLocation()
    if self.petList[4].actor then
      self.petList[4].actor:Abs_K2_SetActorLocation_WithoutHit(UE4.FVector(x, pos.y, pos.z))
    end
  end
end

function StarLightPhotoEditor_C:ChangePet4PosY(text, CommitMethod)
  local y = tonumber(text)
  if y and CommitMethod == UE4.ETextCommit.OnEnter then
    local pos = self.petList[4].actor:Abs_K2_GetActorLocation()
    if self.petList[4].actor then
      self.petList[4].actor:Abs_K2_SetActorLocation_WithoutHit(UE4.FVector(pos.x, y, pos.z))
    end
  end
end

function StarLightPhotoEditor_C:ChangePet4PosZ(text, CommitMethod)
  local z = tonumber(text)
  if z and CommitMethod == UE4.ETextCommit.OnEnter then
    local pos = self.petList[4].actor:Abs_K2_GetActorLocation()
    if self.petList[4].actor then
      self.petList[4].actor:Abs_K2_SetActorLocation_WithoutHit(UE4.FVector(pos.x, pos.y, z))
    end
  end
end

function StarLightPhotoEditor_C:ChangePet4RotX(text, CommitMethod)
  local x = tonumber(text)
  if x and CommitMethod == UE4.ETextCommit.OnEnter then
    local rot = self.petList[4].actor:K2_GetActorRotation()
    local y = rot.Pitch
    local z = rot.Yaw
    self.petList[4].actor:K2_SetActorRotation(UE4.FRotator(y, z, x), false)
  end
end

function StarLightPhotoEditor_C:ChangePet4RotY(text, CommitMethod)
  local y = tonumber(text)
  if y and CommitMethod == UE4.ETextCommit.OnEnter then
    local rot = self.petList[4].actor:K2_GetActorRotation()
    local z = rot.Yaw
    local x = rot.Roll
    self.petList[4].actor:K2_SetActorRotation(UE4.FRotator(y, z, x), false)
  end
end

function StarLightPhotoEditor_C:ChangePet4RotZ(text, CommitMethod)
  local z = tonumber(text)
  if z and CommitMethod == UE4.ETextCommit.OnEnter then
    local rot = self.petList[4].actor:K2_GetActorRotation()
    local y = rot.Pitch
    local x = rot.Roll
    self.petList[4].actor:K2_SetActorRotation(UE4.FRotator(y, z, x), false)
  end
end

function StarLightPhotoEditor_C:ChangePet4Body(text, CommitMethod)
  local body = tonumber(text)
  if body then
    self.Body[4] = body
  end
end

function StarLightPhotoEditor_C:ChangePet5ID(text, CommitMethod)
  local ID = tonumber(text)
  if ID and CommitMethod == UE4.ETextCommit.OnEnter then
    self:ChangePet(5, ID)
  end
end

function StarLightPhotoEditor_C:ChangePet5PosX(text, CommitMethod)
  local x = tonumber(text)
  if x and CommitMethod == UE4.ETextCommit.OnEnter then
    local pos = self.petList[5].actor:Abs_K2_GetActorLocation()
    if self.petList[5].actor then
      self.petList[5].actor:Abs_K2_SetActorLocation_WithoutHit(UE4.FVector(x, pos.y, pos.z))
    end
  end
end

function StarLightPhotoEditor_C:ChangePet5PosY(text, CommitMethod)
  local y = tonumber(text)
  if y and CommitMethod == UE4.ETextCommit.OnEnter then
    local pos = self.petList[5].actor:Abs_K2_GetActorLocation()
    if self.petList[5].actor then
      self.petList[5].actor:Abs_K2_SetActorLocation_WithoutHit(UE4.FVector(pos.x, y, pos.z))
    end
  end
end

function StarLightPhotoEditor_C:ChangePet5PosZ(text, CommitMethod)
  local z = tonumber(text)
  if z and CommitMethod == UE4.ETextCommit.OnEnter then
    local pos = self.petList[5].actor:Abs_K2_GetActorLocation()
    if self.petList[5].actor then
      self.petList[5].actor:Abs_K2_SetActorLocation_WithoutHit(UE4.FVector(pos.x, pos.y, z))
    end
  end
end

function StarLightPhotoEditor_C:ChangePet5RotX(text, CommitMethod)
  local x = tonumber(text)
  if x and CommitMethod == UE4.ETextCommit.OnEnter then
    local rot = self.petList[5].actor:K2_GetActorRotation()
    local y = rot.Pitch
    local z = rot.Yaw
    self.petList[5].actor:K2_SetActorRotation(UE4.FRotator(y, z, x), false)
  end
end

function StarLightPhotoEditor_C:ChangePet5RotY(text, CommitMethod)
  local y = tonumber(text)
  if y and CommitMethod == UE4.ETextCommit.OnEnter then
    local rot = self.petList[5].actor:K2_GetActorRotation()
    local z = rot.Yaw
    local x = rot.Roll
    self.petList[5].actor:K2_SetActorRotation(UE4.FRotator(y, z, x), false)
  end
end

function StarLightPhotoEditor_C:ChangePet5RotZ(text, CommitMethod)
  local z = tonumber(text)
  if z and CommitMethod == UE4.ETextCommit.OnEnter then
    local rot = self.petList[5].actor:K2_GetActorRotation()
    local y = rot.Pitch
    local x = rot.Roll
    self.petList[5].actor:K2_SetActorRotation(UE4.FRotator(y, z, x), false)
  end
end

function StarLightPhotoEditor_C:ChangePet5Body(text, CommitMethod)
  local body = tonumber(text)
  if body then
    self.Body[5] = body
  end
end

function StarLightPhotoEditor_C:ChangePet6ID(text, CommitMethod)
  local ID = tonumber(text)
  if ID and CommitMethod == UE4.ETextCommit.OnEnter then
    self:ChangePet(6, ID)
  end
end

function StarLightPhotoEditor_C:ChangePet6PosX(text, CommitMethod)
  local x = tonumber(text)
  if x and CommitMethod == UE4.ETextCommit.OnEnter then
    local pos = self.petList[6].actor:Abs_K2_GetActorLocation()
    if self.petList[6].actor then
      self.petList[6].actor:Abs_K2_SetActorLocation_WithoutHit(UE4.FVector(x, pos.y, pos.z))
    end
  end
end

function StarLightPhotoEditor_C:ChangePet6PosY(text, CommitMethod)
  local y = tonumber(text)
  if y and CommitMethod == UE4.ETextCommit.OnEnter then
    local pos = self.petList[6].actor:Abs_K2_GetActorLocation()
    if self.petList[6].actor then
      self.petList[6].actor:Abs_K2_SetActorLocation_WithoutHit(UE4.FVector(pos.x, y, pos.z))
    end
  end
end

function StarLightPhotoEditor_C:ChangePet6PosZ(text, CommitMethod)
  local z = tonumber(text)
  if z and CommitMethod == UE4.ETextCommit.OnEnter then
    local pos = self.petList[6].actor:Abs_K2_GetActorLocation()
    if self.petList[6].actor then
      self.petList[6].actor:Abs_K2_SetActorLocation_WithoutHit(UE4.FVector(pos.x, pos.y, z))
    end
  end
end

function StarLightPhotoEditor_C:ChangePet6RotX(text, CommitMethod)
  local x = tonumber(text)
  if x and CommitMethod == UE4.ETextCommit.OnEnter then
    local rot = self.petList[6].actor:K2_GetActorRotation()
    local y = rot.Pitch
    local z = rot.Yaw
    self.petList[6].actor:K2_SetActorRotation(UE4.FRotator(y, z, x), false)
  end
end

function StarLightPhotoEditor_C:ChangePet6RotY(text, CommitMethod)
  local y = tonumber(text)
  if y and CommitMethod == UE4.ETextCommit.OnEnter then
    local rot = self.petList[6].actor:K2_GetActorRotation()
    local z = rot.Yaw
    local x = rot.Roll
    self.petList[6].actor:K2_SetActorRotation(UE4.FRotator(y, z, x), false)
  end
end

function StarLightPhotoEditor_C:ChangePet6RotZ(text, CommitMethod)
  local z = tonumber(text)
  if z and CommitMethod == UE4.ETextCommit.OnEnter then
    local rot = self.petList[6].actor:K2_GetActorRotation()
    local y = rot.Pitch
    local x = rot.Roll
    self.petList[6].actor:K2_SetActorRotation(UE4.FRotator(y, z, x), false)
  end
end

function StarLightPhotoEditor_C:ChangePet6Body(text, CommitMethod)
  local body = tonumber(text)
  if body then
    self.Body[6] = body
  end
end

return StarLightPhotoEditor_C
