local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local Base = NPCActionBase
local NPCActionSelectSchool = Base:Extend("NPCActionSelectSchool")

function NPCActionSelectSchool:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionSelectSchool:Execute()
  _G.NRCModeManager:DoCmd(_G.ActivityModuleCmd.OpenSelectionOfBranchCollegesPanel, self)
  Base.Execute(self)
end

return NPCActionSelectSchool
