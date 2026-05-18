local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local MagicCreationUtils = Class()
local LandTraceExtent = 200.0
local SoundIdCreate = 202702
local SoundIdRecycle = 202704
local NotIgnoreOverlapProfiles = {
  "NPCCharacterFree",
  "NPCCharacterFreeNoInteract",
  "CreateMagicForbid"
}
MagicCreationUtils.NpcValidType = {
  UnInited = -2,
  Invalid = -1,
  Valid = 0,
  Planeness_NoLand = 1,
  Planeness_Angle = 2,
  Planeness_Height = 3,
  Water = 4,
  Overlap = 10,
  OverlapNotLoaded = 11,
  OverlapEaves = 12,
  Cliff = 20,
  Pit = 21,
  AirWall = 30,
  BossArea = 40,
  WrongScene = 50,
  SpaceNotSufficient = 60,
  Normal = 100
}

function MagicCreationUtils.TryGetLocalizationMessage(id, default)
  if nil == id then
    return default
  end
  local conf = _G.DataConfigManager:GetLocalizationConf(id)
  if nil ~= conf then
    return conf.msg
  end
  return default
end

function MagicCreationUtils.GetInvalidReason(type)
  if type == MagicCreationUtils.NpcValidType.Invalid then
    return "\230\154\130\230\151\182\230\151\160\230\179\149\230\150\189\230\148\190"
  elseif type == MagicCreationUtils.NpcValidType.UnInited then
    return MagicCreationUtils.TryGetLocalizationMessage("TryCastMagic_Create_HoldingRequired", "\229\138\160\232\189\189\228\184\173")
  elseif type == MagicCreationUtils.NpcValidType.Planeness_NoLand then
    return MagicCreationUtils.TryGetLocalizationMessage("TryCastMagic_Create_Planeness", "\229\156\176\233\157\162\228\184\141\229\164\159\229\185\179\229\157\166")
  elseif type == MagicCreationUtils.NpcValidType.Planeness_Angle then
    return MagicCreationUtils.TryGetLocalizationMessage("TryCastMagic_Create_Planeness", "\229\156\176\233\157\162\228\184\141\229\164\159\229\185\179\229\157\166")
  elseif type == MagicCreationUtils.NpcValidType.Planeness_Height then
    return MagicCreationUtils.TryGetLocalizationMessage("TryCastMagic_Create_Planeness", "\229\156\176\233\157\162\228\184\141\229\164\159\229\185\179\229\157\166")
  elseif type == MagicCreationUtils.NpcValidType.Water then
    return MagicCreationUtils.TryGetLocalizationMessage("TryCastMagic_Create_Water", "\228\184\141\232\131\189\230\148\190\231\189\174\228\186\142\230\176\180\233\157\162\228\184\138")
  elseif type == MagicCreationUtils.NpcValidType.Overlap then
    return MagicCreationUtils.TryGetLocalizationMessage("TryCastMagic_Create_Overlapped", "\232\191\153\233\135\140\228\184\142\229\133\182\228\187\150\231\137\169\228\187\182\233\135\141\229\143\160")
  elseif type == MagicCreationUtils.NpcValidType.OverlapNotLoaded then
    return MagicCreationUtils.TryGetLocalizationMessage("TryCastMagic_Create_FetchingNpc", "\232\191\153\233\135\140\230\156\137\229\138\160\232\189\189\228\184\173\231\154\132\231\137\169\228\187\182")
  elseif type == MagicCreationUtils.NpcValidType.OverlapEaves then
    return MagicCreationUtils.TryGetLocalizationMessage("TryCastMagic_Create_Narrow", "\228\184\138\230\150\185\231\169\186\233\151\180\232\190\131\228\184\186\231\139\173\231\170\132")
  elseif type == MagicCreationUtils.NpcValidType.Cliff then
    return MagicCreationUtils.TryGetLocalizationMessage("TryCastMagic_Create_TooHigh", "\229\156\176\233\157\162\228\184\142\231\142\169\229\174\182\233\171\152\229\186\166\229\183\174\232\183\157\232\190\131\229\164\167")
  elseif type == MagicCreationUtils.NpcValidType.Pit then
    return MagicCreationUtils.TryGetLocalizationMessage("TryCastMagic_Create_TooHigh", "\229\156\176\233\157\162\228\184\142\231\142\169\229\174\182\233\171\152\229\186\166\229\183\174\232\183\157\232\190\131\229\164\167")
  elseif type == MagicCreationUtils.NpcValidType.AirWall then
    return MagicCreationUtils.TryGetLocalizationMessage("TryCastMagic_Create_AirWall", "\230\173\164\229\164\132\228\184\141\229\143\175\230\150\189\230\148\190")
  elseif type == MagicCreationUtils.NpcValidType.BossArea then
    return MagicCreationUtils.TryGetLocalizationMessage("TryCastMagic_Create_BossArea", "\229\177\158\228\186\142\229\141\177\233\153\169\229\140\186\229\159\159")
  elseif type == MagicCreationUtils.NpcValidType.WrongScene then
    return MagicCreationUtils.TryGetLocalizationMessage("TryCastMagic_WrongScene", "\230\173\164\229\164\132\228\184\141\229\143\175\230\150\189\230\148\190")
  elseif type == MagicCreationUtils.NpcValidType.SpaceNotSufficient then
    return MagicCreationUtils.TryGetLocalizationMessage("TryCastMagic_Create_Narrow", "\231\169\186\233\151\180\231\139\173\231\170\132")
  end
  return nil
