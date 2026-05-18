local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local Base = BattleActionBase
local BattleB1P2EnterPerformAction = Base:Extend("BattleB1P2EnterPerformAction")
FsmUtils.MergeMembers(Base, BattleB1P2EnterPerformAction, {})

function BattleB1P2EnterPerformAction:OnEnter()
  self.BattleManager = _G.BattleManager
  _G.NRCModuleManager:DoCmd(_G.B1FinalBattleModuleCmd.SetIsFirstDialogue, true)
  self.PawnManger = self.BattleManager.battlePawnManager
  local BossPets = self.PawnManger:GetInFieldAllPet(BattleEnum.Team.ENUM_ENEMY, true)
  if BossPets and BossPets[1] then
    local skillPath = BattleConst.B1P2EnterG6
    local class = BattleSkillManager:GetLoadedClass(skillPath)
    if not class then
      Log.WarningFormat("Can't load skill class %s", skillPath)
      self:Finish()
      return
    end
    local skillComponent = BossPets[1].model.RocoSkill
    local skill = skillComponent:FindOrAddSkillObj(class)
    if not skill then
      Log.WarningFormat("Can't find or load skill object %s %s", class, skillPath)
      self:Finish()
      return
    end
    skill:SetCaster(BossPets[1].model)
    skill:SetTargets({
      BossPets[1].model
    })
    skill:SetCharacters(_G.BattleManager.battlePawnManager:GetAllPawnActorForSkill())
    skill:RegisterEventCallback("End", self, self.Finish)
    skill:RegisterEventCallback("PreEnd", self, self.Finish)
    skill:RegisterEventCallback("ActionStart", self, self.OnActionStart)
    skillComponent:LoadAndPlaySkill(skill)
  else
    self:Finish()
  end
end

function BattleB1P2EnterPerformAction:OnActionStart()
  _G.BattleManager.battleRuntimeData:RemoveB1P2LevelSequence()
  BattleManager:PlayBattleBGM()
end

function BattleB1P2EnterPerformAction:OnFinish()
  local roundStarNotify = self.fsm:GetProperty("roundStarNotify")
  if roundStarNotify then
    self.BattleManager.stateFsm:SetProperty("Flows", roundStarNotify.perform_cmd)
    self.BattleManager.stateFsm:SetProperty("SettleInfo", roundStarNotify.settle_info)
    self.BattleManager.stateFsm:SetProperty("IsMySelfPerform", true)
    self.BattleManager.stateFsm:SetProperty("IsFromRoundStart", roundStarNotify.perform_cmd.IsFromRoundStart or false)
  end
end

return BattleB1P2EnterPerformAction
