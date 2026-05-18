require("UnLuaEx")
local CreatePlayerModuleCmd = require("NewRoco.Modules.System.CreatePlayerModule.CreatePlayerModuleCmd")
local LoginModuleEvent = require("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local BP_LoginPlayerMesh_C = Class("BP_LoginPlayerMesh_C")

function BP_LoginPlayerMesh_C:NotifyGender()
  Log.Debug("Login: NotifyGender")
  local CurLevelName = LevelHelper:GetLevelName()
  if self.bIsMale then
    if "Login" == CurLevelName then
      NRCEventCenter:DispatchEvent(LoginModuleEvent.CharacterSelected, LoginModuleEvent.MaleCharacterSelected)
      NRCEventCenter:DispatchEvent(LoginModuleEvent.EndPostSelectionIdle, LoginModuleEvent.MaleCharacterSelected)
    else
      NRCModuleManager:DoCmd(CreatePlayerModuleCmd.OnMaleBtnClick)
    end
  elseif "Login" == CurLevelName then
    NRCEventCenter:DispatchEvent(LoginModuleEvent.CharacterSelected, LoginModuleEvent.FemaleCharacterSelected)
    NRCEventCenter:DispatchEvent(LoginModuleEvent.EndPostSelectionIdle, LoginModuleEvent.FemaleCharacterSelected)
  else
    NRCModuleManager:DoCmd(CreatePlayerModuleCmd.OnFemaleBtnClick)
  end
end

return BP_LoginPlayerMesh_C
