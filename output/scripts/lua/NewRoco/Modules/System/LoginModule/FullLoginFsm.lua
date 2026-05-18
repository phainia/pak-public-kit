local Fsm = require("NewRoco.Modules.Core.Fsm.Fsm")
local LoginModuleEvent = require("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local LoginEnum = require("NewRoco.Modes.LoginMode.LoginEnum")
local LoginUtils = require("NewRoco.Modules.System.LoginModule.LoginUtils")
local StartChildrenFsmAction = require("NewRoco.Modes.LoginMode.Actions.StartChildrenFsmAction")
local PlayVideoAction = require("NewRoco.Modules.System.LoginModule.Actions.PlayVideoAction")
local NRCLoginFsmImplementation = require("NewRoco.Modules.System.LoginModule.LoginFsm")
local SendEventToFsmAction = require("NewRoco.Modes.LoginMode.Actions.SendEventAction")
local MSDKLoginFsmImplementation = require("NewRoco.Modules.System.LoginModule.MSDKLoginFsm")
local ShowPanelAction = require("NewRoco.Modules.System.LoginModule.Actions.ShowPanelAction")
local CheckConditionAction = require("NewRoco.Modules.System.LoginModule.Actions.CheckConditionAction")
local DoCmdAction = require("NewRoco.Modules.System.LoginModule.Actions.DoCmdAction")
local SwitchLevelAction = require("NewRoco.Modules.System.LoginModule.Actions.SwitchLevelAction")
local PopWindowAction = require("NewRoco.Modules.System.LoginModule.Actions.PopWindowAction")
local EndLoginAction = require("NewRoco.Modes.LoginMode.Actions.EndLoginAction")
local LoadLoginNoticeAction = require("NewRoco.Modules.System.LoginModule.Actions.LoadLoginNoticeAction")
local ChangeToDimoPlaySceneAction = require("NewRoco.Modules.System.LoginModule.Actions.ChangeToDimoPlaySceneAction")
local UpdateStageLocalText = require("NewRoco.Modules.System.UpdateUIModule.UpdateStageLocalText")
local FINISHED = "FINISHED"

local function InstantiateFullLoginFsm()
  local LoginFsm = Fsm("LoginFsm")
  LoginUtils.InstantiateMSDKLoginObserver()
  LoginUtils.InstantiateMSDKNoticeObserver()
  
  function LoginFsm.OnConnected(event, errorCode)
    Log.Warning("LoginFsm OnConnected:", event, errorCode)
  end
  
  NRCEventCenter:UnRegisterEvent(LoginFsm, _G.NRCGlobalEvent.ON_CONNECTED, LoginFsm.OnConnected)
  local PrologueState = LoginFsm:CreateSequentialState(LoginEnum.StateNames.PrologueState)
  local DeviceWarningState = LoginFsm:CreateSequentialState(LoginEnum.StateNames.DeviceWarningState)
  local MSDKState = LoginFsm:CreateComposedState(LoginEnum.StateNames.MSDKState)
  local LoadingState = LoginFsm:CreateSequentialState(LoginEnum.StateNames.LoadingState)
  local DownloadDirectlyPreProcessingState = LoginFsm:CreateSequentialState(LoginEnum.StateNames.DownloadDirectlyPreProcessingState)
  local NRCLoginState = LoginFsm:CreateComposedState(LoginEnum.StateNames.NRCLoginState)
  local RestoreState = LoginFsm:CreateSequentialState(LoginEnum.StateNames.RestoreState)
  local ExitGameState = LoginFsm:CreateSequentialState(LoginEnum.StateNames.ExitGameState)
  local AgreementStatusCheckState = LoginFsm:CreateComposedState(LoginEnum.StateNames.AgreementStatusCheckState)
  local NRCLoginFsm = LoginUtils.CreateChildrenFsm(LoginFsm, "NRCLoginFsm")
  LoginFsm.NRCLoginFsm = NRCLoginFsm
  NRCLoginFsmImplementation(NRCLoginFsm)
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
  PrologueState:AddAction(DoCmdAction("HideBackPanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.AccountSwitchPanel,
      false,
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
  PrologueState:AddAction(DoCmdAction("HideExitGamePanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.ExitGamePanel,
      false,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  PrologueState:AddTransitionToState(FINISHED, DeviceWarningState)
  DeviceWarningState:AddAction(DoCmdAction("CheckNeedNoticeUpgradeDriverVersion", {
    Cmd = LoginModuleCmd.CheckNeedNoticeUpgradeDriverVersion,
    bDoAndContinue = false
  }))
  DeviceWarningState:AddTransitionToState(LoginModuleEvent.DeviceCheckPassed, MSDKState)
  local MSDKAutoLoginState = MSDKState:CreateChildSequentialState(LoginEnum.StateNames.MSDKAutoLoginState)
  local MSDKPlatformSelectionState = MSDKState:CreateChildSequentialState(LoginEnum.StateNames.MSDKPlatformSelectionState)
  local MSDKLoginFailState = MSDKState:CreateChildSequentialState(LoginEnum.StateNames.MSDKLoginFailState)
  local MSDKQQVerificationState = MSDKState:CreateChildSequentialState(LoginEnum.StateNames.MSDKQQVerificationState)
  local MSDKVXVerificationState = MSDKState:CreateChildSequentialState(LoginEnum.StateNames.MSDKVXVerificationState)
  local QQChosenPreAgreementState = MSDKState:CreateChildSequentialState(LoginEnum.StateNames.QQChosenPreAgreementState)
  local VXChosenPreAgreementState = MSDKState:CreateChildSequentialState(LoginEnum.StateNames.VXChosenPreAgreementState)
  local MSDKQQLoginSuccessState = MSDKState:CreateChildSequentialState(LoginEnum.StateNames.MSDKQQLoginSuccessState)
  local MSDKVXLoginSuccessState = MSDKState:CreateChildSequentialState(LoginEnum.StateNames.MSDKVXLoginSuccessState)
  local MSDKGeneralLoginSuccessState = MSDKState:CreateChildSequentialState(LoginEnum.StateNames.MSDKGeneralLoginSuccessState)
  local MSDKQQLogoutState = MSDKState:CreateChildSequentialState(LoginEnum.StateNames.MSDKQQLogoutState)
  local MSDKVXLogoutState = MSDKState:CreateChildSequentialState(LoginEnum.StateNames.MSDKVXLogoutState)
  local MSDKRestoreState = MSDKState:CreateChildSequentialState(LoginEnum.StateNames.MSDKRestoreState)
  local MSDKAgreementState = MSDKState:CreateChildSequentialState(LoginEnum.StateNames.MSDKAgreementState)
  local MSDKAgreementReconfirmState = MSDKState:CreateChildSequentialState(LoginEnum.StateNames.MSDKAgreementReconfirmState)
  local MSDKEndState = MSDKState:CreateChildSequentialState(LoginEnum.StateNames.MSDKEndState)
  local MSDKFakeState = MSDKState:CreateChildSequentialState(LoginEnum.StateNames.MSDKFakeState)
  MSDKAutoLoginState:AddAction(CheckConditionAction("CheckIsOnPC", {
    Condition = LoginEnum.Conditions.IsOnPc,
    Success = FINISHED
  }))
  MSDKAutoLoginState:AddAction(CheckConditionAction("CheckSkipMSDK", {
    Condition = LoginEnum.Conditions.SkipMSDK,
    Success = FINISHED
  }))
  if _G.GlobalConfig.UserKickedOutFromGame then
    MSDKAutoLoginState:AddAction(CheckConditionAction("JustGotoLogOut", {
      Condition = LoginEnum.Conditions.IsKickedOut,
      Success = LoginModuleEvent.AccountSwitch,
      Fail = LoginModuleEvent.AccountSwitch
    }))
    _G.GlobalConfig.UserKickedOutFromGame = false
  end
  MSDKAutoLoginState:AddAction(DoCmdAction("HideAccountPanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.AccountPanel,
      false,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  MSDKAutoLoginState:AddAction(DoCmdAction("TryAutoLogin", {
    Cmd = LoginModuleCmd.TryAutoLogin,
    bDoAndContinue = false,
    Timeout = 5
  }))
  MSDKAutoLoginState:AddTransitionToState(LoginModuleEvent.LoginSuccess, MSDKGeneralLoginSuccessState)
  MSDKAutoLoginState:AddTransitionToState(LoginModuleEvent.LoginFail, MSDKPlatformSelectionState)
  MSDKAutoLoginState:AddTransitionToState(FINISHED, MSDKPlatformSelectionState)
  MSDKRestoreState:AddAction(DoCmdAction("ShowAccountPanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.AccountPanel,
      true,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  MSDKRestoreState:AddAction(DoCmdAction("HideDownloadPanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.DownloadPanel,
      false,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  MSDKRestoreState:AddAction(DoCmdAction("HideLoginPanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.NRCLoginPanel,
      false,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  MSDKRestoreState:AddAction(DoCmdAction("HideBackPanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.AccountSwitchPanel,
      false,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  MSDKRestoreState:AddAction(DoCmdAction("HideAnnouncementPanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.AnnouncementPanel,
      false,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  MSDKRestoreState:AddAction(DoCmdAction("HideRepairToolsPanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.RepairToolsPanel,
      false,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  MSDKRestoreState:AddAction(DoCmdAction("HideCustomerServicePanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.CustomerServicePanel,
      false,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  MSDKRestoreState:AddAction(DoCmdAction("HideExitGamePanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.ExitGamePanel,
      false,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  MSDKRestoreState:AddAction(ShowPanelAction("HideAccountInfo", {
    PanelName = LoginEnum.PanelNames.AccountInfo,
    TurnOn = false,
    bKeepInBigWorld = true
  }))
  MSDKRestoreState:AddAction(CheckConditionAction("CheckIsQQ", {
    Condition = LoginEnum.Conditions.LoginChannel,
    ExpectedConditionValue = LoginEnum.ChannelNames.QQ,
    Success = LoginModuleEvent.QQLoginChosen
  }))
  MSDKRestoreState:AddAction(CheckConditionAction("CheckIsWX", {
    Condition = LoginEnum.Conditions.LoginChannel,
    ExpectedConditionValue = LoginEnum.ChannelNames.WeChat,
    Success = LoginModuleEvent.VXLoginChosen
  }))
  MSDKRestoreState:AddTransitionToState(FINISHED, MSDKAutoLoginState)
  MSDKRestoreState:AddTransitionToState(LoginModuleEvent.QQLoginChosen, MSDKQQLogoutState)
  MSDKRestoreState:AddTransitionToState(LoginModuleEvent.VXLoginChosen, MSDKVXLogoutState)
  MSDKQQLogoutState:AddAction(DoCmdAction("LogOutQQ", {
    Cmd = LoginModuleCmd.StartQQLogin,
    Arguments = {false},
    bDoAndContinue = true
  }))
  MSDKQQLogoutState:AddTransitionToState(FINISHED, MSDKPlatformSelectionState)
  MSDKVXLogoutState:AddAction(DoCmdAction("LogOutWX", {
    Cmd = LoginModuleCmd.StartVXLogin,
    Arguments = {false},
    bDoAndContinue = true
  }))
  MSDKVXLogoutState:AddTransitionToState(FINISHED, MSDKPlatformSelectionState)
  MSDKPlatformSelectionState:AddAction(CheckConditionAction("CheckSkipMSDK", {
    Condition = LoginEnum.Conditions.SkipMSDK,
    Success = FINISHED
  }))
  MSDKPlatformSelectionState:AddAction(DoCmdAction("ResetDownloadBasePaksWithoutLoginFlag", {
    Cmd = LoginModuleCmd.ResetDownloadBasePaksWithoutLoginFlag,
    bDoAndContinue = true
  }))
  MSDKPlatformSelectionState:AddAction(DoCmdAction("ShowCompliancePanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.CompliancePanel,
      true,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  MSDKPlatformSelectionState:AddAction(DoCmdAction("HideNameInputAndServer", {
    Cmd = LoginModuleCmd.ShowUserNameAndServer,
    Arguments = {false},
    bDoAndContinue = true
  }))
  MSDKPlatformSelectionState:AddAction(DoCmdAction("ShowPlatformButtons", {
    Cmd = LoginModuleCmd.ShowPlatformChoices
  }))
  MSDKPlatformSelectionState:AddTransitionToState(FINISHED, MSDKFakeState)
  MSDKPlatformSelectionState:AddTransitionToState(LoginModuleEvent.QQLoginChosen, QQChosenPreAgreementState)
  MSDKPlatformSelectionState:AddTransitionToState(LoginModuleEvent.VXLoginChosen, VXChosenPreAgreementState)
  MSDKPlatformSelectionState:AddTransitionToState(LoginModuleEvent.LoginSuccess, MSDKGeneralLoginSuccessState)
  QQChosenPreAgreementState:AddAction(DoCmdAction("SaveChosenQQChannel", {
    Cmd = LoginModuleCmd.SetConditionInData,
    bDoAndContinue = true,
    Arguments = {
      LoginEnum.Conditions.ChosenChannelBtn,
      LoginEnum.ChannelNames.QQ
    }
  }))
  QQChosenPreAgreementState:AddTransitionToState(FINISHED, AgreementStatusCheckState)
  VXChosenPreAgreementState:AddAction(DoCmdAction("SaveChosenVXChannel", {
    Cmd = LoginModuleCmd.SetConditionInData,
    bDoAndContinue = true,
    Arguments = {
      LoginEnum.Conditions.ChosenChannelBtn,
      LoginEnum.ChannelNames.WeChat
    }
  }))
  VXChosenPreAgreementState:AddTransitionToState(FINISHED, AgreementStatusCheckState)
  MSDKQQVerificationState:AddAction(DoCmdAction("StartMSDKVerification", {
    Arguments = {true},
    Cmd = LoginModuleCmd.StartQQLogin
  }))
  MSDKQQVerificationState:AddTransitionToState(LoginModuleEvent.LoginSuccess, MSDKQQLoginSuccessState)
  MSDKQQVerificationState:AddTransitionToState(LoginModuleEvent.LoginFail, MSDKLoginFailState)
  MSDKQQVerificationState:AddTransitionToState(FINISHED, MSDKLoginFailState)
  MSDKVXVerificationState:AddAction(DoCmdAction("StartMSDKVerification", {
    Arguments = {true},
    Cmd = LoginModuleCmd.StartVXLogin
  }))
  MSDKVXVerificationState:AddTransitionToState(LoginModuleEvent.LoginSuccess, MSDKVXLoginSuccessState)
  MSDKVXVerificationState:AddTransitionToState(LoginModuleEvent.LoginFail, MSDKLoginFailState)
  MSDKVXVerificationState:AddTransitionToState(FINISHED, MSDKLoginFailState)
  MSDKLoginFailState:AddAction(DoCmdAction("ShowLoginFailNotify", {
    Cmd = LoginModuleCmd.ShowBanner,
    bDoAndContinue = true,
    Arguments = {
      LuaText.fullloginfsm_2
    }
  }))
  MSDKLoginFailState:AddAction(DoCmdAction("CloseWaitingUI", {
    Cmd = LoginModuleCmd.CloseLoginWaitingUI,
    bDoAndContinue = true
  }))
  MSDKLoginFailState:AddTransitionToState(FINISHED, MSDKPlatformSelectionState)
  MSDKQQLoginSuccessState:AddAction(DoCmdAction("SaveChannel", {
    Cmd = LoginModuleCmd.OverwriteAndSaveCondition,
    bDoAndContinue = true,
    Arguments = {
      LoginEnum.Conditions.LoginChannel,
      LoginEnum.ChannelNames.QQ
    }
  }))
  MSDKQQLoginSuccessState:AddTransitionToState(FINISHED, MSDKGeneralLoginSuccessState)
  MSDKVXLoginSuccessState:AddAction(DoCmdAction("SaveChannel", {
    Cmd = LoginModuleCmd.OverwriteAndSaveCondition,
    bDoAndContinue = true,
    Arguments = {
      LoginEnum.Conditions.LoginChannel,
      LoginEnum.ChannelNames.WeChat
    }
  }))
  MSDKVXLoginSuccessState:AddTransitionToState(FINISHED, MSDKGeneralLoginSuccessState)
  MSDKGeneralLoginSuccessState:AddAction(DoCmdAction("HideNameInputAndServer", {
    Cmd = LoginModuleCmd.ShowUserNameAndServer,
    Arguments = {false},
    bDoAndContinue = true
  }))
  MSDKGeneralLoginSuccessState:AddAction(DoCmdAction("CloseWaitingUI", {
    Cmd = LoginModuleCmd.CloseLoginWaitingUI,
    bDoAndContinue = true
  }))
  MSDKGeneralLoginSuccessState:AddTransitionToState(FINISHED, MSDKEndState)
  MSDKFakeState:AddAction(DoCmdAction("SetLauncherOpenId", {
    Cmd = LoginModuleCmd.SetLauncherOpenId,
    bDoAndContinue = true
  }))
  MSDKFakeState:AddAction(DoCmdAction("LogOutGameServer", {
    Cmd = OnlineModuleCmd.Logout,
    bDoAndContinue = true
  }))
  MSDKFakeState:AddTransitionToState(FINISHED, MSDKEndState)
  MSDKEndState:AddAction(DoCmdAction("UpdateServerList", {
    Cmd = LoginModuleCmd.RefreshServerList,
    bDoAndContinue = false,
    FinishEvent = LoginModuleEvent.OnServerListUpdated
  }))
  MSDKEndState:AddAction(DoCmdAction("CheckIfShowDownloadResBtn", {
    Cmd = LoginModuleCmd.CheckIfShowDownloadResBtn,
    bDoAndContinue = true
  }))
  MSDKState:AddTransitionToState(FINISHED, LoadingState)
  MSDKState:AddTransitionToState(LoginModuleEvent.AccountSwitch, MSDKRestoreState)
  local AgreementPopupState = AgreementStatusCheckState:CreateChildSequentialState(LoginEnum.StateNames.AgreementPopupState)
  local AgreementConfirmState = AgreementStatusCheckState:CreateChildSequentialState(LoginEnum.StateNames.AgreementConfirmState)
  local AgreementCancelState = AgreementStatusCheckState:CreateChildSequentialState(LoginEnum.StateNames.AgreementCancelState)
  AgreementPopupState:AddTransitionToState(LoginModuleEvent.PopUpWindowConfirm, AgreementConfirmState)
  AgreementPopupState:AddTransitionToState(LoginModuleEvent.PopUpWindowCancel, AgreementCancelState)
  AgreementPopupState:AddTransitionToState(FINISHED, AgreementCancelState)
  AgreementCancelState:AddTransitionToState(FINISHED, MSDKPlatformSelectionState)
  AgreementCancelState:AddAction(DoCmdAction("SaveChosenQQChannel", {
    Cmd = LoginModuleCmd.SetConditionInData,
    bDoAndContinue = true,
    Arguments = {
      LoginEnum.Conditions.ChosenChannelBtn,
      ""
    }
  }))
  AgreementPopupState:AddAction(DoCmdAction("PopupAgreement", {
    Cmd = LoginModuleCmd.ShowAgreement,
    bDoAndContinue = false
  }))
  AgreementConfirmState:AddAction(CheckConditionAction("CheckIfQQChosen", {
    Condition = LoginEnum.Conditions.ChosenChannelBtn,
    ExpectedConditionValue = LoginEnum.ChannelNames.QQ,
    Success = LoginModuleEvent.QQLoginChosen
  }))
  AgreementConfirmState:AddAction(CheckConditionAction("CheckIfQQChosen", {
    Condition = LoginEnum.Conditions.ChosenChannelBtn,
    ExpectedConditionValue = LoginEnum.ChannelNames.WeChat,
    Success = LoginModuleEvent.VXLoginChosen
  }))
  AgreementConfirmState:AddTransitionToState(LoginModuleEvent.QQLoginChosen, MSDKQQVerificationState)
  AgreementConfirmState:AddTransitionToState(LoginModuleEvent.VXLoginChosen, MSDKVXVerificationState)
  RestoreState:AddAction(ShowPanelAction("OpenMainLoginUI", {
    PanelName = LoginEnum.PanelNames.NRCLoginPanel,
    TurnOn = false
  }))
  RestoreState:AddAction(StartChildrenFsmAction("NRCLoginFsm", {ChildrenFsm = NRCLoginFsm, TurnOff = true}))
  RestoreState:AddAction(DoCmdAction("LogOutQQ", {
    Cmd = LoginModuleCmd.StartQQLogin,
    Arguments = {false},
    bDoAndContinue = true
  }))
  RestoreState:AddAction(DoCmdAction("LogOutWX", {
    Cmd = LoginModuleCmd.StartVXLogin,
    Arguments = {false},
    bDoAndContinue = true
  }))
  RestoreState:AddAction(ShowPanelAction("HideAccountInfo", {
    PanelName = LoginEnum.PanelNames.AccountInfo,
    TurnOn = false,
    bKeepInBigWorld = true
  }))
  RestoreState:AddTransitionToState(FINISHED, PrologueState)
  LoadingState:AddAction(DoCmdAction("HideCanDownloadPanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.CanDownloadPanel,
      false,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  LoadingState:AddAction(DoCmdAction("ShowUserName", {
    Cmd = LoginModuleCmd.RefreshUserName,
    bDoAndContinue = true
  }))
  LoadingState:AddAction(DoCmdAction("HidePlatformButtons", {
    Cmd = LoginModuleCmd.HidePlatformChoices,
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  LoadingState:AddAction(DoCmdAction("ShowAccountSwitchPanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.AccountSwitchPanel,
      true,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  LoadingState:AddAction(DoCmdAction("ShowAnnouncementPanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.AnnouncementPanel,
      true,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  LoadingState:AddAction(DoCmdAction("ShowRepairToolsPanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.RepairToolsPanel,
      true,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  LoadingState:AddAction(DoCmdAction("ShowCustomerServicePanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.CustomerServicePanel,
      true,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  LoadingState:AddAction(ShowPanelAction("ShowAccountInfo", {
    PanelName = LoginEnum.PanelNames.AccountInfo,
    TurnOn = true,
    bKeepInBigWorld = true
  }))
  LoadingState:AddAction(CheckConditionAction("CheckIfDownloadBasePaksWithoutLogin", {
    Condition = LoginEnum.Conditions.IfDownloadBasePaksWithoutLogin,
    Success = LoginModuleEvent.DownloadBasePaksWithoutLogin
  }))
  LoadingState:AddAction(DoCmdAction("ShowAccountPanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.AccountPanel,
      true,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  LoadingState:AddAction(DoCmdAction("ShowCompliancePanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.CompliancePanel,
      true,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  LoadingState:AddAction(DoCmdAction("ShowLoginSuccessNotify", {
    Cmd = LoginModuleCmd.ShowBanner,
    bDoAndContinue = true,
    Arguments = {
      LuaText.fullloginfsm_3
    }
  }))
  LoadingState:AddTransitionToState(FINISHED, NRCLoginState)
  LoadingState:AddTransitionToState(LoginModuleEvent.AccountSwitch, MSDKRestoreState)
  LoadingState:AddTransitionToState(LoginModuleEvent.DownloadBasePaksWithoutLogin, DownloadDirectlyPreProcessingState)
  local NRCLoginVideoState = NRCLoginState:CreateChildSequentialState(LoginEnum.StateNames.NRCLoginVideoState)
  local NRCLoginNoticeState = NRCLoginState:CreateChildSequentialState(LoginEnum.StateNames.NRCLoginNoticeState)
  local NRCLoginUpdateState = NRCLoginState:CreateChildComposedState(LoginEnum.StateNames.UpdateState)
  local NRCUpdateFailedState = NRCLoginState:CreateChildBurstState(LoginEnum.StateNames.UpdateFailedState)
  local NRCCharacterSelectionVideoState = NRCLoginState:CreateChildBurstState(LoginEnum.StateNames.NRCCharacterSelectionVideoState)
  local NRCLoginSelectionState = NRCLoginState:CreateChildSequentialState(LoginEnum.StateNames.NRCLoginSelectionState)
  local NRCLoginEndMaleMovieState = NRCLoginState:CreateChildBurstState(LoginEnum.StateNames.NRCLoginEndMaleMovieState)
  local NRCLoginEndFemaleMovieState = NRCLoginState:CreateChildBurstState(LoginEnum.StateNames.NRCLoginEndFemaleMovieState)
  local NRCLoginEndState = NRCLoginState:CreateChildSequentialState(LoginEnum.StateNames.NRCLoginEndState)
  DownloadDirectlyPreProcessingState:AddAction(DoCmdAction("HideEnterPanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.NRCEnterPanel,
      false,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  DownloadDirectlyPreProcessingState:AddAction(DoCmdAction("HideCompliancePanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.CompliancePanel,
      false,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  DownloadDirectlyPreProcessingState:AddAction(DoCmdAction("HideAccountPanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.AccountPanel,
      false,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  DownloadDirectlyPreProcessingState:AddAction(DoCmdAction("ResetDownloadBasePaksWithoutLoginFlag", {
    Cmd = LoginModuleCmd.ResetDownloadBasePaksWithoutLoginFlag,
    bDoAndContinue = true
  }))
  DownloadDirectlyPreProcessingState:AddTransitionToState(FINISHED, NRCLoginUpdateState)
  NRCLoginVideoState:AddAction(DoCmdAction("HideUpdateRepairToolsPanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.UpdateRepairToolsPanel,
      false,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  NRCLoginVideoState:AddAction(DoCmdAction("HideUpdatePanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.UpdateProgressPanel,
      false,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  NRCLoginVideoState:AddAction(DoCmdAction("HideEnterPanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.NRCEnterPanel,
      false,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
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
  NRCLoginVideoState:AddAction(DoCmdAction("ShowCompliancePanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.CompliancePanel,
      true,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  NRCLoginVideoState:AddTransitionToState(LoginModuleEvent.CheckIfDownloadBaseResAfterLogin, NRCLoginUpdateState)
  NRCLoginVideoState:AddTransitionToState(LoginModuleEvent.PlayerExist, NRCLoginEndState)
  NRCLoginVideoState:AddTransitionToState(LoginModuleEvent.OnDisconnected, RestoreState)
  NRCLoginVideoState:AddTransitionToState(LoginModuleEvent.PlayerNotExist, NRCCharacterSelectionVideoState)
  NRCLoginVideoState:AddTransitionToState(FINISHED, NRCLoginNoticeState)
  NRCLoginNoticeState:AddAction(LoadLoginNoticeAction("LoadLoginNoticeAction"))
  NRCLoginNoticeState:AddTransitionToState(LoginModuleEvent.CheckIfDownloadBaseResAfterLogin, NRCLoginUpdateState)
  NRCLoginNoticeState:AddTransitionToState(LoginModuleEvent.PlayerExist, NRCLoginEndState)
  NRCLoginNoticeState:AddTransitionToState(LoginModuleEvent.OnDisconnected, RestoreState)
  NRCLoginNoticeState:AddTransitionToState(LoginModuleEvent.PlayerNotExist, NRCCharacterSelectionVideoState)
  NRCUpdateFailedState:AddAction(DoCmdAction("PopupErrorTipsDialog", {
    Cmd = UpdateUIModuleCmd.PopupErrorTipsDialog
  }))
  NRCUpdateFailedState:AddTransitionToState(LoginModuleEvent.RetryUpdate, NRCLoginUpdateState)
  NRCUpdateFailedState:AddTransitionToState(LoginModuleEvent.BackToSDKLoginSuccess, NRCLoginState)
  local NRCCheckDownloadBaseResState = NRCLoginUpdateState:CreateChildBurstState(LoginEnum.StateNames.NRCCheckDownloadBaseResState)
  local NRCDownloadBaseResState = NRCLoginUpdateState:CreateChildBurstState(LoginEnum.StateNames.NRCDownloadBaseResState)
  local NRCDownloadBaseResEndState = NRCLoginUpdateState:CreateChildBurstState(LoginEnum.StateNames.NRCDownloadBaseResEndState)
  local MountDownloadedPakState = NRCLoginUpdateState:CreateChildBurstState(LoginEnum.StateNames.MountDownloadedPakState)
  local CheckIfShowEnterBtnState = NRCLoginUpdateState:CreateChildBurstState(LoginEnum.StateNames.CheckIfShowEnterBtnState)
  local EnterWorldWithoutDownloadResState = NRCLoginUpdateState:CreateChildBurstState(LoginEnum.StateNames.EnterWorldWithoutDownloadResState)
  local PufferNoWifiNoticeState = NRCLoginUpdateState:CreateChildBurstState(LoginEnum.StateNames.PufferNoWifiNoticeState)
  local PufferContinueDownloadState = NRCLoginUpdateState:CreateChildBurstState(LoginEnum.StateNames.PufferContinueDownloadState)
  local UpdateDisconnectState = NRCLoginUpdateState:CreateChildBurstState(LoginEnum.StateNames.UpdateDisconnectState)
  NRCLoginUpdateState:AddTransitionToState(LoginModuleEvent.UpdateError, NRCUpdateFailedState)
  NRCLoginUpdateState:AddTransitionToState(LoginModuleEvent.RetryUpdate, NRCLoginUpdateState)
  NRCLoginUpdateState:AddTransitionToState(LoginModuleEvent.OnDisconnected, UpdateDisconnectState)
  NRCLoginUpdateState:AddTransitionToState(LoginModuleEvent.BackToSDKLoginSuccess, NRCLoginState)
  UpdateDisconnectState:AddAction(DoCmdAction("CancelUpdates", {
    Cmd = LoginModuleCmd.CancelUpdates,
    bDoAndContinue = true
  }))
  UpdateDisconnectState:AddTransitionToState(FINISHED, RestoreState)
  NRCCheckDownloadBaseResState:AddAction(CheckConditionAction("SkipUpdateOnLocalBuild", {
    Condition = LoginEnum.Conditions.IsFullPackage,
    Success = LoginModuleEvent.DelayDownloadBaseRes
  }))
  NRCCheckDownloadBaseResState:AddAction(DoCmdAction("CheckDownloadBaseRes", {
    Cmd = LoginModuleCmd.CheckDownloadBaseRes
  }))
  NRCCheckDownloadBaseResState:AddTransitionToState(LoginModuleEvent.DownloadBaseResAfterLogin, NRCDownloadBaseResState)
  NRCCheckDownloadBaseResState:AddTransitionToState(LoginModuleEvent.NoNeedToDownloadBaseRes, MountDownloadedPakState)
  NRCCheckDownloadBaseResState:AddTransitionToState(LoginModuleEvent.DelayDownloadBaseRes, EnterWorldWithoutDownloadResState)
  NRCDownloadBaseResState:AddAction(DoCmdAction("CheckIfShowNotificationBtn", {
    Cmd = LoginModuleCmd.CheckIfShowNotificationBtn,
    bDoAndContinue = true
  }))
  NRCDownloadBaseResState:AddAction(DoCmdAction("HideLoginPanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.NRCLoginPanel,
      false,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  NRCDownloadBaseResState:AddAction(DoCmdAction("HideEnterButton", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.NRCEnterPanel,
      false,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  NRCDownloadBaseResState:AddAction(DoCmdAction("HideAccountPanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.AccountPanel,
      false,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  NRCDownloadBaseResState:AddAction(DoCmdAction("HideCompliancePanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.CompliancePanel,
      false,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  NRCDownloadBaseResState:AddAction(DoCmdAction("ShowUpdateRepairToolsPanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.UpdateRepairToolsPanel,
      true,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  NRCDownloadBaseResState:AddAction(DoCmdAction("ShowUpdateProgress", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.UpdateProgressPanel,
      true,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  NRCDownloadBaseResState:AddAction(DoCmdAction("SetStartDownloading", {
    Cmd = LoginModuleCmd.SetPanelIsDownloading,
    bDoAndContinue = true,
    Arguments = {true}
  }))
  NRCDownloadBaseResState:AddAction(DoCmdAction("ResetProgressBar", {
    Cmd = LoginModuleCmd.SetProgress,
    bDoAndContinue = true,
    Arguments = {
      0,
      UpdateStageLocalText.PufferBasePaksDownloading
    }
  }))
  NRCDownloadBaseResState:AddAction(DoCmdAction("DownloadBasePak", {
    Cmd = LoginModuleCmd.DownloadBasePak
  }))
  NRCDownloadBaseResState:AddTransitionToState(LoginModuleEvent.BaseResDownloadDone, MountDownloadedPakState)
  NRCDownloadBaseResState:AddTransitionToState(LoginModuleEvent.PufferNoWifi, PufferNoWifiNoticeState)
  PufferNoWifiNoticeState:AddAction(DoCmdAction("PufferOpenNoWifiNoticeDialog", {
    Cmd = LoginModuleCmd.PufferOpenNoWifiNoticeDialog
  }))
  PufferNoWifiNoticeState:AddTransitionToState(LoginModuleEvent.ContinuePufferUpdate, PufferContinueDownloadState)
  PufferContinueDownloadState:AddAction(DoCmdAction("PufferResumeDownload", {
    Cmd = LoginModuleCmd.PufferResumeDownload
  }))
  PufferContinueDownloadState:AddTransitionToState(LoginModuleEvent.PufferNoWifi, PufferNoWifiNoticeState)
  PufferContinueDownloadState:AddTransitionToState(LoginModuleEvent.BaseResDownloadDone, MountDownloadedPakState)
  MountDownloadedPakState:AddAction(DoCmdAction("MountDownloadedPaks", {
    Cmd = LoginModuleCmd.MountDownloadedPaks,
    FinishEvent = LoginModuleEvent.MountDownloadedPakDone
  }))
  MountDownloadedPakState:AddTransitionToState(FINISHED, CheckIfShowEnterBtnState)
  CheckIfShowEnterBtnState:AddAction(DoCmdAction("CheckIfShowEnterBtn", {
    Cmd = LoginModuleCmd.CheckIfShowEnterBtn,
    bDoAndContinue = false,
    FinishEvent = LoginModuleEvent.NotShowEnterBtn
  }))
  CheckIfShowEnterBtnState:AddAction(DoCmdAction("EnterWorld", {
    Cmd = LoginModuleCmd.AutoLoginAndEnterWorld,
    bDoAndContinue = false
  }))
  CheckIfShowEnterBtnState:AddTransitionToState(LoginModuleEvent.ShowEnterBtn, NRCDownloadBaseResEndState)
  CheckIfShowEnterBtnState:AddTransitionToState(LoginModuleEvent.PlayerExist, NRCLoginEndState)
  CheckIfShowEnterBtnState:AddTransitionToState(LoginModuleEvent.PlayerNotExist, NRCCharacterSelectionVideoState)
  CheckIfShowEnterBtnState:AddTransitionToState(LoginModuleEvent.OnDisconnected, RestoreState)
  EnterWorldWithoutDownloadResState:AddAction(DoCmdAction("AutoLoginAndEnterWorld", {
    Cmd = LoginModuleCmd.AutoLoginAndEnterWorld,
    bDoAndContinue = false
  }))
  EnterWorldWithoutDownloadResState:AddTransitionToState(LoginModuleEvent.PlayerExist, NRCLoginEndState)
  EnterWorldWithoutDownloadResState:AddTransitionToState(LoginModuleEvent.PlayerNotExist, NRCCharacterSelectionVideoState)
  EnterWorldWithoutDownloadResState:AddTransitionToState(LoginModuleEvent.OnDisconnected, RestoreState)
  NRCDownloadBaseResEndState:AddAction(DoCmdAction("HideUpdateProgress", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.UpdateProgressPanel,
      false,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  NRCDownloadBaseResEndState:AddAction(DoCmdAction("SetEndDownloading", {
    Cmd = LoginModuleCmd.SetPanelIsDownloading,
    bDoAndContinue = true,
    Arguments = {false}
  }))
  NRCDownloadBaseResEndState:AddAction(DoCmdAction("ShowAccountPanel", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.AccountPanel,
      true,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  NRCDownloadBaseResEndState:AddAction(DoCmdAction("CheckIfShowDownloadResBtn", {
    Cmd = LoginModuleCmd.CheckIfShowDownloadResBtn,
    bDoAndContinue = true
  }))
  NRCDownloadBaseResEndState:AddAction(DoCmdAction("ShowEnterButton", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.NRCLoginPanel,
      true,
      LoginModuleEvent.UIAnimationDone
    },
    FinishEvent = LoginModuleEvent.UIAnimationDone
  }))
  NRCDownloadBaseResEndState:AddTransitionToState(FINISHED, NRCLoginNoticeState)
  NRCDownloadBaseResEndState:AddTransitionToState(LoginModuleEvent.PlayerExist, NRCLoginEndState)
  NRCDownloadBaseResEndState:AddTransitionToState(LoginModuleEvent.PlayerNotExist, NRCCharacterSelectionVideoState)
  NRCDownloadBaseResEndState:AddTransitionToState(LoginModuleEvent.OnDisconnected, RestoreState)
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
  NRCCharacterSelectionVideoState:AddAction(DoCmdAction("HideEnterButton", {
    Cmd = LoginModuleCmd.ShowCanvas,
    bDoAndContinue = false,
    Arguments = {
      LoginEnum.CanvasNames.NRCEnterPanel,
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
  NRCCharacterSelectionVideoState:AddAction(DoCmdAction("HideCompliancePanel", {
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
  NRCCharacterSelectionVideoState:AddTransitionToState(LoginModuleEvent.OnDisconnected, RestoreState)
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
  NRCLoginSelectionState:AddTransitionToState(LoginModuleEvent.OnDisconnected, RestoreState)
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
  NRCLoginEndMaleMovieState:AddTransitionToState(LoginModuleEvent.OnDisconnected, RestoreState)
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
  NRCLoginEndFemaleMovieState:AddTransitionToState(LoginModuleEvent.OnDisconnected, RestoreState)
  NRCLoginEndState:AddAction(EndLoginAction("EndLoginAction"))
  NRCLoginState:AddTransitionToState(LoginModuleEvent.AccountSwitch, MSDKRestoreState)
  NRCLoginState:AddTransitionToState(LoginModuleEvent.ChangeAccount, MSDKState)
  ExitGameState:AddAction(DoCmdAction("CloseApp", {
    Cmd = UpdateUIModuleCmd.CloseApp
  }))
  LoginFsm:SetInitState(PrologueState)
  return LoginFsm
end

return InstantiateFullLoginFsm