end

function MagicCreationUtils.TryGetGlobalConfig(tableId, key, member, default)
  local value = _G.DataConfigManager:GetGlobalConfigByKeyType(key, tableId)
  if value and value[member] then
    return value[member]
  end
  return default
end

function MagicCreationUtils.GetCreateTargetNpcRefreshId(magicInfo)
  local effectStruct = magicInfo.magicBaseConfig.effect_struct
  if nil == effectStruct or #effectStruct <= 0 then
    Log.Error("magicInfo.magicBaseConfig.effect_struct is nil or empty")
    return nil
  end
  local param = effectStruct[1].effect_params_1
  if nil == param or #param <= 0 then
    Log.Error("effectStruct[1].effect_params is nil or empty")
    return nil
  end
  return param[1]
end

function MagicCreationUtils.NpcSnapToGround(npc)
  if not npc then
    return
  end
  local landInfo = MagicCreationUtils.GetLandInfo(npc.viewObj:K2_GetActorLocation())
  if nil ~= landInfo then
    npc:SetActorLocation(SceneUtils.ConvertRelativeToAbsolute(landInfo.position))
  end
end

function MagicCreationUtils.GetActorBounds(viewObj)
  local Comps = viewObj:K2_GetComponentsByClass(UE.UMeshComponent)
  local allMin, allMax
  for _, Comp in tpairs(Comps) do
    local origin = UE4.FVector(0, 0, 0)
    local extent = UE4.FVector(0, 0, 0)
    local radius = 0
    UE4.UKismetSystemLibrary.GetComponentBounds(Comp, origin, extent, radius)
    local min = origin - extent
    local max = origin + extent
    if nil == allMin then
      allMin = UE.FVector(min.X, min.Y, min.Z)
    else
      allMin.X = math.min(allMin.X, min.X)
      allMin.Y = math.min(allMin.Y, min.Y)
      allMin.Z = math.min(allMin.Z, min.Z)
    end
    if nil == allMax then
      allMax = UE.FVector(max.X, max.Y, max.Z)
    else
      allMax.X = math.max(allMax.X, max.X)
      allMax.Y = math.max(allMax.Y, max.Y)
      allMax.Z = math.max(allMax.Z, max.Z)
    end
  end
  local allOrigin, allExtent
  if nil == allMin and nil == allMin then
    allOrigin = viewObj:K2_GetActorLocation()
    if nil ~= viewObj.BoundingRadius then
      allExtent = UE.FVector(viewObj.BoundingRadius, viewObj.BoundingRadius, 0)
    else
      allExtent = UE.FVector(0, 0, 0)
    end
  else
    allOrigin = (allMax + allMin) / 2.0
    allExtent = (allMax - allMin) / 2.0
  end
  return allOrigin, allExtent
