local MissileUtils = require("NewRoco.Modules.Core.Missile.MissileUtils")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local LuaMathUtils = require("NewRoco.Utils.LuaMathUtils")
local MissileEvent = require("NewRoco.Modules.Core.Missile.MissileEvent")
local WorldCombatSkillComponent = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatSkillComponent")
local WorldCombatModuleEvent = require("NewRoco.Modules.System.WorldCombat.WorldCombatModuleEvent")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local TaskModuleEvent = require("NewRoco.Modules.Core.Task.TaskModuleEvent")
local MissileModule = NRCModuleBase:Extend("MissileModule")

function MissileModule:OnConstruct()
  _G.MissileModuleCmd = reload("NewRoco.Modules.Core.Missile.MissileModuleCmd")
  self.data = self:SetData("MissileModuleData", "NewRoco.Modules.Core.Missile.MissileModuleData")
  self.currGuid = 0
end

function MissileModule:OnActive()
  self:RegisterMissileComps()
  UpdateManager:UnRegister(self)
  _G.NRCEventCenter:RegisterEvent(self.name, self, WorldCombatModuleEvent.End, self.ClearAllRes)
  _G.NRCEventCenter:RegisterEvent(self.name, self, TaskModuleEvent.BattleStart, self.ClearAllRes)
end

function MissileModule:GetMissileId()
  self.currGuid = self.currGuid + 1
  return self.currGuid
end

function MissileModule:RegisterMissileComps()
  local MissileComponent = require("NewRoco.Modules.Core.Scene.Component.Missile.MissileComponent")
  local TraceMissileComponent = require("NewRoco.Modules.Core.Scene.Component.Missile.TraceMissileComponent")
  local CurveMissileComponent = require("NewRoco.Modules.Core.Scene.Component.Missile.CurveMissileComponent")
  MissileComponent.module = self
  TraceMissileComponent.module = self
  CurveMissileComponent.module = self
end

function MissileModule:CreateMissile(missileId, caster, target, targetPos, skillId, actionIdx, missileData, createPosSync, createRotSync, missileNpc)
  if not caster then
    Log.Error("MissileModule:CreateMissile can't create missile without a caster")
    return
  end
  if nil == missileData then
    local ActionData = Context:GetDynamicData(actionIdx)
    missileData = ActionData and ActionData.missileData
  end
  if nil == missileData then
    Log.Error("MissileModule:CreateMissile can't create missile without a valid action data")
    return
  end
  local missile = missileNpc
  if not missile or not missile.viewObj then
    return
  end
  missile.missileComp = MissileUtils:GetComponent(missileData.MissileType)
  missile:AddComponent(missile.missileComp)
  missile.missileComp:InitMissileData(caster, target, targetPos, skillId, actionIdx, missileData, missile.viewObj:K2_GetActorLocation(), missile.viewObj:K2_GetActorRotation():ToVector())
  if nil == missileId then
    missileId = missile.serverData.base.actor_id
  end
  missile.missileComp.missileId = missileId
  self.data.unLaunchMissiles[missileId] = missile
  missile.missileComp:OnCreate()
  caster:SendEvent(MissileEvent.ON_MISSILE_CREATE, missileId)
  return missileId
end

function MissileModule:InternalCreateMissile(missileId, caster, target, targetPos, skillId, actionIdx, missileData)
end

