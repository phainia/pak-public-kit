local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local ServerData = require("Common.LocalServer.LocalBattleRSPTable")
local BattleCheckMainWindowAction = BattleActionBase:Extend("BattleCheckMainWindowAction")

function BattleCheckMainWindowAction:Ctor(name, properties)
  BattleActionBase.Ctor(self, name, properties)
  self.BattleManager = _G.BattleManager
end

function BattleCheckMainWindowAction:OnEnter()
  self:OnTick()
end

function BattleCheckMainWindowAction:OnTick(DeltaTime)
  if not BattleManager.isInBattle then
    return
  end
  if BattleManager.isEnterActionWaitResDone and not ServerData.values.battleMode and not BattleUtils.IsMainWindowReady() then
    return
  end
  self:Finish()
end

return BattleCheckMainWindowAction