end

function MagicCreationUtils.GetLandInfo(targetLocation)
  local startLocation = UE.FVector(targetLocation.X, targetLocation.Y, targetLocation.Z + LandTraceExtent)
  local endLocation = UE.FVector(targetLocation.X, targetLocation.Y, targetLocation.Z - LandTraceExtent)
  local channel = UE4.UNRCStatics.ConvertToTraceChannel(UE4.ECollisionChannel.ECC_GameTraceChannel5)
  local hitResults, bSuccess = UE4.UKismetSystemLibrary.LineTraceMulti(_G.UE4Helper.GetCurrentWorld(), startLocation, endLocation, channel, true, nil)
  if bSuccess then
    local landInfo = {}
    for _, hitResult in tpairs(hitResults) do
      if not hitResult.bBlockingHit then
      elseif landInfo.position == nil or landInfo.position.Z < hitResult.ImpactPoint.Z then
        landInfo.position = UE4.FVector(hitResult.ImpactPoint.X, hitResult.ImpactPoint.Y, hitResult.ImpactPoint.Z)
        landInfo.normal = UE4.FVector(hitResult.Normal.X, hitResult.Normal.Y, hitResult.Normal.Z)
      end
    end
    return landInfo
  end
  return nil
end

function MagicCreationUtils.GetWaterHeight(targetLocation)
  if not targetLocation then
    return nil
  end
  local startLocation = UE.FVector(targetLocation.X, targetLocation.Y, targetLocation.Z + LandTraceExtent)
  local endLocation = UE.FVector(targetLocation.X, targetLocation.Y, targetLocation.Z - LandTraceExtent)
  local waterTraceChannel = UE.ETraceTypeQuery.Water
  local hitResult, bSuccess = UE4.UKismetSystemLibrary.LineTraceSingle(_G.UE4Helper.GetCurrentWorld(), startLocation, endLocation, waterTraceChannel, false, nil, 0)
  if bSuccess then
    return hitResult.ImpactPoint.Z
  end
  return nil
end

function MagicCreationUtils.CheckAirWallNearby(npc, additionalDistance)
  if nil == npc then
    return false
  end
  if nil == additionalDistance then
    additionalDistance = 0
  end
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local playerPos = localPlayer:GetActorLocation()
  local npcPos = npc:GetActorLocation()
  npcPos.Z = playerPos.Z
  local _, extent = MagicCreationUtils.GetActorBounds(npc.viewObj)
  local radius = math.max(extent.X, extent.Y)
  local traceChannel = UE4.UNRCStatics.ConvertToTraceChannel(UE4.ECollisionChannel.ECC_GameTraceChannel14)
  local actorsToIgnore = {}
  if nil ~= localPlayer then
    table.insert(actorsToIgnore, localPlayer.viewObj)
  end
  table.insert(actorsToIgnore, npc.viewObj)
  local world = _G.UE4Helper.GetCurrentWorld()
  local delta = UE4.FVector(0.2, 0.2, 0.2)
  local hitResults, _ = UE4.UKismetSystemLibrary.Abs_SphereTraceMulti(world, npcPos - delta, npcPos + delta, radius + additionalDistance, traceChannel, false, actorsToIgnore, nil, nil, false, nil, nil, nil)
  
  local function checkIsAirWall(hitResult)
    local component = hitResult.Component
    if not component:IsA(UE4.UProceduralMeshComponent) then
      return false
    end
    local collisionEnabled = component:GetCollisionEnabled()
    if collisionEnabled == UE4.ECollisionEnabled.QueryOnly then
      return false
    end
    local response = component:GetCollisionResponseToChannel(UE4.ECollisionChannel.ECC_GameTraceChannel14)
    if response == UE.ECollisionResponse.ECR_Ignore then
      return false
    end
    return true
  end
  
  local bCanDrawDebug = _G.NRCModuleManager:DoCmd(_G.MagicCreationModuleCmd.GetCanDrawDebug)
  for _, hitResult in tpairs(hitResults) do
    if checkIsAirWall(hitResult) then
      if bCanDrawDebug and hitResult.Component then
        local duration = 0.03333333333333333
        UE4.UKismetSystemLibrary.Abs_DrawDebugPoint(world, hitResult.ImpactPoint, 10.0, UE4.FLinearColor(1, 0.9, 0, 1), duration)
        UE4.UKismetSystemLibrary.Abs_DrawDebugString(world, hitResult.ImpactPoint, UE4.UKismetSystemLibrary.GetDisplayName(hitResult.Component), nil, UE4.FLinearColor(1, 0.8, 0, 1), duration)
      end
      return true
    end
  end
  return false
