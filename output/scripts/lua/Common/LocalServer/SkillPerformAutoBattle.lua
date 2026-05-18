local JsonUtils = require("Common.JsonUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local ServerData = require("Common.LocalServer.LocalBattleRSPTable")
local SkillPerformAutoBattle = {}
local configFilename = "AutoPerformBattle"

function SkillPerformAutoBattle:Enable()
  _G.BattleEventCenter:Bind(self, BattleEvent.ROUND_STATE_SELECT, BattleEvent.FX_PERF_ON_SKILL_PLAY_START, BattleEvent.FX_PERF_ON_SKILL_PLAY_PAUSE, BattleEvent.PLAYER_SPAWNED, BattleEvent.PET_LOAD_MODE_LOVER, BattleEvent.StartSkill_AutoPerform)
  self.fileName = configFilename
  self.isRunning = true
  self.skillIndex = 1
  self.skillLoopCount = 0
  self.isFirstEnter = true
  self.skillPathDict = {}
  self.isFinished = false
  self.isStarted = false
  ServerData.values.CurSelectedPetPlayer = 1
  ServerData.values.CurSelectedPetEnemy = 401
  ServerData.AutoTestOver = false
  self:LoadFile()
  self.config = _G.DataConfigManager:GetSceneResConf(10003)
  self.config.source = "/Game/ArtRes/Level/Performance/SkillPerform"
  if self.performData.worldPath then
    self.config.source = self.performData.worldPath
  end
  if self.performData.vfxQuality then
    local vfxQuality = string.lower(self.performData.vfxQuality)
    Log.Debug("setting effects graphic quality: " .. vfxQuality)
    self:SetEffectGraphicQuality(vfxQuality)
  end
  _G.StartAutoGCByTick = 0
  UE4.UNRCStatics.ExecConsoleCommand("nrc.DebugAutoBattle 1")
end

function SkillPerformAutoBattle:SetEffectGraphicQuality(vfxQuality)
  if "high" == vfxQuality then
    UE4.USkillBlueprintLibrary.SetEffectsQuality(UE4.ESkillEffectsQuality.High)
  elseif "medium" == vfxQuality then
    UE4.USkillBlueprintLibrary.SetEffectsQuality(UE4.ESkillEffectsQuality.Medium)
  elseif "low" == vfxQuality then
    UE4.USkillBlueprintLibrary.SetEffectsQuality(UE4.ESkillEffectsQuality.Low)
  end
end

function SkillPerformAutoBattle:GetOpenID()
  if self.performData and self.performData.openID then
    return self.performData.openID
  else
    self.performData = JsonUtils.LoadSaved(configFilename, {})
    if self.performData then
      return self.performData.openID
    end
  end
end

function SkillPerformAutoBattle:HideBattleUI()
  function _G.BattleManager.OpenBattleMainWindow()
  end
  
  function NRCModuleBase.LogError()
  end
  
  local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
  
  function BattleUtils.HasMainWindow()
    return true
  end
  
  local BuffAEffectPopupComponent = require("NewRoco.Modules.Core.Battle.Entity.Components.BuffEffectPopup.BuffAEffectPopupComponent")
  
  function BuffAEffectPopupComponent.DoPopup()
  end
end

function SkillPerformAutoBattle:LoadFile()
  self.performData = JsonUtils.LoadSaved(self.fileName, {})
  if self.performData then
    if not self.performData.IsShowBattleUI then
      self:HideBattleUI()
    end
    for _, black in ipairs(self.performData.blackSkillPath or {}) do
      self.skillPathDict[black] = true
    end
    local Skills = {}
    local AllSkill = _G.DataConfigManager:GetAllByName("SKILL_CONF")
    local Enum = require("Data.Config.Enum")
    AllSkill[200000].name = "\231\169\186\230\138\128\232\131\189"
    AllSkill[200000].desc = "\231\169\186\230\138\128\232\131\189"
    AllSkill[200000].res_id = "/Game/ArtRes/Effects/G6Skill/SkillPerformAutoTest/EmptySkill.EmptySkill"
    _G.DataConfigManager:GetSkillConf(200000)
    for _, v in pairs(AllSkill) do
      if v.res_id ~= nil and not self.skillPathDict[v.res_id] then
        self.skillPathDict[v.res_id] = true
        if self.performData.skillNames and #self.performData.skillNames > 0 then
          for _, name in ipairs(self.performData.skillNames) do
            if string.find(v.res_id, name) then
              table.insert(Skills, v)
            end
          end
        else
          table.insert(Skills, v)
        end
      end
    end
    if self.performData.isAllListForSelf then
      for _, v in ipairs(Skills) do
        local data = {}
        data.caster = "self"
        data.loopCount = self.performData.allListLoopCount or 1
        data.skillId = v.id
        table.insert(self.performData.skillList, data)
      end
    end
    if self.performData.isAllListForEnemy then
      for _, v in ipairs(Skills) do
        local data = {}
        data.caster = "enemy"
        data.loopCount = self.performData.allListLoopCount or 1
        data.skillId = v.id
        table.insert(self.performData.skillList, data)
      end
    end
    table.sort(self.performData.skillList, function(a, b)
      return a.skillId < b.skillId
    end)
    JsonUtils.DumpSaved(self.fileName .. "_performData", self.performData)
    if nil == not self.performData.playSkillStopAt then
      Log.Debug("SkillPerformAutoBattle:LoadFile() playSkillStopAt = " .. self.performData.playSkillStopAt)
    else
      Log.Debug("SkillPerformAutoBattle:LoadFile() Num of Skills to perform = " .. #self.performData.skillList)
    end
  end
end

function SkillPerformAutoBattle:GetBattlePosition()
  if self.performData and self.performData.pos then
    return UE4.FVector(self.performData.pos.x, self.performData.pos.y, self.performData.pos.z)
  end
end

function SkillPerformAutoBattle:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.ROUND_STATE_SELECT then
    if not self.isStarted then
      self.isStarted = true
    end
    _G.DelayManager:DelayFrames(30, self.ReleaseSkillRes, self)
    _G.DelayManager:DelayFrames(60, self.PerformNextSkill, self)
    self:RefreshAllPets()
    return true
  end
  if eventName == BattleEvent.FX_PERF_ON_SKILL_PLAY_START then
    local frameCount = self.SkillObject:GetLength() * self.SkillObject:GetFPS()
    local cmd = string.format("FxPerf.Start %s_%s %f", self.skill_cast.skill_id, self.SkillObject:GetDisplayName(), frameCount)
    UE4.UNRCStatics.ExecConsoleCommand(cmd)
    return true
  end
  if eventName == BattleEvent.FX_PERF_ON_SKILL_PLAY_PAUSE then
    local cmd = string.format("FxPerf.Pause")
    UE4.UNRCStatics.ExecConsoleCommand(cmd)
    return true
  end
  if eventName == BattleEvent.PLAYER_SPAWNED then
    if self.performData and not self.performData.IsShowBattleModel then
      local player = (...)
      if player.model then
        local mesh = player.model:GetComponentByClass(UE.USkeletalMeshComponent)
        if mesh then
          mesh:SetVisibility(false)
          mesh:SetHiddenInGame(true)
        end
      end
    end
    return true
  end
  if eventName == BattleEvent.PET_LOAD_MODE_LOVER then
    if self.performData and not self.performData.IsShowBattleModel then
      local pet = (...)
      local mesh = pet.model:GetComponentByClass(UE.USkeletalMeshComponent)
      if mesh then
        mesh:SetVisibility(false)
        mesh:SetHiddenInGame(true)
      end
    end
    return true
  end
  if eventName == BattleEvent.StartSkill_AutoPerform then
    if self.performData and not self.performData.IsShowBattleEffect then
      local skillObject = (...)
      local actions = skillObject:GetAllActions()
      for i = 1, actions:Length() do
        local action = actions:Get(i)
        if action:IsA(UE.URocoPlayFxSystemAction) or action:IsA(UE.URocoPlayParticleEffectAction) or action:IsA(UE.URocoPlayProjectileEffectAction) or action:IsA(UE.URocoSpawnAction) or action:IsA(UE.URocoPlayAnimationAction) then
          action.m_Enable = false
        end
      end
    end
    return true
  end
end

function SkillPerformAutoBattle:ReleaseSkillRes()
  local allPets = BattleManager.battlePawnManager:GetAllPets()
  for i = 1, #allPets do
    allPets[i].model:ClearMaterials()
  end
  collectgarbage("collect")
  UE4.UNRCStatics.ForceGarbageCollection(true)
  UE4.USkillRecordLibrary.ReleaseAllSkill()
end

function SkillPerformAutoBattle:RefreshAllPets()
  local pets = _G.BattleManager.battlePawnManager:GetAllPets()
  for i, v in ipairs(pets) do
    self:RefreshSelfForSkillTest(v)
  end
end

function SkillPerformAutoBattle:ClearAllPetsSkill()
  local pets = _G.BattleManager.battlePawnManager:GetAllPets()
  for _, pet in ipairs(pets) do
    pet:ClearSkill()
  end
end

function SkillPerformAutoBattle:BattleFieldLeaveBattle()
  BattleManager:ClearBattle()
end

function SkillPerformAutoBattle:RefreshSelfForSkillTest(pet)
  if pet.model then
    pet:SetScale(1.0)
    if not pet.card:CheckIsMimic() then
      pet.perception:PinOnTheGround()
    end
    pet:ResetRotation(true)
    pet.model:SetActorHiddenInGame(false)
    local mesh = pet.model:GetComponentByClass(UE4.USkeletalMeshComponent)
    if mesh then
      mesh:SetVisibility(true)
    end
  end
end

function SkillPerformAutoBattle:PreFirstPerform()
  UE4.UNRCStatics.ExecConsoleCommand("WorldTileTool.FreezeWorldComposition 1")
  UE4.UNRCStatics.ExecConsoleCommand("show DynamicShadows")
  UE4.UNRCStatics.ExecConsoleCommand("r.TriangleBasedShadowing 0")
  UE4.UNRCStatics.ExecConsoleCommand("DisableAllScreenMessages")
  if self.performData.enableOverdrawProfiling then
    UE4.UFxPerfToolEditorFunctionLibrary.SetViewMode("simpleoverdraw")
    UE4.UNRCStatics.ExecConsoleCommand("r.MobileMSAA 1")
    UE4.UNRCStatics.ExecConsoleCommand("r.ShaderComplexity.PostProcess.Enable 1")
  end
end

function SkillPerformAutoBattle:PostLastPerform()
  if self.performData.enableOverdrawProfiling then
    UE4.UFxPerfToolEditorFunctionLibrary.SetViewMode("lit")
    UE4.UNRCStatics.ExecConsoleCommand("r.ShaderComplexity.PostProcess.Enable 0")
    UE4.UNRCStatics.ExecConsoleCommand("r.MobileMSAA 4")
  end
  UE4.UNRCStatics.ExecConsoleCommand("WorldTileTool.FreezeWorldComposition 0")
  UE4.UNRCStatics.ExecConsoleCommand("show DynamicShadows")
  UE4.UNRCStatics.ExecConsoleCommand("r.TriangleBasedShadowing 0")
  UE4.UNRCStatics.ExecConsoleCommand("EnableAllScreenMessages")
end

function SkillPerformAutoBattle:PerformNextSkill()
  local playStopAt = #self.performData.skillList
  if self.performData.playSkillStopAt then
    playStopAt = self.performData.playSkillStopAt
  end
  if self.performData.slomo then
    _G.UE4.UGameplayStatics.SetGlobalTimeDilation(_G.UE4Helper.GetCurrentWorld(), self.performData.slomo)
    UE4.UNRCStatics.ExecConsoleCommand("t.MaxFPS 0")
    UE4Helper.PrintScreenMsg(string.format("slomo %f", self.performData.slomo))
  end
  _G.BattleResourceManager:ReleaseAllCastSkillObject()
  _G.BattleResourceManager:ClearUClass()
  _G.BattleSkillManager:ClearCache()
  if self.performData and playStopAt >= self.skillIndex and self.skillIndex <= #self.performData.skillList then
    local skillData = self.performData.skillList[self.skillIndex]
    local SkillConf = _G.DataConfigManager:GetSkillConf(skillData.skillId, true)
    if self.skillIndex == #self.performData.skillList / 2 then
      UE4.UNRCStatics.ExecConsoleCommand("memreport -full")
    end
    if SkillConf and SkillConf.res_id ~= nil and SkillConf.type ~= Enum.SkillActiveType.SAT_PLAYERSKILL then
      local current_msg = string.format("PerformNextSkill %d/%d [%d] %s %d/%d", self.skillIndex, playStopAt, skillData.skillId, skillData.caster, self.skillLoopCount + 1, skillData.loopCount)
      UE4Helper.PrintScreenMsg(current_msg)
      self.skillLoopCount = self.skillLoopCount + 1
      if self.skillLoopCount >= skillData.loopCount then
        self.skillLoopCount = 0
        self.skillIndex = self.skillIndex + 1
      end
      if self.isFirstEnter then
        self:RefreshAllPets()
        if self.performData.enableUnrealStats then
          UE4.UNRCStatics.ExecConsoleCommand("FxPerf.Start stats")
        else
          UE4.UNRCStatics.ExecConsoleCommand("rhi.EnablePerfCustomCsvStat 1")
          UE4.UNRCStatics.ExecConsoleCommand("FxPerf.Start")
        end
        UE4.UNRCStatics.ExecConsoleCommand("memreport -full")
        self:PreFirstPerform()
        self.isFirstEnter = false
      end
      ServerData.ChangeBattleType(skillData.caster)
      if skillData.caster == "enemy" then
        local req = self:GetSkillCMDReq(skillData, true)
        req.__local_isEnemy = true
        _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_CMD_PUSHBACK_REQ, req)
      else
        local req = self:GetSkillCMDReq(skillData, false)
        _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_CMD_PUSHBACK_REQ, req)
      end
    else
      if SkillConf and SkillConf.type == Enum.SkillActiveType.SAT_PLAYERSKILL then
        Log.Warning("Skip SAT_PLAYERSKILL")
      end
      if not SkillConf then
        Log.Error("zgx Skill is not exist ", skillData.skillId)
      end
      self.skillLoopCount = 0
      self.skillIndex = self.skillIndex + 1
      self:PerformNextSkill()
    end
  else
    ServerData.ChangeBattleType("self")
    _G.DelayManager:DelayFrames(150, self.Disable, self)
  end
