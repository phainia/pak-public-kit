local FsmAction = require("NewRoco.Modules.Core.Fsm.FsmAction")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local PriorityEnum = require("PriorityEnum")
local Base = BattleActionBase
local BattleRoundSelectPreloadResAction = Base:Extend("BattleRoundSelectPreloadResAction")
FsmUtils.MergeMembers(Base, BattleRoundSelectPreloadResAction, {})

function BattleRoundSelectPreloadResAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleRoundSelectPreloadResAction:OnEnter()
  local operationPets = _G.BattleManager.battlePawnManager:GetInFieldAllPet(BattleEnum.Team.ENUM_TEAM, true)
  local preloadResMap = {}
  local preloadResList = {}
  for _, battlePet in ipairs(operationPets) do
    local battlePetCard = battlePet and battlePet.card
    local displayRoundSkills = battlePetCard and battlePetCard:GetDisplayAndReadySkills() or {}
    for _, skillData in ipairs(displayRoundSkills) do
      local skillId = _G.SkillUtils.CheckSkillId(skillData.skill_id)
      local skillConf = _G.SkillUtils.GetSkillConf(skillId, true)
      local iconPath = skillConf and skillConf.icon
      if iconPath then
        preloadResMap[iconPath] = true
      end
    end
  end
  for iconPath, _ in pairs(preloadResMap) do
    table.insert(preloadResList, iconPath)
  end
  self.preLoadAssetNumber = #preloadResList
  self.isResFinish = false
  local resCacheTime = 10
  if 0 == #preloadResList then
    self:Finish()
  else
    for _, resPath in ipairs(preloadResList) do
      _G.BattleResourceManager:PreloadAssetAsync(self, resPath, self.PreloadAssetCallBack, self.PreloadAssetCallBack, resCacheTime, PriorityEnum.UI_NRCImage_Default)
    end
  end
end

function BattleRoundSelectPreloadResAction:PreloadAssetCallBack()
  self.preLoadAssetNumber = self.preLoadAssetNumber - 1
  Log.Info("BattleRoundSelectPreloadResAction:PreloadAssetCallBack", self.preLoadAssetNumber)
  if 0 == self.preLoadAssetNumber then
    self.isResFinish = true
    self:CheckLoadFinish()
  end
end

function BattleRoundSelectPreloadResAction:CheckLoadFinish()
  if self.isResFinish then
    self:Finish()
  end
end

function BattleRoundSelectPreloadResAction:OnExit()
end

return BattleRoundSelectPreloadResAction