end

function MagicCreationUtils.CheckOverlap(npc, center, extent, actorsToIgnore, duration)
  if nil == npc then
    return false
  end
  if not npc.viewObj then
    return false
  end
  if nil == center or nil == extent then
    center, extent = MagicCreationUtils.GetActorBounds(npc.viewObj)
  end
  if 0 == extent.Z then
    extent.Z = 20.0
    center.Z = center.Z + extent.Z
  end
  center.Z = center.Z + 10.0
  local radius = math.max(extent.X, extent.Y)
  if nil == actorsToIgnore then
    actorsToIgnore = {}
  end
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if nil ~= localPlayer then
    table.insert(actorsToIgnore, localPlayer.viewObj)
    local statusComp = localPlayer.statusComponent
    if statusComp and statusComp:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_HAND_IN_HAND) then
      local customParam = statusComp:GetCustomParams(ProtoEnum.WorldPlayerStatusType.WPST_HAND_IN_HAND)
      if customParam then
        local uin2 = customParam.player_interact_param.player_uin2
        local otherPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GetPlayerByUin, uin2)
        if otherPlayer then
          table.insert(actorsToIgnore, otherPlayer.viewObj)
        end
      end
    end
  end
  table.insert(actorsToIgnore, npc.viewObj)
  if nil == duration then
    duration = 0.03333333333333333
  end
  local traceObjectTypes = {
    UE4.EObjectTypeQuery.WorldDynamic,
    UE4.EObjectTypeQuery.WorldStatic,
    UE4.EObjectTypeQuery.Pawn,
    UE4.EObjectTypeQuery.Character,
    UE4.EObjectTypeQuery.Tree,
    UE4.EObjectTypeQuery.PhysicsBody,
    UE4.EObjectTypeQuery.Vehicle,
    UE4.EObjectTypeQuery.Destructible
  }
  local bCanDrawDebug = _G.NRCModuleManager:DoCmd(_G.MagicCreationModuleCmd.GetCanDrawDebug)
  local world = _G.UE4Helper.GetCurrentWorld()
  
  local function judgeHitResult(hitResult)
    if not hitResult then
      return false
    end
    local comp = hitResult.Component
    if not UE4.UObject.IsValid(comp) then
      return false
    end
    if comp:IsA(UE4.ULandscapeHeightfieldCollisionComponent) then
      if bCanDrawDebug then
        UE4.UKismetSystemLibrary.DrawDebugString(world, hitResult.ImpactPoint, UE4.UKismetSystemLibrary.GetDisplayName(comp), nil, UE4.FLinearColor(0.1, 0.2, 0.8, 0.8), duration)
      end
      return
    end
    local collisionEnabled = comp:GetCollisionEnabled()
    if collisionEnabled == UE4.ECollisionEnabled.QueryOnly then
      local actor = hitResult.Actor
      if actor and actor.BoundingRadius then
        return true
      end
      local response = comp:GetCollisionResponseToChannel(UE4.ECollisionChannel.ECC_GameTraceChannel17)
      if response ~= UE4.ECollisionResponse.ECR_Ignore then
        return true
      end
      if actor:IsA(UE4.ARocoReplicateCharacter) then
        return true
      end
      local profileName = comp:GetCollisionProfileName()
      for _, profile in pairs(NotIgnoreOverlapProfiles) do
        if profileName == profile then
          return true
        end
      end
      return false
    end
    return true
  end
  
  local function checkInOneDirection(delta)
    local hitResults = MagicCreationUtils.CylinderTraceMultiForObjects(center, radius, extent.Z, traceObjectTypes, actorsToIgnore, delta, duration)
    for _, hitResult in pairs(hitResults) do
      if judgeHitResult(hitResult) then
        if bCanDrawDebug and hitResult.Component then
          UE4.UKismetSystemLibrary.DrawDebugString(world, hitResult.ImpactPoint, UE4.UKismetSystemLibrary.GetDisplayName(hitResult.Component), nil, UE4.FLinearColor(1, 0.2, 0, 1), duration)
        end
        return true
      end
    end
    return false
  end
  
  if checkInOneDirection(UE4.FVector(0.1, 0.1, 0.1)) then
    return true
  end
  if checkInOneDirection(UE4.FVector(-0.1, -0.1, 0.1)) then
    return true
  end
  return false
