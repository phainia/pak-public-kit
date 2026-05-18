local Base = require("NewRoco.Modules.Core.Scene.Component.Buff.Magic.ScenePlayerMagicBaseBuff")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local MagicCreationUtils = require("NewRoco.Modules.System.MagicCreation.MagicCreationUtils")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local HomeEntranceAreaId = 141030025
local HomeEntranceRotator = UE4.FRotator(0, 65, 0)
local HomeEntranceExtent = UE4.FVector(2500, 2500, 1000)
local ScenePlayerCreateBuff = Base:Extend("ScenePlayerCreateBuff")
local TopKFinderNum = 8
local TopKDistance = 800

function ScenePlayerCreateBuff:OnBegin(owner, MagicInfo)
  Base.OnBegin(self, owner, MagicInfo)
  local WandData = owner:GetCurWandDataByMagicType(ProtoEnum.SceneMagicType.SMT_CREATE)
  self.magicInfo.mozhangBP.DisappearFx = WandData.CreateMagicResource.NS_Create_Disappead
  if self.owner == nil or not self.owner.isLocal then
    return
  end
  self.magicInfo.pauseBuff = nil
  self.lastTickValidType = nil
  self.magicInfo.valid = MagicCreationUtils.NpcValidType.UnInited
  self.CreateDistance = MagicCreationUtils.TryGetGlobalConfig(_G.DataConfigManager.ConfigTableId.NPC_GLOBAL_CONFIG, "nexus_to_player_distance_when_creating", "num", 100)
  self.AirWallCheckAdditionalDistance = 200
  local teleportRuleId = MagicCreationUtils.TryGetGlobalConfig(_G.DataConfigManager.ConfigTableId.MAP_GLOBAL_CONFIG, "create_magic_teleport_rule_id", "num", 0)
  local teleportConf = _G.DataConfigManager:GetTeleportRulesConf(teleportRuleId)
  if teleportConf and teleportConf.range and teleportConf.range > 0 then
    self.AirWallCheckAdditionalDistance = teleportConf.range
  end
  self.BossAreaCheckRadius = MagicCreationUtils.TryGetGlobalConfig(_G.DataConfigManager.ConfigTableId.NPC_GLOBAL_CONFIG, "create_magic_boss_area_distance", "num", 500)
  self:CreateLocalNPC()
  self:SetHomeEntranceInfo()
end

function ScenePlayerCreateBuff:CreateLocalNPC()
  local refresh_content_id = MagicCreationUtils.GetCreateTargetNpcRefreshId(self.magicInfo)
  if not refresh_content_id then
    return
  end
  local refreshConf = _G.DataConfigManager:GetNpcRefreshContentConf(refresh_content_id, true)
  if nil == refreshConf then
    Log.Error("failed to find npc refresh config", refresh_content_id)
    return
  end
  local npc = MagicCreationUtils.CreateLocalNpc(refreshConf.npc_id, SceneUtils.ClientPos2ServerPos(self.owner:GetActorLocation()))
  npc:AddEventListener(self, NPCModuleEvent.VIEW_LOADED, self.OnNpcLoaded)
  npc:AddEventListener(self, NPCModuleEvent.On_NPC_Destroy, self.OnNpcDestroyed)
  self.magicInfo.npc = npc
  _G.NRCModuleManager:DoCmd(_G.MagicCreationModuleCmd.ApplySuitEffect, npc)
end

function ScenePlayerCreateBuff:OnNpcLoaded(viewObj)
  if not viewObj then
    return
  end
  local npc = viewObj.sceneCharacter
  if not npc then
    return
  end
  npc:RemoveEventListener(self, NPCModuleEvent.VIEW_LOADED, self.OnNpcLoaded)
  self:UpdateNpcTransform()
  self:CheckNpcValid()
end

function ScenePlayerCreateBuff:OnNpcDestroyed(npc)
  if npc then
    npc:RemoveEventListener(self, NPCModuleEvent.On_NPC_Destroy, self.OnNpcDestroyed)
  end
  self.lastTickValidType = nil
end

function ScenePlayerCreateBuff:OnUpdate(deltaTime)
  Base.OnUpdate(self, deltaTime)
  if self.owner == nil or not self.owner.isLocal then
    return
  end
  if self.magicInfo.pauseBuff then
    return
  end
  if self.magicInfo.npc and self.magicInfo.npc.viewObj ~= false and nil ~= self.magicInfo.npc.viewObj then
    self:UpdateNpcTransform()
    self:CheckNpcValid()
    if _G.NRCModuleManager:DoCmd(_G.MagicCreationModuleCmd.GetCanDrawDebug) then
      local npcLocation = self.magicInfo.npc:GetActorLocation()
      local playerLocation = self.owner:GetActorLocation()
      UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(_G.UE4Helper.GetCurrentWorld(), npcLocation, 5, 20, UE4.FLinearColor(0, 1, 0, 1), deltaTime)
      UE4.UKismetSystemLibrary.Abs_DrawDebugArrow(_G.UE4Helper.GetCurrentWorld(), playerLocation, npcLocation, 10, UE4.FLinearColor(0, 1, 0.1, 1), deltaTime, 5)
    end
  end
end

function ScenePlayerCreateBuff:UpdateNpcTransform()
  local npc = self.magicInfo.npc
  local viewObj = npc.viewObj
  if false == viewObj then
    return
  end
  local caster = self.owner
  local playerPosition = caster.viewObj:K2_GetActorLocation()
  local cameraManager = self.owner:GetUEController().PlayerCameraManager
  local direction = cameraManager:GetCameraRotation():ToVector()
  local radius = viewObj.BoundingRadius or 0.0
  local npcTargetOrigin = playerPosition + direction * (self.CreateDistance + radius)
  npc:SetActorLocation(SceneUtils.ConvertRelativeToAbsolute(npcTargetOrigin))
  MagicCreationUtils.NpcSnapToGround(npc)