function MissileModule:RequestCreateMissile(caster, target, targetPos, skillId, actionIdx, missileData)
  caster:EnsureComponent(WorldCombatSkillComponent).currentContext:UpdateDynamicData(actionIdx, {missileData = missileData})
  local createPos, createRot
  createPos, createRot = self:GetSocketLocAndDir(caster.viewObj, missileData.AttachSocket, missileData.OffsetTransform)
  createPos = SceneUtils.ClientPos2ServerPos(createPos)
  createRot = SceneUtils.ClientRotator2ServerPos(UE.UKismetMathLibrary.Quat_Rotator(createRot), 10)
  local req = ProtoMessage:newZoneSceneWorldCombatSkillSpawnBulletReq()
  req.npc_id = caster.serverData.base.actor_id
  req.skill_spawn_bullet_info.skill_id = skillId
  req.skill_spawn_bullet_info.action_idx = actionIdx
  req.skill_spawn_bullet_info.caster_id = caster.serverData.base.actor_id
  req.skill_spawn_bullet_info.target_id = target.serverData.base.actor_id
  req.skill_spawn_bullet_info.target_pos = targetPos
  req.skill_spawn_bullet_info.init_pos = createPos
  req.skill_spawn_bullet_info.init_dir = createRot
  ZoneServer:Send(ProtoCMD.ZoneSvrCmd.ZONE_SCENE_WORLD_COMBAT_SKILL_SPAWN_BULLET_REQ, req)
end

function MissileModule:LaunchMissile(missileId)
  local missileTemp = self:GetMissileById(missileId)
  if not missileTemp then
    return
  end
  if not missileTemp.viewObj then
    Log.Debug("MissileModule:LaunchMissile, missile viewObj is not valid when launch!")
    missileTemp:AddEventListener(self, NPCModuleEvent.VIEW_SHELL_LOADED, self.LaterLaunchMissile)
    return
  end
  local TargetDir = missileTemp.missileComp.targetPos - missileTemp:GetActorLocation()
  TargetDir:Normalize()
  Log.Debug("MissileModule:LaunchMissile", missileTemp:GetActorRotation():ToVector(), TargetDir, missileTemp:GetActorLocation(), missileTemp.missileComp.targetPos, missileTemp.missileComp.target)
  table.removeKey(self.data.unLaunchMissiles, missileId)
  self.data.launchedMissiles[missileId] = missileTemp
  missileTemp.missileComp:OnLaunch()
  if not _G.WorldCombatModuleCmd or _G.WorldCombatModuleCmd and _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.IsInOfflineMode) then
    missileTemp.collisionComps = {}
    self:StartDetectCollision(missileId)
  end
  if 1 == table.len(self.data.launchedMissiles) then
    UpdateManager:Register(self)
    UpdateManager:Register(self)
  end
end

function MissileModule:CreateMissileByData(missileNpcId, caster, target, targetPos, skillId, missileData)
  local missile = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, missileNpcId)
  if not missile then
    Log.Error("MissileModule:LaunchMissileByData failed, cannot get missile npc by server id!!!", missileNpcId)
    return
  end
  local Lua_NPCBaseHandy = require("NewRoco.Modules.Core.NPC.Lua_NPCBaseHandy")
  missile.luaObj = Lua_NPCBaseHandy()
  missile.luaObj.sceneCharacter = missile
  local TraceMissileComponent = require("NewRoco.Modules.Core.Scene.Component.Missile.TraceMissileComponent")
  missile.missileComp = MissileUtils:GetComponent(missileData.MissileType) or TraceMissileComponent()
  missile.missileComp:Attach(missile, self)
  missile.missileComp:InitMissileData(caster, target, targetPos, skillId, 0, missileData, LuaMathUtils.ConvPositionToVector(missile:GetActorLocation()), missile:GetActorRotation():ToVector())
  local missileId = self:GetMissileId()
  missile.missileComp.missileId = missileId
  self.data.unLaunchMissiles[missileId] = missile
  if not missile.viewObj then
    Log.Debug("MissileModule:LaunchMissileByData, missile viewObj is not valid when launch!")
    missile:AddEventListener(self, NPCModuleEvent.VIEW_SHELL_LOADED, self.LaterLaunchMissileByData)
    return missileId
  end
  missile.missileComp:OnCreate()
  return missileId
end

function MissileModule:LaunchMissileByData(missileNpcId, missileId, caster, target, targetPos, skillId, missileData)
  missileId = missileId or self:CreateMissileByData(missileNpcId, caster, target, targetPos, skillId, missileData)
  self:LaunchMissile(missileId)