end

function MagicCreationUtils.CylinderTraceMultiForObjects(center, radius, height, traceObjectTypes, actorsToIgnore, delta, duration)
  local drawDebugType = UE4.EDrawDebugTrace.None
  local traceColor, traceHitColor, drawTime
  if _G.NRCModuleManager:DoCmd(_G.MagicCreationModuleCmd.GetCanDrawDebug) then
    drawDebugType = UE4.EDrawDebugTrace.ForDuration
    traceColor = UE4.FLinearColor(0.6, 1, 0, 1)
    traceHitColor = UE4.FLinearColor(0.2, 0.7, 0.2, 1)
    drawTime = duration or 0.1
  end
  if nil == delta then
    delta = UE4.FVector(0.1, 0.1, 0.1)
  end
  local world = _G.UE4Helper.GetCurrentWorld()
  local boxHitResults, _ = UE4.UKismetSystemLibrary.BoxTraceMultiForObjects(world, center - delta, center + delta, UE4.FVector(radius, radius, height), UE4.FRotator(0, 0, 0), traceObjectTypes, true, actorsToIgnore, drawDebugType, nil, false, traceColor, traceHitColor, drawTime)
  local capsuleHitResults, _ = UE4.UKismetSystemLibrary.CapsuleTraceMultiForObjects(world, center - delta, center + delta, radius, height + radius, traceObjectTypes, true, actorsToIgnore, drawDebugType, nil, false, traceColor, traceHitColor, drawTime)
  local hitResultNums = {}
  
  local function statHitResult(hitResult)
    if not hitResult then
      return
    end
    local component = hitResult.Component
    if not UE4.UObject.IsValid(component) then
      return
    end
    if hitResultNums[component] then
      hitResultNums[component].num = hitResultNums[component].num + 1
    else
      hitResultNums[component] = {num = 1, result = hitResult}
    end
  end
  
  for _, hitResult in tpairs(boxHitResults) do
    statHitResult(hitResult)
  end
  for _, hitResult in tpairs(capsuleHitResults) do
    statHitResult(hitResult)
  end
  local finalHitResults = {}
  for _, record in pairs(hitResultNums) do
    if record and record.num > 1 then
      table.insert(finalHitResults, record.result)
    end
  end
  return finalHitResults
end

