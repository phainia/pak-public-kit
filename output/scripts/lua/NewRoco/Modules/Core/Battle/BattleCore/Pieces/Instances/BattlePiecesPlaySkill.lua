local BattlePiecesBase = require("NewRoco.Modules.Core.Battle.BattleCore.Pieces.BattlePiecesBase")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local Base = BattlePiecesBase
local BattlePiecesPlaySkill = Base:Extend("BattlePiecesPlaySkill")

function BattlePiecesPlaySkill:Play()
  self.isOver = false
  self:StartPreLoad()
end

function BattlePiecesPlaySkill:StartPreLoad()
  if self.resList and #self.resList > 0 then
    self.loadedResCount = 0
    BattleSkillManager:PreLoadRes(self.resList, true, PriorityEnum.Passive_Battle_High)
  else
    self:OnResLoadFinish()
  end
end

function BattlePiecesPlaySkill:OnBattleEvent(event, value)
  if event == BattleEvent.OnSkillResLoaded then
    for i = 1, #self.resList do
      if value == self.resList[i] then
        self.loadedResCount = self.loadedResCount + 1
      end
    end
    if self.loadedResCount == #self.resList then
      BattleEventCenter:UnBindByList(self, BattleEvent.OnSkillResLoaded)
      self:OnResLoadFinish(value)
    end
    return true
  end
end

function BattlePiecesPlaySkill:OnResLoadFinish()
end

function BattlePiecesPlaySkill:OnBattleOver()
end

function BattlePiecesPlaySkill:Complete()
  Base.Complete(self)
  self.isOver = true
end

function BattlePiecesPlaySkill:PlaySkill(battlePet, skillComponent, skillObject, isNotPlay)
  local _, skill = BattleSkillManager:PrepareSkill(battlePet, skillComponent, skillObject)
  if not skill then
    Log.WarningFormat("Can't find or load skill object %s %s", skillObject.ResID)
    self:Complete()
    return
  end
  if not isNotPlay then
    skillComponent:PlaySkill(skill)
  end
  return skill
end

return BattlePiecesPlaySkill
