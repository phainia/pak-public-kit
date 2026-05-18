local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local TrainBattleOpenMagicManualAction = BattleActionBase:Extend("TrainBattleOpenMagicManualAction")

function TrainBattleOpenMagicManualAction:OnEnter()
  local isBan = _G.FunctionBanManager:GetConditionCounter(_G.Enum.PlayerConditionType.PCT_BATTLE)
  if isBan then
    _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.WaitBattleEndShowMagicManualTeach)
  else
    _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.ShowMagicManualTeach)
  end
  self:Finish()
end

function TrainBattleOpenMagicManualAction:OnFinish()
end

return TrainBattleOpenMagicManualAction