function MagicCreationUtils.CheckOverlapNotLoadedCapsule(origin, extent, npc)
  if not npc then
    return false
  end
  local targetPosition = npc:GetServerPosition()
  local targetScale = npc:GetConfigScale()
  local targetRadius = (npc.modelConf.capsule_radius / 1000.0 or 0) * targetScale
  local targetHalfHeight = (npc.modelConf.capsule_halfheight / 1000.0 or 0) * targetScale
  local targetOrigin = UE4.FVector(targetPosition.x, targetPosition.y, targetPosition.z + targetHalfHeight)
  local world = _G.UE4Helper.GetCurrentWorld()
  local spawnTransform = UE4.FTransform(UE4.FQuat(), targetOrigin)
  local detectActor = world:Abs_SpawnActor(UE4.ATriggerCapsule, spawnTransform, UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn, nil, nil, nil, nil)
  local capsuleComp = detectActor.CollisionComponent
  if detectActor and capsuleComp then
    local function clearDetectActor()
      detectActor:K2_DestroyActor()
      
      detectActor = nil
    end
    
    capsuleComp:SetCapsuleSize(targetRadius, targetHalfHeight, false)
    local components = UE4.TArray(UE4.UPrimitiveComponent)
    local radius = math.max(extent.X, extent.Y)
    local halfHeight = extent.z
    if 0 == halfHeight then
      halfHeight = 10.0
      origin.Z = origin.Z + halfHeight
    end
    local bSuccess = UE4.UKismetSystemLibrary.CapsuleOverlapComponents(world, origin, radius, halfHeight, {
      UE.EObjectTypeQuery.WorldDynamic
    }, {
      UE.UCapsuleComponent
    }, nil, components)
    if true == bSuccess then
      local bCanDrawDebug = _G.NRCModuleManager:DoCmd(_G.MagicCreationModuleCmd.GetCanDrawDebug)
      for _, component in tpairs(components) do
        if component == capsuleComp then
          if bCanDrawDebug then
            local displayName = npc:DebugNPCNameAndID()
            local duration = 0.03333333333333333
            UE4.UKismetSystemLibrary.DrawDebugCylinder(world, origin - UE4.FVector(0, 0, halfHeight), origin + UE4.FVector(0, 0, halfHeight), radius, 20, UE4.FLinearColor(1, 0, 0, 1), duration, 2)
            UE4.UKismetSystemLibrary.Abs_DrawDebugString(world, targetOrigin, displayName, nil, UE4.FLinearColor(1, 0.5, 0, 1), duration)
            UE4.UKismetSystemLibrary.Abs_DrawDebugCylinder(world, targetOrigin - UE4.FVector(0, 0, targetHalfHeight), targetOrigin + UE4.FVector(0, 0, targetHalfHeight), targetRadius, 20, UE4.FLinearColor(1, 1, 0, 0.5), duration, 2)
          end
          clearDetectActor()
          return true
        end
      end
    end
    clearDetectActor()
  end
  return false
end

function MagicCreationUtils.DeleteLocalNpc(npc)
  if npc.viewObj ~= false then
    npc:Destroy()
    return
  end
  
  local function onViewShellLoaded(caller, npc)
    npc:Destroy()
  end
  
  npc:AddEventListener(npc, NPCModuleEvent.VIEW_SHELL_LOADED, onViewShellLoaded)
end

function MagicCreationUtils.CreateLocalNpc(npcId, position, yaw)
  local npc = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.CreateLocalNPC, npcId, position, yaw, nil, PriorityEnum.Active_Player_Throw_Npc)
  return npc
end

function MagicCreationUtils.GetSkillLoadPath(skill)
  if not skill then
    return ""
  end
  local _, idx = skill:find(".*/")
  local package = skill:sub(1, idx)
  local asset = skill:sub(idx + 1, skill:len())
  local path = package .. asset .. "." .. asset .. "_C"
  return path
end

function MagicCreationUtils.DoRecycleBp(npc)
  if not npc then
    return
  end
  if npc.InteractionComponent then
    npc.InteractionComponent:TryDisableInteraction()
  end
  local viewObj = npc.viewObj
  if not viewObj then
    return
  end
  if viewObj.Disappear then
    viewObj:Disappear()
  end
  viewObj.hasRecycled = true
end

