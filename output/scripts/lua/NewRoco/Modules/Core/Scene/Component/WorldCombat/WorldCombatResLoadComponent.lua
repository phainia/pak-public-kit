local ActorComponent = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local WorldCombatSkillEvent = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatSkillEvent")
local NRCResourceManagerEnum = require("Core.Service.ResourceManager.NRCResourceManagerEnum")
local WorldCombatModuleEvent = require("NewRoco.Modules.System.WorldCombat.WorldCombatModuleEvent")
local NRCUtils = require("Core.NRCUtils")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Base = ActorComponent
local WorldCombatResLoadComponent = Base:Extend("WorldCombatResLoadComponent")
WorldCombatResLoadComponent.ShieldSkillIds = {
  144,
  145,
  155
}
WorldCombatResLoadComponent.NMShieldSkillIds = {
  146,
  147,
  158
}

function WorldCombatResLoadComponent:Ctor()
  Base.Ctor(self)
  self.needPreLoadSkillRes = true
  self:ClearAllRes()
end

function WorldCombatResLoadComponent:Attach(owner)
  Base.Attach(self, owner)
  _G.NRCEventCenter:RegisterEvent(self.name, self, WorldCombatModuleEvent.End, self.ClearAllRes)
  self.skillIdList = {}
  self.skillClassPathList = {}
  self.normalResPathList = {}
  self.loadCompleteResList = {}
  if not self.owner.serverData then
    return
  end
  local npc_content_id = self.owner.serverData.npc_base.npc_content_cfg_id
  local bossIdsConf = _G.DataConfigManager:GetBossSkillsMapConf(npc_content_id, true)
  if not bossIdsConf then
    return
  end
  table.deepCopy(bossIdsConf.skill_ids, self.skillIdList, true)
  if not SceneUtils.IsLogicStatusNightmareBossActivated(owner) then
    for _, skillId in pairs(WorldCombatResLoadComponent.ShieldSkillIds) do
      if not table.contains(self.skillIdList, skillId) then
        table.insert(self.skillIdList, skillId)
      end
    end
  else
    for _, skillId in pairs(WorldCombatResLoadComponent.NMShieldSkillIds) do
      if not table.contains(self.skillIdList, skillId) then
        table.insert(self.skillIdList, skillId)
      end
    end
  end
  self.normalResPathList = {
    "/Game/ArtRes/Effects/Particle/Scene/BossBattle/NS_BossBattle_Shield_HitNormal.NS_BossBattle_Shield_HitNormal",
    "/Game/ArtRes/Effects/Particle/Scene/BossBattle/NS_BossBattle_Shield_HitCritical.NS_BossBattle_Shield_HitCritical",
    "/Game/ArtRes/Effects/Particle/Scene/BossBattle/NS_BossBattle_EMShield_HitNormal.NS_BossBattle_EMShield_HitNormal",
    "/Game/ArtRes/Effects/Particle/Scene/BossBattle/NS_BossBattle_EMShield_HitCritical.NS_BossBattle_EMShield_HitCritical",
    "/Game/ArtRes/Effects/Particle/Scene/BossBattle/NS_BossBattle_Shield_Invalid.NS_BossBattle_Shield_Invalid",
    "/Game/ArtRes/Effects/Particle/Scene/BossBattle/NS_BossBattle_EMShield_Invalid.NS_BossBattle_EMShield_Invalid",
    "NiagaraSystem'/Game/ArtRes/Effects/Particle/Scene/BossBattle/NS_Scene_BossBattle_Boom.NS_Scene_BossBattle_Boom'"
  }
  local worldCombatConf = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.WORLD_COMBAT_CONF):GetAllDatas()
  local childNpcList = {}
  for _, conf in pairs(worldCombatConf) do
    if conf.refresh_content_id ~= npc_content_id or not conf.preloading_npc then
    else
      for _, npcId in pairs(conf.preloading_npc) do
        local childModelId = _G.DataConfigManager:GetNpcConf(npcId).model_conf
        local childModelPath = _G.DataConfigManager:GetModelConf(childModelId).path
        table.insert(self.normalResPathList, childModelPath)
        table.insert(childNpcList, npcId)
      end
      break
    end
  end
  local bossSkillsMapConf = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.BOSS_SKILLS_MAP_CONF):GetAllDatas()
  for _, npcId in pairs(childNpcList) do
    for _, conf in pairs(bossSkillsMapConf) do
      if conf.npc_id == npcId then
        for _, skillId in pairs(conf.skill_ids) do
          if not table.contains(self.skillIdList, skillId) then
            table.insert(self.skillIdList, skillId)
          end
        end
      end
    end
  end
  local worldBuffConf = _G.DataConfigManager:GetAllByTableID(_G.DataConfigManager.ConfigTableId.WORLD_BUFF_CONF)
  if not worldBuffConf then
    return
  end
  for _, conf in pairs(worldBuffConf) do
    for _, option in pairs(conf.option) do
      if option.particle_name and option.particle_name ~= "" and not table.contains(self.normalResPathList, option.particle_name) then
        table.insert(self.normalResPathList, option.particle_name)
      end
      if option.skill_name and "" ~= option.skill_name then
        local buffSkillPath = NRCUtils.FormatBlueprintAssetPath(option.skill_name)
        if not table.contains(self.normalResPathList, buffSkillPath) then
          table.insert(self.normalResPathList, buffSkillPath)
        end
      end
    end
  end
