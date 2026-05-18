local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local Base = BattleActionBase
local BattlePreloadFightStartAction = Base:Extend("BattlePreloadFightStartAction")
FsmUtils.MergeMembers(Base, BattlePreloadFightStartAction, {})

function BattlePreloadFightStartAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattlePreloadFightStartAction:OnEnter()
  self.loadResCount = 0
  if BattleUtils.IsPvp() then
    self.resList = {
      BattleConst.PvPEnter.TwoPlayerPetSkill_C,
      BattleConst.PvPEnter.TwoEnemyPetSkill_C
    }
  else
    self.resList = {
      BattleConst.PvPEnter.TwoPlayerPetSkill_C,
      BattleConst.PvPEnter.TwoEnemyPetSkill_C
    }
  end
  BattleEventCenter:Bind(self, BattleEvent.OnSkillResLoaded)
  _G.BattleSkillManager:PreLoadRes(self.resList, true)
end

function BattlePreloadFightStartAction:BeginLoadRes()
  for i = 1, #self.preloadResList do
    self.loadResCount = self.loadResCount + 1
    _G.BattleResourceManager:LoadResAsync(self, self.preloadResList[i], self.PreloadAssetCallBack, self.PreloadAssetCallBack)
  end
end

function BattlePreloadFightStartAction:OnBattleEvent(event, value)
  if event == BattleEvent.OnSkillResLoaded then
    Log.Error("BattleMultiPvPEnter1Action:OnBattleEvent:", event, value)
    if self.loadedResCount == #self.resList then
      self:LoadHud()
    end
    return true
  end
end

function BattlePreloadFightStartAction:TryFinish()
  if 0 == self.loadResCount then
    self:Finish()
  end
end

return BattlePreloadFightStartAction
