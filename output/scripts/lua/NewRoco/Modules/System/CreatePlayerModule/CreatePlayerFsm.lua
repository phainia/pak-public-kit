local Fsm = require("NewRoco.Modules.Core.Fsm.Fsm")
local CreateplayerEnum = require("NewRoco.Modes.CreatePlayerMode.CreatePlayerEnum")
local CreatePlayerEvent = require("NewRoco.Modules.System.CreatePlayerModule.CreatePlayerEvent")
local DimoControlAction = require("NewRoco.Modules.System.CreatePlayerModule.Action.DimoControlAction")
local SelectPlayerAction = require("NewRoco.Modules.System.CreatePlayerModule.Action.SelectPlayerAction")
local LoadLocalNPCOptionsAction = require("NewRoco.Modules.System.CreatePlayerModule.Action.LoadLocalNPCOptionsAction")
local StartChildrenFsmAction = require("NewRoco.Modes.LoginMode.Actions.StartChildrenFsmAction")
local CreatePlayerUtils = require("NewRoco.Modules.System.LoginModule.LoginUtils")
local NRCLoginFsmImplementation = require("NewRoco.Modules.System.LoginModule.LoginFsm")
local DoCmdAction = require("NewRoco.Modules.System.LoginModule.Actions.DoCmdAction")
local CreatePlayerModuleCmd = require("NewRoco.Modules.System.CreatePlayerModule.CreatePlayerModuleCmd")
local PlayerModuleCmd = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleCmd")
local EndLoginAction = require("NewRoco.Modes.LoginMode.Actions.EndLoginAction")
local LoginModuleEvent = require("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local PlaySequenceAction = require("NewRoco.Modes.LoginMode.Actions.PlaySequenceAction")
local SendEventToFsmAction = require("NewRoco.Modes.LoginMode.Actions.SendEventAction")
local LoginInitAction = require("NewRoco.Modes.LoginMode.Actions.LoginInitAction")
local AddCreatePlayerTaskAction = require("NewRoco.Modules.System.CreatePlayerModule.Action.AddCreatePlayerTaskAction")
local DimoControlUIAction = require("NewRoco.Modules.System.CreatePlayerModule.Action.DimoControlUIAction")
local CreatePlayerDefaultHideCursor = require("NewRoco.Modules.System.CreatePlayerModule.Action.CreatePlayerDefaultHideCursor")
local FINISHED = "FINISHED"

local function InstantiateCreatePlayerFsm(levelData)
  local CreatePlayerFsm = Fsm("CreatePlayerFsm")
  local ParentModule = CreatePlayerFsm:CreateVar("ParentModule", nil)
  local NRCLoginFsm = CreatePlayerUtils.CreateChildrenFsm(CreatePlayerFsm, "NRCLoginFsm")
  CreatePlayerFsm.NRCLoginFsm = NRCLoginFsm
  NRCLoginFsmImplementation(NRCLoginFsm, true)
  local hasLookedEnterSequence = false
  local hasEnterSelectCharacter = false
  if levelData then
    if levelData.points and 1 == levelData.points[1].pos.x then
      hasLookedEnterSequence = true
    end
    if levelData.points and 1 == levelData.points[1].dir.z then
      hasEnterSelectCharacter = true
    end
  end
  local EnterSequenceState = CreatePlayerFsm:CreateSequentialState(CreateplayerEnum.StateNames.EnterSequenceState)
  local DimoControlState = CreatePlayerFsm:CreateSequentialState(CreateplayerEnum.StateNames.DimoControlState)
  local SelectPlayerState = CreatePlayerFsm:CreateSequentialState(CreateplayerEnum.StateNames.SelectPlayerState)
  local NRCLoginEndState = CreatePlayerFsm:CreateSequentialState(CreateplayerEnum.StateNames.NRCLoginEndState)
  EnterSequenceState:AddAction(LoginInitAction("LoginInitAction"))
  EnterSequenceState:AddAction(CreatePlayerDefaultHideCursor("DefaultHideCursor", {bDesireHide = true}))
  EnterSequenceState:AddAction(DoCmdAction("BindSequenceCameraToController", {
    Cmd = CreatePlayerModuleCmd.BindCameraToController,
    bDoAndContinue = true
  }))
  EnterSequenceState:AddAction(DoCmdAction("CloseLoadingUI", {
    Cmd = LoadingUIModuleCmd.CloseCreatePlayerLoadingUI,
    bDoAndContinue = true,
    Arguments = {true}
  }))
  EnterSequenceState:AddAction(PlaySequenceAction("PlayEnterSequence", {
    path = UEPath.CREATEPLAYER_ENTER,
    PlayRate = 1.0
  }))
  EnterSequenceState:AddAction(DoCmdAction("RevertCameraToPlayer", {
    Cmd = CreatePlayerModuleCmd.RevertCameraToPlayer,
    bDoAndContinue = true
  }))
  EnterSequenceState:AddAction(LoadLocalNPCOptionsAction("LoadLocalNPCOptions"))
  EnterSequenceState:AddAction(SendEventToFsmAction("EnterDimoCtrl", {
    Event = CreatePlayerEvent.StartDimoCtrl
  }))
  EnterSequenceState:AddTransitionToState(CreatePlayerEvent.StartDimoCtrl, DimoControlState)
  if hasEnterSelectCharacter then
    SelectPlayerState:AddAction(LoginInitAction("LoginInitAction"))
    SelectPlayerState:AddAction(CreatePlayerDefaultHideCursor("DefaultHideCursor", {bDesireHide = true}))
  elseif hasLookedEnterSequence then
    DimoControlState:AddAction(LoginInitAction("LoginInitAction"))
    SelectPlayerState:AddAction(CreatePlayerDefaultHideCursor("DefaultHideCursor", {bDesireHide = true}))
  end
  DimoControlState:AddAction(DoCmdAction("CloseLoadingUI", {
    Cmd = LoadingUIModuleCmd.CloseCreatePlayerLoadingUI,
    bDoAndContinue = true
  }))
  DimoControlState:AddAction(DoCmdAction("PlayCreatePlayerMusic", {
    Cmd = CreatePlayerModuleCmd.PlayCreatePlayerMusic,
    bDoAndContinue = true
  }))
  DimoControlState:AddAction(DimoControlUIAction("OpenDimoCtrlPanel", {ParentModule = ParentModule, bOpen = true}))
  DimoControlState:AddAction(AddCreatePlayerTaskAction("AddTaskAction", {ParentModule = ParentModule}))
  DimoControlState:AddAction(DimoControlAction("DimoControlAction"))
  DimoControlState:AddTransitionToState(CreatePlayerEvent.StartSelect, SelectPlayerState)
  SelectPlayerState:AddAction(DoCmdAction("CloseLoadingUI", {
    Cmd = LoadingUIModuleCmd.CloseCreatePlayerLoadingUI,
    bDoAndContinue = true
  }))
  SelectPlayerState:AddAction(DimoControlUIAction("OpenDimoCtrlPanel", {ParentModule = ParentModule, bOpen = false}))
  SelectPlayerState:AddAction(StartChildrenFsmAction("NRCLoginFsm", {ChildrenFsm = NRCLoginFsm}))
  SelectPlayerState:AddTransitionToState(LoginModuleEvent.EnterLoginEndVideoFemale, NRCLoginEndState)
  SelectPlayerState:AddTransitionToState(LoginModuleEvent.EnterLoginEndVideoMale, NRCLoginEndState)
  NRCLoginEndState:AddAction(DoCmdAction("StopCreatePlayerMusic", {
    Cmd = CreatePlayerModuleCmd.StopCreatePlayerMusic,
    bDoAndContinue = true
  }))
  NRCLoginEndState:AddAction(CreatePlayerDefaultHideCursor("CancelDefaultHideCursor", {bDesireHide = false}))
  NRCLoginEndState:AddAction(EndLoginAction("EndLoginAction"))
  if hasEnterSelectCharacter then
    CreatePlayerFsm:SetInitState(SelectPlayerState)
  elseif hasLookedEnterSequence then
    CreatePlayerFsm:SetInitState(DimoControlState)
  else
    CreatePlayerFsm:SetInitState(EnterSequenceState)
  end
  return CreatePlayerFsm
end

return InstantiateCreatePlayerFsm
