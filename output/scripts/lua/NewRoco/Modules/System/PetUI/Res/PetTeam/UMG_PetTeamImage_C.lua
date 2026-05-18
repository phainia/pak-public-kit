local PetUtils = require("NewRoco.Utils.PetUtils")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local UMG_PetTeamImage_C = _G.NRCViewBase:Extend("UMG_PetTeamImage_C")
local PetMutationUtils = require("NewRoco.Utils.PetMutationUtils")
local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local Clamp = math.clamp
local RandomPetRotation = UE.FRotator(0, 190, 0)

function UMG_PetTeamImage_C:OnConstruct()
  self.Overridden.Construct(self)
  self.petList = {}
  self.slotActors = {}
  self.isFirstRun = true
  self.State = false
  self:RegisterEvent(self, PetUIModuleEvent.PetTeamTouchStarted, self.OnPetTeamTouchStarted)
  self:RegisterEvent(self, PetUIModuleEvent.PetTeamTouchMoved, self.OnPetTeamTouchMoved)
  self:RegisterEvent(self, PetUIModuleEvent.PetTeamTouchEnded, self.OnPetTeamTouchEnded)
  self:RegisterEvent(self, PetUIModuleEvent.PetTeamWarehouseItemSelected, self.OnPetTeamWarehouseItemSelected)
  self:InitUI()
end

function UMG_PetTeamImage_C:InitUI()
  self:InitSlots()
  self:InitSceneCapture()
  self:LoadSelectSkill()
end

function UMG_PetTeamImage_C:LoadSelectSkill()
  local assetPath = "/Game/ArtRes/Effects/G6Skill/UI/Team/G6_UI_PVPTeamShow.G6_UI_PVPTeamShow_C"
  self:LoadPanelRes(assetPath, 255, self.OnSkill1LoadSucc)
  assetPath = "/Game/ArtRes/Effects/G6Skill/UI/Team/G6_UI_PVPTeamLoop.G6_UI_PVPTeamLoop_C"
  self:LoadPanelRes(assetPath, 255, self.OnSkill2LoadSucc)
end

function UMG_PetTeamImage_C:OnSkill1LoadSucc(resRequest, skillClass)
  self.skillClass = skillClass
  self.skillClassRef = skillClass and UnLua.Ref(skillClass)
  if self.IsWaitingSkillLoad then
    self:SetTeamData(self.teamIdx, self.teamData, self.curTeamType)
    self.IsWaitingSkillLoad = false
  end
end

function UMG_PetTeamImage_C:OnSkill2LoadSucc(resRequest, particleObj)
  self.particleObject = particleObj
  self.particleObjectRef = particleObj and UnLua.Ref(particleObj)
end

