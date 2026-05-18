local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local Base = BattleActionBase
local BattleCheckPrepareResIsOverAction = Base:Extend("BattleCheckPrepareResIsOverAction")

function BattleCheckPrepareResIsOverAction:Ctor()
  Base.Ctor(self)
  self:SetActionType(BattleActionBase.ActionType.ClientUnSkipableAction)
end

function BattleCheckPrepareResIsOverAction:CheckBattlePrepareOver()
  return _G.BattleManager.PrepareOver
end

function BattleCheckPrepareResIsOverAction:OnEnter()
end

function BattleCheckPrepareResIsOverAction:LoadOver()
  if _G.enableAdaptiveBattlePetPos then
    local myPet = BattleManager.battlePawnManager:GetInFieldPet(BattleEnum.Team.ENUM_TEAM)
    if myPet then
      BattleManager.vBattleField:AdaptiveMyBattlePetPos(myPet.model)
      myPet:PinOnTheGround()
    end
    local enemyPet = BattleManager.battlePawnManager:GetInFieldPet(BattleEnum.Team.ENUM_ENEMY)
    if enemyPet then
      BattleManager.vBattleField:AdaptiveEnemyBattlePetPos(enemyPet)
      enemyPet:PinOnTheGround()
    end
  end
  BattleManager:PlayBattleBGM()
end

function BattleCheckPrepareResIsOverAction:ShowPlayer(player)
  if player then
    player:ShowPlayer()
  end
end

function BattleCheckPrepareResIsOverAction:OnTick(DeltaTime)
  if not self:CheckBattlePrepareOver() then
    return
  end
  self:LoadOver()
  self:Finish()
end

function BattleCheckPrepareResIsOverAction:OnFinish()
end

return BattleCheckPrepareResIsOverAction
