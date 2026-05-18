local RocoSkillAction = require("NewRoco.Modules.Core.Battle.Skill.RocoSkillAction")
local SkillDebugNpc = require("NewRoco.Modules.Core.Scene.Actor.SkillDebugNpc")
local WorldCombatSkillComponent = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatSkillComponent")
local ProtoEnum = require("Data.PB.ProtoEnum")
local Base = RocoSkillAction
local SelectPointsGroupMap = {
  "DefaultGroup",
  "Group2",
  "Group3",
  "Group4",
  "Group5",
  "Group6"
}
local BossSkillIdToCreationSkillId = {
  [135] = 134,
  [141] = 140,
  [143] = 142,
  [151] = 149,
  [149] = 150
}
local RocoSpawnNpcAction = Base:Extend("RocoSpawnNpcAction")

function RocoSpawnNpcAction:Ctor()
  Base.Ctor(self)
end

local IS_EDITOR = _G.RocoEnv.IS_EDITOR

function RocoSpawnNpcAction:IsSkillEditor()
  if not IS_EDITOR then
    return false
  end
  local SkillObject = self:GetSkill()
  if not SkillObject then
    return false
  end
  return SkillObject.IsSkillEditor
end

function RocoSpawnNpcAction:PreLoadUObjects()
  self.modelPath = UE.UNRCStatics.GetSoftObjPath(self.NpcClass)
  if not self.modelPath or self.modelPath == "" then
    local refreshConf = _G.DataConfigManager:GetNpcRefreshContentConf(self.ContentId, true)
    if refreshConf then
      local npcConf = _G.DataConfigManager:GetNpcConf(refreshConf.npc_id)
      self.modelPath = _G.DataConfigManager:GetModelConf(npcConf.model_conf).path
    end
  end
  self:AddStringPathToAsyncList(self.modelPath)
  _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.NPC_REFRESH_CONTENT_CONF)
  _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.NPC_CONF)
end

function RocoSpawnNpcAction:OnActionStart()
  if not self:IsSkillEditor() and _G.WorldCombatModuleCmd and not _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.IsInOfflineMode) then
    return
  end
  local caster = self:GetActorByActorInfo(self.DefaultExecuteActorInfo)
  local transform = UE.FTransform()
  UE.RocoSkillUtils.GetTransformByAttachSetting(self, self.TargetInfo, transform)
  if UE.UKismetMathLibrary.Vector_IsNearlyZero(transform.Translation) then
    transform.Translation = self:GetDefaultTargetActor() and self:GetDefaultTargetActor():K2_GetActorLocation() or caster:K2_GetActorLocation()
  end
  transform.Translation = transform.Translation + UE.FVector(math.rand(-5000, 5000), math.rand(-5000, 5000), 0)
  local refreshConf = _G.DataConfigManager:GetNpcRefreshContentConf(self.ContentId, true)
  if not refreshConf then
    return
  end
  local npcConf = _G.DataConfigManager:GetNpcConf(refreshConf.npc_id)
  local performData = {
    performType = SkillDebugNpc.PerformType.NormalSkill,
    skillPath = nil,
    missileData = {}
  }
  self.modelPath = UE.UNRCStatics.GetSoftObjPath(self.NpcClass)
  if not self.modelPath or self.modelPath == "" then
    self.modelPath = _G.DataConfigManager:GetModelConf(npcConf.model_conf).path
  end
  self.createdNpc = SkillDebugNpc.CreateNpc(self, caster, npcConf, performData, transform, nil, self.modelPath, table.contains(refreshConf.init_status, ProtoEnum.SpaceActorLogicStatus.SALS_NIGHTMARE_BOSS))
  if not self.LifeTime or self.LifeTime <= 0 then
    self.LifeTime = refreshConf.survive_time
  end
  if _G.WorldCombatModuleCmd and _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.IsInOfflineMode) then
    if self.LifeTime <= 0 then
      self.LifeTime = 100
    end
    self.LifeTime = math.min(self.LifeTime, 100)
  end
  if self.LifeTime and self.LifeTime > 0 then
    if self.lifeTimerId then
      _G.DelayManager:CancelDelayById(self.lifeTimerId)
      self.lifeTimerId = nil
    end
    self.lifeTimerId = _G.DelayManager:DelaySeconds(self.LifeTime, self.OnNpcTimeOut, self)
  end
  local targetNpc = _G.PlayerModuleCmd and _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER) or nil
  local target = targetNpc and targetNpc.viewObj or nil
  local targetList = self:GetSkillObj():GetTargets()
  if targetList and #targetList > 0 then
    target = targetList[1]
  end
  if target then
    self.createdNpc:FaceTo(target)
  end
  local skillPath = UE4.UNRCStatics.GetSoftObjPath(self.SkillClass)
  local skillId = self:GetSkillObj():GetBlackboard():GetValueAsInt("creatureSkillId")
  local createrSkillConf = _G.DataConfigManager:GetWorldCombatSkillConf(skillId, true)
  if createrSkillConf and not string.IsNilOrEmpty(createrSkillConf.skill_ref) then
    skillPath = createrSkillConf.skill_ref
  else
    self.createdNpc.bInitAI = true
  end
  self.createdNpc:PostInit(not self:IsSkillEditor())
  self.createdNpc:EnsureComponent(WorldCombatSkillComponent):StartSkill(0, skillPath, self.createdNpc.viewObj, target, nil, true, self:GetSkillObj())
end

function RocoSpawnNpcAction:OnNpcTimeOut()
  if self.createdNpc and UE.UObject.IsValid(self.createdNpc.viewObj) then
    self.createdNpc:EnsureComponent(WorldCombatSkillComponent):ForceStopCurrentSkill()
    self.createdNpc:Destroy()
    self.createdNpc = nil
  end
  if self.lifeTimerId then
    _G.DelayManager:CancelDelayById(self.lifeTimerId)
    self.lifeTimerId = nil
  end
end

function RocoSpawnNpcAction:OnChildNpcViewLoaded(npc)
  if not self.childSkillId then
    return
  end
  npc:EnsureComponent(WorldCombatSkillComponent):ClientTryCastSkill(self.childSkillId, npc:EnsureComponent(WorldCombatSkillComponent).currentContext.target)
end

function RocoSpawnNpcAction:CreateNpcInfoAtDistance(npcId, distance)
  local npcInfo = ProtoMessage:newActorInfo_Npc()
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local npcModule = NRCModuleManager:GetModule("NPCModule")
  npcInfo.base.actor_id = npcModule:AcquireFakeID()
  npcInfo.base.lv = 1
  npcInfo.base.pt.pos = ProtoMessage:newPosition()
  local player = localPlayer.viewObj:Abs_K2_GetActorLocation()
  npcInfo.base.pt.pos.x = player.X + math.random(100 + distance, 300 + distance)
  npcInfo.base.pt.pos.y = player.Y + math.random(100 + distance, 300 + distance)
  npcInfo.base.pt.pos.z = player.Z + 50
  npcInfo.base.pt.dir = UE.FVector(0, 0, 1)
  npcInfo.npc_base.npc_cfg_id = npcId
  npcInfo.npc_base.npc_content_cfg_id = 140382
  return npcInfo
end

function RocoSpawnNpcAction:OnActionEnd()
end

return RocoSpawnNpcAction
