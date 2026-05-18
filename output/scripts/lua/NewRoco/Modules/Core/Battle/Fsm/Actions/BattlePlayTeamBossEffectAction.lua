local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattlePlayTeamBossEffectAction = BattleActionBase:Extend("BattlePlayTeamBossEffectAction")

function BattlePlayTeamBossEffectAction:OnEnter()
  self.BattleManager = _G.BattleManager
  self.PawnManger = self.BattleManager.battlePawnManager
  local BossPets = self.PawnManger:GetInFieldAllPet(BattleEnum.Team.ENUM_ENEMY, true)
  if BossPets and BossPets[1] then
    self.BossPetType = BattleConst.BloodType2AttrType[BossPets[1].card.petInfo.battle_common_pet_info.blood_id]
    local skillPath = BattleConst.TeamBloodBossEffect
    local class = BattleResourceManager:GetCacheAssetDirect(skillPath)
    if not class then
      Log.WarningFormat("Can't load skill class %s", skillPath)
      self:Finish()
      return
    end
    local skillComponent = BossPets[1].model.RocoSkill
    local skill = skillComponent:AddSkillObjFromClassAndReturn(class)
    if not skill then
      Log.WarningFormat("Can't find or load skill object %s %s", class, skillPath)
      self:Finish()
      return
    end
    local pets = BattleManager.battlePawnManager:GetInFieldAllPet(BattleEnum.Team.ENUM_TEAM)
    for i = 1, #pets do
      BattleUtils.SetParticleKeyForSkillObj(pets[i].model, skill, pets[i].card.medalBlackBoard)
    end
    skill:SetCaster(BossPets[1].model)
    skill:SetTargets({
      BossPets[1].model
    })
    skill:SetPassive(true)
    skill:SetCharacters(_G.BattleManager.battlePawnManager:GetAllPawnActorForSkill())
    skill:RegisterEventCallback("SetBossType", self, self.SetBossType)
    skill:RegisterEventCallback("End", self, self.Finish)
    skill:RegisterEventCallback("PreEnd", self, self.Finish)
    skill:RegisterEventCallback("ActionStart", self, self.OnActionStart)
    skillComponent:LoadAndPlaySkill(skill)
  else
    self:Finish()
  end
end

function BattlePlayTeamBossEffectAction:SetBossType(name, skill)
  if skill then
    local blackboard = skill:GetBlackboard()
    if blackboard then
      local effect = blackboard:GetValueAsObject("spawnActor_0001")
      if effect then
        effect:SetPetType(self.BossPetType)
      end
      effect = blackboard:GetValueAsObject("spawnActor_0002")
      if effect then
        effect:SetPetType(self.BossPetType)
      end
    end
  end
end

function BattlePlayTeamBossEffectAction:OnActionStart()
  NRCModeManager:DoCmd(BattleUIModuleCmd.CloseTransformLoadingUI)
end

return BattlePlayTeamBossEffectAction
