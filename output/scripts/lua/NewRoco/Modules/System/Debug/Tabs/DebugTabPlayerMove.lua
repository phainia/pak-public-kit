local Base = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local PlayerDataEvent = require("Data.Global.PlayerDataEvent")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local ScenePlayerPet = require("NewRoco.Modules.Core.Scene.Actor.ScenePlayerPet")
local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local BattleField = require("NewRoco.Modules.Core.Battle.Common.BattleField")
local DebugTabPlayerMove = Base:Extend("DebugTabPlayerMove")

function DebugTabPlayerMove:Ctor()
  Base.Ctor(self)
  GlobalConfig.PlayerMoveLog = false
end

function DebugTabPlayerMove:SetupTabs()
  self:Add("\230\136\145\228\184\186\228\187\128\228\185\136\228\184\141\232\131\189\231\167\187\229\138\168?", self.DumpInput, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\232\191\152\230\136\145\232\135\170\231\148\177\231\167\187\229\138\168", self.ResetInput, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\231\167\187\229\138\168\232\176\131\232\175\149\230\151\165\229\191\151\230\128\187\229\188\128\229\133\179", self.ToggleMoveLog, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\136\145\228\184\186\228\187\128\228\185\136\228\184\141\232\131\189\231\191\187\232\182\138", self.OpenMantleLog, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\136\145\228\184\186\228\187\128\228\185\136\228\184\141\232\131\189\230\148\128\231\136\172", self.OpenClimbLog, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\136\145\228\184\186\228\187\128\228\185\136\228\184\141\232\131\189StepUp", self.OpenStepUpLog, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\233\170\145\228\185\152\232\176\131\232\175\149\230\151\165\229\191\151\230\128\187\229\188\128\229\133\179", self.ToggleRideMoveLog, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
end

function DebugTabPlayerMove:ToggleMoveLog(name, panel, level)
  GlobalConfig.PlayerMoveLog = not GlobalConfig.PlayerMoveLog
  local logLevel = GlobalConfig.PlayerMoveLog and "Verbose" or "Debug"
  if panel then
    if type(level) == "string" then
      logLevel = level
    end
  elseif type(level) == "string" then
    logLevel = level
  end
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, string.format("Log LogPlayerMovement %s", logLevel))
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, string.format("Log LogMantle %s", logLevel))
end

function DebugTabPlayerMove:ToggleRideMoveLog(name, panel, level)
  GlobalConfig.RideMoveLog = not GlobalConfig.RideMoveLog
  local logLevel = GlobalConfig.RideMoveLog and "Verbose" or "Debug"
  if panel then
    if type(level) == "string" then
      logLevel = level
    end
  elseif type(level) == "string" then
    logLevel = level
  end
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, string.format("Log LogNRCCharacterMove %s", logLevel))
end

function DebugTabPlayerMove:OpenMantleLog()
  self:ToggleMoveLog(nil, nil, "Debug")
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, string.format("Log LogMantle Verbose"))
end

function DebugTabPlayerMove:OpenClimbLog()
  self:ToggleMoveLog(nil, nil, "Debug")
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, string.format("Log LogClimb Verbose"))
end

function DebugTabPlayerMove:OpenStepUpLog()
  self:ToggleMoveLog(nil, nil, "Debug")
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, string.format("Log LogStepUp Verbose"))
end

function DebugTabPlayerMove:DumpInput()
  local player = _G.NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if player then
    player:DumpCriticalVariables()
  end
end

function DebugTabPlayerMove:ResetInput()
  local player = _G.NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if player then
    if player.inputComponent then
      player.inputComponent:ResetInputSwitch()
    end
    player:PausePlayerMovement(self, false)
  end
  if UE4Helper.IsPCMode() then
    _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.RemoveBlockIMC, self)
  end
end

return DebugTabPlayerMove