function UMG_PetTeamImage_C:InitSlots()
  local slotActors = self.slotActors
  for i = 1, 6 do
    local slotActor = self.previewWorld:getActorByName("Slot_" .. i)
    if slotActor then
      slotActors[#slotActors + 1] = slotActor
    end
  end
end

function UMG_PetTeamImage_C:SetParent(parent)
  self.Parent = parent
end

function UMG_PetTeamImage_C:SetTeamData(teamIdx, teamData, teamType, forceUpdate)
  self.curTeamType = teamType
  self.teamIdx = teamIdx
  self.teamData = teamData
  if nil == teamData then
    self:ForceContinue()
    Log.Error("UMG_PetTeamImage_C:SetTeamData is nil")
    return
  end
  if nil == teamData.pet_infos then
    teamData.pet_infos = {}
  end
  self.teamPetGids = teamData.pet_infos
  if not self.skillClass then
    self.IsWaitingSkillLoad = true
    return
  end
  if nil == self.lastTeamPetGids then
    self.lastTeamPetGids = {}
  end
  local notChanged = true
  local lastTeamPetGids = self.lastTeamPetGids
  for i = 1, 6 do
    local gid = teamData.pet_infos[i] and teamData.pet_infos[i].pet_gid or nil
    if lastTeamPetGids[i] ~= gid then
      lastTeamPetGids[i] = gid
      notChanged = false
    end
  end
  if self.isFirstRun then
    self:UpdateBgImg()
  end
  if not forceUpdate and notChanged then
    self:ForceContinue()
    return
  end
  lastTeamPetGids = {}
  for index, value in ipairs(teamData.pet_infos) do
    lastTeamPetGids[index] = value.pet_gid
  end
  self.lastTeamPetGids = lastTeamPetGids
  self.petDatas = {}
  for _, petGid in ipairs(teamData.pet_infos) do
    local petInfo = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(petGid.pet_gid, teamData.is_mirror)
    table.insert(self.petDatas, petInfo)
  end
  self:UpdateSlotActors(forceUpdate)
  self.isFirstRun = false
end

function UMG_PetTeamImage_C:ForceContinue()
  if self.isFirstRun then
    self.Parent.Parent:SetProgressPercent(1)
    self.isFirstRun = false
  end
end

function UMG_PetTeamImage_C:PlayShowAnim()
  if #self.petList > 0 then
    for slotId, petItem in ipairs(self.petList) do
      if petItem.actor then
        self:PlayShowSkill(petItem.actor, slotId)
        self.Parent:ShowSlotInfoTag(slotId)
        if slotId == #self.petList then
          self.Parent:SetPanelHitTestVisible(true)
        end
      end
    end
  else
    self.Parent:SetPanelHitTestVisible(true)
  end
end

function UMG_PetTeamImage_C:OnPetTeamWarehouseItemSelected(petData)
  if petData and petData == self.curSelPetData then
    return
  end
  self.curSelPetData = petData
  local curSlotId = self.focusSlotId
  if petData and curSlotId and 0 ~= curSlotId then
    local slotPet = self.petList[curSlotId]
    if slotPet and slotPet.actor then
      slotPet.actor:SetActorHiddenInGame(self.State)
    end
    if self.tempPet and self.tempPet.actor then
      self:DestroyActor(self.tempPet.actor)
    end
    if self.tempPet == nil then
      self.tempPet = {}
    end
    local slotActor = self.slotActors[curSlotId]
    self.tempPet.actor = self:AddPetToScene(petData.BaseConfId, slotActor, 0, petData.gid)
  else
    if self.tempPet and self.tempPet.actor then
      self.tempPet.actor:SetActorHiddenInGame(self.State)
    end
    if curSlotId and 0 ~= curSlotId and self.petList[curSlotId] then
      self.petList[curSlotId].actor:SetActorHiddenInGame(self.State)
    end
  end
end

local _iSelected = false

function UMG_PetTeamImage_C:OnPetTeamTouchStarted(slotId, screenPosition)
  if self:IsSlotEmpty(slotId) then
    _iSelected = false
    return
  end
  _iSelected = true
  self.startPos = screenPosition
  self.curActor = self.petList[slotId].actor
  self.curSlot = slotId
  self.startLocation = self.curActor:ABS_K2_GetActorLocation()
  self.startLocation.Z = self.startLocation.Z + 20
  self.curActor:Abs_K2_SetActorLocation_WithoutHit(self.startLocation)
  self:PlayTouchSkill()
  self:ShowDragIndicator(true)
  self:CalTouchData()
end

function UMG_PetTeamImage_C:CalTouchData()
  local pet1Pos = self.slotActors[1]:ABS_K2_GetActorLocation()
  local pet6Pos = self.slotActors[6]:ABS_K2_GetActorLocation()
  local viewportSize = UE4.UWidgetLayoutLibrary.GetViewportSize(UE4Helper.GetCurrentWorld())
  local ProjMat = UE4.FMatrix()
  UE4.UNRCStatics.CalculateViewProjectionMatrix(self.cameraComponent, ProjMat)
  local Pro1Pos = UE4.UNRCStatics.Abs_ProjectWorldToScreenHiddenWithViewportPos(pet1Pos, viewportSize.X, viewportSize.Y, ProjMat)
  local Pro6Pos = UE4.UNRCStatics.Abs_ProjectWorldToScreenHiddenWithViewportPos(pet6Pos, viewportSize.X, viewportSize.Y, ProjMat)
  Pro1Pos = UE4.USlateBlueprintLibrary.AbsoluteToLocal(self:GetCachedGeometry(), Pro1Pos)
  Pro6Pos = UE4.USlateBlueprintLibrary.AbsoluteToLocal(self:GetCachedGeometry(), Pro6Pos)
  self.unitValue = (pet6Pos.Y - pet1Pos.Y) / (Pro6Pos.X - Pro1Pos.X)
  self.leftValue = pet1Pos.Y - Pro1Pos.X * self.unitValue
  self.slot1Pos = self.slotActors[1]:ABS_K2_GetActorLocation()
  self.curMaxPosX = 100000000
  for index = 1, #self.slotActors do
    local pos = self.slotActors[index]:ABS_K2_GetActorLocation()
    self.curMaxPosX = math.min(pos.X, self.curMaxPosX)
  end
end

local newLocation = UE4.FVector(0, 0, 0)

function UMG_PetTeamImage_C:OnPetTeamTouchMoved(screenPosition)
  if false == _iSelected then
    return
  end
  if self.curActor and UE4.UObject.IsValid(self.curActor) then
    newLocation.X = self.curMaxPosX - 70
    newLocation.Z = self.startLocation.Z
    newLocation.Y = screenPosition.X * self.unitValue + self.leftValue
    self.curActor:Abs_K2_SetActorLocation_WithoutHit(newLocation)
  end
end

function UMG_PetTeamImage_C:OnPetTeamTouchEnded(slotId)
  if false == _iSelected then
    return
  end
  self:StopTouchSkill()
  local finalSlot = slotId
  if self:IsSlotEmpty(finalSlot) then
    finalSlot = self.curSlot
  end
  self:SwapSlot(self.curSlot, finalSlot)
  self:ShowDragIndicator(false)
  if finalSlot ~= self.curSlot then
    self:ChangeTeam()
  end
  _iSelected = false
end

function UMG_PetTeamImage_C:PlayTouchSkill()
  if not self.particleObject then
    return
  end
  local caster = self.curActor
  if caster then
    caster.RocoSkill:ClearAllPassiveSkillObjs()
    local skillObj = caster.RocoSkill:FindOrAddSkillObj(self.particleObject)
    skillObj:SetCaster(caster)
    skillObj:SetPassive(true)
    self.TouchSkillBlackboard = skillObj:GetBlackboard()
    self.TouchSkillBlackboard:SetValueAsBool("TouchLoop", true)
    caster.RocoSkill:LoadAndPlaySkill(skillObj)
  end
end

function UMG_PetTeamImage_C:StopTouchSkill()
  if self.TouchSkillBlackboard then
    self.TouchSkillBlackboard:SetValueAsBool("TouchLoop", false)
    self.TouchSkillBlackboard = nil
  end
end

function UMG_PetTeamImage_C:ChangeTeam()
  local teamInfo = self.module:GetPetTeamUITeamInfo(self.curTeamType)
  local changeTeam = teamInfo.teams[self.teamIdx + 1]
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.ChangePetTeamInfo, changeTeam.pet_infos, self.teamIdx, self.module.data.OpenTeamType)
  self.Parent:RefreshTeamInfo()
