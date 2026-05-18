local InputModuleEvent = require("NewRoco.Modules.Core.Input.InputModuleEvent")
local InputModuleData = require("NewRoco.Modules.Core.Input.InputModuleData")
local InputModule = NRCModuleBase:Extend("InputModule")

function InputModule:OnConstruct()
  _G.InputModuleCmd = require("NewRoco.Modules.Core.Input.InputModuleCmd")
  self.InputModule = self
  self.enableLog = false
  self._inputModuleData = InputModuleData()
end

function InputModule:OnActive()
  self:RegisterCmd(InputModuleCmd.OnInput_JoyStick, self.DoCmdOnInput_JoyStick)
  self:RegisterCmd(InputModuleCmd.OnInput_TouchEnd, self.DoCmdOnInput_TouchEnd)
  self:RegisterCmd(InputModuleCmd.OnInput_TouchStart, self.DoCmdOnInput_TouchStart)
  self:RegisterCmd(InputModuleCmd.OnInput_Turn, self.DoCmdOnInput_Turn)
  self:RegisterCmd(InputModuleCmd.OnInput_CastAbility, self.DoCmdOnInput_CastAbility)
  self:RegisterCmd(InputModuleCmd.OnInput_StopAbility, self.DoCmdOnInput_StopAbility)
end

function InputModule:GetInputModuleData()
  return self._inputModuleData
end

function InputModule:DoCmdOnInput_JoyStick(...)
  self:DispatchEvent(InputModuleEvent.OnInput_JoyStick, ...)
end

function InputModule:DoCmdOnInput_TouchEnd(...)
  self:DispatchEvent(InputModuleEvent.OnInput_TouchEnd, ...)
end

function InputModule:DoCmdOnInput_TouchStart(...)
  self:DispatchEvent(InputModuleEvent.OnInput_TouchStart, ...)
end

function InputModule:DoCmdOnInput_Turn(...)
  self:DispatchEvent(InputModuleEvent.OnInput_Turn, ...)
end

function InputModule:DoCmdOnInput_CastAbility(...)
  self:DispatchEvent(InputModuleEvent.OnInput_CastAbility, ...)
end

function InputModule:DoCmdOnInput_StopAbility(...)
  self:DispatchEvent(InputModuleEvent.OnInput_StopAbility, ...)
end

return InputModule
