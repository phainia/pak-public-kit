require("UnLuaEx")
local LoginModuleEvent = reload("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local BP_LoginPlayer_C = NRCClass()

function BP_LoginPlayer_C:NotifyGender()
  local controller = UE4.UGameplayStatics.GetPlayerController(self, 0)
  if not controller.bPlayerSelected then
    controller.bPlayerSelected = true
    controller.bMaleSelected = self.bIsMale
    if self.bIsMale then
      NRCEventCenter:DispatchEvent(LoginModuleEvent.CharacterSelected, LoginModuleEvent.MaleCharacterSelected)
    else
      NRCEventCenter:DispatchEvent(LoginModuleEvent.CharacterSelected, LoginModuleEvent.FemaleCharacterSelected)
    end
  elseif self.bIsMale ~= controller.bMaleSelected then
    local TargetStateEvent = LoginModuleEvent.FemaleCharacterSelected
    if self.bIsMale then
      TargetStateEvent = LoginModuleEvent.MaleCharacterSelected
    end
    NRCEventCenter:DispatchEvent(LoginModuleEvent.EndSequenceLoop, TargetStateEvent)
    controller.bMaleSelected = self.bIsMale
  end
end

return BP_LoginPlayer_C
