local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local Base = NPCActionBase
local NPCActionShowFakeMagicMessage = Base:Extend("NPCActionShowFakeMagicMessage")

function NPCActionShowFakeMagicMessage:Ctor(Owner, Config, Info)
  self.Owner = Owner
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionShowFakeMagicMessage:Execute(playerId, needSendReq)
  Base.Execute(self, playerId, false)
  if self.Config then
    local fakeMessageId = tonumber(self.Config.action_param1)
    _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.OpenShowFakeMagicMessage, fakeMessageId, self)
  end
end

return NPCActionShowFakeMagicMessage
