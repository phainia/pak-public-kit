local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local ThrowBallPlayerTeamShowAction = BattleActionBase:Extend("ThrowBallPlayerTeamShowAction")

function ThrowBallPlayerTeamShowAction:Ctor(name, properties)
  BattleActionBase.Ctor(self, name, properties)
  self.BattleManager = _G.BattleManager
  self.PawnManager = self.BattleManager.battlePawnManager
end

function ThrowBallPlayerTeamShowAction:OnEnter()
  Log.Debug("ThrowBallPlayerTeamShowAction OnEnter")
  local pet = self.PawnManager:GetTeamPet(BattleEnum.Team.ENUM_TEAM, 1)
  local enemyPet = self.PawnManager:GetTeamPet(BattleEnum.Team.ENUM_ENEMY, 1)
  pet.model:SetActorScale3D(UE4.FVector(1, 1, 1))
  enemyPet.model:SetActorScale3D(UE4.FVector(1, 1, 1))
  self:Finish()
end

function ThrowBallPlayerTeamShowAction:OnExit()
  self.BattleManager = nil
  self.PawnManager = nil
end

return ThrowBallPlayerTeamShowAction
