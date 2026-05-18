local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local MagicReplayActionBase = require("NewRoco.Modules.System.MagicReplay.Action.MagicReplayActionBase")
local Base = MagicReplayActionBase
local MagicReplayBlockInputAction = Base:Extend("MagicReplayBlockInputAction")
FsmUtils.MergeMembers(Base, MagicReplayBlockInputAction, {
  {name = "Block", type = "boolean"}
})

function MagicReplayBlockInputAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function MagicReplayBlockInputAction:OnEnter()
  if self:GetProperty("Block", false) then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.OpenInputBlocker, "MagicReplayModule.MagicReplayBlockInputAction")
  else
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.CloseInputBlocker, "MagicReplayModule.MagicReplayBlockInputAction")
  end
  self:Finish()
end

function MagicReplayBlockInputAction:OnExit()
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.CloseInputBlocker, "MagicReplayModule.MagicReplayBlockInputAction")
end

return MagicReplayBlockInputAction
