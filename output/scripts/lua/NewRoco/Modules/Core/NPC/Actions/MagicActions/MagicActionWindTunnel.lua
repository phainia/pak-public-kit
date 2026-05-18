local NPCModuleEnum = require("NewRoco.Modules.Core.NPC.NPCModuleEnum")
local Base = require("NewRoco.Modules.Core.NPC.Actions.MagicActions.MagicActionBase")
local MagicActionWindTunnel = Base:Extend("MagicActionWindTunnel")

function MagicActionWindTunnel:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function MagicActionWindTunnel:OnExecute()
  self:Finish(true)
end

function MagicActionWindTunnel:OnSubmit(rsp)
end

return MagicActionWindTunnel
