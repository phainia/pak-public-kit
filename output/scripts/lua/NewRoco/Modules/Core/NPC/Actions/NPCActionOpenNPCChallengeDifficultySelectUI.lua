local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local Base = NPCActionBase
local NPCActionOpenNPCChallengeDifficultySelectUI = Base:Extend("NPCActionOpenNPCChallengeDifficultySelectUI")

function NPCActionOpenNPCChallengeDifficultySelectUI:Execute(playerId, needSendReq)
  Base.Execute(self, playerId, needSendReq)
  self.SpecBattleUIId = tonumber(self.Config.action_param1) or 0
  _G.NRCModuleManager:DoCmd(_G.ActivityModuleCmd.OpenNpcChallengeDifficultySelectPanel, self.SpecBattleUIId, self)
end

return NPCActionOpenNPCChallengeDifficultySelectUI
