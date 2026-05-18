local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local ChangeBattleSceneAction = BattleActionBase:Extend("ChangeBattleSceneAction")

function ChangeBattleSceneAction:OnEnter()
  local asyncData = {
    owner = self,
    callback = self.OnBlackShown
  }
  NRCModuleManager:DoCmdAsync(asyncData, BattleUIModuleCmd.OpenLoading)
  _G.LevelHelper:OpenLevel("BattleField_demo")
end

function ChangeBattleSceneAction:OnBlackShown()
  self:Finish()
end

function ChangeBattleSceneAction:OnExit()
end

return ChangeBattleSceneAction
