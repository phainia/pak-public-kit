local NRCModeAction = require("Core.NRCMode.NRCModeAction")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local LoginModuleEvent = reload("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local Base = NRCModeAction
local CreatePlayersAction = Base:Extend("CreatePlayersAction")

function CreatePlayersAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function CreatePlayersAction:OnEnter()
  Log.Debug("CreatePlayersAction OnEnter")
  self:CreatePlayers()
end

function CreatePlayersAction:CreatePlayers()
  self:Finish()
end

function CreatePlayersAction:OnExit()
  Log.Debug("CreatePlayersAction OnExit:", self.name)
end

return CreatePlayersAction
