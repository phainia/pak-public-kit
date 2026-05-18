local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local Base = NPCActionBase
local NPCActionDoCmd = Base:Extend("NPCActionDoCmd")

function NPCActionDoCmd:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionDoCmd:Execute(playerId, needSendReq)
  Base.Execute(self, playerId, needSendReq)
  if not string.IsNilOrEmpty(self.Config.action_param4) then
    _G.NRCModuleManager:DoCmd(self.Config.action_param4, self.Config.action_param1, self.Config.action_param2)
  end
  self:Finish(true)
end

return NPCActionDoCmd
