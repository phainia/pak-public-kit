local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattlePerformEvent = require("NewRoco.Modules.Core.Battle.BattleCore.BattlePerformEvent")
local Base = BattleActionBase
local BattleB1P1ReconnectEnterPerformAction = Base:Extend("BattleB1P1ReconnectEnterPerformAction")
FsmUtils.MergeMembers(Base, BattleB1P1ReconnectEnterPerformAction, {})

function BattleB1P1ReconnectEnterPerformAction:OnEnter()
  if not BattleUtils.IsB1FinalBattleP1() then
    self:Finish()
    return
  end
  self.BattleManager = _G.BattleManager
  self.PawnManger = self.BattleManager.battlePawnManager
  BattleSkillManager:PreLoadSingleResInternal(BattleConst.B1P1EnterG6Reconnect, true, 255, self, self.OnSkillLoad)
end

function BattleB1P1ReconnectEnterPerformAction:OnSkillLoad()
  local BossPlayer = self.PawnManger:GetPlayerEnemyTeam()
  if BossPlayer and BossPlayer.model then
    local skillPath = BattleConst.B1P1EnterG6Reconnect
    local class = BattleSkillManager:GetLoadedClass(skillPath)
    if not class then
      Log.WarningFormat("Can't load skill class %s", skillPath)
      self:Finish()
      return
    end
    local skillComponent = BossPlayer.model.RocoSkill
    local skill = skillComponent:AddSkillObjFromClassAndReturn(class)
    if not skill then
      Log.WarningFormat("Can't find or load skill object %s %s", class, skillPath)
      self:Finish()
      return
    end
    if self:EnemyHasSupplyPet() then
      local blackboard = skill:GetBlackboard()
      if blackboard and UE.UObject.IsValid(blackboard) then
        blackboard:SetValueAsString("CreateBall", "CreateBall")
      end
    end
    skill:SetCaster(BossPlayer.model)
    skill:SetTargets({
      BossPlayer.model
    })
    skill:SetCharacters(_G.BattleManager.battlePawnManager:GetAllPawnActorForSkill())
    skill:RegisterEventCallback("SavedBallBP", self, self.SavedBallBP)
    skill:RegisterEventCallback("End", self, self.OnSkillComplete)
    skill:RegisterEventCallback("PreEnd", self, self.OnSkillComplete)
    skillComponent:PlaySkill(skill)
    Log.Debug("BattleB1P1ReconnectEnterPerformAction:BattleB1P1ReconnectEnterPerformAction")
    self.skillObject = skill
  else
    _G.BattleManager.battleRuntimeData:RemoveB1P1LevelSequence()
    self:Finish()
  end
end

function BattleB1P1ReconnectEnterPerformAction:EnemyHasSupplyPet()
  local enemyAliveCount = self:GetSurvivalEnemyPetNum()
  Log.Debug("BattleB1P1ReconnectEnterPerformAction:EnemyHasSupplyPet", enemyAliveCount)
  return enemyAliveCount > 1 and enemyAliveCount <= 6
end

function BattleB1P1ReconnectEnterPerformAction:GetSurvivalEnemyPetNum()
  if BattleUtils.GetBattleInitInfo().b1_final_battle and BattleUtils.GetBattleInitInfo().b1_final_battle.p1_enemy_pet_num then
    return BattleUtils.GetBattleInitInfo().b1_final_battle.p1_enemy_pet_num
  end
  local enemyAlivePet = self.PawnManger:GetPlayerEnemyTeam().deck:GetAliveCards()
  return #enemyAlivePet
end

function BattleB1P1ReconnectEnterPerformAction:SavedBallBP()
  if self.skillObject then
    local blackboard = self.skillObject:GetBlackboard()
    if blackboard and UE.UObject.IsValid(blackboard) then
      local B1BallBP = blackboard:GetValueAsObject(BattleConst.B1BallBlackboardKey)
      if B1BallBP and UE.UObject.IsValid(B1BallBP) then
        self.BattleManager.battleRuntimeData:SetB1P1BallActor(B1BallBP)
        if self:EnemyHasSupplyPet() then
          local enemyAliveCount = self:GetSurvivalEnemyPetNum()
          if enemyAliveCount < 6 then
            B1BallBP["CW" .. enemyAliveCount - 1](B1BallBP)
          end
        end
      end
    end
  end
end

function BattleB1P1ReconnectEnterPerformAction:OnSkillComplete()
  if self.skillObject then
    local blackboard = self.skillObject:GetBlackboard()
    if blackboard and UE.UObject.IsValid(blackboard) then
      blackboard:RemoveObjectValue(BattleConst.B1BallBlackboardKey)
    end
    self.skillObject = nil
  end
  self:Finish()
end

return BattleB1P1ReconnectEnterPerformAction