end

function UMG_PetTeamImage_C:IsSlotEmpty(slotId)
  if self.teamPetGids == nil then
    return true
  end
  return slotId > #self.teamPetGids
end

function UMG_PetTeamImage_C:SwapSlot(a, b)
  local ALocation, ARotation, BLocation, BRotation
  local slotA = self.slotActors[a]
  local slotB = self.slotActors[b]
  local petA = self.petList[a]
  local petB = self.petList[b]
  if a == b then
    self:PlacePetAtSlot(petA, slotA)
    self:RecalcActorLocation(self.petList[a].actor)
    return
  end
  self:PlacePetAtSlot(petA, slotB)
  self:PlacePetAtSlot(petB, slotA)
  self:RecalcActorLocation(self.petList[a].actor)
  self:RecalcActorLocation(self.petList[b].actor)
  local tempPet = self.petList[b]
  self.petList[b] = self.petList[a]
  self.petList[a] = tempPet
  local t_gid = self.teamPetGids[b]
  self.teamPetGids[b] = self.teamPetGids[a]
  self.teamPetGids[a] = t_gid
end

function UMG_PetTeamImage_C:GetFinalSlot(newLocation)
  local slotActors = self.slotActors
  local miniDistance = 9999999
  local finalSlot
  for index, slotActor in ipairs(slotActors) do
    local slotActorLoc = slotActor:ABS_K2_GetActorLocation()
    local distance = newLocation:Dist(slotActorLoc)
    if miniDistance > distance then
      miniDistance = distance
      finalSlot = index
    end
  end
  return finalSlot
