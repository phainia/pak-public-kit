local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local Base = BattleActionBase
local BattlePrepareAction = Base:Extend("BattlePrepareAction")
FsmUtils.MergeMembers(Base, BattlePrepareAction, nil)

function BattlePrepareAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.BattleManager = _G.BattleManager
  self.BattleField = self.BattleManager.vBattleField
  self.CameraManager = self.BattleField.battleCameraManager
  self.PawnManager = self.BattleManager.battlePawnManager
end

function BattlePrepareAction:OnEnter()
  Log.Debug("BattlePrepareAction:OnEnter")
  if BattleManager.PrepareOver then
    Log.Error("BattlePrepareAction skip")
    self:Finish()
    return
  end
  self.timeout = 100.0
  self.IsPrepare = false
end

function BattlePrepareAction:StartPrepare()
  if not self.IsPrepare then
    self.IsPrepare = true
    self.BattleManager:PrepareBattle()
  end
end

function BattlePrepareAction:CheckBattlePrepareOver()
  return _G.BattleManager.PrepareOver
end

function BattlePrepareAction:CheckMainWindowReady()
  return BattleUtils.IsMainWindowReady()
end

function BattlePrepareAction:LoadOver()
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
  BattleUtils.SetTeamCollisionState(BattleEnum.Team.ENUM_TEAM, false)
  BattleUtils.SetTeamCollisionState(BattleEnum.Team.ENUM_ENEMY, false)
  self.BattleManager:PlayBattleBGM()
  self:Finish()
end

function BattlePrepareAction:OnTick(DeltaTime)
  if not BattleManager.isInBattle then
    return
  end
  if not self:CheckMainWindowReady() then
    return
  end
  self:StartPrepare()
  if not self:CheckBattlePrepareOver() then
    return
  end
  self:LoadOver()
end

function BattlePrepareAction:OnExit()
  Log.Debug("BattlePrepareAction:OnExit")
end

return BattlePrepareAction