end

function WorldCombatResLoadComponent:OnSetViewObj()
  Base.OnSetViewObj(self)
  if not _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.IsInOfflineMode) then
    local hitComps = self.owner.viewObj:GetComponentsByTag(UE4.UPrimitiveComponent, "SkillHit")
    for idx = 1, hitComps:Length() do
      local hitComp = hitComps:Get(idx)
      hitComp:SetGenerateOverlapEvents(false)
      hitComp:SetComponentTickEnabled(false)
    end
  end
  self.rocoSkillComp = self.owner.viewObj.RocoSkill
  if self.owner.viewObj.SetLoadPriority and type(self.owner.viewObj.SetLoadPriority) == "function" then
    self.owner.viewObj:SetLoadPriority(PriorityEnum.Passive_WorldCombat_Important)
  end
end

function WorldCombatResLoadComponent:DeAttach()
  Base.DeAttach(self)
  _G.NRCEventCenter:UnRegisterEvent(self, WorldCombatModuleEvent.End, self.ClearAllRes)
  self.skillIdList = {}
  self.normalResPathList = {}
  self:ClearAllRes()
end

function WorldCombatResLoadComponent:ClearAllRes()
  self.WaitToLoadSkillIds = {}
  self.WaitToLoadSkillPaths = {}
  self.ExcludeSkillIds = {2011}
  self.skillClassList = {}
  self.skillClassRefList = {}
  self.skillObjList = {}
  self.skillObjRefList = {}
  self.normalResList = {}
  self.normalResRefList = {}
  self.LoadingNormalResList = {}
  self.loadCompleteResList = {}
end

function WorldCombatResLoadComponent:IsInPreLoadRange(sqrDistanceIgnoreZ, PreLoadRange)
  if not w then
    return true
  end
  return sqrDistanceIgnoreZ < PreLoadRange * PreLoadRange
end

function WorldCombatResLoadComponent:OnDistanceOptimize(sqrDistanceIgnoreZ, viewDotValue, sqrDistance, distanceRatio)
  local npc_content_id = self.owner.serverData.npc_base.npc_content_cfg_id
  local bossIdsConf = _G.DataConfigManager:GetBossSkillsMapConf(npc_content_id, true)
  if bossIdsConf and self.needPreLoadSkillRes and self:IsInPreLoadRange(sqrDistanceIgnoreZ, bossIdsConf.preload_distance) then
    for _, skillId in pairs(self.skillIdList) do
      if table.contains(self.WaitToLoadSkillIds, skillId) or table.contains(self.ExcludeSkillIds, skillId) then
      else
        local skillConf = _G.DataConfigManager:GetWorldCombatSkillConf(skillId, true)
        if not skillConf or not skillConf.effective then
          Log.Debug("WorldCombatResLoadComponent:OnDistanceOptimize: Config data of skill is invalid!!!", skillId)
          if not table.contains(self.ExcludeSkillIds, skillId) then
            table.insert(self.ExcludeSkillIds, skillId)
          end
        elseif not skillConf.skill_ref then
          Log.Debug("WorldCombatResLoadComponent:OnDistanceOptimize: skill_ref of skill config is invalid!!!", skillId)
          if not table.contains(self.ExcludeSkillIds, skillId) then
            table.insert(self.ExcludeSkillIds, skillId)
          end
        else
          local skillClassPath = NRCUtils.FormatBlueprintAssetPath(skillConf.skill_ref)
          if table.contains(self.loadCompleteResList, skillClassPath) then
            if not table.contains(self.ExcludeSkillIds, skillId) then
              table.insert(self.ExcludeSkillIds, skillId)
            end
          else
            _G.NRCResourceManager:LoadResAsync(self, skillClassPath, PriorityEnum.Active_World_Combat_Boss, 100, self.SkillClassLoadSuccess, self.SkillClassLoadFailed)
            table.insert(self.WaitToLoadSkillIds, skillId)
          end
        end
      end
    end
    for _, skillClassPath in pairs(self.skillClassPathList) do
      if not table.contains(self.loadCompleteResList, skillClassPath) and not table.contains(self.WaitToLoadSkillPaths, skillClassPath) then
        _G.NRCResourceManager:LoadResAsync(self, skillClassPath, PriorityEnum.Active_World_Combat_Boss, 100, self.SkillClassLoadSuccess, self.SkillClassLoadFailed)
        table.insert(self.WaitToLoadSkillPaths, skillClassPath)
      end
    end
    for _, resPath in pairs(self.normalResPathList) do
      if self.LoadingNormalResList[resPath] then
      elseif self.normalResList[resPath] then
      else
        local Res = _G.NRCResourceManager:LoadResAsync(self, resPath, PriorityEnum.Active_World_Combat_Boss, 100, self.NormalResLoadSuccess, self.NormalResLoadFailed)
        self.LoadingNormalResList[resPath] = Res
      end
    end
  end
