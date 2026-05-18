local MagicActionBase = require("NewRoco.Modules.Core.NPC.Actions.MagicActions.MagicActionBase")
local Base = MagicActionBase
local MagicActionUnlockOwl = Base:Extend("MagicActionUnlockOwl")

function MagicActionUnlockOwl:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

return MagicActionUnlockOwl
