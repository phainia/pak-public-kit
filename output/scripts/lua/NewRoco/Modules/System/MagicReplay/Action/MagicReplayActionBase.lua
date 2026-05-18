local MagicReplayUtils = require("NewRoco.Modules.System.MagicReplay.MagicReplayUtils")
local FsmAction = require("NewRoco.Modules.Core.Fsm.FsmAction")
local Base = FsmAction
local MagicReplayActionBase = Base:Extend("MagicReplayActionBase")

function MagicReplayActionBase:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

return MagicReplayActionBase