end

function UMG_PetTeamImage_C:PlacePetAtSlot(petInfo, slot)
  local location = slot:Abs_K2_GetActorLocation()
  local rotation = slot:K2_GetActorRotation()
  local petGid = petInfo and petInfo.gid
  local teamData = self.teamData
  local is_mirror = teamData and teamData.is_mirror
  local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(petGid, is_mirror)
  local petTypeInfo = petData and petData.type
  local petTypeInfoType = petTypeInfo and petTypeInfo.type
  local isRandomPet = petTypeInfoType == ProtoEnum.PetTypeInfo.ENUM.PET_TYPE_RANDOM
  if isRandomPet then
    rotation = RandomPetRotation
  end
  local actor = petInfo and petInfo.actor
  if UE.UObject.IsValid(actor) then
    actor:Abs_K2_SetActorLocation_WithoutHit(location)
    actor:K2_SetActorRotation(rotation, false)
  end
end

function UMG_PetTeamImage_C:OnDestruct()
  self.Overridden.Destruct(self)
  self:CancelDelay()
  self:UnRegisterEvent(self, PetUIModuleEvent.PetTeamTouchStarted, self.OnPetTeamTouchStarted)
  self:UnRegisterEvent(self, PetUIModuleEvent.PetTeamTouchMoved, self.OnPetTeamTouchMoved)
  self:UnRegisterEvent(self, PetUIModuleEvent.PetTeamTouchEnded, self.OnPetTeamTouchEnded)
  self:UnRegisterEvent(self, PetUIModuleEvent.PetTeamWarehouseItemSelected, self.OnPetTeamWarehouseItemSelected)
  self:DestoryAllActors()
  self.UpdateCamera = nil
  self.TargetLocation = nil
  self.Parent = nil
  self.focusSlotId = nil
  self.tempPet = nil
  self.isBack = nil
  self.slotActors = nil
  self.petList = nil
  self.skillClass = nil
  if UE.UObject.IsValid(self.skillClassRef) and self.skillClassRef then
    UnLua.Unref(self.skillClassRef)
  end
  self.skillClassRef = nil
  self.curSelPetData = nil
  self.particleObject = nil
  if UE.UObject.IsValid(self.particleObjectRef) and self.particleObjectRef then
    UnLua.Unref(self.particleObjectRef)
  end
  if self.bgRequest then
    _G.NRCResourceManager:UnLoadRes(self.bgRequest)
    self.bgRequest = nil
  end
  self.particleObjectRef = nil
end

function UMG_PetTeamImage_C:OnTick(deltaTime)
end

function UMG_PetTeamImage_C:VInterpTo(Current, Target, DeltaTime, Speed)
  if Speed <= 0 then
    return Target, true
  end
  local dist = Target - Current
  if dist:SizeSquared2D() <= 1 then
    return Target, true
  end
  local delta = dist * Clamp(DeltaTime * Speed, 0.0, 1.0)
  return Current + delta, false
