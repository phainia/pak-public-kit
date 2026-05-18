local BattleShowDialogueAction = require("NewRoco.Modules.Core.Battle.Fsm.Actions.B1FinalBattle.BattleShowDialogueAction")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local Base = BattleShowDialogueAction
local BattleB1P2EndEnterPerformDialogueAction = Base:Extend("BattleB1P2EndEnterPerformDialogueAction")

function BattleB1P2EndEnterPerformDialogueAction:GetDialogueId()
  return DataConfigManager:GetBattleGlobalConfig("B1_P2_START_DIALOGUE").num
end

function BattleB1P2EndEnterPerformDialogueAction:OnFinish()
  _G.BattleManager:ChangeOperateMode(BattleEnum.Operation.ENUM_SKILL)
  local pet = _G.BattleManager.battlePawnManager:GetInFieldAllPet(BattleEnum.Team.ENUM_TEAM, true)
  _G.BattleEventCenter:Dispatch(BattleEvent.UPDATE_DATA, pet[1], true)
  local mainWindow = _G.BattleUtils.GetMainWindow()
  if mainWindow then
    mainWindow:RefreshOperatePanel()
  end
end

return BattleB1P2EndEnterPerformDialogueAction
