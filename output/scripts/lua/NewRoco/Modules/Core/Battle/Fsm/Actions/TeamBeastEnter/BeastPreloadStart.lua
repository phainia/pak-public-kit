local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local Base = BattleActionBase
local BeastPreloadStart = Base:Extend("BeastPreloadStart")
FsmUtils.MergeMembers(Base, BeastPreloadStart, {})

function BeastPreloadStart:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self:SetActionType(Base.ActionType.ClientLoadResAction)
end

function BeastPreloadStart:OnEnter()
  _G.BattleManager:InitBattleField()
  local BeastBoss = BattleUtils.GetTraceNpc()
  local skillPath
  if not (BeastBoss and BeastBoss.npc) or not BeastBoss.npc.viewObj then
    skillPath = BattleConst.TeamPerEnterFarBattle
  else
    skillPath = BattleConst.TeamBeastPerEnterBattle
  end
  BattleEventCenter:Bind(self, BattleEvent.OnSkillResLoaded)
  self.loadedResCount = 0
  self.resList = {skillPath}
  BattleSkillManager:PreLoadRes(self.resList, true)
  self.fsm:SetProperty("BeastStartSkill", skillPath)
end

function BeastPreloadStart:OnBattleEvent(event, value)
  if self.finished then
    return
  end
  if event == BattleEvent.OnSkillResLoaded then
    for i = 1, #self.resList do
      if value == self.resList[i] then
        self.loadedResCount = self.loadedResCount + 1
      end
    end
    if self.loadedResCount == #self.resList then
      self:Finish()
    end
    return true
  end
end

function BeastPreloadStart:OnFinish()
  BattleEventCenter:UnBind(self)
end

return BeastPreloadStart