end

function MissileModule:LaunchCurveMissile(missileNpcId, missileId, caster, target, targetPos, skillId, missileAction, missileData)
  missileId = missileId or self:CreateMissileByData(missileNpcId, caster, target, targetPos, skillId, missileData)
  local missile = self:GetMissileById(missileId)
  missile.missileComp.missileAction = missileAction
  self:LaunchMissile(missileId)
end

function MissileModule:LaterLaunchMissile(missile)
  Log.Debug("MissileModule:LaterLaunchMissile", missile.viewObj)
  self:LaunchMissile(missile.missileComp:GetOwnerId())
end

function MissileModule:LaterLaunchMissileByData(missile)
  if not missile.viewObj then
    return
  end
  missile.missileComp:OnCreate()
  missile.missileComp.logicPos = missile:GetActorLocation()
  missile.missileComp.logicDir = missile:GetActorRotation():ToVector()
  Log.Debug("MissileModule:LaterLaunchMissileByData", missile.viewObj)
  self:LaunchMissile(missile.missileComp.missileId)
end

function MissileModule:RequestLaunchMissile(caster, skillId, missileId)
  local req = ProtoMessage:newZoneSceneWorldCombatSkillFireBulletReq()
  req.npc_id = caster.serverData.base.actor_id
  req.skill_fire_bullet_info.skill_id = skillId
  req.skill_fire_bullet_info.bullet_id = missileId
  self.pendingLaunch = true
  ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_SCENE_WORLD_COMBAT_SKILL_FIRE_BULLET_REQ, req, self, self.LaunchMissileRsp, false, true)
end

function MissileModule:LaunchMissileRsp(rsp)
  if 0 ~= rsp.ret_info.ret_code then
    Log.PrintScreenMsg("LaunchMissileRsp failed: %d", rsp.ret_info.ret_code)
    self:ClearUnlaunchedRes()
  end
  self.pendingLaunch = false
end

function MissileModule:GetMissileDataBySkillInfo(skillId)
end

function MissileModule:GetSocketLocAndDir(model, socket, offsetTransform)
  local skMesh = model:GetComponentByClass(UE4.USkeletalMeshComponent)
  if nil == skMesh then
    Log.Error("Cannot get SkeletalMesh from NPC: %d in MissileModule", model.sceneCharacter.serverData.base.actor_id)
    return
  end
  local socketTransform = UE.UKismetMathLibrary.ComposeTransforms(offsetTransform, skMesh:Abs_GetSocketTransform(socket))
  local _socketPos = socketTransform.Translation
  local socketPos = UE.FVector(_socketPos.X, _socketPos.Y, _socketPos.Z)
  local _socketRot = socketTransform.Rotation
  local socketRot = UE.FQuat(_socketRot.X, _socketRot.Y, _socketRot.Z, _socketRot.W)
  return socketPos, socketRot
end

function MissileModule:GetMissileById(missileId)
  return self.data.unLaunchMissiles[missileId] or self.data.launchedMissiles[missileId]
end

function MissileModule:OnTick(DeltaTime)
  for _, missile in pairs(self.data.launchedMissiles) do
    if not missile.viewObj then
    else
      missile.missileComp:Update(DeltaTime)
    end
  end
end

function MissileModule:OnMissileArrived(missileId)
  local missileTemp = self:GetMissileById(missileId)
  Log.Debug("MissileModule:OnMissileArrived", missileId)
  table.removeKey(self.data.launchedMissiles, missileId)
  if nil == missileTemp then
    return
  end
  local npcModule = NRCModuleManager:GetModule("NPCModule")
  if not (npcModule and missileTemp.serverData) or not missileTemp.serverData.base.actor_id then
    missileTemp:Destroy()
  else
    npcModule:RemoveNpc(missileTemp.serverData.base.actor_id, true)
  end
  local collisionModule = NRCModuleManager:GetModule("CollisionModule")
  if not collisionModule and _G.RocoEnv.IS_EDITOR then
    local CollisionModule = require("NewRoco.Modules.Core.Collision.CollisionModule")
    collisionModule = CollisionModule()
    collisionModule:OnConstruct()
  end
  if nil == missileTemp.collisionComps then
    return
  end
  for _, collisionComp in pairs(missileTemp.collisionComps) do
    collisionModule:RemoveCollisionComp(collisionComp)
  end
  if table.len(self.data.launchedMissiles) <= 0 then
    UpdateManager:UnRegister(self)
    Log.Debug("MissileModule:UpdateManager:UnRegister", missileId)
  end