end

function UMG_PetTeamImage_C:FInterpTo(Current, Target, DeltaTime, InterpSpeed)
  if InterpSpeed <= 0 then
    return Target, true
  end
  if nil == Current then
    Current = 0
  end
  local Dist = Target - Current
  if Dist * Dist < 0.001 then
    return Target, true
  end
  local DeltaMove = Dist * Clamp(DeltaTime * InterpSpeed, 0.0, 1.0)
  return Current + DeltaMove, false
end

function UMG_PetTeamImage_C:SetCaptureScene(State)
  self.State = State
  if State then
    for _, v in ipairs(self.petList) do
      v.actor:SetActorHiddenInGame(self.State)
    end
    self.previewWorld:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    for _, v in ipairs(self.petList) do
      v.actor:SetActorHiddenInGame(self.State)
    end
    self.previewWorld:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_PetTeamImage_C:HideAllActorsExcept(bHide, slotId)
  for k, v in ipairs(self.petList) do
    if k ~= slotId then
      v.actor:SetActorHiddenInGame(bHide)
    end
  end
end

function UMG_PetTeamImage_C:ShowDragIndicator(isShow)
  self.Parent:ShowDragIndicator(isShow)
end

function UMG_PetTeamImage_C:InitSceneCapture()
  local MainCamera = self.previewWorld:getActorByName("MainCamera")
  self.cameraComponent = MainCamera:GetComponentByClass(UE4.UCameraComponent)
  self.previewWorld:SetCapturePostProcessing(self.captureComponent)
  local viewInfo = self.cameraComponent:GetCameraView(0)
end

local _loadedCount = 0

function UMG_PetTeamImage_C:UpdateSlotActors(forceUpdate)
  _loadedCount = 0
  local petDatas = self.petDatas
  if self.petList == nil then
    self.petList = {}
  end
  local petList = self.petList
  local slotActors = self.slotActors
  for i = 1, #slotActors do
    local nextPetData = petDatas[i]
    local currentPetData = petList[i]
    local nextPetGid = nextPetData and nextPetData.gid
    local currentPetGid = currentPetData and currentPetData.gid
    if nextPetData and (forceUpdate or nil == currentPetData or nextPetGid ~= currentPetGid) then
      if nil == currentPetData then
        petList[i] = {}
        currentPetData = petList[i]
      end
      if currentPetData.actor then
        self:DestroyActor(currentPetData.actor)
      end
      local petGid = self.teamPetGids[i]
      local baseConfId = nextPetData and nextPetData.base_conf_id
      currentPetData.actor = self:AddPetToScene(baseConfId, slotActors[i], i, petGid.pet_gid)
      currentPetData.gid = nextPetData.gid
    elseif nil == nextPetGid and currentPetData then
      self:DestroyActor(currentPetData.actor)
      petList[i] = nil
    end
  end
end

function UMG_PetTeamImage_C:DestroyActor(actor)
  self.previewWorld:DestroyActor(actor)
end

