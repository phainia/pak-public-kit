local NRCModeAction = require("Core.NRCMode.NRCModeAction")
local LoginUtils = require("NewRoco.Modules.System.LoginModule.LoginUtils")
local LoginModuleEvent = reload("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local LoginEnum = require("NewRoco.Modes.LoginMode.LoginEnum")
local Base = NRCModeAction
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local PlayVideoAction = Base:Extend("PlayVideoAction")

function PlayVideoAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.VideoProperties = properties
  if properties.path == nil then
    Log.Error("Video path invalid")
  end
end

function PlayVideoAction:OnEnter()
  if self.VideoProperties.StartVideoListMode then
    _G.NRCModuleManager:DoCmd(UpdateUIModuleCmd.PlayVideoList)
    if self.VideoProperties.bPlayAndContinue then
      self:Finish()
    end
    return
  end
  if self.VideoProperties.FinishEvent then
    _G.NRCEventCenter:RegisterEvent("PlayVideoAction", self, self.VideoProperties.FinishEvent, self.OnReceiveFinishEvent)
  end
  if self.VideoProperties.bFinishOnVideoOpen or self.VideoProperties.bAutoFadeOut then
    _G.NRCEventCenter:RegisterEvent("PlayVideoAction", self, LoginModuleEvent.VideoOpened, self.OnVideoOpened)
  end
  if self.VideoProperties.bLoop then
    _G.NRCModuleManager:DoCmd(UpdateUIModuleCmd.PlayVideo, self.VideoProperties.path, self.VideoProperties.bLoop)
  else
    _G.NRCModuleManager:DoCmd(UpdateUIModuleCmd.PlayVideo, self.VideoProperties.path, self.VideoProperties.bLoop, self, self.OnVideoComplete)
  end
  if self.VideoProperties.bPlayAndContinue then
    self:Finish()
  end
end

function PlayVideoAction:OnReceiveFinishEvent()
  self:CheckUnregisterEvents()
  self:Finish()
end

function PlayVideoAction:CheckUnregisterEvents()
  local FinishEvent = self.VideoProperties.FinishEvent
  if FinishEvent then
    _G.NRCEventCenter:UnRegisterEvent(self, FinishEvent, self.OnReceiveFinishEvent)
  end
  if self.VideoProperties.bFinishOnVideoOpen or self.VideoProperties.bAutoFadeOut then
    _G.NRCEventCenter:UnRegisterEvent(self, LoginModuleEvent.VideoOpened, self.OnVideoOpened)
  end
end

function PlayVideoAction:OnVideoOpened()
  if self.VideoProperties.bAutoFadeOut then
    DelayManager:DelaySeconds(0.5, function()
      NRCModuleManager:DoCmd(UpdateUIModuleCmd.ShowBlackBackground, 0)
    end)
  end
  if self.VideoProperties.bFinishOnVideoOpen then
    self:CheckUnregisterEvents()
    self:Finish()
  end
end

function PlayVideoAction:OnVideoComplete()
  Log.Debug("PlayVideoAction OnVideoComplete")
  if self.VideoProperties.EndEvent then
    LoginUtils.SendEventToLoginFsm(self.VideoProperties.EndEvent)
  else
    self:Finish()
    return
  end
  if self.VideoProperties.bFinishOnVideoEnd then
    self:Finish()
  end
end

function PlayVideoAction:OnExit()
  NRCEventCenter:UnRegisterEvent(self, LoginModuleEvent.PlayVideoComplete, self.OnVideoComplete)
  Log.Debug("PlayVideoAction OnExit:", self.name)
end

return PlayVideoAction
