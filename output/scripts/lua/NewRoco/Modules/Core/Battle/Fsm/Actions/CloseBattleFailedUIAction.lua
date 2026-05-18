local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local CloseBattleFailedUIAction = BattleActionBase:Extend("CloseBattleFailedUIAction")

function CloseBattleFailedUIAction:OnEnter()
  NRCEventCenter:RegisterEvent("CloseBattleFailedUIAction", self, BattleEvent.FailedUIClicked, self.OnBlackScreenRemoved)
end

function CloseBattleFailedUIAction:OnBlackScreenRemoved()
  NRCModeManager:DoCmd(BattleUIModuleCmd.CloseBattleFailedUI)
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  player.viewObj.RocoSkill:StopCurrentSkill()
  local skillObj = player.viewObj.RocoSkill:FindOrAddSkillObj(player.viewObj.TransEffect)
  if not skillObj then
    Log.Error("\231\142\169\229\174\182\228\188\160\233\128\129\231\137\185\230\149\136\232\181\132\230\186\144\232\174\190\231\189\174\229\164\177\232\180\165\239\188\140\232\175\183\230\163\128\230\159\165")
    return
  end
  skillObj:SetCaster(player.viewObj)
  Log.Debug("SceneLocalPlayer:CheckLandLoaded play teleport effect")
  player.viewObj.RocoSkill:PlaySkill(skillObj)
  self:Finish()
end

function CloseBattleFailedUIAction:OnFinish()
  NRCEventCenter:UnRegisterEvent(self, BattleEvent.FailedUIClicked, self.OnBlackScreenRemoved)
end

return CloseBattleFailedUIAction
