local FsmAction = require("NewRoco.Modules.Core.Fsm.FsmAction")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = FsmAction
local CinematicModuleEvent = reload("NewRoco.Modules.Core.Cinematic.CinematicModuleEvent")
local CinematicEndAction = Base:Extend("CinematicEndAction")
FsmUtils.MergeMembers(Base, CinematicEndAction, {})

function CinematicEndAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function CinematicEndAction:OnEnter()
  self:Finish()
end

function CinematicEndAction:Done()
end

function CinematicEndAction:OnExit()
  local Success = self.fsm:GetProperty("Result", false)
  _G.NRCModuleManager:DoCmd(_G.CinematicModuleCmd.CloseCinematic, Success)
end

return CinematicEndAction
