local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local Base = NPCActionBase
local NPCActionHomePlantLandUnlock = Base:Extend("NPCActionHomePlantLandUnlock")

function NPCActionHomePlantLandUnlock:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionHomePlantLandUnlock:Execute()
  Base.Execute(self)
  self:Finish(true)
end

return NPCActionHomePlantLandUnlock
