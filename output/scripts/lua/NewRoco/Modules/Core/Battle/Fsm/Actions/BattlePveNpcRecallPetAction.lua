local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattlePlayAnimBaseAction = require("NewRoco.Modules.Core.Battle.Fsm.Actions.Base.BattlePlayAnimBaseAction")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattlePlayAnimBaseAction
local BattlePveNpcRecallPetAction = Base:Extend("BattlePveNpcRecallPetAction")
FsmUtils.MergeMembers(Base, BattlePveNpcRecallPetAction, {})

function BattlePveNpcRecallPetAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattlePveNpcRecallPetAction:OnEnter()
  Log.Debug("BattlePveNpcRecallPetAction OnEnter ")
  if BattleUtils.IsPve() then
    Log.Debug("BattlePveNpcRecallPetAction OnEnter 0")
    local npc = BattleManager.battlePawnManager:GetPlayerEnemyTeam()
    Log.Debug("BattlePveNpcRecallPetAction OnEnter 1:", type(_G.BattleManager.battlePawnManager:GetPlayerEnemyTeam()))
    local battlePet = BattleManager.battlePawnManager:GetInFieldPet(BattleEnum.Team.ENUM_ENEMY)
    if battlePet then
      npc:PlaySkill(BattleConst.SkillID.PetDeadWithPlayerEnemy, battlePet, self, self.Finish, {
        BallPath = battlePet:GetBallPath()
      })
    else
      self:Finish()
    end
  else
    Log.Debug("BattlePveNpcRecallPetAction OnEnter 2")
    self:Finish()
  end
end

function BattlePveNpcRecallPetAction:OnExit()
end

return BattlePveNpcRecallPetAction
