local NRCModeAction = require("Core.NRCMode.NRCModeAction")
local Base = NRCModeAction
local DimoControlAction = Base:Extend("DimoControlAction")

function DimoControlAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.properties = properties
end

function DimoControlAction:OnEnter()
  Log.Debug("DimoControlAction OnEnter")
end

return DimoControlAction
