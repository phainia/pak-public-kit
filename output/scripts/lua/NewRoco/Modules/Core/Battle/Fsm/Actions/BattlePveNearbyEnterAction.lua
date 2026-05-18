local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local ServerData = require("Common.LocalServer.LocalBattleRSPTable")
local BattlePveNearbyEnterAction = BattleActionBase:Extend("BattlePveNearbyEnterAction")

function BattlePveNearbyEnterAction:Ctor(name, properties)
  BattleActionBase.Ctor(self, name, properties)
  self.BattleManager = _G.BattleManager
  self.BattleField = self.BattleManager.vBattleField
  self.CameraManager = self.BattleField.battleCameraManager
  self.PawnManager = self.BattleManager.battlePawnManager
end

function BattlePveNearbyEnterAction:OnEnter()
  self.timeout = 100.0
  self.IsPrepare = false
  _G.BattleEventCenter:Bind(self, BattleEvent.PET_SPAWNED, BattleEvent.PLAYER_SPAWNED)
  self:OnTick()
end

function BattlePveNearbyEnterAction:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.PET_SPAWNED or eventName == BattleEvent.PLAYER_SPAWNED then
    self.timeout = 100.0
    return true
  end
end

function BattlePveNearbyEnterAction:CheckBattlePrepareOver()
  return _G.BattleManager.PrepareOver
end

function BattlePveNearbyEnterAction:CheckMainWindowReady()
  return BattleUtils.IsMainWindowReady()
end

function BattlePveNearbyEnterAction:CheckBattleSceneReady()
  return true
end

function BattlePveNearbyEnterAction:OnTick(DeltaTime)
  if not BattleManager.isInBattle then
    return
  end
  if BattleManager.isEnterActionWaitResDone and not ServerData.values.battleMode and not self:CheckMainWindowReady() then
    return
  end
  if not self:CheckBattlePrepareOver() then
    return
  end
  self:OnLoaded()
end

function BattlePveNearbyEnterAction:RestorePet(flag)
  Log.Debug("Try Restore Pet Scale!")
  local Pets = self.PawnManager:GetInFieldAllPet(flag)
  if Pets then
    for _, pet in ipairs(Pets) do
      pet:SetScale(1)
    end
  else
    Log.Error("Can't restore pet!!!!!!")
  end
end

function BattlePveNearbyEnterAction:OnLoaded()
  BattleManager:PlayBattleBGM()
  self:Finish()
end

function BattlePveNearbyEnterAction:OnFinish()
  _G.BattleEventCenter:UnBind(self)
end

function BattlePveNearbyEnterAction:OnExit()
  _G.BattleEventCenter:UnBind(self)
  self.BattleManager = nil
  self.BattleField = nil
  self.CameraManager = nil
end

return BattlePveNearbyEnterAction