function UMG_PetTeamImage_C:AddPetToScene(petId, slotActor, slotId, petGid)
  local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(petGid, self.teamData.is_mirror)
  local petTypeInfo = petData and petData.type
  local petTypeInfoType = petTypeInfo and petTypeInfo.type
  local petTypeInfoParam = petTypeInfo and petTypeInfo.param
  local isRandomPet = petTypeInfoType == ProtoEnum.PetTypeInfo.ENUM.PET_TYPE_RANDOM
  if isRandomPet then
    local skillDamType = petTypeInfoParam
    petId = PetUtils.GetRandomPetBaseConfIdFromSkillDamType(skillDamType)
  end
  local petbaseConf = petId and _G.DataConfigManager:GetPetbaseConf(petId, true)
  local modelConfId = petbaseConf and petbaseConf.model_conf
  local modelCfg = modelConfId and _G.DataConfigManager:GetModelConf(modelConfId, true)
  local modelScale = petbaseConf and petbaseConf.formation_ui_scale or 1
  local transform = slotActor:GetTransform()
  if isRandomPet then
    transform.Rotation = RandomPetRotation:ToQuat()
  end
  local modelPath = modelCfg and modelCfg.path or ""
  local modelClass = UE4.UClass.Load(modelPath)
  if not modelClass then
    Log.ErrorFormat("UMG_PetTeamImage_C:AddPetToScene \230\168\161\229\158\139\232\183\175\229\190\132\233\148\153\232\175\175 [%s].", modelCfg.path or "")
    modelClass = UE4.UClass.Load(BattleConst.YajijiPath)
    if not modelClass then
      self:ForceContinue()
      return
    end
  end
  local actor = self.previewWorld:SpawnActor(modelClass, transform)
  if not actor then
    Log.ErrorFormat("UMG_PetTeamImage_C:SpawnActor \229\136\155\229\187\186Actor\229\164\177\232\180\165.", modelCfg.path or "")
    self:ForceContinue()
    return
  end
  actor.CharacterMovement:SetMovementMode(UE4.EMovementMode.MOVE_Custom, 0)
  actor:SetIKEnable(false)
  local mesh = actor:GetComponentByClass(UE4.USkeletalMeshComponent)
  mesh.bForceMipStreaming = true
  local heightModelScale = PetMutationUtils.GetHeightModelScaleByPetData(petData)
  actor.scale = modelScale * mesh.RelativeScale3D.Z * heightModelScale * (modelCfg.model_scale / 100)
  actor.petData = petData
  actor.mesh = mesh
  actor:SetLoadPriority(PriorityEnum.UI_Pet_Mutation)
  PetMutationUtils.PrepareMutationAssets(actor, petData)
  if self.isFirstRun then
    actor:InitOutSceneAsync(self, self.OnPetLoaded1)
  else
    actor:InitOutSceneAsync(self, self.OnPetLoaded2)
    self.Parent:ShowSlotInfoTag(slotId)
  end
  actor:SetActorHiddenInGame(self.State)
  return actor
end

function UMG_PetTeamImage_C:OnPetLoaded1(actor)
  self:OnPetLoaded(actor, false)
end

function UMG_PetTeamImage_C:OnPetLoaded2(actor)
  self:OnPetLoaded(actor, false)
end

function UMG_PetTeamImage_C:OnPetLoaded(actor, isShowSkill)
  actor:OnDistanceOptimize(0, 1, true, 0)
  actor.mesh:SetForcedLOD(1)
  PetMutationUtils.DoMutation(actor, actor.petData)
  actor.petData = nil
  UE.UNRCCharacterUtils.SetCharacterMeshScale(actor, actor.scale)
  self:RecalcActorLocation(actor)
  actor:PlayAnimByName("relax1")
  if isShowSkill then
    self:PlayShowSkill(actor)
  end
  _loadedCount = _loadedCount + 1
  local petAmount = #self.petDatas
  local percent = 0.2 + _loadedCount / petAmount * 0.8
  self.Parent.Parent:SetProgressPercent(percent)
end

function UMG_PetTeamImage_C:PlayShowSkill(actor, slotId)
  if self.State then
    return
  end
  if nil == actor then
    Log.Warning("UMG_PetTeamImage_C:PlayShowSkill actor is nil")
    return
  end
  if nil == self.skillClass then
    Log.Warning("UMG_PetTeamImage_C:PlayShowSkill skillClass is nil")
    return
  end
  local caster = actor
  if self.skillClass and caster then
    caster.RocoSkill:ClearAllPassiveSkillObjs()
    local skillObj = caster.RocoSkill:FindOrAddSkillObj(self.skillClass)
    skillObj:SetCaster(caster)
    skillObj:SetPassive(true)
    skillObj:RegisterEventCallback("SetPosition", self, self.OnSetPosition)
    caster.RocoSkill:LoadAndPlaySkill(skillObj)
  end
