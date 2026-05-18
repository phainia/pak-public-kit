local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleSeamlessLoadAction = BattleActionBase:Extend()

function BattleSeamlessLoadAction:Ctor(name, properties)
  BattleActionBase.Ctor(self, name, properties)
  self.BattleManager = _G.BattleManager
  self.BattleField = self.BattleManager.vBattleField
end

function BattleSeamlessLoadAction:OnEnter()
end

function BattleSeamlessLoadAction:CheckMainWindowReady()
  return BattleUtils.IsMainWindowReady()
end

function BattleSeamlessLoadAction:CheckSceneReady()
  return true
end

function BattleSeamlessLoadAction:CheckTimeReady()
  return self.execTime >= BattleConst.InPlace.AirTime
end

function BattleSeamlessLoadAction:OnTick(DeltaTime)
  if not self:CheckTimeReady() then
    return
  end
  if not self:CheckMainWindowReady() then
    return
  end
  if not self:CheckSceneReady() then
    return
  end
  self:Finish()
end

function BattleSeamlessLoadAction:OnExit()
  self.BattleManager = nil
  self.BattleField = nil
end

return BattleSeamlessLoadAction
