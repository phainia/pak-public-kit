local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local Base = NPCActionBase
local M = Base:Extend("NPCActionHomeIndoorPerformExpand")

function M:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function M:Execute()
  Base.Execute(self)
  NRCModuleManager:DoCmd(HomeModuleCmd.OpenHomeExpandPanel)
  self:Finish(true)
end

return M
