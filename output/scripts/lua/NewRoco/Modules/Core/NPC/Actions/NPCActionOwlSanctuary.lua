local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local Base = NPCActionBase
local NPCActionOwlSanctuary = Base:Extend("NPCActionOwlSanctuary")

function NPCActionOwlSanctuary:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionOwlSanctuary:Execute()
  _G.NRCModeManager:DoCmd(_G.SleepingOwlModuleCmd.OpenMainPanel, self.Owner.owner.serverData.base.actor_id, self)
  Base.Execute(self)
end

return NPCActionOwlSanctuary