end

function ScenePlayerCreateBuff:CheckNpcValid()
  self.magicInfo.valid = self:GetNpcValidType(self.magicInfo.npc)
  if MagicCreationUtils.TypeNeedResetHeight(self.magicInfo.valid) then
    local caster = self.owner
    local casterAbsOrigin = caster:GetActorLocation()
    local casterHalfHeight = caster:GetScaledHalfHeight()
    local casterHeight = casterAbsOrigin.Z - casterHalfHeight
    local npcAbsLocation = self.magicInfo.npc:GetActorLocation()
    npcAbsLocation.Z = casterHeight
    self.magicInfo.npc:SetActorLocation(npcAbsLocation)
  end
  local newValidType = self:ConvertValidType(self.magicInfo.valid)
  _G.NRCModuleManager:DoCmd(_G.MagicCreationModuleCmd.SetNpcAppearance, self.magicInfo.npc, self.magicInfo.valid)
  self.lastTickValidType = newValidType
end

function ScenePlayerCreateBuff:GetNpcValidType(npc)
  if nil == npc then
    return MagicCreationUtils.NpcValidType.Invalid
  end
  local viewObj = npc.viewObj
  if false == viewObj or nil == viewObj then
    return MagicCreationUtils.NpcValidType.Invalid
  end
  local origin, extent = MagicCreationUtils.GetActorBounds(viewObj)
  if _G.NRCModuleManager:DoCmd(_G.MagicCreationModuleCmd.CheckBossAreaOverlap, origin, self.BossAreaCheckRadius, true) then
    return MagicCreationUtils.NpcValidType.BossArea
  end
  local isHeightValid = _G.NRCModuleManager:DoCmd(_G.MagicCreationModuleCmd.CheckNpcHeightDifferenceWithPlayer, origin)
  local isLandValid = _G.NRCModuleManager:DoCmd(_G.MagicCreationModuleCmd.CheckLandValid, origin, extent)
  if isLandValid == MagicCreationUtils.NpcValidType.Water then
    return isLandValid
  end
  if isHeightValid ~= MagicCreationUtils.NpcValidType.Valid then
    return isHeightValid
  end
  if isLandValid ~= MagicCreationUtils.NpcValidType.Valid then
    return isLandValid
  end
  if MagicCreationUtils.CheckAirWallNearby(npc, self.AirWallCheckAdditionalDistance) then
    return MagicCreationUtils.NpcValidType.AirWall
  end
  if MagicCreationUtils.CheckOverlap(npc, origin, extent) then
    return MagicCreationUtils.NpcValidType.Overlap
  end
  local topKNpcs = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetTopKNpcInCpp, TopKFinderNum, TopKDistance)
  for _, topNpc in ipairs(topKNpcs) do
    if self:ConstValidateTopK(topNpc, npc) and MagicCreationUtils.CheckOverlapNotLoadedCapsule(origin, extent, topNpc) then
      if topNpc.viewObj and topNpc.viewObj.resourceLoaded then
        return MagicCreationUtils.NpcValidType.Overlap
      else
        return MagicCreationUtils.NpcValidType.OverlapNotLoaded
      end
    end
  end
  if _G.NRCModuleManager:DoCmd(_G.MagicCreationModuleCmd.CheckEavesExisted, origin, extent, {
    npc.viewObj
  }) then
    return MagicCreationUtils.NpcValidType.OverlapEaves
  end
  if self:CheckInHomeEntrance(origin, extent) then
    return MagicCreationUtils.NpcValidType.WrongScene
  end
  return MagicCreationUtils.NpcValidType.Valid
end

function ScenePlayerCreateBuff:ConvertValidType(type)
  if type == MagicCreationUtils.NpcValidType.Valid then
    return type
  end
  return MagicCreationUtils.NpcValidType.Invalid
end

function ScenePlayerCreateBuff:ConstValidateTopK(npc, ignore)
  if not npc then
    return false
  end
  if ignore and npc == ignore then
    return false
  end
  if npc:GetVisible() and npc.viewObj and npc.viewObj.resourceLoaded then
    return false
  end
  return true
end

function ScenePlayerCreateBuff:SetHomeEntranceInfo()
  local areaConf = _G.DataConfigManager:GetAreaConf(HomeEntranceAreaId, true)
  if nil == areaConf then
    return
  end
  local center_xyz = areaConf.center_xyz
  if nil == center_xyz or #center_xyz < 3 then
    return
  end
  local location = UE4.FVector(center_xyz[1], center_xyz[2], center_xyz[3])
  self.homeEntranceTransform = UE4.FTransform(HomeEntranceRotator:ToQuat(), location, _G.FVectorOne)
end

function ScenePlayerCreateBuff:CheckInHomeEntrance(origin, extent)
  if not self.homeEntranceTransform then
    return false
  end
  local abs_origin = SceneUtils.ConvertRelativeToAbsolute(origin)
  if UE4.UKismetMathLibrary.IsPointInBoxWithTransform(abs_origin, self.homeEntranceTransform, HomeEntranceExtent) then
    if _G.NRCModuleManager:DoCmd(_G.MagicCreationModuleCmd.GetCanDrawDebug) then
      UE4.UKismetSystemLibrary.Abs_DrawDebugBox(_G.UE4Helper.GetCurrentWorld(), self.homeEntranceTransform.Translation, HomeEntranceExtent, UE4.FLinearColor(0.8, 0.2, 0.05, 0.8), self.homeEntranceTransform.Rotation:ToRotator(), 0.03333333333333333, 5)
    end
    return true
  end
  return false
end

return ScenePlayerCreateBuff
