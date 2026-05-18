local NRCModeAction = require("Core.NRCMode.NRCModeAction")
local LoginUtils = require("NewRoco.Modules.System.LoginModule.LoginUtils")
local LoginModuleEvent = reload("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local Base = NRCModeAction
local SetCharacterAction = Base:Extend("SetCharacterAction")

function SetCharacterAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.properties = properties
  if self.properties.bIsMale then
    self.Event = LoginModuleEvent.SetCharacterToMale
  else
    self.Event = LoginModuleEvent.SetCharacterToFemale
  end
end

function SetCharacterAction:OnEnter()
  Log.Debug("SetCharacterAction OnEnter")
  if self.properties.bIsMale ~= nil then
    NRCEventCenter:DispatchEvent(self.Event)
  end
  if LoginUtils.GetPropertyHolder() and self.properties then
    LoginUtils.GetPropertyHolder().bIsMale = self.properties.bIsMale
  else
    Log.Error("SetCharacterAction:Not in selection phase")
  end
  self:Finish()
end

function SetCharacterAction:OnExit()
  Log.Debug("SetCharacterAction OnExit:", self.name)
end

return SetCharacterAction