end

function SkillPerformAutoBattle:GetSkillCMDReq(skillData, isEnemy)
  local skillId = skillData.skillId
  local petId
  if not isEnemy then
    petId = ServerData.GetPlayerBattlePetID()
  else
    petId = ServerData.GetEnemyBattlePetID()
  end
  local BattleRoundFlowReqList = {}
  local BattleRoundFlowReq = {}
  local req = _G.ProtoMessage:newZoneBattleCmdPushbackReq()
  req.req_type = _G.ProtoEnum.BATTLE_REQ_TYPE.CMD_CAST_SKILL
  BattleRoundFlowReq.req_type = _G.ProtoEnum.BATTLE_REQ_TYPE.CMD_CAST_SKILL
  BattleRoundFlowReq.cast_skill = {}
  BattleRoundFlowReq.cast_skill.skill_id = skillId
  BattleRoundFlowReq.cast_skill.caster_pet_id = petId
  table.insert(BattleRoundFlowReqList, BattleRoundFlowReq)
  self.cmdPushbackReq = req
  req.req = BattleRoundFlowReqList
  req.feature_data = _G.NRCSDKManager:GetLightFeaturePacket()
  return req
end

function SkillPerformAutoBattle:Disable()
  UE4.UNRCStatics.ExecConsoleCommand("nrc.DebugAutoBattle 0")
  _G.BattleEventCenter:UnBind(self)
  self.skillPathDict = {}
  if not self.isFirstEnter then
    UE4.UNRCStatics.ExecConsoleCommand("rhi.EnablePerfCustomCsvStat 0")
    UE4.UNRCStatics.ExecConsoleCommand("FxPerf.Stop")
    UE4.UNRCStatics.ExecConsoleCommand("memreport -full")
    self.isFinished = true
  end
  self:PostLastPerform()
  self.isRunning = false
end

return SkillPerformAutoBattle