end

function WorldCombatResLoadComponent:SkillClassLoadSuccess(req, asset)
  if not UE.UObject.IsValid(self.rocoSkillComp) then
    if UE.UObject.IsValid(self.owner.viewObj) then
      Log.Error("WorldCombatResLoadComponent:SkillClassLoadSuccess: No rocoSkillComp on owner!!!", self.owner.viewObj:GetName())
    end
    return
  end
  local skillObj = self.rocoSkillComp:AddSkillObjFromClassAndReturn(asset)
  if UE.UObject.IsValid(self.owner.viewObj) and UE.UObject.IsValid(skillObj) then
    skillObj.OnAsyncLoadCompleted:Add(self.owner.viewObj, self.SkillResLoadComplete)
    skillObj:StartAsyncLoading()
  end
  table.insert(self.skillClassRefList, UnLua.Ref(asset))
  self.skillClassList[req.assetPath] = asset
  if UE.UObject.IsValid(skillObj) then
    table.insert(self.skillObjRefList, UnLua.Ref(skillObj))
    self.skillObjList[req.assetPath] = skillObj
    local actions = skillObj:GetAllActions()
    for i = 1, actions:Length() do
      local action = actions:Get(i)
      if action:IsA(UE.URocoWorldCombatSpawnNpcThenSkillAction) and action.NpcSpawnAndSkillInfo then
        local childSkill = action.NpcSpawnAndSkillInfo.TargetSkill
        local childSkillPath = NRCUtils.FormatBlueprintAssetPath(UE.UKismetSystemLibrary.GetPathName(childSkill))
        if childSkillPath and "" ~= childSkillPath and not table.contains(self.skillClassPathList, childSkillPath) then
          table.insert(self.skillClassPathList, childSkillPath)
        end
      end
    end
  end
  if not table.contains(self.loadCompleteResList, req.assetPath) then
    table.insert(self.loadCompleteResList, req.assetPath)
  end
  self.owner:SendEvent(WorldCombatSkillEvent.SKILL_CLASS_LOADED, asset)
end

function WorldCombatResLoadComponent:SkillClassLoadFailed(req, msg)
  Log.Debug("WorldCombatResLoadComponent:SkillLoadFailed: ", msg, req.assetPath)
  if not table.contains(self.loadCompleteResList, req.assetPath) then
    table.insert(self.loadCompleteResList, req.assetPath)
  end
end

function WorldCombatResLoadComponent:SkillResLoadComplete(skillObj)
  Log.Debug("WorldCombatResLoadComponent: SkillResLoadComplete", skillObj:GetSkillID(), skillObj:GetName())
end

function WorldCombatResLoadComponent:NormalResLoadSuccess(req, asset)
  table.insert(self.normalResRefList, UnLua.Ref(asset))
  self.normalResList[req.assetPath] = asset
end

function WorldCombatResLoadComponent:NormalResLoadFailed(req, msg)
  Log.Debug("WorldCombatResLoadComponent:normalResLoadFailed: ", msg, req.assetPath)
end

function WorldCombatResLoadComponent:GetResAssetByPath(path)
  if not path then
    return
  end
  return self.normalResList[path]
end

function WorldCombatResLoadComponent:AddSkillIdToLoad(skillId)
  if table.contains(self.skillIdList, skillId) then
    return
  end
  table.insert(self.skillIdList, skillId)
end

function WorldCombatResLoadComponent:AddNormalResPathToLoad(resPath)
  if table.contains(self.normalResPathList, resPath) then
    return
  end
  table.insert(self.normalResPathList, resPath)
end

function WorldCombatResLoadComponent:GetSkillClassByPath(classPath)
  if table.containsKey(self.skillClassList, classPath) then
    return self.skillClassList[classPath]
  end
  local ownerNpc = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, self.owner.serverData.base.owner_id)
  if ownerNpc then
    local OwnerResLoadComponent = ownerNpc:EnsureComponent(WorldCombatResLoadComponent)
    return OwnerResLoadComponent:GetSkillClassByPath(classPath)
  end
  return nil
end

return WorldCombatResLoadComponent
