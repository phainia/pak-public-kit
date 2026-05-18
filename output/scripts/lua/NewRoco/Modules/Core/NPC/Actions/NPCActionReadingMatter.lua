local DialogueModuleCmd = require("NewRoco.Modules.System.Dialogue.DialogueModuleCmd")
local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local Base = NPCActionBase
local NPCActionReadingMatter = Base:Extend("NPCActionReadingMatter")

function NPCActionReadingMatter:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionReadingMatter:Execute(playerId, needSendReq)
  Base.Execute(self, playerId, needSendReq)
  _G.NRCModuleManager:DoCmd(DialogueModuleCmd.OpenReadingMatter, tonumber(self.Config.action_param1), self)
end

return NPCActionReadingMatter