function MagicCreationUtils.PlayDeletingSkill(npc)
  if not npc then
    return
  end
  local viewObj = npc.viewObj
  if not viewObj then
    return
  end
  local skillRef = viewObj.DisappearSkill
  local skillPath = UE4.UNRCStatics.GetSoftObjPath(skillRef)
  if "" == skillPath then
    Log.Warning("MagicCreationUtils.PlayDeletingSkill disappear_skill is nil", npc:DebugNPCNameAndID())
    return
  end
  
  local function onSkillEnd(name, skill)
    npc:SetNotDestroyFlag(false)
    npc:SetVisible(false)
  end
  
  local function onLoadSuccess(caller, req, skillClass)
    if npc.InteractionComponent then
      npc.InteractionComponent:TryDisableInteraction()
    end
    if npc.ClearPet then
      npc:ClearPet()
    end
    local player
    if _G.DataModelMgr.PlayerDataModel:IsVisitState() then
      local ownerUin = _G.DataModelMgr.PlayerDataModel:GetPlayerVisitOwnerUin()
      player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GetPlayerByUin, ownerUin)
    else
      player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    end
    local skillComp = viewObj and viewObj.RocoSkill
    if not skillComp then
      Log.Warning("target npc has no skill component", npc.modelConf.id, npc.modelConf.path)
      onSkillEnd()
      return
    end
    if not skillClass then
      Log.Warning("skill class is nil", skillPath)
      onSkillEnd()
      return
    end
    local skill = skillComp:FindOrAddSkillObj(skillClass)
    local caster = player and player.viewObj or viewObj
    skillComp:StopCurrentSkill()
    skill:SetCaster(caster)
    skill:SetTargets({viewObj})
    if player then
      local wandConf = player:GetCurWandConf()
      if wandConf then
        _G.NRCAudioManager:SetEmitterSwitch("Suit", wandConf.WandName, caster, "")
      end
    end
    
    local function onSkillLoaded(name, skillObj)
      MagicCreationUtils.DoRecycleBp(npc)
      _G.NRCAudioManager:PlaySound3DWithActorAuto(SoundIdRecycle, viewObj, npc:DebugNPCNameAndID())
      skillComp:PlaySkill(skill)
    end
    
    skill:RegisterEventCallback("OnAsyncLoadActionEnd", npc, onSkillLoaded)
    skill:RegisterEventCallback("End", npc, onSkillEnd)
    skill:StartAsyncLoading()
  end
  
  local function onLoadFailed(caller, req, message)
    Log.Warning("SkillPath Load Failed", skillPath, message)
    onSkillEnd()
  end
  
  npc.cachedLocationOnDelete = npc:GetActorLocation()
  npc.cachedScaleOnDelete = npc:GetActorScale3D()
  npc:SetNotDestroyFlag(true)
  _G.NRCResourceManager:LoadResAsync(self, skillPath, PriorityEnum.Passive_World_NPC_Close_BP, 0, onLoadSuccess, onLoadFailed, nil)
end

function MagicCreationUtils.PlayCreatingSkill(npc, onLoadedCaller, onLoadedCallback)
  local viewObj = npc.viewObj
  if not viewObj then
    return
  end
  local skillRef = viewObj.EmergeSkill
  local skillPath = UE4.UNRCStatics.GetSoftObjPath(skillRef)
  if "" == skillPath then
    Log.Warning("MagicCreationUtils.PlayCreatingSkill emerge_skill is nil", npc:DebugNPCNameAndID())
    return
  end
  
  local function onSkillPreEnd(name, skill)
    npc:SetVisible(true)
    _G.NRCModuleManager:DoCmd(_G.MagicCreationModuleCmd.PreperformLocalReady, npc)
  end
  
  local function onLoadSuccess(caller, req, skillClass)
    local skillComp = viewObj and UE4.UObject.IsValid(viewObj) and viewObj.RocoSkill
    if not skillComp then
      Log.Warning("target npc has no skill component", npc.modelConf.id, npc.modelConf.path)
      onSkillPreEnd()
      return
    end
    if not skillClass then
      Log.Warning("skill class is nil", skillPath)
      onSkillPreEnd()
      return
    end
    local skill = skillComp:FindOrAddSkillObj(skillClass)
    skillComp:StopCurrentSkill()
    skill:SetCaster(viewObj)
    skill:SetTargets({viewObj})
    
    local function onSkillLoaded(caller, skillObj)
      if onLoadedCallback then
        onLoadedCallback(onLoadedCaller)
      end
      skillComp:PlaySkill(skill)
      _G.NRCAudioManager:PlaySound3DWithActorAuto(SoundIdCreate, viewObj, npc:DebugNPCNameAndID())
    end
    
    skill:RegisterEventCallback("OnAsyncLoadActionEnd", npc, onSkillLoaded)
    skill:RegisterEventCallback("End", npc, onSkillPreEnd)
    skill:StartAsyncLoading()
  end
  
  local function onLoadFailed(caller, req, message)
    Log.Warning("SkillPath Load Failed", skillPath, message)
    if onLoadedCallback then
      onLoadedCallback(onLoadedCaller)
    end
    onSkillPreEnd()
  end
  
  _G.NRCResourceManager:LoadResAsync(self, skillPath, PriorityEnum.Passive_World_NPC_Close_BP, 0, onLoadSuccess, onLoadFailed, nil)