end

function MissileModule:StartDetectCollision(missileId, scale)
  local collisionModule = NRCModuleManager:GetModule("CollisionModule")
  if not collisionModule then
    local CollisionModule = require("NewRoco.Modules.Core.Collision.CollisionModule")
    collisionModule = CollisionModule()
    collisionModule:OnConstruct()
  end
  local missile = self:GetMissileById(missileId)
  if not missile or not UE.UObject.IsValid(missile.viewObj) then
    return
  end
  local hitComps = missile.viewObj:GetComponentsByTag(UE4.UPrimitiveComponent, "SkillHit")
  scale = scale or 1.0
  for idx = 1, hitComps:Length() do
    local hitComp = hitComps:Get(idx)
    if not UE.UObject.IsValid(hitComp) then
      return
    end
    hitComp:SetWorldScale3D(hitComp:K2_GetComponentScale() * scale)
    hitComp:SetCollisionProfileName("SkillHit")
    hitComp:SetCollisionEnabled(UE.ECollisionEnabled.QueryOnly)
    hitComp:SetGenerateOverlapEvents(true)
    local collisionComp = collisionModule:GetCollisionComp(missile, hitComp)
    collisionComp:BindCollisionEvent(missile.missileComp, Enum.CollisionEventType.ON_COMPONENT_BEGINOVERLAP, missile.missileComp.OnCollision, 0, false)
    collisionComp = collisionModule:GetNewCollisionComp(missile, hitComp)
    collisionComp:BindCollisionEvent(missile.missileComp, Enum.CollisionEventType.ON_COMPONENT_HIT, missile.missileComp.OnCollision, 0, false)
  end
end

function MissileModule:OnDeactive()
  _G.NRCEventCenter:UnRegisterEvent(self, WorldCombatModuleEvent.End, self.ClearAllRes)
  _G.NRCEventCenter:UnRegisterEvent(self, TaskModuleEvent.BattleStart, self.ClearAllRes)
  for _, missile in pairs(self.data.unLaunchMissiles) do
    missile.missileComp:Destroy(Enum.MissileDestroyReason.MDR_SKILL_END_UN_LAUNCH)
  end
  for _, missile in pairs(self.data.launchedMissiles) do
    missile.missileComp:Destroy(Enum.MissileDestroyReason.MDR_SKILL_END_UN_LAUNCH)
  end
  self.data:ResetData()
end

function MissileModule:ClearUnlaunchedRes()
  for _, missile in pairs(self.data.unLaunchMissiles) do
    missile.missileComp:Destroy(Enum.MissileDestroyReason.MDR_SKILL_END_UN_LAUNCH)
  end
  self.unLaunchMissiles = {}
end

function MissileModule:ClearlaunchedRes()
  for _, missile in pairs(self.data.launchedMissiles) do
    missile.missileComp:Destroy(Enum.MissileDestroyReason.MDR_SKILL_END_UN_LAUNCH)
  end
  self.launchedMissiles = {}
end

function MissileModule:ClearAllRes()
  self:ClearUnlaunchedRes()
  self:ClearlaunchedRes()
end

function MissileModule:OnContextSkillEnd()
  if not self.pendingLaunch then
    self:ClearUnlaunchedRes()
  end
end

function MissileModule:DebugCreateMissile(casterActor, targetActor, targetPos, missileData)
end

return MissileModule
