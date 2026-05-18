local Base = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local MagicActionTransferNpc = Base:Extend("MagicActionTransferNpc")

function MagicActionTransferNpc:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function MagicActionTransferNpc:Execute()
  Base.Execute(self)
end

function MagicActionTransferNpc:PostOnCommit(rsp)
  if 0 ~= rsp.ret_info.ret_code then
  end
end

return MagicActionTransferNpc