end

function UMG_PetTeamImage_C:OnSetPosition(event, skillObj)
  local caster = skillObj:GetCaster()
  caster:SetActorHiddenInGame(false)
end

function UMG_PetTeamImage_C:OnSkillEnd()
  local Actors = UE4.TArray(UE.AActor)
  for _, pet in ipairs(self.petList) do
    if pet.actor then
      Actors:Add(pet.actor)
    end
  end
  self:SortTeam(Actors, 0.1)
end

function UMG_PetTeamImage_C:OnTempPetSkillEnd()
  local Actors = UE4.TArray(UE.AActor)
  if self.tempPet and self.tempPet.actor then
    Actors:Add(self.tempPet.actor)
  end
  self:SortTeam(Actors, 0)
end

function UMG_PetTeamImage_C:RecalcActorLocation(actor)
  local Root = actor:K2_GetRootComponent()
  local height = Root:GetScaledCapsuleHalfHeight()
  local location = actor:K2_GetActorLocation()
  location.Z = location.Z + height
  actor:K2_SetActorLocation(location, false, nil, false)
end

function UMG_PetTeamImage_C:DestoryAllActors()
  for i = #self.petList, 1, -1 do
    local petData = self.petList[i]
    local actor = petData and petData.actor
    if UE4.UObject.IsValid(actor) then
      actor.mesh:ReleaseResource()
      actor.mesh:Release()
      self.previewWorld:DestroyActor(actor)
    end
    self.petList[i] = nil
  end
  self:DeleteBGBP()
end

function UMG_PetTeamImage_C:UpdateBgImg()
  local BPPath = "/Game/NewRoco/Modules/System/PetUI/Res/BackGroundBP/BP_UI_PetTeamBg_02.BP_UI_PetTeamBg_02_C"
  if self.curTeamType == Enum.PlayerTeamType.PTT_PVP_BATTLE_2 then
    BPPath = "/Game/NewRoco/Modules/System/PetUI/Res/BackGroundBP/BP_UI_PetTeamBg_03.BP_UI_PetTeamBg_03_C"
  elseif self.curTeamType == Enum.PlayerTeamType.PTT_PVP_BATTLE_3 then
    BPPath = "/Game/NewRoco/Modules/System/PetUI/Res/BackGroundBP/BP_UI_PetTeamBg.BP_UI_PetTeamBg_C"
  elseif self.curTeamType == Enum.PlayerTeamType.PTT_PVP_BATTLE_4 then
    BPPath = "/Game/NewRoco/Modules/System/PetUI/Res/BackGroundBP/BP_UI_PetTeamBg_PVP.BP_UI_PetTeamBg_PVP_C"
  end
  self:DeleteBGBP()
  self.bgRequest = _G.NRCResourceManager:LoadResAsync(self, BPPath, -1, -1, self.LoadBpOver)
end

function UMG_PetTeamImage_C:DeleteBGBP()
  if self.BGRef and UE.UObject.IsValid(self.BGRef) then
    UnLua.Unref(self.BGRef)
  end
  self.BGRef = nil
  if self.BGbp then
    self.previewWorld:DestroyActor(self.BGbp)
  end
  self.BGbp = nil
end

function UMG_PetTeamImage_C:LoadBpOver(resRequest, BgClass)
  local actor = self.previewWorld:SpawnActor(BgClass, UE.FTransform())
  self:AsyncLoadSceneOver()
  if not actor then
    Log.Error("zgx load bp of Bg faild")
  else
    self.BGbp = actor
    self.BGRef = UnLua.Ref(actor)
  end
end

function UMG_PetTeamImage_C:AsyncLoadSceneOver()
  if self.Parent then
    self.Parent:AsyncLoadSceneOver()
  end
end

return UMG_PetTeamImage_C
