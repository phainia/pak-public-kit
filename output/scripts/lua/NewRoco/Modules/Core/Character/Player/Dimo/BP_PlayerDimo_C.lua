require("UnLuaEx")
local Base = NRCClass
local MainUICmd = require("NewRoco.Modules.System.MainUI.MainUIModuleCmd")
local CreatePlayerEvent = require("NewRoco.Modules.System.CreatePlayerModule.CreatePlayerEvent")
local CreatePlayerModuleCmd = require("NewRoco.Modules.System.CreatePlayerModule.CreatePlayerModuleCmd")
local BP_PlayerDimo_C = Base:Extend("BP_PlayerDimo_C")

function BP_PlayerDimo_C:ReceiveBeginPlay()
  self.Overridden.ReceiveBeginPlay(self)
  if not NRCEnv:IsCreatePlayerMode() then
    NRCModeManager:ActiveMode("CreatePlayerMode")
  end
end

function BP_PlayerDimo_C:StartSelectCharacter()
  local fsm = NRCModuleManager:DoCmd(CreatePlayerModuleCmd.GetCreatePlayerFsm)
  fsm:SendEvent(CreatePlayerEvent.StartSelect)
  NRCModuleManager:DoCmd(CreatePlayerModuleCmd.UploadLevelInfo, 1, 1, 1, 1, 1, 1)
end

function BP_PlayerDimo_C:StopDash()
  self.Overridden.StopDash(self)
  local playerModule = NRCModuleManager:GetModule("PlayerModule")
  if not playerModule.playerActor.bIsDashing then
    _G.NRCEventCenter:DispatchEvent(CreatePlayerEvent.PlayerStopDash)
  end
end

return BP_PlayerDimo_C
