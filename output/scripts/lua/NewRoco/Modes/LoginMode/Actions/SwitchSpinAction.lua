local NRCModeAction = require("Core.NRCMode.NRCModeAction")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local LoginModuleEvent = reload("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local Base = NRCModeAction
local SwitchSpinAction = Base:Extend("SwitchSpinAction")

function SwitchSpinAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.bEnableSpin = properties.bEnableSpin
end

function SwitchSpinAction:OnEnter()
  Log.Debug("SwitchSpinAction OnEnter")
  if self.bEnableSpin then
    self.fsm.bIsMale = nil
    _G.NRCAudioManager:SetStateByName("Login_Game", "Create", "SwitchSpinAction")
    NRCEventCenter:RegisterEvent("SwitchSpinAction", self, LoginModuleEvent.CharacterSelected, self.OnCharacterSelected)
    NRCEventCenter:DispatchEvent(LoginModuleEvent.EnableSelection)
  else
    NRCEventCenter:DispatchEvent(LoginModuleEvent.DisableSelection)
    self:Finish()
  end
end

function SwitchSpinAction:RestorePlayerPosition()
  local controller = LoginUtils.GetLoginController()
  controller:RestorePlayerPosition(self, self.Finish)
end

function SwitchSpinAction:OnCharacterSelected(inEvent)
  if inEvent then
    NRCEventCenter:UnRegisterEvent(self, LoginModuleEvent.CharacterSelected, self.OnCharacterSelected)
    self.fsm:SendEvent(inEvent)
  else
    self:Finish()
  end
end

function SwitchSpinAction:OnExit()
  NRCEventCenter:UnRegisterEvent(self, LoginModuleEvent.CharacterSelected, self.OnCharacterSelected)
  Log.Debug("SwitchSpinAction OnExit:", self.name)
end

return SwitchSpinAction
