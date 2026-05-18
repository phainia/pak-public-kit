local Fsm = require("NewRoco.Modules.Core.Fsm.Fsm")
local LoginEnum = require("NewRoco.Modes.LoginMode.LoginEnum")
local LoginModuleEvent = require("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local ShowPanelAction = require("NewRoco.Modules.System.LoginModule.Actions.ShowPanelAction")
local CheckConditionAction = require("NewRoco.Modules.System.LoginModule.Actions.CheckConditionAction")
local DoCmdAction = require("NewRoco.Modules.System.LoginModule.Actions.DoCmdAction")
local PopWindowAction = require("NewRoco.Modules.System.LoginModule.Actions.PopWindowAction")
local PlayVideoAction = require("NewRoco.Modules.System.LoginModule.Actions.PlayVideoAction")
local SwitchLevelAction = require("NewRoco.Modules.System.LoginModule.Actions.SwitchLevelAction")
local EndLoginAction = require("NewRoco.Modes.LoginMode.Actions.EndLoginAction")
local StartChildrenFsmAction = require("NewRoco.Modes.LoginMode.Actions.StartChildrenFsmAction")
local LoginUtils = require("NewRoco.Modules.System.LoginModule.LoginUtils")
local NRCLoginFsmImplementation = require("NewRoco.Modules.System.LoginModule.LoginFsm")
local ChangeToDimoPlaySceneAction = require("NewRoco.Modules.System.LoginModule.Actions.ChangeToDimoPlaySceneAction")
local LoadLoginNoticeAction = require("NewRoco.Modules.System.LoginModule.Actions.LoadLoginNoticeAction")
local FINISHED = "FINISHED"

local function CreateFsm()
  local LoginFsm = Fsm("FullLoginFsmPC")
  LoginUtils.InstantiateMSDKNoticeObserver()
  NRCEventCenter:UnRegisterEvent(LoginFsm, _G.NRCGlobalEvent.ON_CONNECTED, LoginFsm.OnConnected)
  local PrologueState = LoginFsm:CreateSequentialState(LoginEnum.StateNames.PrologueState)
  local FirstTimeLoginState = LoginFsm:CreateBurstState(LoginEnum.StateNames.FirstTimeLoginState)
  local WeGameState = LoginFsm:CreateComposedState(LoginEnum.StateNames.WeGameState)
  local LoadingState = LoginFsm:CreateSequentialState(LoginEnum.StateNames.LoadingState)
  local RestoreState = LoginFsm:CreateSequentialState(LoginEnum.StateNames.RestoreState)
  local BackToMainState = LoginFsm:CreateSequentialState(LoginEnum.StateNames.BackToMainState)
  local NRCLoginState = LoginFsm:CreateComposedState(LoginEnum.StateNames.NRCLoginState)
  local ExitState = LoginFsm:CreateSequentialState(LoginEnum.StateNames.ExitGameState)
  local WeGameStartReqState = WeGameState:CreateChildSequentialState(LoginEnum.StateNames.WeGameStartReqState)
  local WeGameSuccessState = WeGameState:CreateChildSequentialState(LoginEnum.StateNames.WeGameSuccessState)
  local WeGameFailState = WeGameState:CreateChildSequentialState(LoginEnum.StateNames.WeGameFailState)
  local WeGameNetBarReqState = WeGameState:CreateChildSequentialState(LoginEnum.StateNames.WeGameNetBarReqState)
  local WeGameRestoreState = WeGameState:CreateChildSequentialState(LoginEnum.StateNames.WeGameRestoreState)
  local WeGameEndState = WeGameState:CreateChildSequentialState(LoginEnum.StateNames.WeGameEndState)
  local NRCLoginFsm = LoginUtils.CreateChildrenFsm(LoginFsm, "NRCLoginFsm")
  LoginFsm.NRCLoginFsm = NRCLoginFsm
  NRCLoginFsmImplementation(NRCLoginFsm)
  PrologueState:AddAction(CheckConditionAction("CheckWeGameSDKInitStatus", {
    Condition = LoginEnum.Conditions.WeGameInitialized,
    Fail = LoginModuleEvent.WeGameInitFailed
  }))
  PrologueState:AddAction(DoCmdAction("OpenVideoUI", {
    Cmd = UpdateUIModuleCmd.OpenMainPanel,
    Arguments = {true},
    FinishEvent = LoginModuleEvent.UIOpened
  }))
  PrologueState:AddAction(DoCmdAction("FadeOutBlackScreen", {
    Cmd = UpdateUIModuleCmd.ShowBlackBackground,
    DoAfterFinish = 0.5,
    Arguments = {0}
  }))
  PrologueState:AddAction(PlayVideoAction("PlayVideoList", {
    path = UEPath.LOGIN_CLOUD_LOOP,
    StartVideoListMode = true,
    bPlayAndContinue = true
  }))
  PrologueState:AddAction(SwitchLevelAction("SwitchToLoginLevel", {Level = "Login"}))
  PrologueState:AddAction(ShowPanelAction("OpenMainLoginUI", {
    PanelName = LoginEnum.PanelNames.NRCLoginPanel,
    TurnOn = true
  }))
  PrologueState:AddAction(DoCmdAction("HideCanDownloadPanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.CanDownloadPanel,
      false,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  PrologueState:AddAction(DoCmdAction("HideAccountPanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.CompliancePanel,
      true,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  PrologueState:AddAction(DoCmdAction("HideAnnouncementPanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.AnnouncementPanel,
      false,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  PrologueState:AddAction(DoCmdAction("HideRepairToolsPanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.RepairToolsPanel,
      false,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  PrologueState:AddAction(DoCmdAction("HideCustomerServicePanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.CustomerServicePanel,
      false,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  PrologueState:AddAction(CheckConditionAction("CheckDevicePermitted", {
    Condition = LoginEnum.Conditions.DevicePermitted,
    Success = FINISHED
  }))
  PrologueState:AddAction(PopWindowAction("DeviceNotSupported", {
    Title = LuaText.fullloginfsm_1,
    Content = LuaText.fullloginfsm_1
  }))
  PrologueState:AddTransitionToState(LoginModuleEvent.WeGameInitFailed, WeGameFailState)
  PrologueState:AddTransitionToState(FINISHED, FirstTimeLoginState)
  FirstTimeLoginState:AddAction(CheckConditionAction("CheckIsFirstTimeLogin", {
    Condition = LoginEnum.Conditions.FirstTimeLogin,
    Fail = FINISHED
  }))
  FirstTimeLoginState:AddAction(PopWindowAction("ShowAgreements"))
  FirstTimeLoginState:AddTransitionToState(FINISHED, WeGameState)
  WeGameStartReqState:AddAction(CheckConditionAction("CheckIfSkipWeGame", {
    Condition = LoginEnum.Conditions.UseWeGame,
    Fail = LoginModuleEvent.LoginSuccess
  }))
  WeGameStartReqState:AddAction(DoCmdAction("TryWeGameReqTicket", {
    Cmd = LoginModuleCmd.TryWeGameReqTicket,
    bDoAndContinue = false,
    Timeout = 15
  }))
  WeGameStartReqState:AddTransitionToState(LoginModuleEvent.LoginSuccess, WeGameNetBarReqState)
  WeGameStartReqState:AddTransitionToState(LoginModuleEvent.LoginFail, WeGameFailState)
  WeGameStartReqState:AddTransitionToState(LoginModuleEvent.AccountSwitch, WeGameRestoreState)
  WeGameStartReqState:AddTransitionToState(LoginModuleEvent.OnDisconnected, BackToMainState)
  WeGameStartReqState:AddTransitionToState(FINISHED, WeGameFailState)
  WeGameNetBarReqState:AddAction(CheckConditionAction("CheckIfSkipWeGame", {
    Condition = LoginEnum.Conditions.UseWeGame,
    Fail = FINISHED
  }))
  WeGameNetBarReqState:AddAction(DoCmdAction("TryNetBarReq", {
    Cmd = LoginModuleCmd.TryNetBarReq,
    bDoAndContinue = true
  }))
  WeGameNetBarReqState:AddTransitionToState(LoginModuleEvent.AccountSwitch, WeGameRestoreState)
  WeGameNetBarReqState:AddTransitionToState(LoginModuleEvent.OnDisconnected, BackToMainState)
  WeGameNetBarReqState:AddTransitionToState(FINISHED, WeGameSuccessState)
  WeGameSuccessState:AddAction(DoCmdAction("HideNameInputAndServer", {
    Cmd = LoginModuleCmd.ShowUserNameAndServer,
    Arguments = {false},
    bDoAndContinue = true
  }))
  WeGameSuccessState:AddTransitionToState(LoginModuleEvent.OnDisconnected, BackToMainState)
  WeGameSuccessState:AddTransitionToState(FINISHED, WeGameEndState)
  WeGameFailState:AddAction(DoCmdAction("CloseWaitingUI", {
    Cmd = LoginModuleCmd.CloseLoginWaitingUI,
    bDoAndContinue = true
  }))
  WeGameFailState:AddAction(DoCmdAction("LogOutGameServer", {
    Cmd = OnlineModuleCmd.Logout,
    bDoAndContinue = true
  }))
  WeGameFailState:AddAction(DoCmdAction("ShowFailInfo", {
    Cmd = LoginModuleCmd.ShowFailInfo,
    bDoAndContinue = false
  }))
  WeGameFailState:AddTransitionToState(FINISHED, ExitState)
  WeGameFailState:AddTransitionToState(LoginModuleEvent.PopUpWindowConfirm, ExitState)
  WeGameFailState:AddTransitionToState(LoginModuleEvent.PopUpWindowCancel, ExitState)
  WeGameFailState:AddTransitionToState(LoginModuleEvent.OnDisconnected, BackToMainState)
  WeGameRestoreState:AddAction(PopWindowAction("ShowAccountSwitchChoice", {
    Content = LuaText.switch_account_tips_pc,
    SmallWindow = true
  }))
  WeGameRestoreState:AddTransitionToState(LoginModuleEvent.PopUpWindowCancel, WeGameStartReqState)
  WeGameRestoreState:AddTransitionToState(LoginModuleEvent.PopUpWindowConfirm, RestoreState)
  WeGameRestoreState:AddTransitionToState(LoginModuleEvent.OnDisconnected, BackToMainState)
  WeGameEndState:AddAction(ShowPanelAction("ShowAccountInfo", {
    PanelName = LoginEnum.PanelNames.AccountInfo,
    TurnOn = true,
    bKeepInBigWorld = true
  }))
  WeGameEndState:AddAction(DoCmdAction("UpdateServerList", {
    Cmd = LoginModuleCmd.RefreshServerList,
    bDoAndContinue = false,
    FinishEvent = LoginModuleEvent.OnServerListUpdated
  }))
  WeGameEndState:AddAction(DoCmdAction("ShowAccountPanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.AccountPanel,
      true,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  WeGameEndState:AddAction(DoCmdAction("HideCanDownloadPanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.CanDownloadPanel,
      false,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  WeGameEndState:AddAction(DoCmdAction("ShowLoginSuccessNotify", {
    Cmd = LoginModuleCmd.ShowBanner,
    bDoAndContinue = true,
    Arguments = {
      LuaText.fullloginfsm_3
    }
  }))
  WeGameEndState:AddAction(DoCmdAction("ShowLoginSuccessNotify", {
    Cmd = LoginModuleCmd.RefreshUserName,
    bDoAndContinue = true
  }))
  WeGameEndState:AddAction(DoCmdAction("HideAnnouncementPanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.AnnouncementPanel,
      true,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  WeGameEndState:AddAction(DoCmdAction("HideRepairToolsPanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.RepairToolsPanel,
      true,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  WeGameEndState:AddAction(DoCmdAction("HideCustomerServicePanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.CustomerServicePanel,
      true,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  WeGameEndState:AddTransitionToState(LoginModuleEvent.OnDisconnected, BackToMainState)
  WeGameEndState:AddTransitionToState(FINISHED, LoadingState)
  WeGameState:AddTransitionToState(FINISHED, LoadingState)
  LoadingState:AddTransitionToState(FINISHED, NRCLoginState)
  LoadingState:AddTransitionToState(LoginModuleEvent.AccountSwitchOnPC, RestoreState)
  LoadingState:AddTransitionToState(LoginModuleEvent.OnDisconnected, BackToMainState)
  RestoreState:AddAction(StartChildrenFsmAction("NRCLoginFsm", {ChildrenFsm = NRCLoginFsm, TurnOff = true}))
  RestoreState:AddAction(DoCmdAction("QuitGameConfirmed", {
    Cmd = LoginModuleCmd.AccountSwitchOnPC,
    DelayTime = 1,
    Arguments = {0}
  }))
  RestoreState:AddTransitionToState(LoginModuleEvent.OnDisconnected, BackToMainState)
  BackToMainState:AddAction(ShowPanelAction("OpenMainLoginUI", {
    PanelName = LoginEnum.PanelNames.NRCLoginPanel,
    TurnOn = false
  }))
  BackToMainState:AddAction(StartChildrenFsmAction("NRCLoginFsm", {ChildrenFsm = NRCLoginFsm, TurnOff = true}))
  BackToMainState:AddAction(ShowPanelAction("HideAccountInfo", {
    PanelName = LoginEnum.PanelNames.AccountInfo,
    TurnOn = false,
    bKeepInBigWorld = true
  }))
  BackToMainState:AddTransitionToState(FINISHED, PrologueState)
  local NRCLoginVideoState = NRCLoginState:CreateChildSequentialState(LoginEnum.StateNames.NRCLoginVideoState)
  local NRCLoginNoticeState = NRCLoginState:CreateChildSequentialState(LoginEnum.StateNames.NRCLoginNoticeState)
  local NRCCharacterSelectionVideoState = NRCLoginState:CreateChildBurstState(LoginEnum.StateNames.NRCCharacterSelectionVideoState)
  local NRCLoginSelectionState = NRCLoginState:CreateChildSequentialState(LoginEnum.StateNames.NRCLoginSelectionState)
  local NRCLoginEndMaleMovieState = NRCLoginState:CreateChildBurstState(LoginEnum.StateNames.NRCLoginEndMaleMovieState)
  local NRCLoginEndFemaleMovieState = NRCLoginState:CreateChildBurstState(LoginEnum.StateNames.NRCLoginEndFemaleMovieState)
  local NRCLoginEndState = NRCLoginState:CreateChildSequentialState(LoginEnum.StateNames.NRCLoginEndState)
  NRCLoginVideoState:AddAction(DoCmdAction("ShowLoginPanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.NRCLoginPanel,
      true,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  NRCLoginVideoState:AddAction(DoCmdAction("ShowAccountPanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.AccountPanel,
      true,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  NRCLoginVideoState:AddAction(DoCmdAction("HideAccountPanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.CompliancePanel,
      true,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  NRCLoginVideoState:AddTransitionToState(LoginModuleEvent.PlayerExist, NRCLoginEndState)
  NRCLoginVideoState:AddTransitionToState(LoginModuleEvent.OnDisconnected, BackToMainState)
  NRCLoginVideoState:AddTransitionToState(LoginModuleEvent.PlayerNotExist, NRCCharacterSelectionVideoState)
  NRCLoginVideoState:AddTransitionToState(FINISHED, NRCLoginNoticeState)
  NRCLoginNoticeState:AddAction(LoadLoginNoticeAction("LoadLoginNoticeAction"))
  NRCLoginNoticeState:AddTransitionToState(LoginModuleEvent.PlayerExist, NRCLoginEndState)
  NRCLoginNoticeState:AddTransitionToState(LoginModuleEvent.OnDisconnected, BackToMainState)
  NRCLoginNoticeState:AddTransitionToState(LoginModuleEvent.PlayerNotExist, NRCCharacterSelectionVideoState)
  NRCCharacterSelectionVideoState:AddAction(DoCmdAction("OpenLoadingUI", {
    Cmd = LoadingUIModuleCmd.OpenCreatePlayerLoadingUI,
    bDoAndContinue = true
  }))
  NRCCharacterSelectionVideoState:AddAction(DoCmdAction("HideLoginPanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.NRCLoginPanel,
      false,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  NRCCharacterSelectionVideoState:AddAction(DoCmdAction("HideAccountPanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.AccountPanel,
      false,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  NRCCharacterSelectionVideoState:AddAction(DoCmdAction("HideAccountPanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.CompliancePanel,
      false,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  NRCCharacterSelectionVideoState:AddAction(ChangeToDimoPlaySceneAction("ChangeToDimoPlaySceneAction"))
  NRCCharacterSelectionVideoState:AddTransitionToState(LoginModuleEvent.CloudVideoEnd, NRCLoginSelectionState)
  NRCCharacterSelectionVideoState:AddTransitionToState(LoginModuleEvent.OnDisconnected, BackToMainState)
  NRCLoginSelectionState:AddAction(DoCmdAction("StartWorldRendering", {
    Cmd = LoginModuleCmd.OverwriteWorldVisibility,
    bDoAndContinue = true,
    Arguments = {false}
  }))
  NRCLoginSelectionState:AddAction(DoCmdAction("CloseVideoUI", {
    Cmd = UpdateUIModuleCmd.OpenMainPanel,
    DoAfterFinish = 0.5,
    Arguments = {false},
    bDoAndContinue = true
  }))
  NRCLoginSelectionState:AddAction(StartChildrenFsmAction("NRCLoginFsm", {ChildrenFsm = NRCLoginFsm}))
  NRCLoginSelectionState:AddTransitionToState(LoginModuleEvent.EnterLoginEndVideoFemale, NRCLoginEndFemaleMovieState)
  NRCLoginSelectionState:AddTransitionToState(LoginModuleEvent.EnterLoginEndVideoMale, NRCLoginEndMaleMovieState)
  NRCLoginSelectionState:AddTransitionToState(LoginModuleEvent.OnDisconnected, BackToMainState)
  NRCLoginEndMaleMovieState:AddAction(DoCmdAction("OpenVideoUI", {
    Cmd = UpdateUIModuleCmd.OpenMainPanel,
    Arguments = {true},
    FinishEvent = LoginModuleEvent.UIOpened
  }))
  NRCLoginEndMaleMovieState:AddAction(PlayVideoAction("PlayEndLoginVideo", {
    path = UEPath.LOGIN_END_MALE,
    EndEvent = LoginModuleEvent.OnEndMovieComplete,
    bLoop = false,
    bFinishOnVideoEnd = true,
    bAutoFadeOut = true
  }))
  NRCLoginEndMaleMovieState:AddAction(DoCmdAction("EnterLoading", {
    Cmd = LoadingUIModuleCmd.OpenLoadingUI,
    Arguments = {
      LuaText.Loading,
      0.1
    },
    bDoAndContinue = true
  }))
  NRCLoginEndMaleMovieState:AddTransitionToState(FINISHED, NRCLoginEndState)
  NRCLoginEndMaleMovieState:AddTransitionToState(LoginModuleEvent.OnDisconnected, BackToMainState)
  NRCLoginEndFemaleMovieState:AddAction(DoCmdAction("OpenVideoUI", {
    Cmd = UpdateUIModuleCmd.OpenMainPanel,
    Arguments = {true},
    FinishEvent = LoginModuleEvent.UIOpened
  }))
  NRCLoginEndFemaleMovieState:AddAction(PlayVideoAction("PlayEndLoginVideo", {
    path = UEPath.LOGIN_END_FEMALE,
    EndEvent = LoginModuleEvent.OnEndMovieComplete,
    bLoop = false,
    bFinishOnVideoEnd = true,
    bAutoFadeOut = true
  }))
  NRCLoginEndFemaleMovieState:AddAction(DoCmdAction("EnterLoading", {
    Cmd = LoadingUIModuleCmd.OpenLoadingUI,
    Arguments = {
      LuaText.Loading,
      0.1
    },
    bDoAndContinue = true
  }))
  NRCLoginEndFemaleMovieState:AddTransitionToState(FINISHED, NRCLoginEndState)
  NRCLoginEndFemaleMovieState:AddTransitionToState(LoginModuleEvent.OnDisconnected, BackToMainState)
  NRCLoginEndState:AddAction(EndLoginAction("EndLoginAction"))
  NRCLoginState:AddTransitionToState(LoginModuleEvent.AccountSwitch, WeGameRestoreState)
  NRCLoginState:AddTransitionToState(LoginModuleEvent.OnDisconnected, BackToMainState)
  ExitState:AddAction(DoCmdAction("CloseApp", {
    Cmd = UpdateUIModuleCmd.CloseApp
  }))
  LoginFsm:SetInitState(PrologueState)
  return LoginFsm
end

return CreateFsm
