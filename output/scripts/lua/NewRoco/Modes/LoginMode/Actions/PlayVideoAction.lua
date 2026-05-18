local NRCModeAction = require("Core.NRCMode.NRCModeAction")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = NRCModeAction
local LoginModuleEvent = reload("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local PlayVideoAction = Base:Extend("PlayVideoAction")

function PlayVideoAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.VideoProperties = properties
  if properties.path == nil then
    Log.Error("Video path invalid")
  end
end

function PlayVideoAction:OnEnter()
  Log.Debug("PlayVideoAction OnEnter")
  self:InjectProperties()
  NRCEventCenter:RegisterEvent("PlayVideoAction", self, LoginModuleEvent.PlayVideoComplete, self.OnVideoComplete)
  NRCEventCenter:DispatchEvent(LoginModuleEvent.PlayVideo, self.VideoProperties)
end

function PlayVideoAction:OnVideoComplete(inEvent)
  if nil == inEvent then
    self:Finish()
  else
    self.fsm:SendEvent(inEvent, self)
  end
end

function PlayVideoAction:OnExit()
  NRCEventCenter:UnRegisterEvent(self, LoginModuleEvent.PlayVideoComplete, self.OnVideoComplete)
  Log.Debug("PlayVideoAction OnExit:", self.name)
end

return PlayVideoAction
