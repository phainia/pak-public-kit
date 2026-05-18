local NRCModeAction = require("Core.NRCMode.NRCModeAction")
local Base = NRCModeAction
local SelectPlayerAction = Base:Extend("SelectPlayerAction")

function SelectPlayerAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.properties = properties
end

function SelectPlayerAction:OnEnter()
  Log.Error("SelectPlayerAction OnEnter")
end

return SelectPlayerAction
