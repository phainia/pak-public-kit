local Fsm = require("NewRoco.Modules.Core.Fsm.Fsm")
local LoginModuleEvent = require("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local LoginEnum = require("NewRoco.Modes.LoginMode.LoginEnum")
local LoginUtils = require("NewRoco.Modules.System.LoginModule.LoginUtils")
local LoginInitAction = require("NewRoco.Modes.LoginMode.Actions.LoginInitAction")
local PlayVideoAction = require("NewRoco.Modes.LoginMode.Actions.PlayVideoAction")
local PlaySequenceAction = require("NewRoco.Modes.LoginMode.Actions.PlaySequenceAction")
local SendEventToFsmAction = require("NewRoco.Modes.LoginMode.Actions.SendEventAction")
local SwitchUIAction = require("NewRoco.Modes.LoginMode.Actions.SwitchUIAction")
local SwitchSpinAction = require("NewRoco.Modes.LoginMode.Actions.SwitchSpinAction")
local StartChildrenFsmAction = require("NewRoco.Modes.LoginMode.Actions.StartChildrenFsmAction")
local RestoreCameraAction = require("NewRoco.Modes.LoginMode.Actions.RestoreCameraAction")
local SetCharacterAction = require("NewRoco.Modes.LoginMode.Actions.SetCharacterAction")
local EnterNameAction = require("NewRoco.Modes.LoginMode.Actions.EnterNameAction")
local EndLoginAction = require("NewRoco.Modes.LoginMode.Actions.EndLoginAction")
local WaitCameraLerpCompleteAction = require("NewRoco.Modes.LoginMode.Actions.WaitCameraLerpCompleteAction")
local FINISHED = "FINISHED"

local function ImplementSelectionFsm(SelectionFsm)
  local SelectionEntryState = SelectionFsm:CreateBurstState(LoginEnum.StateNames.SelectionEntry)
  local PreSelectionState = SelectionFsm:CreateBurstState(LoginEnum.StateNames.PreSelection)
  local SelectionState = SelectionFsm:CreateSequentialState(LoginEnum.StateNames.Selection)
  local PostSelectionStateFemale = SelectionFsm:CreateSequentialState(LoginEnum.StateNames.PostSelectionFemale)
  local PostSelectionStateMale = SelectionFsm:CreateSequentialState(LoginEnum.StateNames.PostSelectionMale)
  local PostSelectionStateFemaleIdle = SelectionFsm:CreateSequentialState(LoginEnum.StateNames.PostSelectionFemaleIdle)
  local PostSelectionStateMaleIdle = SelectionFsm:CreateSequentialState(LoginEnum.StateNames.PostSelectionMaleIdle)
  local RestoreSelectionStateMale = SelectionFsm:CreateSequentialState(LoginEnum.StateNames.RestoreSelectionStateMale)
  local RestoreSelectionStateFemale = SelectionFsm:CreateSequentialState(LoginEnum.StateNames.RestoreSelectionStateFemale)
  local RestoreSelectionStateIdleFemale = SelectionFsm:CreateSequentialState(LoginEnum.StateNames.RestoreSelectionStateIdleFemale)
  local RestoreSelectionStateIdleMale = SelectionFsm:CreateSequentialState(LoginEnum.StateNames.RestoreSelectionStateIdleMale)
  local EndSelectionState = SelectionFsm:CreateSequentialState(LoginEnum.StateNames.EndSelection)
  local BackFromSelectionState = SelectionFsm:CreateSequentialState(LoginEnum.StateNames.BackFromSelection)
  SelectionEntryState:AddAction(SendEventToFsmAction("CheckGender", {
    GetEventHandler = LoginUtils.GetSelectionEnterStateEvent
  }))
  PreSelectionState:AddAction(SwitchUIAction("HideLoginPanels", {
    Event = LoginModuleEvent.HideLoginPanels
  }))
  PreSelectionState:AddAction(PlaySequenceAction("PlayEnterSequence", {
    path = UEPath.LOGIN_ENTER
  }))
  PreSelectionState:AddAction(SendEventToFsmAction("EnterSelection", {
    Event = LoginModuleEvent.EnterSelection
  }))
  RestoreSelectionStateMale:AddAction(PlaySequenceAction("ReversePlayGenderConfirmEnter", {
    path = UEPath.GENDER_CONFIRM_ENTER_MALE,
    bLoop = false,
    bPlayReverse = true,
    PlayRate = 3.0
  }))
  RestoreSelectionStateMale:AddAction(SendEventToFsmAction("EnterSelection", {
    Event = LoginModuleEvent.EnterSelection
  }))
  RestoreSelectionStateFemale:AddAction(PlaySequenceAction("ReversePlayGenderConfirmEnter", {
    path = UEPath.GENDER_CONFIRM_ENTER_FEMALE,
    bLoop = false,
    bPlayReverse = true,
    PlayRate = 3.0
  }))
  RestoreSelectionStateFemale:AddAction(SendEventToFsmAction("EnterSelection", {
    Event = LoginModuleEvent.EnterSelection
  }))
  SelectionState:AddAction(SetCharacterAction("SetToMaleCharacter", {bIsMale = nil}))
  SelectionState:AddAction(SwitchSpinAction("EnablePlayerSpinControl", {bEnableSpin = true}))
  PostSelectionStateFemale:AddAction(SwitchSpinAction("DisablePlayerSpinControl", {bEnableSpin = false}))
  PostSelectionStateFemale:AddAction(PlaySequenceAction("PlayGenderConfirmEnterSequence", {
    path = UEPath.GENDER_CONFIRM_ENTER_FEMALE,
    PlayRate = 3.0,
    bLoop = false,
    bPlayAndContinue = true
  }))
  PostSelectionStateFemale:AddAction(SendEventToFsmAction("EnterDesign", {
    Event = LoginModuleEvent.EnterSelectionFemaleIdle
  }))
  PostSelectionStateFemaleIdle:AddAction(RestoreCameraAction("RestoreCamera", {bIsMale = false}))
  PostSelectionStateFemaleIdle:AddAction(SwitchUIAction("ShowConfirmPanel", {
    Event = LoginModuleEvent.ShowConfirmPanel
  }))
  PostSelectionStateFemaleIdle:AddAction(SetCharacterAction("SetToFemaleCharacter", {bIsMale = false}))
  PostSelectionStateFemaleIdle:AddAction(PlaySequenceAction("PlayGenderConfirmIdleSequence", {
    path = UEPath.GENDER_CONFIRM_IDLE_FEMALE,
    bLoop = true,
    bFillWithIdle = true,
    endEvent = LoginModuleEvent.EndPostSelectionIdle,
    blockEndEvent = LoginModuleEvent.FemaleCharacterSelected
  }))
  PostSelectionStateMale:AddAction(SwitchSpinAction("DisablePlayerSpinControl", {bEnableSpin = false}))
  PostSelectionStateMale:AddAction(PlaySequenceAction("PlayGenderConfirmEnterSequence", {
    path = UEPath.GENDER_CONFIRM_ENTER_MALE,
    PlayRate = 3.0,
    bLoop = false,
    bPlayAndContinue = true
  }))
  PostSelectionStateMale:AddAction(SendEventToFsmAction("EnterDesign", {
    Event = LoginModuleEvent.EnterSelectionMaleIdle
  }))
  PostSelectionStateMaleIdle:AddAction(RestoreCameraAction("RestoreCamera", {bIsMale = true}))
  PostSelectionStateMaleIdle:AddAction(SwitchUIAction("ShowConfirmPanel", {
    Event = LoginModuleEvent.ShowConfirmPanel
  }))
  PostSelectionStateMaleIdle:AddAction(SetCharacterAction("SetToMaleCharacter", {bIsMale = true}))
  PostSelectionStateMaleIdle:AddAction(PlaySequenceAction("PlayGenderConfirmIdleSequence", {
    path = UEPath.GENDER_CONFIRM_IDLE_MALE,
    bLoop = true,
    bFillWithIdle = true,
    endEvent = LoginModuleEvent.EndPostSelectionIdle,
    blockEndEvent = LoginModuleEvent.MaleCharacterSelected
  }))
  RestoreSelectionStateIdleMale:AddAction(SwitchUIAction("HideConfirmPanels", {
    Event = LoginModuleEvent.HideConfirmPanels
  }))
  RestoreSelectionStateIdleMale:AddAction(PlaySequenceAction("ReversePlayGenderConfirmEnter", {
    path = UEPath.NAME_CONFIRM_ENTER_MALE,
    bLoop = false,
    bPlayReverse = true,
    PlayRate = 4.0
  }))
  RestoreSelectionStateIdleMale:AddAction(SendEventToFsmAction("EnterSelection", {
    Event = LoginModuleEvent.EnterSelectionMaleIdle
  }))
  RestoreSelectionStateIdleFemale:AddAction(SwitchUIAction("HideConfirmPanels", {
    Event = LoginModuleEvent.HideConfirmPanels
  }))
  RestoreSelectionStateIdleFemale:AddAction(PlaySequenceAction("ReversePlayGenderConfirmEnter", {
    path = UEPath.NAME_CONFIRM_ENTER_FEMALE,
    bLoop = false,
    bPlayReverse = true,
    PlayRate = 4.0
  }))
  RestoreSelectionStateIdleFemale:AddAction(SendEventToFsmAction("EnterSelection", {
    Event = LoginModuleEvent.EnterSelectionFemaleIdle
  }))
  EndSelectionState:AddAction(SendEventToFsmAction("EndSelection", {
    Event = LoginModuleEvent.EnterDesign,
    bSendThenFinish = true,
    bToParentFsm = true
  }))
  BackFromSelectionState:AddAction(SendEventToFsmAction("EnterSelection", {
    Event = LoginModuleEvent.OnClickBack,
    bSendThenFinish = true,
    bToParentFsm = true
  }))
  SelectionEntryState:AddTransitionToState(LoginModuleEvent.ContinueToPreselection, PreSelectionState)
  SelectionEntryState:AddTransitionToState(LoginModuleEvent.ContinueToRestoreSelectionFemale, RestoreSelectionStateIdleFemale)
  SelectionEntryState:AddTransitionToState(LoginModuleEvent.ContinueToRestoreSelectionMale, RestoreSelectionStateIdleMale)
  PreSelectionState:AddTransitionToState(LoginModuleEvent.EnterSelection, SelectionState)
  PreSelectionState:AddTransitionToState(LoginModuleEvent.OnClickBack, BackFromSelectionState)
  RestoreSelectionStateMale:AddTransitionToState(LoginModuleEvent.EnterSelection, SelectionState)
  RestoreSelectionStateMale:AddTransitionToState(LoginModuleEvent.OnClickBack, BackFromSelectionState)
  RestoreSelectionStateFemale:AddTransitionToState(LoginModuleEvent.EnterSelection, SelectionState)
  RestoreSelectionStateFemale:AddTransitionToState(LoginModuleEvent.OnClickBack, BackFromSelectionState)
  SelectionState:AddTransitionToState(LoginModuleEvent.MaleCharacterSelected, PostSelectionStateMale)
  SelectionState:AddTransitionToState(LoginModuleEvent.FemaleCharacterSelected, PostSelectionStateFemale)
  SelectionState:AddTransitionToState(LoginModuleEvent.OnClickBack, BackFromSelectionState)
  PostSelectionStateFemale:AddTransitionToState(LoginModuleEvent.EnterSelectionFemaleIdle, PostSelectionStateFemaleIdle)
  PostSelectionStateFemale:AddTransitionToState(LoginModuleEvent.OnClickBack, BackFromSelectionState)
  PostSelectionStateFemaleIdle:AddTransitionToState(LoginModuleEvent.BackToSelection, RestoreSelectionStateFemale)
  PostSelectionStateFemaleIdle:AddTransitionToState(LoginModuleEvent.MaleCharacterSelected, PostSelectionStateMaleIdle)
  PostSelectionStateFemaleIdle:AddTransitionToState(LoginModuleEvent.EnterDesign, EndSelectionState)
  PostSelectionStateFemaleIdle:AddTransitionToState(LoginModuleEvent.OnClickBack, BackFromSelectionState)
  PostSelectionStateMale:AddTransitionToState(LoginModuleEvent.EnterSelectionMaleIdle, PostSelectionStateMaleIdle)
  PostSelectionStateMale:AddTransitionToState(LoginModuleEvent.OnClickBack, BackFromSelectionState)
  PostSelectionStateMaleIdle:AddTransitionToState(LoginModuleEvent.BackToSelection, RestoreSelectionStateMale)
  PostSelectionStateMaleIdle:AddTransitionToState(LoginModuleEvent.FemaleCharacterSelected, PostSelectionStateFemaleIdle)
  PostSelectionStateMaleIdle:AddTransitionToState(LoginModuleEvent.EnterDesign, EndSelectionState)
  PostSelectionStateMaleIdle:AddTransitionToState(LoginModuleEvent.OnClickBack, BackFromSelectionState)
  RestoreSelectionStateIdleMale:AddTransitionToState(LoginModuleEvent.EnterSelectionMaleIdle, PostSelectionStateMaleIdle)
  RestoreSelectionStateIdleMale:AddTransitionToState(LoginModuleEvent.OnClickBack, BackFromSelectionState)
  RestoreSelectionStateIdleFemale:AddTransitionToState(LoginModuleEvent.EnterSelectionFemaleIdle, PostSelectionStateFemaleIdle)
  RestoreSelectionStateIdleFemale:AddTransitionToState(LoginModuleEvent.OnClickBack, BackFromSelectionState)
  SelectionFsm:SetInitState(SelectionEntryState)
end

local function ImplementDesignFsm(DesignFsm)
  local DesignEntryState = DesignFsm:CreateSequentialState(LoginEnum.StateNames.DesignEntry)
  local PlayEnterDesignMaleSequence = DesignFsm:CreateSequentialState(LoginEnum.StateNames.PlayEnterDesignMaleSequence)
  local PlayEnterDesignFemaleSequence = DesignFsm:CreateSequentialState(LoginEnum.StateNames.PlayEnterDesignFemaleSequence)
  local DesignStateMale = DesignFsm:CreateSequentialState(LoginEnum.StateNames.DesignMale)
  local DesignStateFemale = DesignFsm:CreateSequentialState(LoginEnum.StateNames.DesignFemale)
  local DesignConfirmMale = DesignFsm:CreateSequentialState(LoginEnum.StateNames.DesignConfirmMale)
  local DesignConfirmFemale = DesignFsm:CreateSequentialState(LoginEnum.StateNames.DesignConfirmFemale)
  local BackToDesignMale = DesignFsm:CreateSequentialState(LoginEnum.StateNames.BackToDesignMale)
  local BackToDesignFemale = DesignFsm:CreateSequentialState(LoginEnum.StateNames.BackToDesignMale)
  local BackFromDesignState = DesignFsm:CreateSequentialState(LoginEnum.StateNames.BackFromDesign)
  local DesignReconnectState = DesignFsm:CreateSequentialState(LoginEnum.StateNames.DesignReconnect)
  local DesignEndState = DesignFsm:CreateSequentialState(LoginEnum.StateNames.DesignEnd)
  DesignEntryState:AddAction(SendEventToFsmAction("CheckGender", {
    GetEventHandler = LoginUtils.GetGender
  }))
  PlayEnterDesignMaleSequence:AddAction(PlaySequenceAction("PlayNameConfirmEnterSequence", {
    path = UEPath.NAME_CONFIRM_ENTER_MALE,
    bLoop = false
  }))
  PlayEnterDesignMaleSequence:AddAction(SendEventToFsmAction("ToDesignStateMale", {
    Event = LoginModuleEvent.ToDesignStateMale
  }))
  PlayEnterDesignMaleSequence:AddTransitionToState(LoginModuleEvent.ToDesignStateMale, DesignStateMale)
  DesignStateMale:AddAction(EnterNameAction("EnterName", {
    endEvent = LoginModuleEvent.DesignToConfirm
  }))
  DesignStateMale:AddAction(SendEventToFsmAction("DesignToConfirmState", {
    Event = LoginModuleEvent.DesignToConfirmState
  }))
  DesignStateMale:AddTransitionToState(LoginModuleEvent.DesignToConfirmState, DesignConfirmMale)
  DesignConfirmMale:AddAction(PlaySequenceAction("PlayNameConfirmIdleSequence", {
    path = UEPath.NAME_CONFIRM_IDLE_MALE,
    bLoop = false,
    PlayRate = 3.0,
    bFillWithIdle = true,
    endEvent = LoginModuleEvent.EndConfirmState
  }))
  DesignConfirmMale:AddTransitionToState(LoginModuleEvent.ConfirmToDesignState, BackToDesignMale)
  DesignConfirmMale:AddTransitionToState(LoginModuleEvent.PlayEndSequence, DesignEndState)
  BackToDesignMale:AddAction(PlaySequenceAction("PlayBackToDesignSequence", {
    path = UEPath.NAME_CONFIRM_IDLE_MALE,
    bLoop = false,
    PlayRate = 3.0,
    bPlayAndContinue = true,
    bPlayReverse = true
  }))
  BackToDesignMale:AddAction(SendEventToFsmAction("BackToDesign", {
    Event = LoginModuleEvent.BackToDesignState
  }))
  BackToDesignMale:AddTransitionToState(LoginModuleEvent.BackToDesignState, DesignStateMale)
  DesignEndState:AddAction(PlaySequenceAction("PlayNameConfirmEndSequence", {
    path = UEPath.NAME_CONFIRM_END_MALE,
    bLoop = false
  }))
  PlayEnterDesignFemaleSequence:AddAction(PlaySequenceAction("PlayNameConfirmEnterSequence", {
    path = UEPath.NAME_CONFIRM_ENTER_FEMALE,
    bLoop = false
  }))
  PlayEnterDesignFemaleSequence:AddAction(SendEventToFsmAction("ToDesignStateFemale", {
    Event = LoginModuleEvent.ToDesignStateFemale
  }))
  PlayEnterDesignFemaleSequence:AddTransitionToState(LoginModuleEvent.ToDesignStateFemale, DesignStateFemale)
  DesignStateFemale:AddAction(EnterNameAction("EnterName", {
    endEvent = LoginModuleEvent.DesignToConfirm
  }))
  DesignStateFemale:AddAction(SendEventToFsmAction("DesignToConfirmState", {
    Event = LoginModuleEvent.DesignToConfirmState
  }))
  DesignStateFemale:AddTransitionToState(LoginModuleEvent.DesignToConfirmState, DesignConfirmFemale)
  DesignConfirmFemale:AddAction(PlaySequenceAction("PlayNameConfirmIdleSequence", {
    path = UEPath.NAME_CONFIRM_IDLE_FEMALE,
    PlayRate = 3.0,
    bLoop = false,
    bFillWithIdle = true,
    endEvent = LoginModuleEvent.EndConfirmState
  }))
  DesignConfirmFemale:AddTransitionToState(LoginModuleEvent.ConfirmToDesignState, BackToDesignFemale)
  DesignConfirmFemale:AddTransitionToState(LoginModuleEvent.PlayEndSequence, DesignEndState)
  BackToDesignFemale:AddAction(PlaySequenceAction("PlayBackToDesignSequence", {
    path = UEPath.NAME_CONFIRM_IDLE_FEMALE,
    PlayRate = 3.0,
    bLoop = false,
    bPlayAndContinue = true,
    bPlayReverse = true
  }))
  BackToDesignFemale:AddAction(SendEventToFsmAction("BackToDesign", {
    Event = LoginModuleEvent.BackToDesignState
  }))
  BackToDesignFemale:AddTransitionToState(LoginModuleEvent.BackToDesignState, DesignStateFemale)
  BackFromDesignState:AddAction(SendEventToFsmAction("CheckGender", {
    Event = LoginModuleEvent.BackToSelection,
    bToParentFsm = true
  }))
  DesignReconnectState:AddAction(SendEventToFsmAction("CheckGender", {
    Event = LoginModuleEvent.OnClickBack,
    bToParentFsm = true
  }))
  DesignEntryState:AddTransitionToState(LoginModuleEvent.MaleCharacterSelected, PlayEnterDesignMaleSequence)
  DesignEntryState:AddTransitionToState(LoginModuleEvent.FemaleCharacterSelected, PlayEnterDesignFemaleSequence)
  DesignStateMale:AddTransitionToState(LoginModuleEvent.OnClickBack, DesignReconnectState)
  DesignStateMale:AddTransitionToState(LoginModuleEvent.MaleCharacterSelected, BackFromDesignState)
  DesignStateFemale:AddTransitionToState(LoginModuleEvent.OnClickBack, DesignReconnectState)
  DesignStateFemale:AddTransitionToState(LoginModuleEvent.FemaleCharacterSelected, BackFromDesignState)
  DesignFsm:SetInitState(DesignEntryState)
end

local function ImplementLoginFsm(NRCFullLoginFsm, newFlag)
  if NRCFullLoginFsm.SelectionFsm then
    NRCFullLoginFsm.SelectionFsm:Stop()
  end
  if NRCFullLoginFsm.DesignFsm then
    NRCFullLoginFsm.DesignFsm:Stop()
  end
  NRCFullLoginFsm.SelectionFsm = LoginUtils.CreateChildrenFsm(NRCFullLoginFsm, "SelectionFsm")
  NRCFullLoginFsm.DesignFsm = LoginUtils.CreateChildrenFsm(NRCFullLoginFsm, "DesignFsm")
  NRCFullLoginFsm.bIsMale = nil
  NRCFullLoginFsm.bIsInitialized = false
  NRCFullLoginFsm.BlockRestoreCameraActionFlag = 0
  
  function NRCFullLoginFsm.DestroyActors()
    LoginUtils.DestroyActors(NRCFullLoginFsm)
  end
  
  function NRCFullLoginFsm:SendBackToMainEvent()
    NRCFullLoginFsm.SelectionFsm:Stop()
    NRCFullLoginFsm.DesignFsm:Stop()
    LoginUtils.DestroyActors()
  end
  
  _G.NRCEventCenter:RegisterEvent("NRCFullLoginFsm", NRCFullLoginFsm, LoginModuleEvent.BackToMain, NRCFullLoginFsm.SendBackToMainEvent)
  local AccountState = NRCFullLoginFsm:CreateSequentialState(LoginEnum.StateNames.Account)
  local ComposedSelectionState = NRCFullLoginFsm:CreateSequentialState(LoginEnum.StateNames.ComposedSelection)
  ImplementSelectionFsm(NRCFullLoginFsm.SelectionFsm)
  local ComposedDesignState = NRCFullLoginFsm:CreateSequentialState(LoginEnum.StateNames.ComposedDesign)
  ImplementDesignFsm(NRCFullLoginFsm.DesignFsm)
  local LoadingState = NRCFullLoginFsm:CreateSequentialState(LoginEnum.StateNames.Loading)
  AccountState:AddAction(LoginInitAction("LoginInitAction"))
  ComposedSelectionState:AddAction(StartChildrenFsmAction("StartSelectionFsm", {
    ChildrenFsm = NRCFullLoginFsm.SelectionFsm
  }))
  ComposedDesignState:AddAction(StartChildrenFsmAction("StartDesignFsm", {
    ChildrenFsm = NRCFullLoginFsm.DesignFsm
  }))
  AccountState:AddTransitionToState(FINISHED, ComposedSelectionState)
  AccountState:AddTransitionToState(LoginModuleEvent.OnClickBack, AccountState)
  ComposedSelectionState:AddTransitionToState(LoginModuleEvent.OnClickBack, AccountState)
  ComposedSelectionState:AddTransitionToState(LoginModuleEvent.EnterDesign, ComposedDesignState)
  ComposedSelectionState:AddTransitionToState(FINISHED, ComposedDesignState)
  ComposedDesignState:AddTransitionToState(LoginModuleEvent.OnClickBack, AccountState)
  ComposedDesignState:AddTransitionToState(LoginModuleEvent.BackToSelection, ComposedSelectionState)
  if newFlag then
    NRCFullLoginFsm:SetInitState(ComposedSelectionState)
  else
    NRCFullLoginFsm:SetInitState(AccountState)
  end
  return NRCFullLoginFsm
end

return ImplementLoginFsm
