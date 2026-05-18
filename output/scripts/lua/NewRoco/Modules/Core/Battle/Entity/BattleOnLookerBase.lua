local BattleObject = require("NewRoco.Modules.Core.Battle.Entity.BattleObject")
local LineTraceUtils = require("NewRoco.Modules.Core.Battle.Common.LineTraceUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local a = require("Common.Coroutine.async")
local au = require("Common.Coroutine.async_util")
local Base = BattleObject
local BattleOnLookerBase = Base:Extend("BattleOnLookerBase")

function BattleOnLookerBase:Ctor()
  Base.Ctor(self)
  self.fadeInAnimList = {"Run", "Walk"}
end

local function InitTask(self)
  if not UE.UObject.IsValid(self.model) then
    local resourcePath = self:GetModelPath()
    if not resourcePath then
      return false, string.format("BattleOnLookerSpawnAction:LoadResources NPC conf id = %s\239\188\140\232\181\132\230\186\144\232\183\175\229\190\132\230\156\170\230\137\190\229\136\176", self.npcInfo and tostring(self.npcInfo.id))
    end
    local npcClass
    do
      local request = _G.BattleResourceManager:GetCacheAsset(resourcePath)
      if request then
        npcClass = request.assert
      end
    end
    if not UE.UObject.IsValid(npcClass) then
      local aLoadResource = a.wrap(_G.BattleResourceManager.LoadResAsyncThunk)
      local status, messageOrResult = a.wait(aLoadResource(_G.BattleResourceManager, nil, resourcePath, nil, nil, nil, _G.PriorityEnum.Passive_Battle_NPC))
      if status then
        local res = messageOrResult
        npcClass = res
      else
        local errorMessage = messageOrResult
        return false, string.format("BattleOnLookerBase:Init \230\136\152\229\156\186 NPC model path = %s \232\181\132\230\186\144\229\138\160\232\189\189\229\164\177\232\180\165 %s", resourcePath, errorMessage)
      end
    end
    if not UE.UObject.IsValid(npcClass) then
      return false, "BattleOnLookerBase:Init npcClass \232\181\132\230\186\144\230\151\160\230\149\136"
    end
    local attachPoint = self.attachPoint
    if not UE.UObject.IsValid(attachPoint) then
      return false, "BattleOnLookerBase:Init \230\140\130\231\130\185\228\184\141\229\173\152\229\156\168"
    end
    local world = _G.UE4Helper.GetCurrentWorld()
    local npcCharacter = world:Abs_SpawnActor(npcClass, attachPoint:Abs_GetTransform(), UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn)
    self.model = npcCharacter
  end
  local postInitOk, errorMessage = self:PostInit()
  if not postInitOk then
    return false, errorMessage
  end
  self.isInitialized = true
  return true
end

function BattleOnLookerBase:GetOnLookerAttachPointInField(attachPointInField)
  local attachActor = _G.BattleManager.vBattleField.battleFieldConf.OnLookerPosMap:Find(attachPointInField)
  return attachActor
end

function BattleOnLookerBase:GetModelPath()
end

function BattleOnLookerBase:GetModel()
  local model
  if UE4.UObject.IsValid(self.model) then
    model = self.model
  end
  return model
end

function BattleOnLookerBase:GetId()
end

function BattleOnLookerBase:InitPosition()
  local npcCharacter = self.model
  local battlePawnId = self:GetId()
  local initNpcLocation = npcCharacter:Abs_K2_GetActorLocation()
  local checkValidPositionResult = BattleOnLookerBase.CheckValidPosition(initNpcLocation)
  if not checkValidPositionResult.isValid then
    return false, string.format("%s, %s", checkValidPositionResult.errorMessage, tostring(battlePawnId))
  end
  local isWaterSurface = checkValidPositionResult.isWaterSurface
  local validPosition = checkValidPositionResult.validPosition
  local standLocation = validPosition
  local VBattleField = _G.BattleManager.vBattleField
  if isWaterSurface then
    VBattleField:SetWaterPlatformVisible(BattleEnum.Team.ENUM_OBSERVER, battlePawnId, not isWaterSurface)
    VBattleField:PawnWaterPlatform(BattleEnum.Team.ENUM_OBSERVER, battlePawnId, standLocation)
  end
  npcCharacter:EnableCanStandOnWaterSurface(isWaterSurface)
  npcCharacter:K2_GetRootComponent():SetCollisionProfileName("NoCollision")
  standLocation.Z = standLocation.Z + 300
  npcCharacter:Abs_K2_SetActorLocation(standLocation, false, nil, false)
  self:PinOnTheGround()
  return true
end

function BattleOnLookerBase.CheckValidPosition(startPosition)
  local result = {}
  result.isValid = true
  result.isWaterSurface = false
  local initNpcLocation = UE4.FVector(startPosition.X, startPosition.Y, startPosition.Z)
  local traceStartLocation = UE4.FVector(startPosition.X, startPosition.Y, startPosition.Z)
  local waterCheckExtentUp = 500
  local waterCheckExtentDown = 250
  local hitWaterSurfaceBegin = UE4.FVector(traceStartLocation.X, traceStartLocation.Y, traceStartLocation.Z + waterCheckExtentUp)
  local hitWaterSurfaceEnd = UE4.FVector(traceStartLocation.X, traceStartLocation.Y, traceStartLocation.Z - waterCheckExtentDown)
  local hitWaterResult = LineTraceUtils.HitWaterSurface(hitWaterSurfaceBegin, hitWaterSurfaceEnd)
  local isHitWater = false
  local posWater
  if hitWaterResult then
    isHitWater = true
    local impactPoint = hitWaterResult.ImpactPoint
    posWater = UE.FVector(impactPoint.X, impactPoint.Y, impactPoint.Z)
  end
  local lineTraceGroundLength = 500
  local posGround, isHitGround = LineTraceUtils.GetPointValidLocationByLineOnGround(traceStartLocation, 0, lineTraceGroundLength, false, nil)
  local isHit = isHitWater or isHitGround
  local isWaterSurface = isHitWater
  local standLocation
  if isHitGround then
    standLocation = posGround
  end
  if isHitWater then
    standLocation = posWater
  end
  if not standLocation then
    isHit = false
  end
  if standLocation and standLocation.Z < initNpcLocation.Z and initNpcLocation.Z - standLocation.Z > 500 then
    isHit = false
  end
  result.isWaterSurface = isWaterSurface
  if isHit then
    if isWaterSurface then
    else
      local UNavigationSystemV1 = UE4.UNavigationSystemV1
      local FVector = UE4.FVector
      local queryExtent = FVector(50, 50, 500)
      local projectPoint, isHitNavigation = UNavigationSystemV1.Abs_K2_ProjectPointToNavigation(UE4Helper.GetCurrentWorld(), standLocation, nil, nil, nil, queryExtent)
      if not isHitNavigation then
        result.isValid = false
        result.errorMessage = "BattleOnLookerBase.CheckValidPosition \228\189\141\231\189\174\233\157\158\230\179\149\239\188\154\228\184\141\229\156\168\230\176\180\233\157\162\228\184\138\228\184\148\231\166\187\229\175\188\232\136\170\231\189\145\230\160\188\229\164\170\232\191\156"
        return result
      end
    end
  else
    result.isValid = false
    result.errorMessage = "BattleOnLookerBase.CheckValidPosition \228\189\141\231\189\174\233\157\158\230\179\149\239\188\154\228\184\141\231\171\153\229\156\168\230\156\137\230\149\136\232\161\168\233\157\162\228\184\138"
    return result
  end
  local replacePetPos = _G.BattleManager.vBattleField.ReplacePetPos
  local npcIsTooCloseToAnyPet = false
  local npcReplaceDistanceThreshold = 250
  if replacePetPos then
    for i, replacePetPositionList in pairs(replacePetPos) do
      for j, petPosition in ipairs(replacePetPositionList) do
        local standLocationHorizontal = UE4.FVector(standLocation.X, standLocation.Y, petPosition.Z)
        local distance = UE4.FVector.Dist(standLocationHorizontal, petPosition)
        if npcReplaceDistanceThreshold > distance then
          npcIsTooCloseToAnyPet = true
        end
      end
    end
  end
  if npcIsTooCloseToAnyPet then
    result.isValid = false
    result.errorMessage = "BattleOnLookerBase.CheckValidPosition \228\189\141\231\189\174\233\157\158\230\179\149\239\188\154\228\184\141\231\171\153\229\156\168\230\156\137\230\149\136\232\161\168\233\157\162\228\184\138"
    return result
  end
  result.validPosition = standLocation
  return result
end

function BattleOnLookerBase:Init(callback)
  if self.initAsyncTaskContext then
    Log.Error("BattleOnLookerBase:Init \229\143\145\231\142\176\229\183\178\231\187\143\229\136\157\229\167\139\229\140\150\231\154\132\229\188\130\230\173\165\228\184\138\228\184\139\230\150\135\239\188\140\231\166\129\230\173\162\233\135\141\229\164\141\229\136\157\229\167\139\229\140\150")
    return
  end
  local task = a.sync(InitTask)
  self.initAsyncTaskContext = au.Launch(task(self), callback)
end

function BattleOnLookerBase:PostInit()
  return true
end

local function InitOutSceneAsyncTask(self, callback)
  if not UE4.UObject.IsValid(self.model) then
    callback(false, "model is nil")
    return
  end
  self.model:SetLoadPriority(PriorityEnum.Passive_Battle_NPC)
  self.model:InitOutSceneAsync(nil, function(npc)
    callback(true, npc)
  end)
  self:HideNpc()
  if self.model.InitEmoji then
    local model = self.model
    model:InitEmoji()
  end
end

BattleOnLookerBase.InitOutSceneAsyncTask = a.wrap(InitOutSceneAsyncTask)

function BattleOnLookerBase:HideNpc()
  if self.model and self.model:IsValid() then
    self.model:SetActorHiddenInGame(true)
  end
end

function BattleOnLookerBase:ShowNpc()
  if self.model and self.model:IsValid() then
    self.model:SetActorHiddenInGame(false)
  end
end

function BattleOnLookerBase:TurnToBattleFieldCenter()
  local targetPosition = _G.BattleManager.vBattleField.battleFieldActor:Abs_K2_GetActorLocation()
  self:TurnTo(targetPosition)
end

function BattleOnLookerBase:TurnTo(targetPosition)
  local sourcePosition = self.model:Abs_K2_GetActorLocation()
  local direction = targetPosition - sourcePosition
  direction.Z = 0
  local rotation = direction:ToRotator():Clamp()
  local targetRotation = self.model:K2_GetActorRotation()
  targetRotation.Yaw = rotation.Yaw
  self.model:K2_SetActorRotation(targetRotation, false)
end

local function ShowNpcWithFadeAndAnimTask(self)
  local animName
  if #self.fadeInAnimList > 0 then
    local randomIndex = math.random(#self.fadeInAnimList)
    animName = self.fadeInAnimList[randomIndex]
  end
  local currentTime = 0
  self:ShowNpc()
  self.model:SetMeshAlpha(1)
  self.model.CharacterMovement:SetMovementMode(UE4.EMovementMode.MOVE_Walking)
  self.model:SetIKEnable(true)
  local fadeOutTime = self.model:PlayAnimByName(animName, nil, nil, nil, nil, 2, nil)
  fadeOutTime = fadeOutTime and fadeOutTime or 2
  fadeOutTime = math.max(fadeOutTime, 1)
  a.wait(au.NextTick())
  while currentTime < fadeOutTime do
    local dt = a.wait(au.NextTick())
    currentTime = currentTime + dt
    local percentage = currentTime / fadeOutTime
    percentage = math.clamp(percentage, 0, 1)
    self.model:SetMeshAlpha(1 - percentage)
  end
  self.model:SetMeshAlpha(0)
  self:PostShowWithFadeAndAnim()
end

function BattleOnLookerBase:ShowNpcWithFadeAndAnim(callback)
  local task = a.sync(ShowNpcWithFadeAndAnimTask)
  self.fadeInAnimationAsyncContext = au.Launch(task(self), callback)
end

local function ModelFadeOutTask(self)
  local currentTime = 0
  local fadeOutTime = 0.5
  self.model:SetMeshAlpha(0)
  a.wait(au.NextTick())
  while currentTime < fadeOutTime do
    local dt = a.wait(au.NextTick())
    currentTime = currentTime + dt
    local percentage = currentTime / fadeOutTime
    percentage = math.clamp(percentage, 0, 1)
    self.model:SetMeshAlpha(percentage)
  end
  self.model:SetMeshAlpha(1)
end

function BattleOnLookerBase:ModelFadeOut(callback)
  local task = a.sync(ModelFadeOutTask)
  self.fadeOutAnimationAsyncContext = au.Launch(task(self), callback)
end

function BattleOnLookerBase:PostShowWithFadeAndAnim()
end

function BattleOnLookerBase:PinOnTheGround()
  local position = self.model:K2_GetActorLocation()
  local newPosition = UE4.UNRCStatics.PinActorOnGround(nil, self.model, position, self.model)
  self.model:K2_SetActorLocation(newPosition, false, nil, false)
end

function BattleOnLookerBase:LoadBPComponents()
  local fTransfom = UE4.FTransform(UE4.FQuat(), UE4.FVector(0, 0, 0))
  local params = {player = self}
  _G.BattleResourceManager:LoadActorAsyncWithParam(self, _G.UEPath.BP_BattlePlayerComponents, fTransfom, PriorityEnum.Passive_Battle_NPC, params, self.LoadBPComponentsComplete)
end

function BattleOnLookerBase:LoadBPComponentsComplete(battlePlayerComponents)
  if not UE4.UObject.IsValid(self.model) then
    Log.Error("battleNpc is destroyed!!!")
    return
  end
  self.battlePlayerComponentsRef = UnLua.Ref(battlePlayerComponents)
  battlePlayerComponents:K2_AttachRootComponentToActor(self.model)
  battlePlayerComponents:K2_SetActorRelativeLocation(UE4.FVector(0, 0, 0), false, nil, false)
  if battlePlayerComponents.ClickTipUIOffset then
    local attachName = BattleUtils.GetAttachPointNameByType(UE4.EFXAttachPointType.Body)
    battlePlayerComponents.ClickTipUIOffset:K2_AttachTo(self.model:GetComponentByClass(UE4.USkeletalMeshComponent), attachName)
  end
  if battlePlayerComponents.SkillPredictionUIOffset then
    local attachName = BattleUtils.GetAttachPointNameByType(UE4.EFXAttachPointType.Hp)
    battlePlayerComponents.SkillPredictionUIOffset:K2_AttachTo(self.model:GetComponentByClass(UE4.USkeletalMeshComponent), attachName)
  end
  if battlePlayerComponents.DialogBoxUIOffset then
    local attachName = BattleUtils.GetAttachPointNameByType(UE4.EFXAttachPointType.Hp)
    battlePlayerComponents.DialogBoxUIOffset:K2_AttachTo(self.model:GetComponentByClass(UE4.USkeletalMeshComponent), attachName)
  end
  if battlePlayerComponents.SelectMarker3dOffset then
    local attachName = BattleUtils.GetAttachPointNameByType(UE4.EFXAttachPointType.Pos)
    battlePlayerComponents.SelectMarker3dOffset:K2_AttachTo(self.model:GetComponentByClass(UE4.USkeletalMeshComponent), attachName)
    local trans = battlePlayerComponents.SelectMarker3dOffset:GetRelativeTransform()
    trans.Translation.Z = trans.Translation.Z + BattleConst.ModelOffset.SelectorMarker3dOffsetZ
    battlePlayerComponents.SelectMarker3dOffset:K2_SetRelativeLocationAndRotation(trans.Translation, trans.Rotation:ToRotator(), false, nil, false)
  end
  self.battlePlayerComponents = battlePlayerComponents
  if battlePlayerComponents.DialogBoxUIActor then
    local dialogBoxUI = battlePlayerComponents.DialogBoxUIActor
    local FVector2D = UE.FVector2D
    local renderScale = self:GetDialogBoxRenderScale()
    dialogBoxUI:SetRenderScale(renderScale)
    local pivot = FVector2D(1, 1)
    dialogBoxUI:SetRenderTransformPivot(pivot)
  end
end

function BattleOnLookerBase:GetDialogBoxRenderScale()
  local npc_round_tip_scale = 1
  local FVector2D = UE.FVector2D
  local renderScale = FVector2D(npc_round_tip_scale, npc_round_tip_scale)
  return renderScale
end

function BattleOnLookerBase:Destroy()
  Log.Info("BattleOnLookerBase:Destroy", self.name)
  if self.destroyed then
    return
  end
  if self.initAsyncTaskContext then
    a.kill(self.initAsyncTaskContext)
    self.initAsyncTaskContext = nil
  end
  if self.fadeInAnimationAsyncContext then
    a.kill(self.fadeInAnimationAsyncContext)
    self.fadeInAnimationAsyncContext = nil
  end
  if self.fadeOutAnimationAsyncContext then
    a.kill(self.fadeOutAnimationAsyncContext)
    self.fadeOutAnimationAsyncContext = nil
  end
  self.battlePlayerComponentsRef = nil
  if UE.UObject.IsValid(self.battlePlayerComponents) then
    self.battlePlayerComponents:Reset()
    self.battlePlayerComponents:K2_DestroyActor()
  end
  self.battlePlayerComponents = nil
  Base.Destroy(self)
end

return BattleOnLookerBase
