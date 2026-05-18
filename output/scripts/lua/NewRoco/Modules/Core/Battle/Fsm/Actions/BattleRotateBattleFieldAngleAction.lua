local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattleActionBase
local BattleRotateBattleFieldAngleAction = Base:Extend("BattleRotateBattleFieldAngleAction")
FsmUtils.MergeMembers(Base, BattleRotateBattleFieldAngleAction, {})

function BattleRotateBattleFieldAngleAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleRotateBattleFieldAngleAction:OnEnter()
  if not BattleManager.battleRuntimeData.battleStartPlayerPos or not _G.BattleManager.vBattleField.battleFieldConf then
    self:Finish()
    return
  end
  if not BattleUtils.IsTeam() then
    self:SetBattleFieldRotation(self:RotateByVector() + BattleDefine.RotateBattleFieldAnglePrefix)
  elseif BattleUtils.IsBloodTeam() then
    self:SetBattleFieldRotation(120)
  end
  self:Finish()
end

function BattleRotateBattleFieldAngleAction:RotateByVector()
  local playerPos = BattleManager.battleRuntimeData.battleStartPlayerPos
  local enemyPos = BattleManager.battleRuntimeData.battleStartEnemyPos
  local Dir = playerPos - enemyPos
  local Rotator = Dir:ToRotator()
  return Rotator.Yaw
end

function BattleRotateBattleFieldAngleAction:SetBattleFieldRotation(rotationZ)
  if UE4.UObject.IsValid(_G.BattleManager.vBattleField.battleFieldConf.BattleFieldActor) then
    _G.BattleManager.vBattleField.battleFieldConf.BattleFieldActor:K2_SetActorRotation(UE4.FRotator(0, rotationZ, 0), false)
  end
end

function BattleRotateBattleFieldAngleAction:OnExit()
end

return BattleRotateBattleFieldAngleAction