end

function MagicCreationUtils.StopNpcSkill(npc)
  local viewObj = npc.viewObj
  local skillComp = viewObj and viewObj.RocoSkill
  if not skillComp then
    Log.Warning("target npc has no skill component", npc.modelConf.id, npc.modelConf.path)
    return
  end
  skillComp:StopCurrentSkill()
end

function MagicCreationUtils.UndoDeleteEffect(npc)
  if nil == npc then
    return
  end
  MagicCreationUtils.StopNpcSkill(npc)
  npc:SetVisible(true)
  npc.InteractionComponent:TryEnableInteraction()
  if npc.cachedLocationOnDelete then
    npc:SetActorLocation(npc.cachedLocationOnDelete)
    npc.cachedLocationOnDelete = nil
  end
  if npc.cachedScaleOnDelete then
    npc:SetActorScale3D(npc.cachedScaleOnDelete)
    npc.cachedScaleOnDelete = nil
  end
  if npc.TryAppearLulu then
    npc:TryAppearLulu()
  end
  local viewObj = npc.viewObj
  if viewObj then
    if viewObj.hasRecycled then
      viewObj.hasRecycled = nil
    end
    if viewObj.Appear then
      viewObj:Appear()
    end
  end
end

function MagicCreationUtils.TypeNeedResetHeight(type)
  local targetTypes = {
    MagicCreationUtils.NpcValidType.Cliff,
    MagicCreationUtils.NpcValidType.Pit,
    MagicCreationUtils.NpcValidType.Water
  }
  for _, val in pairs(targetTypes) do
    if val == type then
      return true
    end
  end
  return false
end

function MagicCreationUtils.CheckHeightDifferenceTooMuchBetweenNpcAndInteractPoint(npcLocation, interactLocation)
  if not npcLocation or not interactLocation then
    return false
  end
  if not npcLocation.Z or not interactLocation.Z then
    return false
  end
  local landInfo = MagicCreationUtils.GetLandInfo(interactLocation)
  if not landInfo then
    return true
  end
  local interactPointLand = landInfo.position
  if not interactPointLand then
    return true
  end
  local heightDifference = math.abs(npcLocation.Z - interactPointLand.Z)
  local height = MagicCreationUtils.TryGetGlobalConfig(_G.DataConfigManager.ConfigTableId.NPC_GLOBAL_CONFIG, "nexus_overlap_interactive_position_high", "num", 30)
  Log.Debug("MagicCreationUtils.CheckHeightDifferenceBetweenNpcAndInteractPoint", npcLocation, interactLocation, interactPointLand, heightDifference)
  if _G.NRCModuleManager:DoCmd(_G.MagicCreationModuleCmd.GetCanDrawDebug) then
    local world = _G.UE4Helper.GetCurrentWorld()
    local duration = 30
    UE4.UKismetSystemLibrary.DrawDebugArrow(world, npcLocation, interactPointLand, 5, UE4.FLinearColor(0.8, 0.4, 0, 1), duration, 2)
    UE4.UKismetSystemLibrary.DrawDebugString(world, (npcLocation + interactPointLand) / 2.0, heightDifference, nil, UE4.FLinearColor(1, 0.5, 0, 1), duration)
  end
  if heightDifference > height then
    return true
  end
  return false
end

return MagicCreationUtils
