local SkillPlayer = require("NewRoco.Modules.Core.Battle.Common.SkillPlayer")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BP_BattleFieldActor_C = NRCClass()

function BP_BattleFieldActor_C:ReceiveBeginPlay()
end

function BP_BattleFieldActor_C:OnSkillAsyncLoadComplete(skillObj)
  Log.Debug("BP_BattleFieldActor_C:OnSkillAsyncLoadComplete")
  BattleSkillManager:OnLoadSkillComplete(skillObj)
end

function BP_BattleFieldActor_C:OnSkillCompleteReal(skillObj)
  Log.Debug("BP_BattleFieldActor_C:OnSkillComplete")
end

function BP_BattleFieldActor_C:PlayAnim(skillID, owner, onAnimFinishCallback, extraParam, extraEvent, needQueueSkillObj, overrideCharacters, overrideTargets, addition)
  if not skillID or 0 == skillID or "" == skillID then
    if onAnimFinishCallback then
      onAnimFinishCallback(owner, false)
    end
    return nil
  end
  local SkillResConf = DataConfigManager:GetSkillResConf(skillID)
  if not SkillResConf then
    return nil
  end
  BattleResourceManager:LoadClassAsyncWithParam(self, SkillResConf.res_id, self.PlayAnimWithClass, nil, owner, onAnimFinishCallback, extraParam, extraEvent, needQueueSkillObj, overrideCharacters, overrideTargets, addition)
end

function BP_BattleFieldActor_C:PlayAnimWithClass(skillClass, owner, onAnimFinishCallback, extraParam, extraEvent, needQueueSkillObj, overrideCharacters, overrideTargets, addition)
  Log.DebugFormat("Try play anim %s", skillClass)
  if not needQueueSkillObj then
    local active = self.Skill:GetActiveSkill()
    if active then
      self.Skill:CancelSkill(active, UE4.ESkillActionResult.SkillActionResultSuccessful)
    end
  end
  if not skillClass then
    if onAnimFinishCallback then
      onAnimFinishCallback(owner, false)
    end
    return nil
  end
  local skillObj = self.Skill:FindOrAddSkillObj(skillClass)
  if skillObj then
    local pawnManager = _G.BattleManager.battlePawnManager
    skillObj:SetDynamicData(extraParam)
    skillObj:SetCharacters(overrideCharacters or pawnManager:GetAllPawnActorForSkill())
    skillObj:SetTargets(overrideTargets)
    if extraEvent then
      for k, v in pairs(extraParam) do
        skillObj:RegisterEventCallback(k, owner, v)
      end
    end
    if addition then
      skillObj:SetAdditions("Pass", addition)
    end
    skillObj:RegisterEventCallback("End", owner, onAnimFinishCallback)
    skillObj:RegisterEventCallback("PreEnd", owner, onAnimFinishCallback)
    self.Skill:PlaySkill(skillObj)
  end
  return skillObj
end

function BP_BattleFieldActor_C:ToggleDarkScene(on, highLightTargets)
  Log.DebugFormat("Request to toggle scene character %s", on and "yes" or "no")
  if not self.DarkScenePlayer then
    if on then
      self.DarkScenePlayer = SkillPlayer(self.Skill, nil, BattleConst.DarkScene.Sequence)
    else
      return
    end
  end
  self.DarkScenePlayer:SetCharacters(_G.BattleManager.battlePawnManager:GetAllPawnActorForSkill())
  self.DarkScenePlayer:SetTargets(highLightTargets)
  self.DarkScenePlayer:Toggle(on)
end

function BP_BattleFieldActor_C:ChangeDarkSceneCaster(caster)
  if self.DarkScenePlayer then
    self.DarkScenePlayer.Caster = caster.model
  end
end

function BP_BattleFieldActor_C:ReceiveDestroyed()
  if self.DarkScenePlayer then
    self.DarkScenePlayer:Destroy()
    self.DarkScenePlayer:UnBindRef()
  end
end

function BP_BattleFieldActor_C:LeaveBattle()
  self:ReceiveDestroyed()
  self.DarkScenePlayer = nil
end

function BP_BattleFieldActor_C:OnLevelSequenceEnd()
  if self.cahcheLSCallBack then
    self.cahcheLSCallBack(self.cahcheLSCaller)
    self.cahcheLSCallBack = nil
    self.cahcheLSCaller = nil
  end
end

function BP_BattleFieldActor_C:SetCacheLSCall(caller, func)
  self.cahcheLSCallBack = func
  self.cahcheLSCaller = caller
end

return BP_BattleFieldActor_C
