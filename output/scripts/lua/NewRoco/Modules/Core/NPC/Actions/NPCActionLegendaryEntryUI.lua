local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local Base = NPCActionBase
local NPCActionLegendaryEntryUI = Base:Extend("NPCActionLegendaryEntryUI")

function NPCActionLegendaryEntryUI:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionLegendaryEntryUI:Execute(playerId, needSendReq)
  Base.Execute(self, playerId, needSendReq)
  self:Finish()
end

return NPCActionLegendaryEntryUI
