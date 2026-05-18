local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local Delegate = require("Utils.Delegate")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local Fsm = require("NewRoco.Modules.Core.Fsm.Fsm")
local BattleFsmEnv = NRCClass()
local FINISHED = "FINISHED"

function BattleFsmEnv:Init()
  self.bindDict = {}
  self.stateCache = {}
  self.BattleFsm = Fsm("BattleFsm")
  self:InitVar()
  self:InitBind()
end

function BattleFsmEnv:GetFsm()
  return self.BattleFsm
end

function BattleFsmEnv:InitVar()
  self.FlowsVar = self.BattleFsm:CreateVar("Flows")
  self.BeforeSupplytFlows = self.BattleFsm:CreateVar("BeforeSupplytFlows")
  self.AfterSupplytFlows = self.BattleFsm:CreateVar("AfterSupplytFlows")
  self.SettleInfoVar = self.BattleFsm:CreateVar("SettleInfo")
  self.SupplyInfosVar = self.BattleFsm:CreateVar("SupplyInfosVar")
  self.RoundStateVar = self.BattleFsm:CreateVar("RoundStateVar")
  self.IsMySelfPerformVar = self.BattleFsm:CreateVar("IsMySelfPerform")
  self.HideScenePetDelegateVar = self.BattleFsm:CreateVar(BattleConst.FsmVarNames.HideScenePetDelegate, Delegate())
  self.HideSceneTreesDelegateVar = self.BattleFsm:CreateVar(BattleConst.FsmVarNames.HideSceneTreesDelegate, Delegate())
  self.ShowSceneTreesDelegateVar = self.BattleFsm:CreateVar(BattleConst.FsmVarNames.ShowSceneTreesDelegate, Delegate())
end

function BattleFsmEnv:InitBind()
  self:AutoBind("InitState")
  self:AutoBind("EnterPerformState")
  self:AutoBind("NearbyEnterState")
  self:AutoBind("NearbyReconnectEnterState")
  self:AutoBind("StandbyState")
  self:AutoBind("SwapPlayState")
  self:AutoBind("RoundPlayState")
  self:AutoBind("RoundSelectState")
  self:AutoBind("WaitingOtherState")
  self:AutoBind("NormalOverState")
  self:AutoBind("SeamlessOverState")
  self:AutoBind("DestroyState")
  self:AutoBind("LeaveBattlePureBlackOutState")
  self:AutoBind("DirectOverState")
end

function BattleFsmEnv:InitStates()
end

function BattleFsmEnv:InitFsmTransition()
  self.BattleFsm:AddTransitionToState(BattleEvent.EnterCatchSuccess, CatchSuccessState)
  self.BattleFsm:AddTransitionToState(BattleEvent.ExitBattle, DestroyState)
  self.BattleFsm:AddTransitionToState(BattleEvent.DirectOverBattle, DirectOverState)
  self.BattleFsm:AddTransitionToState(BattleEvent.EnterNormalOver, NormalOverState)
  self.BattleFsm:AddTransitionToState(BattleEvent.EnterRunAwayLeadFight, WorldLeaderRunAwayState)
  self.BattleFsm:AddTransitionToState(BattleEvent.EnterFailOver, FailOverState)
  self.BattleFsm:AddTransitionToState(BattleEvent.EnterSeamlessOver, SeamlessOverState)
  self.BattleFsm:AddTransitionToState(BattleEvent.EnterWorldLeaderSeamlessOver, WorldLeaderSeamlessOverState)
  self.BattleFsm:AddTransitionToState(BattleEvent.EnterPVPOver, PVPOver)
  self.BattleFsm:AddTransitionToState(BattleEvent.EnterPVPRankOver, PVPRankOver)
  self.BattleFsm:AddTransitionToState(BattleEvent.EnterNpcChallengeOver, NpcChallengeOver)
  self.BattleFsm:AddTransitionToState(BattleEvent.EnterBloodTeamBattleOver, TeamBloodBattleOver)
  self.BattleFsm:AddTransitionToState(BattleEvent.EnterBeastTeamBattleOver, TeamBeastBattleOver)
  self.BattleFsm:AddTransitionToState(BattleEvent.EnterRebuildBattleField, ReBuildBattleFieldState)
  self.BattleFsm:AddTransitionToState(BattleEvent.EnterPlayerSkillEscape, PlayerSkillEscapeState)
  self.BattleFsm:AddTransitionToState(BattleEvent.EnterEnemyEscape, EnemyEscapeState)
  self.BattleFsm:AddTransitionToState(BattleEvent.EnterPvpPlayerPerform, PvpPlayerPerform)
  self.BattleFsm:AddTransitionToState(BattleEvent.FinalBattleOver, FinalBattleOver)
  self.BattleFsm:AddTransitionToState(BattleEvent.EnterWaitOtherLoad, WaitOtherLoad)
  self.BattleFsm:SetInitState(InitState)
end

function BattleFsmEnv:BindState(StateName, buildFunc, transitionFunc)
  if not self.bindDict[StateName] then
    self.bindDict[StateName] = {}
  end
  self.bindDict[StateName].buildFunc = buildFunc
  self.bindDict[StateName].transitionFunc = transitionFunc
end

function BattleFsmEnv:AutoBind(StateName)
  local buildFunc = self[StateName .. "Builder"]
  local transitionFunc = self[StateName .. "Transition"]
  self:BindState(StateName, buildFunc, transitionFunc)
end

function BattleFsmEnv:BuildState(StateName)
  if not self.bindDict[StateName] then
    self:AutoBind(StateName)
    Log.Error("BuildState cannt find:", StateName)
  end
  if not self.bindDict[StateName].buildFunc then
    Log.Error("BuildState self.bindDict[StateName].buildFunc is nil", StateName)
    return
  end
  self.bindDict[StateName].buildFunc(self)
end

function BattleFsmEnv:TransitionState(StateName)
  if not self.bindDict[StateName] then
    self:AutoBind(StateName)
    Log.Error("BuildState cannt find:", StateName)
  end
  if not self.bindDict[StateName].transitionFunc then
    Log.Error("BuildState self.bindDict[StateName].transitionFunc is nil", StateName)
    return
  end
  self.bindDict[StateName].transitionFunc(self)
end

function BattleFsmEnv:GetState(StateName, safeCheck)
  if safeCheck then
    local state = self[StateName]
    if not state then
      Log.Error(StateName, "\228\184\141\229\173\152\229\156\168\239\188\140\228\191\157\230\138\164\233\128\187\232\190\145\229\144\175\231\148\168")
      self:BuildState(StateName)
    end
    return state
  else
    return rawget(self, StateName)
  end
end

function BattleFsmEnv:AddTransitionToState(FromStateName, ToStateName, StateEvent)
  local fromState = self:GetState(FromStateName)
  local toState = self:GetState(ToStateName)
  if not fromState then
    self:AutoBind(FromStateName)
    self:BuildState(FromStateName)
    fromState = self:GetState(FromStateName)
  end
  if not toState then
    self:AutoBind(ToStateName)
    self:BuildState(ToStateName)
    toState = self:GetState(ToStateName)
  end
  if fromState and toState then
    fromState:AddTransitionToState(StateEvent, toState)
  end
end

function BattleFsmEnv:InitStateBuilder()
  self.InitState = self.BattleFsm:CreateBurstState(BattleEnum.StateNames.Init)
  self.InitState:AddLazyAction("BattlePreloadResAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattlePreloadResAction")
  self.InitState:AddLazyAction("PreEnterBattlePerformAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.PreEnterBattlePerformAction")
  self.InitState:AddLazyAction("PreProcessEnterBattleAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.PreProcessEnterBattleAction")
  self.InitState:AddLazyAction("BattleLockLodAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleLockLodAction")
  self.InitState:AddLazyAction("BattleInitAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleInitAction")
end

function BattleFsmEnv:InitStateTransition()
  self:AddTransitionToState("InitState", "EnterPerformState", BattleEvent.EnterNearbyEnter)
  self:AddTransitionToState("InitState", "EnterLeaderPerformState", BattleEvent.EnterLeaderEnter)
  self:AddTransitionToState("InitState", "NearbyEnterState", BattleEvent.EnterNearbyEnterPVE)
  self:AddTransitionToState("InitState", "PVESpecialDelayEnterState", BattleEvent.EnterNearbyEnterPVESpecialDelay)
  self:AddTransitionToState("InitState", "NearbyReconnectEnterState", BattleEvent.EnterNearbyReconnectEnter)
  self:AddTransitionToState("InitState", "LeaderReconnectEnterState", BattleEvent.EnterLeaderReconnectEnter)
  self:AddTransitionToState("InitState", "PVPEnterState", BattleEvent.EnterPVPEnter)
  self:AddTransitionToState("InitState", "PVPReconnectEnterState", BattleEvent.EnterPVPReconnectEnter)
  self:AddTransitionToState("InitState", "NpcChallengeState", BattleEvent.EnterNpcChallengeEnter)
  self:AddTransitionToState("InitState", "NpcChallengeReconnectEnterState", BattleEvent.EnterNpcChallengeReconnectEnter)
  self:AddTransitionToState("InitState", "TeamBloodState", BattleEvent.EnterTeamBlood)
  self:AddTransitionToState("InitState", "TeamBloodReconnectState", BattleEvent.EnterTeamBloodReconnect)
  self:AddTransitionToState("InitState", "TeamBeastState", BattleEvent.EnterTeamBeast)
  self:AddTransitionToState("InitState", "TeamBeastReconnectState", BattleEvent.EnterTeamBeastReconnect)
  self:AddTransitionToState("InitState", "FinalBattleState", BattleEvent.EnterFinalBattle)
  self:AddTransitionToState("InitState", "FinalBattleReconnectState", BattleEvent.EnterFinalBattleReconnect)
  self:AddTransitionToState("InitState", "StandbyState", FINISHED)
end

function BattleFsmEnv:EnterPerformStateBuilder()
  self.EnterPerformState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.EnterPerform)
  self.EnterPerformState:AddLazyAction("BattleContactPerformInWorldAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleContactPerformInWorldAction")
  self.EnterPerformState:AddLazyAction("BattlePlayBattleStandAnimAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattlePlayBattleStandAnimAction")
  self.EnterPerformState:AddLazyAction("BattleAfterPerformAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleAfterPerformAction")
end

function BattleFsmEnv:EnterPerformStateTransition()
  self:AddTransitionToState("EnterPerformState", "NearbyEnterState", BattleEvent.EnterNearbyEnter)
  self:AddTransitionToState("EnterPerformState", "ThrowBallEnterState", BattleEvent.EnterNearbyThrowBall)
end

function BattleFsmEnv:NearbyEnterStateBuilder()
  self.NearbyEnterState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.NearbyEnter)
  self.NearbyEnterState:AddLazyAction("BattleRotateBattleFieldAngleAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleRotateBattleFieldAngleAction")
  self.NearbyEnterState:AddLazyAction("BattleFindNearbyBattleLocation", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleFindNearbyBattleLocation")
  self.NearbyEnterState:AddLazyAction("BattleConstructNearbyBattleEnvAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleConstructNearbyBattleEnvAction")
  self.NearbyEnterState:AddLazyAction("BattleGetPosIn1VNAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleGetPosIn1VNAction")
  self.NearbyEnterState:AddLazyAction("BattleNearbyEnterAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleNearbyEnterAction")
  self.NearbyEnterState:AddLazyAction("HideBattlePawnsAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.HideBattlePawnsAction")
  self.NearbyEnterState:AddLazyAction("BattleOnLookerSpawnAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleOnLookerSpawnAction")
  self.NearbyEnterState:AddLazyAction("BattleIntroSelectAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleIntroSelectAction")
end

function BattleFsmEnv:NearbyEnterTransition()
  self:AddTransitionToState("NearbyEnterState", "RoleShowState", BattleEvent.Intro)
  self:AddTransitionToState("NearbyEnterState", "PVERoleShowState", BattleEvent.PVEIntro)
  self:AddTransitionToState("NearbyEnterState", "PVPRoleShowState", BattleEvent.PVPIntro)
end

function BattleFsmEnv:PVPEnterStateBuilder()
  self.PVPEnterState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.PVPEnter)
  self.PVPEnterState:AddLazyAction("BattleRotateBattleFieldAngleAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleRotateBattleFieldAngleAction")
  self.PVPEnterState:AddLazyAction("BattleFindNearbyBattleLocation", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleFindNearbyBattleLocation")
  self.PVPEnterState:AddLazyAction("BattleConstructNearbyBattleEnvAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleConstructNearbyBattleEnvAction")
  self.PVPEnterState:AddLazyAction("BattleHideSceneTreesAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleHideSceneTreesAction", {
    StartDelegate = self.HideSceneTreesDelegateVar
  })
  self.PVPEnterState:AddLazyAction("BattleNearbyEnterAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleNearbyEnterAction")
  self.PVPEnterState:AddLazyAction("BattleHideScenePetAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleHideScenePetAction", {
    StartDelegate = self.HideScenePetDelegateVar
  })
  self.PVPEnterState:AddLazyAction("BattlePvPCloseAirWallAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattlePvPCloseAirWallAction")
  self.PVPEnterState:AddLazyAction("ShowBattlePawnsAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.ShowBattlePawnsAction")
  self.PVPEnterState:AddLazyAction("BattleOnLookerSpawnAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleOnLookerSpawnAction")
  self.PVPEnterState:AddLazyAction("BattleReconnectShowEnterBuffAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleReconnectShowEnterBuffAction")
  self.PVPEnterState:AddLazyAction("BattleOpenCriticalRedPanelAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleOpenCriticalRedPanelAction")
  self.PVPEnterState:AddLazyAction("BattlePveEnterActionRoleHpShow", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattlePveEnterActionRoleHpShow")
  self.PVPEnterState:AddLazyAction("SendLoadFinishReqAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.SendLoadFinishReqAction")
end

function BattleFsmEnv:PVPEnterStateTransition()
  self:AddTransitionToState("PVPEnterState", "SwapSelectState", BattleEvent.EnterSwapSelect)
  self:AddTransitionToState("PVPEnterState", "SelectRidPetState", BattleEvent.EnterSelectRidPet)
  self:AddTransitionToState("PVPEnterState", "EvolutionSelectState", BattleEvent.EnterEvolutionSelect)
  self:AddTransitionToState("PVPEnterState", "RoundSelectState", BattleEvent.EnterRoundSelect)
  self:AddTransitionToState("PVPEnterState", "PrePlayState", BattleEvent.EnterPrePlay)
  self:AddTransitionToState("PVPEnterState", "StandbyState", FINISHED)
end

function BattleFsmEnv:WaitOtherLoadBuilder()
  self.WaitOtherLoad = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.WaitOtherLoad)
  self.WaitOtherLoad:AddLazyAction("BattleWaitOtherLoadAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleWaitOtherLoadAction")
end

function BattleFsmEnv:WaitOtherLoadTransition()
  self:AddTransitionToState("WaitOtherLoad", "SwapSelectState", BattleEvent.EnterSwapSelect)
  self:AddTransitionToState("WaitOtherLoad", "SelectRidPetState", BattleEvent.EnterSelectRidPet)
  self:AddTransitionToState("WaitOtherLoad", "EvolutionSelectState", BattleEvent.EnterEvolutionSelect)
  self:AddTransitionToState("WaitOtherLoad", "RoundSelectState", BattleEvent.EnterRoundSelect)
  self:AddTransitionToState("WaitOtherLoad", "PrePlayState", BattleEvent.EnterPrePlay)
  self:AddTransitionToState("WaitOtherLoad", "StandbyState", FINISHED)
end

function BattleFsmEnv:PVPReconnectEnterStateBuilder()
  self.PVPReconnectEnterState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.PVPReconnectEnter)
  self.PVPReconnectEnterState:AddLazyAction("OpenBlackScreenAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.OpenBlackScreenAction")
  self.PVPReconnectEnterState:AddLazyAction("BattleRotateBattleFieldAngleAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleRotateBattleFieldAngleAction")
  self.PVPReconnectEnterState:AddLazyAction("BattleFindNearbyBattleLocation", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleFindNearbyBattleLocation")
  self.PVPReconnectEnterState:AddLazyAction("BattleConstructNearbyBattleEnvAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleConstructNearbyBattleEnvAction")
  self.PVPReconnectEnterState:AddLazyAction("BattleHideSceneTreesAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleHideSceneTreesAction")
  self.PVPReconnectEnterState:AddLazyAction("BattleNearbyEnterAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleNearbyEnterAction")
  self.PVPReconnectEnterState:AddLazyAction("BattleFocusCameraToTeampetAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleFocusCameraToTeampetAction")
  self.PVPReconnectEnterState:AddLazyAction("BattleHideScenePetAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleHideScenePetAction")
  self.PVPReconnectEnterState:AddLazyAction("ShowBattlePawnsAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.ShowBattlePawnsAction")
  self.PVPReconnectEnterState:AddLazyAction("BattleOnLookerSpawnAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleOnLookerSpawnAction")
  self.PVPReconnectEnterState:AddLazyAction("PreProcessEnterWatchBattleAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.PreProcessEnterWatchBattleAction")
  self.PVPReconnectEnterState:AddLazyAction("BattleReconnectShowEnterBuffAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleReconnectShowEnterBuffAction")
  self.PVPReconnectEnterState:AddLazyAction("BattleOpenCriticalRedPanelAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleOpenCriticalRedPanelAction")
  self.PVPReconnectEnterState:AddLazyAction("CloseBlackScreenAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.CloseBlackScreenAction")
  self.PVPReconnectEnterState:AddLazyAction("SendLoadFinishReqAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.SendLoadFinishReqAction")
end

function BattleFsmEnv:PVPReconnectEnterStateTransition()
  self:AddTransitionToState("PVPReconnectEnterState", "SwapSelectState", BattleEvent.EnterSwapSelect)
  self:AddTransitionToState("PVPReconnectEnterState", "SelectRidPetState", BattleEvent.EnterSelectRidPet)
  self:AddTransitionToState("PVPReconnectEnterState", "EvolutionSelectState", BattleEvent.EnterEvolutionSelect)
  self:AddTransitionToState("PVPReconnectEnterState", "RoundSelectState", BattleEvent.EnterRoundSelect)
  self:AddTransitionToState("PVPReconnectEnterState", "PrePlayState", BattleEvent.EnterPrePlay)
  self:AddTransitionToState("PVPReconnectEnterState", "StandbyState", FINISHED)
end

function BattleFsmEnv:NpcChallengeStateBuilder()
  self.NpcChallengeState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.NpcChallengeEnter)
  self.NpcChallengeState:AddLazyAction("BattleRotateBattleFieldAngleAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleRotateBattleFieldAngleAction")
  self.NpcChallengeState:AddLazyAction("BattleFindNearbyBattleLocation", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleFindNearbyBattleLocation")
  self.NpcChallengeState:AddLazyAction("BattleConstructNearbyBattleEnvAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleConstructNearbyBattleEnvAction")
  self.NpcChallengeState:AddLazyAction("BattleHideSceneTreesAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleHideSceneTreesAction", {
    StartDelegate = self.HideSceneTreesDelegateVar
  })
  self.NpcChallengeState:AddLazyAction("BattleNearbyEnterAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleNearbyEnterAction")
  self.NpcChallengeState:AddLazyAction("BattleHideScenePetAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleHideScenePetAction", {
    StartDelegate = self.HideScenePetDelegateVar
  })
  self.NpcChallengeState:AddLazyAction("ShowBattlePawnsAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.ShowBattlePawnsAction")
  self.NpcChallengeState:AddLazyAction("BattleOnLookerSpawnAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleOnLookerSpawnAction")
  self.NpcChallengeState:AddLazyAction("BattleReconnectShowEnterBuffAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleReconnectShowEnterBuffAction")
  self.NpcChallengeState:AddLazyAction("BattleOpenCriticalRedPanelAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleOpenCriticalRedPanelAction")
  self.NpcChallengeState:AddLazyAction("BattleShowMechanismValidationAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowMechanismValidationAction")
  self.NpcChallengeState:AddLazyAction("BattlePveEnterActionRoleHpShow", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattlePveEnterActionRoleHpShow")
  self.NpcChallengeState:AddLazyAction("SendLoadFinishReqAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.SendLoadFinishReqAction")
end

function BattleFsmEnv:NpcChallengeStateTransition()
  self:AddTransitionToState("NpcChallengeState", "SwapSelectState", BattleEvent.EnterSwapSelect)
  self:AddTransitionToState("NpcChallengeState", "SelectRidPetState", BattleEvent.EnterSelectRidPet)
  self:AddTransitionToState("NpcChallengeState", "EvolutionSelectState", BattleEvent.EnterEvolutionSelect)
  self:AddTransitionToState("NpcChallengeState", "RoundSelectState", BattleEvent.EnterRoundSelect)
  self:AddTransitionToState("NpcChallengeState", "PrePlayState", BattleEvent.EnterPrePlay)
  self:AddTransitionToState("NpcChallengeState", "StandbyState", FINISHED)
end

function BattleFsmEnv:NpcChallengeReconnectEnterStateBuilder()
  self.NpcChallengeReconnectEnterState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.NpcChallengeReconnectEnter)
  self.NpcChallengeReconnectEnterState:AddLazyAction("OpenBlackScreenAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.OpenBlackScreenAction")
  self.NpcChallengeReconnectEnterState:AddLazyAction("BattleRotateBattleFieldAngleAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleRotateBattleFieldAngleAction")
  self.NpcChallengeReconnectEnterState:AddLazyAction("BattleFindNearbyBattleLocation", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleFindNearbyBattleLocation")
  self.NpcChallengeReconnectEnterState:AddLazyAction("BattleConstructNearbyBattleEnvAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleConstructNearbyBattleEnvAction")
  self.NpcChallengeReconnectEnterState:AddLazyAction("BattleHideSceneTreesAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleHideSceneTreesAction")
  self.NpcChallengeReconnectEnterState:AddLazyAction("BattleNearbyEnterAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleNearbyEnterAction")
  self.NpcChallengeReconnectEnterState:AddLazyAction("BattleFocusCameraToTeampetAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleFocusCameraToTeampetAction")
  self.NpcChallengeReconnectEnterState:AddLazyAction("BattleHideScenePetAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleHideScenePetAction")
  self.NpcChallengeReconnectEnterState:AddLazyAction("ShowBattlePawnsAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.ShowBattlePawnsAction")
  self.NpcChallengeReconnectEnterState:AddLazyAction("BattleOnLookerSpawnAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleOnLookerSpawnAction")
  self.NpcChallengeReconnectEnterState:AddLazyAction("PreProcessEnterWatchBattleAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.PreProcessEnterWatchBattleAction")
  self.NpcChallengeReconnectEnterState:AddLazyAction("BattleReconnectShowEnterBuffAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleReconnectShowEnterBuffAction")
  self.NpcChallengeReconnectEnterState:AddLazyAction("BattleOpenCriticalRedPanelAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleOpenCriticalRedPanelAction")
  self.NpcChallengeReconnectEnterState:AddLazyAction("CloseBlackScreenAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.CloseBlackScreenAction")
  self.NpcChallengeReconnectEnterState:AddLazyAction("SendLoadFinishReqAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.SendLoadFinishReqAction")
end

function BattleFsmEnv:NpcChallengeReconnectEnterStateTransition()
  self:AddTransitionToState("NpcChallengeReconnectEnterState", "SwapSelectState", BattleEvent.EnterSwapSelect)
  self:AddTransitionToState("NpcChallengeReconnectEnterState", "SelectRidPetState", BattleEvent.EnterSelectRidPet)
  self:AddTransitionToState("NpcChallengeReconnectEnterState", "EvolutionSelectState", BattleEvent.EnterEvolutionSelect)
  self:AddTransitionToState("NpcChallengeReconnectEnterState", "RoundSelectState", BattleEvent.EnterRoundSelect)
  self:AddTransitionToState("NpcChallengeReconnectEnterState", "PrePlayState", BattleEvent.EnterPrePlay)
  self:AddTransitionToState("NpcChallengeReconnectEnterState", "StandbyState", FINISHED)
end

function BattleFsmEnv:TeamBloodStateBuilder()
  self.TeamBloodState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.TeamBloodEnter)
  self.TeamBloodState:AddLazyAction("BattleRotateBattleFieldAngleAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleRotateBattleFieldAngleAction")
  self.TeamBloodState:AddLazyAction("BattleFindNearbyBattleLocation", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleFindNearbyBattleLocation")
  self.TeamBloodState:AddLazyAction("BattleConstructNearbyBattleEnvAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleConstructNearbyBattleEnvAction")
  self.TeamBloodState:AddLazyAction("BattleHideSceneTreesAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleHideSceneTreesAction")
  self.TeamBloodState:AddLazyAction("BattleNearbyEnterAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleNearbyEnterAction")
  self.TeamBloodState:AddLazyAction("BattleHideScenePetAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleHideScenePetAction")
  self.TeamBloodState:AddLazyAction("ShowBattlePawnsAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.ShowBattlePawnsAction")
  self.TeamBloodState:AddLazyAction("CloseBlackScreenAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.CloseBlackScreenAction")
  self.TeamBloodState:AddLazyAction("BattleTeamBloodEnterAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleTeamBloodEnterAction")
  self.TeamBloodState:AddLazyAction("BattlePlayTeamBossEffectAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattlePlayTeamBossEffectAction")
  self.TeamBloodState:AddLazyAction("BattleReconnectShowEnterBuffAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleReconnectShowEnterBuffAction")
  self.TeamBloodState:AddLazyAction("BattleOpenCriticalRedPanelAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleOpenCriticalRedPanelAction")
  self.TeamBloodState:AddLazyAction("SendLoadFinishReqAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.SendLoadFinishReqAction")
end

function BattleFsmEnv:TeamBloodStateTransition()
  self:AddTransitionToState("TeamBloodState", "SwapSelectState", BattleEvent.EnterSwapSelect)
  self:AddTransitionToState("TeamBloodState", "SelectRidPetState", BattleEvent.EnterSelectRidPet)
  self:AddTransitionToState("TeamBloodState", "EvolutionSelectState", BattleEvent.EnterEvolutionSelect)
  self:AddTransitionToState("TeamBloodState", "RoundSelectState", BattleEvent.EnterRoundSelect)
  self:AddTransitionToState("TeamBloodState", "RevertTeamBattleState", BattleEvent.EnterRevertTeamBattle)
  self:AddTransitionToState("TeamBloodState", "TeamBattleCatch", BattleEvent.EnterTeamCatch)
  self:AddTransitionToState("TeamBloodState", "PrePlayState", BattleEvent.EnterPrePlay)
  self:AddTransitionToState("TeamBloodState", "StandbyState", FINISHED)
end

function BattleFsmEnv:TeamBloodReconnectStateBuilder()
  self.TeamBloodReconnectState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.TeamBloodReconnectEnter)
  self.TeamBloodReconnectState:AddLazyAction("BattleRotateBattleFieldAngleAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleRotateBattleFieldAngleAction")
  self.TeamBloodReconnectState:AddLazyAction("BattleFindNearbyBattleLocation", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleFindNearbyBattleLocation")
  self.TeamBloodReconnectState:AddLazyAction("BattleConstructNearbyBattleEnvAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleConstructNearbyBattleEnvAction")
  self.TeamBloodReconnectState:AddLazyAction("BattleGetPosIn1VNAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleGetPosIn1VNAction")
  self.TeamBloodReconnectState:AddLazyAction("BattleHideSceneTreesAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleHideSceneTreesAction")
  self.TeamBloodReconnectState:AddLazyAction("BattleNearbyEnterAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleNearbyEnterAction")
  self.TeamBloodReconnectState:AddLazyAction("BattleFocusCameraToTeampetAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleFocusCameraToTeampetAction")
  self.TeamBloodReconnectState:AddLazyAction("BattleHideScenePetAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleHideScenePetAction")
  self.TeamBloodReconnectState:AddLazyAction("BattlePlayTeamBossEffectAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattlePlayTeamBossEffectAction")
  self.TeamBloodReconnectState:AddLazyAction("ShowBattlePawnsAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.ShowBattlePawnsAction")
  self.TeamBloodReconnectState:AddLazyAction("BattleReconnectShowEnterBuffAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleReconnectShowEnterBuffAction")
  self.TeamBloodReconnectState:AddLazyAction("BattleOpenCriticalRedPanelAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleOpenCriticalRedPanelAction")
  self.TeamBloodReconnectState:AddLazyAction("CloseBlackScreenAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.CloseBlackScreenAction")
  self.TeamBloodReconnectState:AddLazyAction("SendLoadFinishReqAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.SendLoadFinishReqAction")
end

function BattleFsmEnv:TeamBloodReconnectStateTransition()
  self:AddTransitionToState("TeamBloodReconnectState", "SwapSelectState", BattleEvent.EnterSwapSelect)
  self:AddTransitionToState("TeamBloodReconnectState", "SelectRidPetState", BattleEvent.EnterSelectRidPet)
  self:AddTransitionToState("TeamBloodReconnectState", "EvolutionSelectState", BattleEvent.EnterEvolutionSelect)
  self:AddTransitionToState("TeamBloodReconnectState", "RoundSelectState", BattleEvent.EnterRoundSelect)
  self:AddTransitionToState("TeamBloodReconnectState", "RevertTeamBattleState", BattleEvent.EnterRevertTeamBattle)
  self:AddTransitionToState("TeamBloodReconnectState", "TeamBattleCatch", BattleEvent.EnterTeamCatch)
  self:AddTransitionToState("TeamBloodReconnectState", "PrePlayState", BattleEvent.EnterPrePlay)
  self:AddTransitionToState("TeamBloodReconnectState", "StandbyState", FINISHED)
end

function BattleFsmEnv:TeamBeastStateBuilder()
  self.TeamBeastState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.TeamBeastEnter)
  self.TeamBeastState:AddLazyAction("BattleRotateBattleFieldAngleAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleRotateBattleFieldAngleAction")
  self.TeamBeastState:AddLazyAction("BattleFindNearbyBattleLocation", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleFindNearbyBattleLocation")
  self.TeamBeastState:AddLazyAction("BattleConstructNearbyBattleEnvAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleConstructNearbyBattleEnvAction")
  self.TeamBeastState:AddLazyAction("BattleHideSceneTreesAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleHideSceneTreesAction")
  self.TeamBeastState:AddLazyAction("BattleNearbyEnterAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleNearbyEnterAction")
  self.TeamBeastState:AddLazyAction("BattleHideScenePetAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleHideScenePetAction")
  self.TeamBeastState:AddLazyAction("ShowBattlePawnsAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.ShowBattlePawnsAction")
  self.TeamBeastState:AddLazyAction("CloseBlackScreenAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.CloseBlackScreenAction")
  self.TeamBeastState:AddLazyAction("BattleTeamBeastEnterAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleTeamBeastEnterAction")
  self.TeamBeastState:AddLazyAction("BattleReconnectShowEnterBuffAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleReconnectShowEnterBuffAction")
  self.TeamBeastState:AddLazyAction("BattleOpenCriticalRedPanelAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleOpenCriticalRedPanelAction")
  self.TeamBeastState:AddLazyAction("SendLoadFinishReqAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.SendLoadFinishReqAction")
end

function BattleFsmEnv:TeamBeastStateTransition()
  self:AddTransitionToState("TeamBeastState", "SwapSelectState", BattleEvent.EnterSwapSelect)
  self:AddTransitionToState("TeamBeastState", "SelectRidPetState", BattleEvent.EnterSelectRidPet)
  self:AddTransitionToState("TeamBeastState", "EvolutionSelectState", BattleEvent.EnterEvolutionSelect)
  self:AddTransitionToState("TeamBeastState", "RoundSelectState", BattleEvent.EnterRoundSelect)
  self:AddTransitionToState("TeamBeastState", "RevertTeamBattleState", BattleEvent.EnterRevertTeamBattle)
  self:AddTransitionToState("TeamBeastState", "TeamBeastDefeatState", BattleEvent.EnterTeamBeastDefeat)
  self:AddTransitionToState("TeamBeastState", "TeamBeastBattleCatch", BattleEvent.EnterTeamBeastCatch)
  self:AddTransitionToState("TeamBeastState", "PrePlayState", BattleEvent.EnterPrePlay)
  self:AddTransitionToState("TeamBeastState", "StandbyState", FINISHED)
end

function BattleFsmEnv:TeamBeastReconnectStateBuilder()
  self.TeamBeastReconnectState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.TeamBeastReconnectEnter)
  self.TeamBeastReconnectState:AddLazyAction("BattleRotateBattleFieldAngleAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleRotateBattleFieldAngleAction")
  self.TeamBeastReconnectState:AddLazyAction("BattleFindNearbyBattleLocation", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleFindNearbyBattleLocation")
  self.TeamBeastReconnectState:AddLazyAction("BattleConstructNearbyBattleEnvAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleConstructNearbyBattleEnvAction")
  self.TeamBeastReconnectState:AddLazyAction("BattleGetPosIn1VNAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleGetPosIn1VNAction")
  self.TeamBeastReconnectState:AddLazyAction("BattleHideSceneTreesAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleHideSceneTreesAction")
  self.TeamBeastReconnectState:AddLazyAction("BattleNearbyEnterAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleNearbyEnterAction")
  self.TeamBeastReconnectState:AddLazyAction("BattleFocusCameraToTeampetAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleFocusCameraToTeampetAction")
  self.TeamBeastReconnectState:AddLazyAction("BattleHideScenePetAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleHideScenePetAction")
  self.TeamBeastReconnectState:AddLazyAction("ShowBattlePawnsAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.ShowBattlePawnsAction")
  self.TeamBeastReconnectState:AddLazyAction("BattleReconnectShowEnterBuffAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleReconnectShowEnterBuffAction")
  self.TeamBeastReconnectState:AddLazyAction("BattleOpenCriticalRedPanelAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleOpenCriticalRedPanelAction")
  self.TeamBeastReconnectState:AddLazyAction("CloseBlackScreenAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.CloseBlackScreenAction")
  self.TeamBeastReconnectState:AddLazyAction("SendLoadFinishReqAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.SendLoadFinishReqAction")
end

function BattleFsmEnv:TeamBeastReconnectStateTransition()
  self:AddTransitionToState("TeamBeastReconnectState", "SwapSelectState", BattleEvent.EnterSwapSelect)
  self:AddTransitionToState("TeamBeastReconnectState", "SelectRidPetState", BattleEvent.EnterSelectRidPet)
  self:AddTransitionToState("TeamBeastReconnectState", "EvolutionSelectState", BattleEvent.EnterEvolutionSelect)
  self:AddTransitionToState("TeamBeastReconnectState", "RoundSelectState", BattleEvent.EnterRoundSelect)
  self:AddTransitionToState("TeamBeastReconnectState", "RevertTeamBattleState", BattleEvent.EnterRevertTeamBattle)
  self:AddTransitionToState("TeamBeastReconnectState", "TeamBeastDefeatState", BattleEvent.EnterTeamBeastDefeat)
  self:AddTransitionToState("TeamBeastReconnectState", "TeamBeastBattleCatch", BattleEvent.EnterTeamBeastCatch)
  self:AddTransitionToState("TeamBeastReconnectState", "PrePlayState", BattleEvent.EnterPrePlay)
  self:AddTransitionToState("TeamBeastReconnectState", "StandbyState", FINISHED)
end

function BattleFsmEnv:FinalBattleStateBuilder()
  self.FinalBattleState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.FinalBattleEnter)
  self.FinalBattleState:AddLazyAction("BattleRotateBattleFieldAngleAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleRotateBattleFieldAngleAction")
  self.FinalBattleState:AddLazyAction("BattleFindNearbyBattleLocation", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleFindNearbyBattleLocation")
  self.FinalBattleState:AddLazyAction("BattleConstructNearbyBattleEnvAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleConstructNearbyBattleEnvAction")
  self.FinalBattleState:AddLazyAction("BattleHideSceneTreesAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleHideSceneTreesAction")
  self.FinalBattleState:AddLazyAction("BattleNearbyEnterAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleNearbyEnterAction")
  self.FinalBattleState:AddLazyAction("BattleHideScenePetAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleHideScenePetAction")
  self.FinalBattleState:AddLazyAction("ShowBattlePawnsAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.ShowBattlePawnsAction")
  self.FinalBattleState:AddLazyAction("BattleFinalBattleShowAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleFinalBattleShowAction")
  self.FinalBattleState:AddLazyAction("BattleOpenCriticalRedPanelAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleOpenCriticalRedPanelAction")
  self.FinalBattleState:AddLazyAction("SendLoadFinishReqAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.SendLoadFinishReqAction")
end

function BattleFsmEnv:FinalBattleStateTransition()
  self:AddTransitionToState("FinalBattleState", "SwapSelectState", BattleEvent.EnterSwapSelect)
  self:AddTransitionToState("FinalBattleState", "SelectRidPetState", BattleEvent.EnterSelectRidPet)
  self:AddTransitionToState("FinalBattleState", "EvolutionSelectState", BattleEvent.EnterEvolutionSelect)
  self:AddTransitionToState("FinalBattleState", "RoundSelectState", BattleEvent.EnterRoundSelect)
  self:AddTransitionToState("FinalBattleState", "PrePlayState", BattleEvent.EnterPrePlay)
  self:AddTransitionToState("FinalBattleState", "StandbyState", FINISHED)
end

function BattleFsmEnv:FinalBattleReconnectStateBuilder()
  self.FinalBattleReconnectState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.FinalBattleReconnectEnter)
  self.FinalBattleReconnectState:AddLazyAction("BattleRotateBattleFieldAngleAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleRotateBattleFieldAngleAction")
  self.FinalBattleReconnectState:AddLazyAction("BattleFindNearbyBattleLocation", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleFindNearbyBattleLocation")
  self.FinalBattleReconnectState:AddLazyAction("BattleConstructNearbyBattleEnvAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleConstructNearbyBattleEnvAction")
  self.FinalBattleReconnectState:AddLazyAction("BattleGetPosIn1VNAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleGetPosIn1VNAction")
  self.FinalBattleReconnectState:AddLazyAction("BattleHideSceneTreesAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleHideSceneTreesAction")
  self.FinalBattleReconnectState:AddLazyAction("BattleNearbyEnterAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleNearbyEnterAction")
  self.FinalBattleReconnectState:AddLazyAction("BattleFocusCameraToTeampetAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleFocusCameraToTeampetAction")
  self.FinalBattleReconnectState:AddLazyAction("BattleHideScenePetAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleHideScenePetAction")
  self.FinalBattleReconnectState:AddLazyAction("ShowBattlePawnsAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.ShowBattlePawnsAction")
  self.FinalBattleReconnectState:AddLazyAction("BattleReconnectShowEnterBuffAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleReconnectShowEnterBuffAction")
  self.FinalBattleReconnectState:AddLazyAction("BattleOpenCriticalRedPanelAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleOpenCriticalRedPanelAction")
  self.FinalBattleReconnectState:AddLazyAction("CloseBlackScreenAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.CloseBlackScreenAction")
  self.FinalBattleReconnectState:AddLazyAction("SendLoadFinishReqAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.SendLoadFinishReqAction")
end

function BattleFsmEnv:FinalBattleReconnectStateTransition()
  self:AddTransitionToState("FinalBattleReconnectState", "SwapSelectState", BattleEvent.EnterSwapSelect)
  self:AddTransitionToState("FinalBattleReconnectState", "SelectRidPetState", BattleEvent.EnterSelectRidPet)
  self:AddTransitionToState("FinalBattleReconnectState", "EvolutionSelectState", BattleEvent.EnterEvolutionSelect)
  self:AddTransitionToState("FinalBattleReconnectState", "RoundSelectState", BattleEvent.EnterRoundSelect)
  self:AddTransitionToState("FinalBattleReconnectState", "PrePlayState", BattleEvent.EnterPrePlay)
  self:AddTransitionToState("FinalBattleReconnectState", "StandbyState", FINISHED)
end

function BattleFsmEnv:PVESpecialDelayEnterStateBuilder()
  self.PVESpecialDelayEnterState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.PVESpecialDelayEnterState)
  self.PVESpecialDelayEnterState:AddLazyAction("OpenBlackScreenAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.OpenBlackScreenAction")
  self.PVESpecialDelayEnterState:AddLazyAction("BattleRotateBattleFieldAngleAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleRotateBattleFieldAngleAction")
  self.PVESpecialDelayEnterState:AddLazyAction("BattleFindNearbyBattleLocation", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleFindNearbyBattleLocation")
  self.PVESpecialDelayEnterState:AddLazyAction("BattleConstructNearbyBattleEnvAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleConstructNearbyBattleEnvAction")
  self.PVESpecialDelayEnterState:AddLazyAction("BattleGetPosIn1VNAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleGetPosIn1VNAction")
  self.PVESpecialDelayEnterState:AddLazyAction("BattleNearbyEnterAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleNearbyEnterAction")
  self.PVESpecialDelayEnterState:AddLazyAction("HideBattlePawnsAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.HideBattlePawnsAction")
  self.PVESpecialDelayEnterState:AddLazyAction("BattleOnLookerSpawnAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleOnLookerSpawnAction")
  self.PVESpecialDelayEnterState:AddLazyAction("BattleShowRuleTipsAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowRuleTipsAction")
  self.PVESpecialDelayEnterState:AddLazyAction("BattleIntroSelectAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleIntroSelectAction")
end

function BattleFsmEnv:PVESpecialDelayEnterStateTransition()
  self:AddTransitionToState("PVESpecialDelayEnterState", "PVESpecialDelayRoleShowState", BattleEvent.PVESpecialDelay)
end

function BattleFsmEnv:PVESpecialDelayRoleShowStateBuilder()
  self.PVESpecialDelayRoleShowState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.PVESpecialDelayRoleShowState)
  self.PVESpecialDelayRoleShowState:AddLazyAction("BattleHideSceneTreesAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleHideSceneTreesAction")
  self.PVESpecialDelayRoleShowState:AddLazyAction("BattleHideScenePetAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleHideScenePetAction")
  self.PVESpecialDelayRoleShowState:AddLazyAction("BattleSpecialDelayPveEnterAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleSpecialDelayPveEnterAction")
  self.PVESpecialDelayRoleShowState:AddLazyAction("RoleHpCriticalTipAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleRoleShowCriticalTipAction")
  self.PVESpecialDelayRoleShowState:AddLazyAction("SendLoadFinishReqAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.SendLoadFinishReqAction")
end

function BattleFsmEnv:PVESpecialDelayRoleShowStateTransition()
  self:AddTransitionToState("PVESpecialDelayRoleShowState", "StandbyState", FINISHED)
end

function BattleFsmEnv:NearbyReconnectEnterStateBuilder()
  self.NearbyReconnectEnterState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.NearbyReconnectEnter)
  self.NearbyReconnectEnterState:AddLazyAction("OpenBlackScreenAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.OpenBlackScreenAction")
  self.NearbyReconnectEnterState:AddLazyAction("BattleRotateBattleFieldAngleAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleRotateBattleFieldAngleAction")
  self.NearbyReconnectEnterState:AddLazyAction("BattleFindNearbyBattleLocation", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleFindNearbyBattleLocation")
  self.NearbyReconnectEnterState:AddLazyAction("BattleConstructNearbyBattleEnvAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleConstructNearbyBattleEnvAction")
  self.NearbyReconnectEnterState:AddLazyAction("BattleGetPosIn1VNAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleGetPosIn1VNAction")
  self.NearbyReconnectEnterState:AddLazyAction("BattleHideSceneTreesAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleHideSceneTreesAction")
  self.NearbyReconnectEnterState:AddLazyAction("BattleNearbyEnterAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleNearbyEnterAction")
  self.NearbyReconnectEnterState:AddLazyAction("BattleFocusCameraToTeampetAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleFocusCameraToTeampetAction")
  self.NearbyReconnectEnterState:AddLazyAction("BattleHideScenePetAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleHideScenePetAction")
  self.NearbyReconnectEnterState:AddLazyAction("ShowBattlePawnsAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.ShowBattlePawnsAction")
  self.NearbyReconnectEnterState:AddLazyAction("BattleOnLookerSpawnAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleOnLookerSpawnAction")
  self.NearbyReconnectEnterState:AddLazyAction("PreProcessEnterWatchBattleAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.PreProcessEnterWatchBattleAction")
  self.NearbyReconnectEnterState:AddLazyAction("BattleReconnectShowEnterBuffAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleReconnectShowEnterBuffAction")
  self.NearbyReconnectEnterState:AddLazyAction("BattleOpenCriticalRedPanelAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleOpenCriticalRedPanelAction")
  self.NearbyReconnectEnterState:AddLazyAction("CloseBlackScreenAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.CloseBlackScreenAction")
  self.NearbyReconnectEnterState:AddLazyAction("BattleShowRuleTipsAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowRuleTipsAction")
  self.NearbyReconnectEnterState:AddLazyAction("SendLoadFinishReqAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.SendLoadFinishReqAction")
end

function BattleFsmEnv:NearbyReconnectEnterStateTransition()
  self:AddTransitionToState("NearbyReconnectEnterState", "SwapSelectState", BattleEvent.EnterSwapSelect)
  self:AddTransitionToState("NearbyReconnectEnterState", "SelectRidPetState", BattleEvent.EnterSelectRidPet)
  self:AddTransitionToState("NearbyReconnectEnterState", "EvolutionSelectState", BattleEvent.EnterEvolutionSelect)
  self:AddTransitionToState("NearbyReconnectEnterState", "NpcAutoEscapeSelectState", BattleEvent.EnterNpcAutoEscape)
  self:AddTransitionToState("NearbyReconnectEnterState", "RoundSelectState", BattleEvent.EnterRoundSelect)
  self:AddTransitionToState("NearbyReconnectEnterState", "PrePlayState", BattleEvent.EnterPrePlay)
  self:AddTransitionToState("NearbyReconnectEnterState", "FinalBattleToP2", BattleEvent.FinalBattleToP2)
  self:AddTransitionToState("NearbyReconnectEnterState", "StandbyState", FINISHED)
end

function BattleFsmEnv:ThrowBallEnterStateBuilder()
  self.ThrowBallEnterState = self.BattleFsm:CreateBurstState(BattleEnum.StateNames.ThrowBallEnter)
  self.ThrowBallEnterState:AddLazyAction("BattleRotateBattleFieldAngleAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleRotateBattleFieldAngleAction")
  self.ThrowBallEnterState:AddLazyAction("BattleFindNearbyBattleLocation", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleFindNearbyBattleLocation")
  self.ThrowBallEnterState:AddLazyAction("BattleConstructNearbyBattleEnvAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleConstructNearbyBattleEnvAction")
  self.ThrowBallEnterState:AddLazyAction("BattleGetPosIn1VNAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleGetPosIn1VNAction")
  self.ThrowBallEnterState:AddLazyAction("BattleHideSceneTreesAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleHideSceneTreesAction", {
    StartDelegate = self.HideSceneTreesDelegateVar
  })
  self.ThrowBallEnterState:AddLazyAction("BattlePrepareAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattlePrepareAction")
  self.ThrowBallEnterState:AddLazyAction("BattlePlayPetStartBattleAnimAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattlePlayPetStartBattleAnimAction", {
    [BattleConst.FsmVarNames.HideSceneTreesDelegate] = self.HideSceneTreesDelegateVar
  })
  self.ThrowBallEnterState:AddLazyAction("BattlePetMoveToRightPosAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattlePetMoveToRightPosAction")
  self.ThrowBallEnterState:AddLazyAction("BattleOnLookerSpawnAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleOnLookerSpawnAction")
  self.ThrowBallEnterState:AddLazyAction("BattleIntroSelectAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleIntroSelectAction")
end

function BattleFsmEnv:ThrowBallEnterStateTransition()
  self:AddTransitionToState("ThrowBallEnterState", "ThrowBallRoleShowState", BattleEvent.Intro)
end

function BattleFsmEnv:ThrowBallReconnectEnterStateBuilder()
  self.ThrowBallReconnectEnterState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.ThrowBallReconnectEnter)
  self.ThrowBallReconnectEnterState:AddLazyAction("OpenBlackScreenAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.OpenBlackScreenAction")
  self.ThrowBallReconnectEnterState:AddLazyAction("BattleRotateBattleFieldAngleAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleRotateBattleFieldAngleAction")
  self.ThrowBallReconnectEnterState:AddLazyAction("BattleFindNearbyBattleLocation", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleFindNearbyBattleLocation")
  self.ThrowBallReconnectEnterState:AddLazyAction("BattleConstructNearbyBattleEnvAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleConstructNearbyBattleEnvAction")
  self.ThrowBallReconnectEnterState:AddLazyAction("BattleGetPosIn1VNAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleGetPosIn1VNAction")
  self.ThrowBallReconnectEnterState:AddLazyAction("BattleHideSceneTreesAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleHideSceneTreesAction")
  self.ThrowBallReconnectEnterState:AddLazyAction("BattleNearbyEnterAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleNearbyEnterAction")
  self.ThrowBallReconnectEnterState:AddLazyAction("BattleFocusCameraToTeampetAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleFocusCameraToTeampetAction")
  self.ThrowBallReconnectEnterState:AddLazyAction("BattleHideScenePetAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleHideScenePetAction")
  self.ThrowBallReconnectEnterState:AddLazyAction("ShowBattlePawnsAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.ShowBattlePawnsAction")
  self.ThrowBallReconnectEnterState:AddLazyAction("BattleOnLookerSpawnAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleOnLookerSpawnAction")
  self.ThrowBallReconnectEnterState:AddLazyAction("BattleReconnectShowEnterBuffAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleReconnectShowEnterBuffAction")
  self.ThrowBallReconnectEnterState:AddLazyAction("BattleOpenCriticalRedPanelAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleOpenCriticalRedPanelAction")
  self.ThrowBallReconnectEnterState:AddLazyAction("CloseBlackScreenAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.CloseBlackScreenAction")
  self.ThrowBallReconnectEnterState:AddLazyAction("SendLoadFinishReqAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.SendLoadFinishReqAction")
end

function BattleFsmEnv:ThrowBallReconnectEnterStateTransition()
  self:AddTransitionToState("ThrowBallReconnectEnterState", "SwapSelectState", BattleEvent.EnterSwapSelect)
  self:AddTransitionToState("ThrowBallReconnectEnterState", "SelectRidPetState", BattleEvent.EnterSelectRidPet)
  self:AddTransitionToState("ThrowBallReconnectEnterState", "EvolutionSelectState", BattleEvent.EnterEvolutionSelect)
  self:AddTransitionToState("ThrowBallReconnectEnterState", "RoundSelectState", BattleEvent.EnterRoundSelect)
  self:AddTransitionToState("ThrowBallReconnectEnterState", "PrePlayState", BattleEvent.EnterPrePlay)
  self:AddTransitionToState("ThrowBallReconnectEnterState", "StandbyState", FINISHED)
end

function BattleFsmEnv:ThrowBallRoleShowStateBuilder()
  self.ThrowBallRoleShowState = self.BattleFsm:CreateBurstState(BattleEnum.StateNames.ThrowBallRoleShow)
  self.ThrowBallRoleShowState:AddLazyAction("RoleHpCriticalTipAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleRoleShowCriticalTipAction")
  self.ThrowBallRoleShowState:AddLazyAction("BattleOpenCriticalRedPanelAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleOpenCriticalRedPanelAction")
  self.ThrowBallRoleShowState:AddLazyAction("SendLoadFinishReqAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.SendLoadFinishReqAction")
end

function BattleFsmEnv:ThrowBallRoleShowStateTransition()
  self:AddTransitionToState("ThrowBallRoleShowState", "StandbyState", FINISHED)
end

function BattleFsmEnv:PVERoleShowStateBuilder()
  self.PVERoleShowState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.PVERoleShow)
  self.PVERoleShowState:AddLazyAction("BattleHideSceneTreesAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleHideSceneTreesAction", {
    StartDelegate = self.HideSceneTreesDelegateVar
  })
  self.PVERoleShowState:AddLazyAction("BattleHideScenePetAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleHideScenePetAction", {
    StartDelegate = self.HideScenePetDelegateVar
  })
  self.PVERoleShowState:AddLazyAction("ShowBattlePawnsAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.ShowBattlePawnsAction")
  self.PVERoleShowState:AddLazyAction("BattlePveEnterActionRoleHpShow", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattlePveEnterActionRoleHpShow")
  self.PVERoleShowState:AddLazyAction("RoleHpCriticalTipAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleRoleShowCriticalTipAction")
  self.PVERoleShowState:AddLazyAction("BattleOpenCriticalRedPanelAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleOpenCriticalRedPanelAction")
  self.PVERoleShowState:AddLazyAction("BattleShowRuleTipsAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowRuleTipsAction")
  self.PVERoleShowState:AddLazyAction("SendLoadFinishReqAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.SendLoadFinishReqAction")
end

function BattleFsmEnv:PVERoleShowStateTransition()
  self:AddTransitionToState("PVERoleShowState", "StandbyState", FINISHED)
end

function BattleFsmEnv:PVPRoleShowStateBuilder()
  self.PVPRoleShowState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.PVPRoleShow)
  self.PVPRoleShowState:AddLazyAction("BattleHideSceneTreesAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleHideSceneTreesAction")
  self.PVPRoleShowState:AddLazyAction("BattlePvpEnterActionSummon", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattlePvpEnterActionSummon")
  self.PVPRoleShowState:AddLazyAction("BattlePvpEnterActionPetShow", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattlePvpEnterActionPetShow")
  self.PVPRoleShowState:AddLazyAction("SendLoadFinishReqAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.SendLoadFinishReqAction")
end

function BattleFsmEnv:PVPRoleShowStateTransition()
end

function BattleFsmEnv:LeaderEnterStateBuilder()
  self.LeaderEnterState = self.BattleFsm:CreateBurstState(BattleEnum.StateNames.LeaderEnter)
  self.LeaderEnterState:AddLazyAction("BattleRotateBattleFieldAngleAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleRotateBattleFieldAngleAction")
  self.LeaderEnterState:AddLazyAction("BattleFindNearbyBattleLocation", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleFindNearbyBattleLocation")
  self.LeaderEnterState:AddLazyAction("BattleConstructNearbyBattleEnvAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleConstructNearbyBattleEnvAction")
  self.LeaderEnterState:AddLazyAction("BattleHideSceneTreesAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleHideSceneTreesAction")
  self.LeaderEnterState:AddLazyAction("BattleNearbyEnterAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleNearbyEnterAction")
  self.LeaderEnterState:AddLazyAction("BattleIntroSelectAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleIntroSelectAction")
end

function BattleFsmEnv:LeaderEnterStateTransition()
  self:AddTransitionToState("LeaderEnterState", "LeaderRoleShowState", BattleEvent.LeaderIntro)
  self:AddTransitionToState("LeaderEnterState", "WorldLeaderRoleShowState", BattleEvent.WorldLeaderIntro)
end

function BattleFsmEnv:LeaderReconnectEnterStateBuilder()
  self.LeaderReconnectEnterState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.LeaderReconnectEnter)
  self.LeaderReconnectEnterState:AddLazyAction("OpenBlackScreenAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.OpenBlackScreenAction")
  self.LeaderReconnectEnterState:AddLazyAction("BattleRotateBattleFieldAngleAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleRotateBattleFieldAngleAction")
  self.LeaderReconnectEnterState:AddLazyAction("BattleFindNearbyBattleLocation", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleFindNearbyBattleLocation")
  self.LeaderReconnectEnterState:AddLazyAction("BattleConstructNearbyBattleEnvAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleConstructNearbyBattleEnvAction")
  self.LeaderReconnectEnterState:AddLazyAction("BattleHideSceneTreesAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleHideSceneTreesAction")
  self.LeaderReconnectEnterState:AddLazyAction("BattleNearbyEnterAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleNearbyEnterAction")
  self.LeaderReconnectEnterState:AddLazyAction("BattleFocusCameraToTeampetAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleFocusCameraToTeampetAction")
  self.LeaderReconnectEnterState:AddLazyAction("BattleHideScenePetAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleHideScenePetAction")
  self.LeaderReconnectEnterState:AddLazyAction("ShowBattlePawnsAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.ShowBattlePawnsAction")
  self.LeaderReconnectEnterState:AddLazyAction("BattleReconnectShowEnterBuffAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleReconnectShowEnterBuffAction")
  self.LeaderReconnectEnterState:AddLazyAction("BattleOpenCriticalRedPanelAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleOpenCriticalRedPanelAction")
  self.LeaderReconnectEnterState:AddLazyAction("CloseBlackScreenAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.CloseBlackScreenAction")
  self.LeaderReconnectEnterState:AddLazyAction("BattleShowRuleTipsAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowRuleTipsAction")
  self.LeaderReconnectEnterState:AddLazyAction("SendLoadFinishReqAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.SendLoadFinishReqAction")
end

function BattleFsmEnv:LeaderReconnectEnterStateTransition()
  self:AddTransitionToState("LeaderReconnectEnterState", "SwapSelectState", BattleEvent.EnterSwapSelect)
  self:AddTransitionToState("LeaderReconnectEnterState", "SelectRidPetState", BattleEvent.EnterSelectRidPet)
  self:AddTransitionToState("LeaderReconnectEnterState", "EvolutionSelectState", BattleEvent.EnterEvolutionSelect)
  self:AddTransitionToState("LeaderReconnectEnterState", "RoundSelectState", BattleEvent.EnterRoundSelect)
  self:AddTransitionToState("LeaderReconnectEnterState", "PrePlayState", BattleEvent.EnterPrePlay)
  self:AddTransitionToState("LeaderReconnectEnterState", "StandbyState", FINISHED)
end

function BattleFsmEnv:EnterLeaderPerformStateBuilder()
  self.EnterLeaderPerformState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.EnterLeaderPerform)
  self.EnterLeaderPerformState:AddLazyAction("BattleLeaderBattleShowTimeAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleLeaderBattleShowTimeAction")
end

function BattleFsmEnv:EnterLeaderPerformStateTransition()
  self:AddTransitionToState("EnterLeaderPerformState", "LeaderEnterState", FINISHED)
end

function BattleFsmEnv:LeaderRoleShowStateBuilder()
  self.LeaderRoleShowState = self.BattleFsm:CreateBurstState(BattleEnum.StateNames.LeaderRoleShow)
  self.LeaderRoleShowState:AddLazyAction("BattleHideSceneTreesAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleHideSceneTreesAction")
  self.LeaderRoleShowState:AddLazyAction("BattleHideScenePetAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleHideScenePetAction")
  self.LeaderRoleShowState:AddLazyAction("ShowBattlePawnsAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.ShowBattlePawnsAction")
  self.LeaderRoleShowState:AddLazyAction("PlayerTeamShowAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.PlayerTeamShowAction")
  self.LeaderRoleShowState:AddLazyAction("EnemyTeamShowAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.EnemyTeamShowAction")
  self.LeaderRoleShowState:AddLazyAction("RoleHpCriticalTipAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleRoleShowCriticalTipAction")
  self.LeaderRoleShowState:AddLazyAction("BattleOpenCriticalRedPanelAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleOpenCriticalRedPanelAction")
  self.LeaderRoleShowState:AddLazyAction("BattleShowRuleTipsAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowRuleTipsAction")
  self.LeaderRoleShowState:AddLazyAction("SendLoadFinishReqAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.SendLoadFinishReqAction")
end

function BattleFsmEnv:LeaderRoleShowStateTransition()
  self:AddTransitionToState("LeaderRoleShowState", "PrePlayState", BattleEvent.EnterPrePlay)
  self:AddTransitionToState("LeaderRoleShowState", "StandbyState", FINISHED)
end

function BattleFsmEnv:RoleShowStateBuilder()
  self.RoleShowState = self.BattleFsm:CreateBurstState(BattleEnum.StateNames.RoleShow)
  self.RoleShowState:AddLazyAction("BattleHideSceneTreesAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleHideSceneTreesAction", {
    StartDelegate = self.HideSceneTreesDelegateVar
  })
  self.RoleShowState:AddLazyAction("BattleHideScenePetAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleHideScenePetAction", {
    StartDelegate = self.HideScenePetDelegateVar
  })
  self.RoleShowState:AddLazyAction("PlayerTeamShowAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.PlayerTeamShowAction", {
    [BattleConst.FsmVarNames.HideSceneTreesDelegate] = self.HideSceneTreesDelegateVar,
    [BattleConst.FsmVarNames.HideScenePetDelegate] = self.HideScenePetDelegateVar
  })
  self.RoleShowState:AddLazyAction("EnemyTeamShowAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.EnemyTeamShowAction")
  self.RoleShowState:AddLazyAction("BattlePetMoveToRightPosAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattlePetMoveToRightPosAction")
  self.RoleShowState:AddLazyAction("RoleHpCriticalTipAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleRoleShowCriticalTipAction")
  self.RoleShowState:AddLazyAction("BattleOpenCriticalRedPanelAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleOpenCriticalRedPanelAction")
  self.RoleShowState:AddLazyAction("BattleShowRuleTipsAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowRuleTipsAction")
  self.RoleShowState:AddLazyAction("SendLoadFinishReqAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.SendLoadFinishReqAction")
end

function BattleFsmEnv:RoleShowStateTransition()
  self:AddTransitionToState("RoleShowState", "PrePlayState", BattleEvent.EnterPrePlay)
  self:AddTransitionToState("RoleShowState", "StandbyState", FINISHED)
end

function BattleFsmEnv:WorldLeaderRoleShowStateBuilder()
  self.WorldLeaderRoleShowState = self.BattleFsm:CreateBurstState(BattleEnum.StateNames.WorldLeaderRoleShow)
  self.WorldLeaderRoleShowState:AddLazyAction("BattleHideSceneTreesAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleHideSceneTreesAction")
  self.WorldLeaderRoleShowState:AddLazyAction("BattleHideScenePetAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleHideScenePetAction")
  self.WorldLeaderRoleShowState:AddLazyAction("BattleWorldLeaderShowAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleWorldLeaderShowAction")
  self.WorldLeaderRoleShowState:AddLazyAction("ShowBattlePawnsAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.ShowBattlePawnsAction")
  self.WorldLeaderRoleShowState:AddLazyAction("PlayerTeamShowAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.PlayerTeamShowAction")
  self.WorldLeaderRoleShowState:AddLazyAction("EnemyTeamShowAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.EnemyTeamShowAction")
  self.WorldLeaderRoleShowState:AddLazyAction("RoleHpCriticalTipAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleRoleShowCriticalTipAction")
  self.WorldLeaderRoleShowState:AddLazyAction("BattleOpenCriticalRedPanelAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleOpenCriticalRedPanelAction")
  self.WorldLeaderRoleShowState:AddLazyAction("BattleShowMechanismValidationAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowMechanismValidationAction")
  self.WorldLeaderRoleShowState:AddLazyAction("BattleShowRuleTipsAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowRuleTipsAction")
  self.WorldLeaderRoleShowState:AddLazyAction("SendLoadFinishReqAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.SendLoadFinishReqAction")
end

function BattleFsmEnv:WorldLeaderRoleShowStateTransition()
  self:AddTransitionToState("WorldLeaderRoleShowState", "PrePlayState", BattleEvent.EnterPrePlay)
  self:AddTransitionToState("WorldLeaderRoleShowState", "StandbyState", FINISHED)
end

function BattleFsmEnv:WorldLeaderRunAwayStateBuilder()
  local WorldLeaderRunAwayState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.WorldLeaderRunAwayState)
  WorldLeaderRunAwayState:AddLazyAction("HideMainWindow", "NewRoco.Modules.Core.Battle.Fsm.Actions.HideBattleMainWindowAction")
  WorldLeaderRunAwayState:AddLazyAction("RunAwayWorldLeader", "NewRoco.Modules.Core.Battle.Fsm.Actions.RunAwayWorldLeaderAction")
end

function BattleFsmEnv:WorldLeaderRunAwayStateTransition()
end

function BattleFsmEnv:WorldLeaderSeamlessOverStateBuilder()
  local WorldLeaderSeamlessOverState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.WorldLeaderSeamlessOver)
  WorldLeaderSeamlessOverState:AddLazyAction("BattleCloseCriticalRedPanelAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleCloseCriticalRedPanelAction")
  WorldLeaderSeamlessOverState:AddLazyAction("SeamlessOverAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.SeamlessOverAction")
  WorldLeaderSeamlessOverState:AddLazyAction("BattleShowSceneTreesAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowSceneTreesAction")
  WorldLeaderSeamlessOverState:AddLazyAction("WorldLeaderLeaveAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.WorldLeaderLeaveAction")
end

function BattleFsmEnv:WorldLeaderSeamlessOverStateTransition()
  self:AddTransitionToState("WorldLeaderSeamlessOverState", "LeaveBattlePureBlackOutState", BattleEvent.EnterPureBlackOut)
  self:AddTransitionToState("WorldLeaderSeamlessOverState", "StandbyState", FINISHED)
end

function BattleFsmEnv:StandbyStateBuilder()
  self.StandbyState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.Standby)
  self.StandbyState:AddLazyAction("BattleWaitingNotifyAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleWaitingNotifyAction", {PlayTime = 20})
end

function BattleFsmEnv:StandbyStateTransition()
  self:AddTransitionToState("StandbyState", "StandbyState", FINISHED)
  self:AddTransitionToState("StandbyState", "PrePlayState", BattleEvent.EnterPrePlay)
  self:AddTransitionToState("StandbyState", "SwapSelectState", BattleEvent.EnterSwapSelect)
  self:AddTransitionToState("StandbyState", "SelectRidPetState", BattleEvent.EnterSelectRidPet)
  self:AddTransitionToState("StandbyState", "EvolutionSelectState", BattleEvent.EnterEvolutionSelect)
  self:AddTransitionToState("StandbyState", "NpcAutoEscapeSelectState", BattleEvent.EnterNpcAutoEscape)
  self:AddTransitionToState("StandbyState", "SwapPlayState", BattleEvent.EnterSwapPlay)
  self:AddTransitionToState("StandbyState", "RoundSelectState", BattleEvent.EnterRoundSelect)
  self:AddTransitionToState("StandbyState", "RevertTeamBattleState", BattleEvent.EnterRevertTeamBattle)
  self:AddTransitionToState("StandbyState", "TeamBattleCatch", BattleEvent.EnterTeamCatch)
  self:AddTransitionToState("StandbyState", "FinalBattleToP2", BattleEvent.FinalBattleToP2)
  self:AddTransitionToState("StandbyState", "TeamBeastDefeatState", BattleEvent.EnterTeamBeastDefeat)
  self:AddTransitionToState("StandbyState", "TeamBeastBattleCatch", BattleEvent.EnterTeamBeastCatch)
  self:AddTransitionToState("StandbyState", "WaitingOtherState", BattleEvent.EnterWaitOther)
  self:AddTransitionToState("StandbyState", "RoundPlayState", BattleEvent.EnterRoundPlay)
  self:AddTransitionToState("StandbyState", "EnemyEscapeState", BattleEvent.EnterEnemyEscape)
  self:AddTransitionToState("StandbyState", "EnemyNpcEscapeState", BattleEvent.EnterEnemyNpcEscape)
  self:AddTransitionToState("StandbyState", "CatchSuccessState", BattleEvent.EnterCatchSuccess)
end

function BattleFsmEnv:PrePlayStateBuilder()
  self.PrePlayState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.PrePlay)
  self.PrePlayState:AddLazyAction("BattlePreloadTurnPlayResAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattlePreloadTurnPlayResAction", {
    Flows = self.FlowsVar,
    SettleInfo = self.SettleInfoVar
  })
  self.PrePlayState:AddLazyAction("BattlePrePlayAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleTurnPlayerAction", {
    Flows = self.FlowsVar,
    SettleInfo = self.SettleInfoVar,
    IsMySelfPerform = self.IsMySelfPerformVar
  })
  self.PrePlayState:AddLazyAction("SendRoundFlowFinishReqAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.SendRoundFlowFinishReqAction", {
    Flows = self.FlowsVar,
    BattleState = _G.ProtoEnum.BATTLEFIELD_STATE.BATTLEFIELD_STATE_PRE_PLAY
  })
end

function BattleFsmEnv:PrePlayStateTransition()
  self:AddTransitionToState("PrePlayState", "StandbyState", FINISHED)
end

function BattleFsmEnv:SwapSelectStateBuilder()
  self.SwapSelectState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.SwapSelect)
  self.SwapSelectState:AddLazyAction("BattleOnLookerSpawnAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleOnLookerSpawnAction")
  self.SwapSelectState:AddLazyAction("BattleSwapSelectAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.RoundEx.BattleSwapSelectAction")
end

function BattleFsmEnv:SwapSelectStateTransition()
  self:AddTransitionToState("SwapSelectState", "StandbyState", FINISHED)
  self:AddTransitionToState("SwapSelectState", "SwapPlayState", BattleEvent.EnterSwapPlay)
  self:AddTransitionToState("SwapSelectState", "RoundPlayState", BattleEvent.EnterRoundPlay)
  self:AddTransitionToState("SwapSelectState", "RoundSelectState", BattleEvent.EnterRoundSelect)
  self:AddTransitionToState("SwapSelectState", "TeamBattleCatch", BattleEvent.EnterTeamCatch)
  self:AddTransitionToState("SwapSelectState", "TeamBeastDefeatState", BattleEvent.EnterTeamBeastDefeat)
  self:AddTransitionToState("SwapSelectState", "TeamBeastBattleCatch", BattleEvent.EnterTeamBeastCatch)
  self:AddTransitionToState("SwapSelectState", "WaitingOtherState", BattleEvent.EnterWaitOther)
end

function BattleFsmEnv:SelectRidPetStateBuilder()
  local SelectRidPetState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.SelectRidPet)
  SelectRidPetState:AddLazyAction("SendRoundFlowFinishReqAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.SendRoundFlowFinishReqAction")
  SelectRidPetState:AddLazyAction("BattleSwapSelectAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.RoundEx.BattleSwapSelectAction")
end

function BattleFsmEnv:SelectRidPetStateTransition()
  self:AddTransitionToState("SelectRidPetState", "StandbyState", FINISHED)
  self:AddTransitionToState("SelectRidPetState", "SwapPlayState", BattleEvent.EnterSwapPlay)
  self:AddTransitionToState("SelectRidPetState", "RoundPlayState", BattleEvent.EnterRoundPlay)
  self:AddTransitionToState("SelectRidPetState", "RoundSelectState", BattleEvent.EnterRoundSelect)
  self:AddTransitionToState("SelectRidPetState", "TeamBattleCatch", BattleEvent.EnterTeamCatch)
  self:AddTransitionToState("SelectRidPetState", "TeamBeastDefeatState", BattleEvent.EnterTeamBeastDefeat)
  self:AddTransitionToState("SelectRidPetState", "TeamBeastBattleCatch", BattleEvent.EnterTeamBeastCatch)
  self:AddTransitionToState("SelectRidPetState", "WaitingOtherState", BattleEvent.EnterWaitOther)
end

function BattleFsmEnv:EvolutionSelectStateBuilder()
  local EvolutionSelectState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.EvolutionSelect)
  EvolutionSelectState:AddLazyAction("BattleEvolutionSelectAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.RoundEx.BattleEvolutionSelectAction")
end

function BattleFsmEnv:EvolutionSelectStateTransition()
  self:AddTransitionToState("EvolutionSelectState", "StandbyState", FINISHED)
  self:AddTransitionToState("EvolutionSelectState", "RoundPlayState", BattleEvent.EnterRoundPlay)
  self:AddTransitionToState("EvolutionSelectState", "RoundSelectState", BattleEvent.EnterRoundSelect)
  self:AddTransitionToState("EvolutionSelectState", "TeamBattleCatch", BattleEvent.EnterTeamCatch)
  self:AddTransitionToState("EvolutionSelectState", "TeamBeastDefeatState", BattleEvent.EnterTeamBeastDefeat)
  self:AddTransitionToState("EvolutionSelectState", "TeamBeastBattleCatch", BattleEvent.EnterTeamBeastCatch)
end

function BattleFsmEnv:NpcAutoEscapeSelectStateBuilder()
  local NpcAutoEscapeSelectState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.NpcAutoEscapeSelect)
  NpcAutoEscapeSelectState:AddLazyAction("BattleNpcAutoEscapeSelectAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.RoundEx.BattleNpcAutoEscapeSelectAction", {
    RoundState = self.RoundStateVar
  })
end

function BattleFsmEnv:NpcAutoEscapeSelectStateTransition()
  self:AddTransitionToState("NpcAutoEscapeSelectState", "StandbyState", FINISHED)
  self:AddTransitionToState("NpcAutoEscapeSelectState", "RoundSelectState", BattleEvent.EnterRoundSelect)
  self:AddTransitionToState("NpcAutoEscapeSelectState", "TeamBattleCatch", BattleEvent.EnterTeamCatch)
  self:AddTransitionToState("NpcAutoEscapeSelectState", "TeamBeastDefeatState", BattleEvent.EnterTeamBeastDefeat)
  self:AddTransitionToState("NpcAutoEscapeSelectState", "TeamBeastBattleCatch", BattleEvent.EnterTeamBeastCatch)
  self:AddTransitionToState("NpcAutoEscapeSelectState", "RoundPlayState", BattleEvent.EnterRoundPlay)
  self:AddTransitionToState("NpcAutoEscapeSelectState", "EnemyNpcEscapeState", BattleEvent.EnterEnemyNpcEscape)
end

function BattleFsmEnv:SwapPlayStateBuilder()
  self.SwapPlayState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.SwapPlay)
  self.SwapPlayState:AddLazyAction("BattleEndPVPTime", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleEndPVPTimeAction")
  self.SwapPlayState:AddLazyAction("HideMainWindow", "NewRoco.Modules.Core.Battle.Fsm.Actions.HideBattleMainWindowAction")
  self.SwapPlayState:AddLazyAction("BeforeBattlePreloadTurnPlayResAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattlePreloadTurnPlayResAction", {
    Flows = self.BeforeSupplytFlows,
    SettleInfo = self.SettleInfoVar
  })
  self.SwapPlayState:AddLazyAction("BeforeSwapPlayTurnPlayer", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleTurnPlayerAction", {
    Flows = self.BeforeSupplytFlows,
    SettleInfo = self.SettleInfoVar,
    IsMySelfPerform = self.IsMySelfPerformVar
  })
  self.SwapPlayState:AddLazyAction("SwapPreloadSupplyPetAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattlePreloadSupplyPetPlayerAction", {
    Infos = self.SupplyInfosVar
  })
  self.SwapPlayState:AddLazyAction("SwapPlaySupplyPetAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleSupplyPetPlayerAction", {
    Infos = self.SupplyInfosVar
  })
  self.SwapPlayState:AddLazyAction("AfterBattlePreloadTurnPlayResAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattlePreloadTurnPlayResAction", {
    Flows = self.AfterSupplytFlows,
    SettleInfo = self.SettleInfoVar
  })
  self.SwapPlayState:AddLazyAction("AfterSwapPlayTurnPlayer", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleTurnPlayerAction", {
    Flows = self.AfterSupplytFlows,
    SettleInfo = self.SettleInfoVar,
    IsMySelfPerform = self.IsMySelfPerformVar
  })
  self.SwapPlayState:AddLazyAction("SendRoundFlowFinishReqAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.SendRoundFlowFinishReqAction", {
    Flows = self.FlowsVar,
    BattleState = _G.ProtoEnum.BATTLEFIELD_STATE.BATTLEFIELD_STATE_ROUND_PETY
  })
end

function BattleFsmEnv:SwapPlayStateTransition()
  self:AddTransitionToState("SwapPlayState", "StandbyState", FINISHED)
end

function BattleFsmEnv:RoundSelectStateBuilder()
  self.RoundSelectState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.RoundSelect)
  self.RoundSelectState:AddLazyAction("BattleOpenCriticalRedPanelAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleOpenCriticalRedPanelAction")
  self.RoundSelectState:AddLazyAction("BattleOpenPredictionAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleOpenPredictionAction")
  self.RoundSelectState:AddLazyAction("BattleOnLookerSpawnAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleOnLookerSpawnAction")
  self.RoundSelectState:AddLazyAction("BattleRoundSelectAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleRoundSelectAction", {
    RoundState = self.RoundStateVar
  })
end

function BattleFsmEnv:RoundSelectStateTransition()
  self:AddTransitionToState("RoundSelectState", "StandbyState", FINISHED)
  self:AddTransitionToState("RoundSelectState", "RoundPlayState", BattleEvent.EnterRoundPlay)
  self:AddTransitionToState("RoundSelectState", "StartInstantState", BattleEvent.EnterInstantPlay)
  self:AddTransitionToState("RoundSelectState", "WaitingOtherState", BattleEvent.EnterWaitOther)
  self:AddTransitionToState("RoundSelectState", "EnemyEscapeState", BattleEvent.EnterEnemyEscape)
  self:AddTransitionToState("RoundSelectState", "TeamBattleCatch", BattleEvent.EnterTeamCatch)
  self:AddTransitionToState("RoundSelectState", "FinalBattleToP2", BattleEvent.FinalBattleToP2)
  self:AddTransitionToState("RoundSelectState", "TeamBeastDefeatState", BattleEvent.EnterTeamBeastDefeat)
  self:AddTransitionToState("RoundSelectState", "TeamBeastBattleCatch", BattleEvent.EnterTeamBeastCatch)
end

function BattleFsmEnv:StartInstantStateBuilder()
  self.StartInstantState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.StartInstant)
  self.StartInstantState:AddLazyAction("HideMainWindow", "NewRoco.Modules.Core.Battle.Fsm.Actions.HideBattleMainWindowAction")
  self.StartInstantState:AddLazyAction("BattleClosePredictionAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleClosePredictionAction")
  self.StartInstantState:AddLazyAction("StartInstantAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.StartInstantAction")
end

function BattleFsmEnv:StartInstantStateTransition()
  self:AddTransitionToState("StartInstantState", "RoundSelectState", BattleEvent.EnterRoundSelect)
  self:AddTransitionToState("StartInstantState", "RoundPlayState", BattleEvent.EnterRoundPlay)
  self:AddTransitionToState("StartInstantState", "NormalOverState", BattleEvent.EnterNormalOver)
  self:AddTransitionToState("StartInstantState", "PlayerSkillEscapeState", BattleEvent.EnterPlayerSkillEscape)
  self:AddTransitionToState("StartInstantState", "FailOverState", BattleEvent.EnterFailOver)
  self:AddTransitionToState("StartInstantState", "EnemyEscapeState", BattleEvent.EnterEnemyEscape)
  self:AddTransitionToState("StartInstantState", "SeamlessOverState", BattleEvent.EnterSeamlessOver)
  self:AddTransitionToState("StartInstantState", "WorldLeaderSeamlessOverState", BattleEvent.EnterWorldLeaderSeamlessOver)
  self:AddTransitionToState("StartInstantState", "PVPOver", BattleEvent.EnterPVPOver)
  self:AddTransitionToState("StartInstantState", "PVPRankOver", BattleEvent.EnterPVPRankOver)
  self:AddTransitionToState("StartInstantState", "NpcChallengeOver", BattleEvent.EnterNpcChallengeOver)
  self:AddTransitionToState("StartInstantState", "TeamBloodBattleOver", BattleEvent.EnterBloodTeamBattleOver)
  self:AddTransitionToState("StartInstantState", "TeamBeastBattleOver", BattleEvent.EnterBeastTeamBattleOver)
  self:AddTransitionToState("StartInstantState", "TeamBattleCatch", BattleEvent.EnterTeamCatch)
  self:AddTransitionToState("StartInstantState", "TeamBeastDefeatState", BattleEvent.EnterTeamBeastDefeat)
  self:AddTransitionToState("StartInstantState", "TeamBeastBattleCatch", BattleEvent.EnterTeamBeastCatch)
  self:AddTransitionToState("StartInstantState", "StandbyState", FINISHED)
end

function BattleFsmEnv:RoundPlayStateBuilder()
  self.RoundPlayState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.RoundPlay)
  self.RoundPlayState:AddLazyAction("BattleEndPVPTime", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleEndPVPTimeAction")
  self.RoundPlayState:AddLazyAction("WaitForRoleHp", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleWaitRoleHpAnimationAction")
  self.RoundPlayState:AddLazyAction("HideMainWindow", "NewRoco.Modules.Core.Battle.Fsm.Actions.HideBattleMainWindowAction")
  self.RoundPlayState:AddLazyAction("BattleClosePredictionAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleClosePredictionAction")
  self.RoundPlayState:AddLazyAction("BattleCloseBagPanelAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleCloseBagPanelAction")
  self.RoundPlayState:AddLazyAction("BattleCloseNpcEscapeSelectPanelAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleCloseNpcEscapeSelectPanelAction")
  self.RoundPlayState:AddLazyAction("BattlePreloadTurnPlayResAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattlePreloadTurnPlayResAction", {
    Flows = self.FlowsVar,
    SettleInfo = self.SettleInfoVar
  })
  self.RoundPlayState:AddLazyAction("CloseBlackScreenAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.CloseBlackScreenAction")
  self.RoundPlayState:AddLazyAction("BattleRoundPlayAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleTurnPlayerAction", {
    Flows = self.FlowsVar,
    SettleInfo = self.SettleInfoVar,
    IsMySelfPerform = self.IsMySelfPerformVar
  })
  self.RoundPlayState:AddLazyAction("BattlePetRevertPosAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattlePetRevertPosAction")
  self.RoundPlayState:AddLazyAction("WaitForRoundPlay", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleWaitRoundPlayAction")
  self.RoundPlayState:AddLazyAction("ClearPendingKillModels", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleClearPendingKillModelsAction")
  self.RoundPlayState:AddLazyAction("SendRoundFlowFinishReqAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.SendRoundFlowFinishReqAction", {
    Flows = self.FlowsVar,
    BattleState = _G.ProtoEnum.BATTLEFIELD_STATE.BATTLEFIELD_STATE_ROUND_PLAY
  })
  self.RoundPlayState:AddLazyAction("RunTeamBattleAfterRoundPerformAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.RunTeamBattleAfterRoundPerformAction", {
    Flows = self.FlowsVar
  })
end

function BattleFsmEnv:RoundPlayStateTransition()
  self:AddTransitionToState("RoundPlayState", "StandbyState", FINISHED)
  self:AddTransitionToState("RoundPlayState", "NormalOverState", BattleEvent.EnterNormalOver)
  self:AddTransitionToState("RoundPlayState", "PlayerSkillEscapeState", BattleEvent.EnterPlayerSkillEscape)
  self:AddTransitionToState("RoundPlayState", "FailOverState", BattleEvent.EnterFailOver)
  self:AddTransitionToState("RoundPlayState", "EnemyEscapeState", BattleEvent.EnterEnemyEscape)
  self:AddTransitionToState("RoundPlayState", "SeamlessOverState", BattleEvent.EnterSeamlessOver)
  self:AddTransitionToState("RoundPlayState", "WorldLeaderSeamlessOverState", BattleEvent.EnterWorldLeaderSeamlessOver)
  self:AddTransitionToState("RoundPlayState", "RoundPlayState", BattleEvent.EnterRoundPlay)
  self:AddTransitionToState("RoundPlayState", "PVPOver", BattleEvent.EnterPVPOver)
  self:AddTransitionToState("RoundPlayState", "PVPRankOver", BattleEvent.EnterPVPRankOver)
  self:AddTransitionToState("RoundPlayState", "NpcChallengeOver", BattleEvent.EnterNpcChallengeOver)
  self:AddTransitionToState("RoundPlayState", "TeamBloodBattleOver", BattleEvent.EnterBloodTeamBattleOver)
  self:AddTransitionToState("RoundPlayState", "TeamBeastBattleOver", BattleEvent.EnterBeastTeamBattleOver)
  self:AddTransitionToState("RoundPlayState", "RoundSelectState", BattleEvent.EnterRoundSelect)
  self:AddTransitionToState("RoundPlayState", "TeamBattleCatch", BattleEvent.EnterTeamCatch)
  self:AddTransitionToState("RoundPlayState", "FinalBattleToP2", BattleEvent.FinalBattleToP2)
  self:AddTransitionToState("RoundPlayState", "TeamBeastDefeatState", BattleEvent.EnterTeamBeastDefeat)
  self:AddTransitionToState("RoundPlayState", "TeamBeastBattleCatch", BattleEvent.EnterTeamBeastCatch)
  self:AddTransitionToState("RoundPlayState", "SelectRidPetState", BattleEvent.EnterSelectRidPet)
end

function BattleFsmEnv:RevertTeamBattleStateBuilder()
  local RevertTeamBattleState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.RevertTeamBattleState)
  RevertTeamBattleState:AddLazyAction("BattleFocusCameraToTeampetAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleFocusCameraToTeampetAction")
  RevertTeamBattleState:AddLazyAction("ShowAndResetBattlePawnsAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.ShowAndResetBattlePawnsAction")
end

function BattleFsmEnv:RevertTeamBattleStateTransition()
  self:AddTransitionToState("RevertTeamBattleState", "RoundSelectState", FINISHED)
  self:AddTransitionToState("RevertTeamBattleState", "RoundSelectState", BattleEvent.EnterRoundSelect)
end

function BattleFsmEnv:TeamBattleCatchBuilder()
  local TeamBattleCatch = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.TeamBattleCatch)
  TeamBattleCatch:AddLazyAction("HideMainWindow", "NewRoco.Modules.Core.Battle.Fsm.Actions.HideBattleMainWindowAction")
  TeamBattleCatch:AddLazyAction("BattleClosePredictionAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleClosePredictionAction")
  TeamBattleCatch:AddLazyAction("BattleTeamEnterCatchAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleTeamEnterCatchAction")
end

function BattleFsmEnv:TeamBattleCatchTransition()
  self:AddTransitionToState("TeamBattleCatch", "RoundSelectState", BattleEvent.EnterRoundSelect)
end

function BattleFsmEnv:FinalBattleToP2Builder()
  local FinalBattleToP2 = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.FinalBattleToP2)
  FinalBattleToP2:AddLazyAction("HideMainWindow", "NewRoco.Modules.Core.Battle.Fsm.Actions.HideBattleMainWindowAction")
  FinalBattleToP2:AddLazyAction("BattleFBSwitchToP2Action", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleFBSwitchToP2Action")
  FinalBattleToP2:AddLazyAction("BattleFinalShowFieldAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleFinalShowFieldAction")
  FinalBattleToP2:AddLazyAction("ShowBattlePawnsAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.ShowBattlePawnsAction")
  FinalBattleToP2:AddLazyAction("BattleFBP2SummerAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleFBP2SummerAction")
end

function BattleFsmEnv:FinalBattleToP2Transition()
  self:AddTransitionToState("FinalBattleToP2", "RoundSelectState", FINISHED)
end

function BattleFsmEnv:TeamBeastDefeatStateBuilder()
  local TeamBeastDefeatState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.TeamBeastDefeatState)
  TeamBeastDefeatState:AddLazyAction("HideMainWindow", "NewRoco.Modules.Core.Battle.Fsm.Actions.HideBattleMainWindowAction")
  TeamBeastDefeatState:AddLazyAction("BattleClosePredictionAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleClosePredictionAction")
  TeamBeastDefeatState:AddLazyAction("BattleTeamBeastDefeatAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleTeamBeastDefeatAction")
  TeamBeastDefeatState:AddLazyAction("BattleShowTeamBeastCatchUIAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowTeamBeastCatchUIAction")
end

function BattleFsmEnv:TeamBeastDefeatStateTransition()
  self:AddTransitionToState("TeamBeastDefeatState", "TeamBeastBattleCatch", BattleEvent.EnterTeamBeastCatch)
  self:AddTransitionToState("TeamBeastDefeatState", "StandbyState", FINISHED)
end

function BattleFsmEnv:TeamBeastBattleCatchBuilder()
  local TeamBeastBattleCatch = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.TeamBeastBattleCatch)
  TeamBeastBattleCatch:AddLazyAction("HideMainWindow", "NewRoco.Modules.Core.Battle.Fsm.Actions.HideBattleMainWindowAction")
  TeamBeastBattleCatch:AddLazyAction("BattleClosePredictionAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleClosePredictionAction")
  TeamBeastBattleCatch:AddLazyAction("BattleTeamBeastBeStun", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleTeamBeastBeStun")
  TeamBeastBattleCatch:AddLazyAction("BattleTeamBeastEnterCatchAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleTeamBeastEnterCatchAction")
end

function BattleFsmEnv:TeamBeastBattleCatchTransition()
  self:AddTransitionToState("TeamBeastBattleCatch", "RoundSelectState", BattleEvent.EnterRoundSelect)
end

function BattleFsmEnv:WaitingOtherStateBuilder()
  local WaitingOtherState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.WaitingOther)
  WaitingOtherState:AddLazyAction("HideMainWindow", "NewRoco.Modules.Core.Battle.Fsm.Actions.HideBattleMainWindowAction")
  WaitingOtherState:AddLazyAction("WaitOtherAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.WaitOtherAction")
end

function BattleFsmEnv:WaitingOtherStateTransition()
  self:AddTransitionToState("WaitingOtherState", "RoundPlayState", BattleEvent.EnterRoundPlay)
  self:AddTransitionToState("WaitingOtherState", "SwapPlayState", BattleEvent.EnterSwapPlay)
  self:AddTransitionToState("WaitingOtherState", "RoundSelectState", BattleEvent.EnterRoundSelect)
  self:AddTransitionToState("WaitingOtherState", "TeamBattleCatch", BattleEvent.EnterTeamCatch)
  self:AddTransitionToState("WaitingOtherState", "TeamBeastDefeatState", BattleEvent.EnterTeamBeastDefeat)
  self:AddTransitionToState("WaitingOtherState", "TeamBeastBattleCatch", BattleEvent.EnterTeamBeastCatch)
end

function BattleFsmEnv:ReBuildBattleFieldStateBuilder()
  local ReBuildBattleFieldState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.ReBuildBattleFieldState)
  ReBuildBattleFieldState:AddLazyAction("OpenBlackScreenAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.OpenBlackScreenAction")
  ReBuildBattleFieldState:AddLazyAction("HideMainWindow", "NewRoco.Modules.Core.Battle.Fsm.Actions.HideBattleMainWindowAction")
  ReBuildBattleFieldState:AddLazyAction("BattleRebuildBattleFieldAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleRebuildBattleFieldAction")
  ReBuildBattleFieldState:AddLazyAction("ShowBattlePawnsAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.ShowBattlePawnsAction")
  ReBuildBattleFieldState:AddLazyAction("BattleFocusCameraToTeampetAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleFocusCameraToTeampetAction")
  ReBuildBattleFieldState:AddLazyAction("CloseBlackScreenAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.CloseBlackScreenAction")
  ReBuildBattleFieldState:AddLazyAction("SendLoadFinishReqAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.SendLoadFinishReqAction")
end

function BattleFsmEnv:ReBuildBattleFieldStateTransition()
  self:AddTransitionToState("ReBuildBattleFieldState", "NormalOverState", BattleEvent.EnterNormalOver)
  self:AddTransitionToState("ReBuildBattleFieldState", "PlayerSkillEscapeState", BattleEvent.EnterPlayerSkillEscape)
  self:AddTransitionToState("ReBuildBattleFieldState", "FailOverState", BattleEvent.EnterFailOver)
  self:AddTransitionToState("ReBuildBattleFieldState", "SeamlessOverState", BattleEvent.EnterSeamlessOver)
  self:AddTransitionToState("ReBuildBattleFieldState", "WorldLeaderSeamlessOverState", BattleEvent.EnterWorldLeaderSeamlessOver)
  self:AddTransitionToState("ReBuildBattleFieldState", "PVPOver", BattleEvent.EnterPVPOver)
  self:AddTransitionToState("ReBuildBattleFieldState", "PVPRankOver", BattleEvent.EnterPVPRankOver)
  self:AddTransitionToState("ReBuildBattleFieldState", "NpcChallengeOver", BattleEvent.EnterNpcChallengeOver)
  self:AddTransitionToState("ReBuildBattleFieldState", "TeamBloodBattleOver", BattleEvent.EnterBloodTeamBattleOver)
  self:AddTransitionToState("ReBuildBattleFieldState", "TeamBeastBattleOver", BattleEvent.EnterBeastTeamBattleOver)
  self:AddTransitionToState("ReBuildBattleFieldState", "PrePlayState", BattleEvent.EnterPrePlay)
  self:AddTransitionToState("ReBuildBattleFieldState", "SwapSelectState", BattleEvent.EnterSwapSelect)
  self:AddTransitionToState("ReBuildBattleFieldState", "SelectRidPetState", BattleEvent.EnterSelectRidPet)
  self:AddTransitionToState("ReBuildBattleFieldState", "EvolutionSelectState", BattleEvent.EnterEvolutionSelect)
  self:AddTransitionToState("ReBuildBattleFieldState", "NpcAutoEscapeSelectState", BattleEvent.EnterNpcAutoEscape)
  self:AddTransitionToState("ReBuildBattleFieldState", "SwapPlayState", BattleEvent.EnterSwapPlay)
  self:AddTransitionToState("ReBuildBattleFieldState", "RoundSelectState", BattleEvent.EnterRoundSelect)
  self:AddTransitionToState("ReBuildBattleFieldState", "RevertTeamBattleState", BattleEvent.EnterRevertTeamBattle)
  self:AddTransitionToState("ReBuildBattleFieldState", "TeamBattleCatch", BattleEvent.EnterTeamCatch)
  self:AddTransitionToState("ReBuildBattleFieldState", "TeamBeastDefeatState", BattleEvent.EnterTeamBeastDefeat)
  self:AddTransitionToState("ReBuildBattleFieldState", "TeamBeastBattleCatch", BattleEvent.EnterTeamBeastCatch)
  self:AddTransitionToState("ReBuildBattleFieldState", "WaitingOtherState", BattleEvent.EnterWaitOther)
  self:AddTransitionToState("ReBuildBattleFieldState", "RoundPlayState", BattleEvent.EnterRoundPlay)
  self:AddTransitionToState("ReBuildBattleFieldState", "EnemyEscapeState", BattleEvent.EnterEnemyEscape)
  self:AddTransitionToState("ReBuildBattleFieldState", "EnemyNpcEscapeState", BattleEvent.EnterEnemyNpcEscape)
  self:AddTransitionToState("ReBuildBattleFieldState", "CatchSuccessState", BattleEvent.EnterCatchSuccess)
  self:AddTransitionToState("ReBuildBattleFieldState", "StandbyState", FINISHED)
end

function BattleFsmEnv:NormalOverStateBuilder()
  self.NormalOverState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.NormalOver)
  self.NormalOverState:AddLazyAction("BattleUnlockLodAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleUnlockLodAction")
  self.NormalOverState:AddLazyAction("BattleCloseCriticalRedPanelAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleCloseCriticalRedPanelAction")
  self.NormalOverState:AddLazyAction("BattleEndPVPTime", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleEndPVPTimeAction")
  self.NormalOverState:AddLazyAction("OpenBlackScreenAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.OpenBlackScreenAction")
  self.NormalOverState:AddLazyAction("BattleShowSceneTreesAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowSceneTreesAction")
  self.NormalOverState:AddLazyAction("BattleShowSceneActorAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowSceneActorAction")
  self.NormalOverState:AddLazyAction("BattleUnlockTeleportAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.Teleport.BattleUnlockTeleportAction")
  self.NormalOverState:AddLazyAction("NormalOverAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.NormalOverAction")
  self.NormalOverState:AddLazyAction("TeleportBackAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.TeleportBackAction")
  self.NormalOverState:AddLazyAction("CloseBlackScreenAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.CloseBlackScreenAction")
  self.NormalOverState:AddLazyAction("SendBattleFinishAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.SendBattleFinishAction")
end

function BattleFsmEnv:NormalOverStateTransition()
  self:AddTransitionToState("NormalOverState", "StandbyState", FINISHED)
end

function BattleFsmEnv:PlayerSkillEscapeStateBuilder()
  local PlayerSkillEscapeState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.PlayerSkillEscape)
  PlayerSkillEscapeState:AddLazyAction("BattleUnlockLodAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleUnlockLodAction")
  PlayerSkillEscapeState:AddLazyAction("BattleShowSceneTreesAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowSceneTreesAction")
  PlayerSkillEscapeState:AddLazyAction("BattleShowSceneActorAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowSceneActorAction")
  PlayerSkillEscapeState:AddLazyAction("BattleUnlockTeleportAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.Teleport.BattleUnlockTeleportAction")
  PlayerSkillEscapeState:AddLazyAction("PlayerSkillEscapeOutAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.PlayerSkillEscapeOutAction")
  PlayerSkillEscapeState:AddLazyAction("NormalOverAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.NormalOverAction")
  PlayerSkillEscapeState:AddLazyAction("TeleportBackAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.TeleportBackAction")
  PlayerSkillEscapeState:AddLazyAction("SendBattleFinishAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.SendBattleFinishAction")
end

function BattleFsmEnv:PlayerSkillEscapeStateTransition()
  self:AddTransitionToState("PlayerSkillEscapeState", "StandbyState", FINISHED)
end

function BattleFsmEnv:SeamlessOverStateBuilder()
  self.SeamlessOverState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.SeamlessOver)
  self.SeamlessOverState:AddLazyAction("BattleCloseCriticalRedPanelAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleCloseCriticalRedPanelAction")
  self.SeamlessOverState:AddLazyAction("SeamlessOverAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.SeamlessOverAction")
  self.SeamlessOverState:AddLazyAction("BattleShowSceneTreesAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowSceneTreesAction", {
    StartDelegate = self.ShowSceneTreesDelegateVar
  })
  self.SeamlessOverState:AddLazyAction("BattleSeamlessNpcOverAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleSeamlessNpcOverAction", {
    [BattleConst.FsmVarNames.ShowSceneTreesDelegate] = self.ShowSceneTreesDelegateVar
  })
  self.SeamlessOverState:AddLazyAction("LeaveBattleAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.LeaveBattleAction", {
    [BattleConst.FsmVarNames.ShowSceneTreesDelegate] = self.ShowSceneTreesDelegateVar
  })
  self.SeamlessOverState:AddLazyAction("SendRoundFlowFinishReqAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.SendRoundFlowFinishReqAction")
end

function BattleFsmEnv:SeamlessOverStateTransition()
  self:AddTransitionToState("SeamlessOverState", "StandbyState", FINISHED)
  self:AddTransitionToState("SeamlessOverState", "LeaveBattlePureBlackOutState", BattleEvent.EnterPureBlackOut)
end

function BattleFsmEnv:PVPOverBuilder()
  local PVPOver = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.PVPOver)
  PVPOver:AddLazyAction("CloseBlackScreenAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.CloseBlackScreenAction")
  PVPOver:AddLazyAction("BattleUnlockLodAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleUnlockLodAction")
  PVPOver:AddLazyAction("BattleCloseCriticalRedPanelAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleCloseCriticalRedPanelAction")
  PVPOver:AddLazyAction("BattleEndPVPTime", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleEndPVPTimeAction")
  PVPOver:AddLazyAction("BattleShowEscapeAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowEscapeAction")
  PVPOver:AddLazyAction("BattlePVPShowFailPlayer", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattlePVPShowFailPlayer")
  PVPOver:AddLazyAction("BattlePVPShowResultUI", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattlePVPShowResultUI")
  PVPOver:AddLazyAction("OpenBlackScreenAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.OpenBlackScreenAction")
  PVPOver:AddLazyAction("BattleShowSceneTreesAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowSceneTreesAction")
  PVPOver:AddLazyAction("BattleShowSceneActorAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowSceneActorAction")
  PVPOver:AddLazyAction("BattleTransformToDestory", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleTransformToDestory")
end

function BattleFsmEnv:PVPOverTransition()
  self:AddTransitionToState("PVPOver", "StandbyState", FINISHED)
end

function BattleFsmEnv:PVPRankOverBuilder()
  local PVPRankOver = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.PVPRankOver)
  PVPRankOver:AddLazyAction("CloseBlackScreenAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.CloseBlackScreenAction")
  PVPRankOver:AddLazyAction("BattleUnlockLodAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleUnlockLodAction")
  PVPRankOver:AddLazyAction("BattleCloseCriticalRedPanelAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleCloseCriticalRedPanelAction")
  PVPRankOver:AddLazyAction("BattleEndPVPTime", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleEndPVPTimeAction")
  PVPRankOver:AddLazyAction("BattleShowEscapeAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowEscapeAction")
  PVPRankOver:AddLazyAction("BattlePVPShowFailPlayer", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattlePVPShowFailPlayer")
  PVPRankOver:AddLazyAction("BattlePVPShowResultUI", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattlePVPShowResultUI")
  PVPRankOver:AddLazyAction("BattlePvpRankMatchEnterAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattlePvpRankMatchEnterAction")
  PVPRankOver:AddLazyAction("BattleShowSceneTreesAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowSceneTreesAction")
  PVPRankOver:AddLazyAction("BattleShowSceneActorAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowSceneActorAction")
  PVPRankOver:AddLazyAction("BattleTransformToDestory", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleTransformToDestory")
end

function BattleFsmEnv:PVPRankOverTransition()
  self:AddTransitionToState("PVPRankOver", "StandbyState", FINISHED)
end

function BattleFsmEnv:NpcChallengeOverBuilder()
  local NpcChallengeOver = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.NpcChallengeOver)
  NpcChallengeOver:AddLazyAction("CloseBlackScreenAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.CloseBlackScreenAction")
  NpcChallengeOver:AddLazyAction("BattleUnlockLodAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleUnlockLodAction")
  NpcChallengeOver:AddLazyAction("BattleCloseCriticalRedPanelAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleCloseCriticalRedPanelAction")
  NpcChallengeOver:AddLazyAction("BattleEndPVPTime", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleEndPVPTimeAction")
  NpcChallengeOver:AddLazyAction("BattleShowEscapeAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowEscapeAction")
  NpcChallengeOver:AddLazyAction("BattlePVPShowFailPlayer", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattlePVPShowFailPlayer")
  NpcChallengeOver:AddLazyAction("BattlePVPShowResultUI", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattlePVPShowResultUI")
  NpcChallengeOver:AddLazyAction("BattleLeaderChallengeShowResultUI", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleLeaderChallengeShowResultUI")
  NpcChallengeOver:AddLazyAction("OpenBlackScreenAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.OpenBlackScreenAction")
  NpcChallengeOver:AddLazyAction("BattleShowSceneTreesAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowSceneTreesAction")
  NpcChallengeOver:AddLazyAction("BattleShowSceneActorAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowSceneActorAction")
  NpcChallengeOver:AddLazyAction("BattleTransformToDestory", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleTransformToDestory")
end

function BattleFsmEnv:NpcChallengeOverTransition()
  self:AddTransitionToState("NpcChallengeOver", "StandbyState", FINISHED)
end

function BattleFsmEnv:TeamBloodBattleOverBuilder()
  local TeamBloodBattleOver = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.TeamBloodBattleOver)
  TeamBloodBattleOver:AddLazyAction("CloseBlackScreenAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.CloseBlackScreenAction")
  TeamBloodBattleOver:AddLazyAction("BattleUnlockLodAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleUnlockLodAction")
  TeamBloodBattleOver:AddLazyAction("BattleCloseCriticalRedPanelAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleCloseCriticalRedPanelAction")
  TeamBloodBattleOver:AddLazyAction("BattleShowTeamBattleResultUIAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowTeamBattleResultUIAction")
  TeamBloodBattleOver:AddLazyAction("BattleShowTeamBattleWinAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowTeamBattleWinAction")
  TeamBloodBattleOver:AddLazyAction("OpenBlackScreenAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.OpenBlackScreenAction")
  TeamBloodBattleOver:AddLazyAction("BattleShowSceneTreesAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowSceneTreesAction")
  TeamBloodBattleOver:AddLazyAction("BattleShowSceneActorAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowSceneActorAction")
  TeamBloodBattleOver:AddLazyAction("BattleTransformToDestory", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleTransformToDestory")
end

function BattleFsmEnv:TeamBloodBattleOverTransition()
  self:AddTransitionToState("TeamBloodBattleOver", "StandbyState", FINISHED)
end

function BattleFsmEnv:TeamBeastBattleOverBuilder()
  local TeamBeastBattleOver = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.TeamBeastBattleOver)
  TeamBeastBattleOver:AddLazyAction("CloseBlackScreenAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.CloseBlackScreenAction")
  TeamBeastBattleOver:AddLazyAction("BattleUnlockLodAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleUnlockLodAction")
  TeamBeastBattleOver:AddLazyAction("BattleCloseCriticalRedPanelAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleCloseCriticalRedPanelAction")
  TeamBeastBattleOver:AddLazyAction("BattleShowTeamBattleResultUIAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowTeamBattleResultUIAction")
  TeamBeastBattleOver:AddLazyAction("OpenBlackScreenAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.OpenBlackScreenAction")
  TeamBeastBattleOver:AddLazyAction("BattleShowSceneTreesAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowSceneTreesAction")
  TeamBeastBattleOver:AddLazyAction("BattleShowSceneActorAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowSceneActorAction")
  TeamBeastBattleOver:AddLazyAction("BattleTransformToDestory", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleTransformToDestory")
end

function BattleFsmEnv:TeamBeastBattleOverTransition()
  self:AddTransitionToState("TeamBeastBattleOver", "StandbyState", FINISHED)
end

function BattleFsmEnv:FailOverStateBuilder()
  local FailOverState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.FailOver)
  FailOverState:AddLazyAction("BattleUnlockLodAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleUnlockLodAction")
  FailOverState:AddLazyAction("HideMainWindow", "NewRoco.Modules.Core.Battle.Fsm.Actions.HideBattleMainWindowAction")
  FailOverState:AddLazyAction("BattleCloseCriticalRedPanelAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleCloseCriticalRedPanelAction")
  FailOverState:AddLazyAction("BattleUnlockTeleportWithCallbackAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.Teleport.BattleUnlockTeleportWithCallbackAction")
  FailOverState:AddLazyAction("BattleShowSceneTreesAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowSceneTreesAction")
  FailOverState:AddLazyAction("BattleShowSceneActorAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowSceneActorAction")
  FailOverState:AddLazyAction("NormalOverAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.NormalOverAction")
  FailOverState:AddLazyAction("TeleportBackAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.TeleportBackAction")
  FailOverState:AddLazyAction("SendBattleFinishAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.SendBattleFinishAction")
end

function BattleFsmEnv:FailOverStateTransition()
  self:AddTransitionToState("FailOverState", "StandbyState", FINISHED)
end

function BattleFsmEnv:PvpPlayerPerformBuilder()
  local PvpPlayerPerform = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.PvpPlayerPerform)
  PvpPlayerPerform:AddLazyAction("BattlePvpPlayerPerformAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattlePvpPlayerPerformAction")
end

function BattleFsmEnv:PvpPlayerPerformTransition()
  self:AddTransitionToState("PvpPlayerPerform", "StandbyState", FINISHED)
end

function BattleFsmEnv:FinalBattleOverBuilder()
  local FinalBattleOver = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.FinalBattleOver)
  FinalBattleOver:AddLazyAction("BattleUnlockLodAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleUnlockLodAction")
  FinalBattleOver:AddLazyAction("BattleCloseCriticalRedPanelAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleCloseCriticalRedPanelAction")
  FinalBattleOver:AddLazyAction("FinalBattleOverPreloadResAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.FinalBattleOverPreloadResAction")
  FinalBattleOver:AddLazyAction("FinalBattleOverPlaySeq1Action", "NewRoco.Modules.Core.Battle.Fsm.Actions.FinalBattleOverPlaySeq1Action")
  FinalBattleOver:AddLazyAction("OpenBlackScreenAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.OpenBlackScreenAction")
  FinalBattleOver:AddLazyAction("BattleShowSceneTreesAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowSceneTreesAction")
  FinalBattleOver:AddLazyAction("BattleShowSceneActorAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowSceneActorAction")
  FinalBattleOver:AddLazyAction("SendRoundFlowFinishReqAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.SendRoundFlowFinishReqAction")
end

function BattleFsmEnv:FinalBattleOverTransition()
  self:AddTransitionToState("FinalBattleOver", "StandbyState", FINISHED)
end

function BattleFsmEnv:CatchSuccessStateBuilder()
  local CatchSuccessState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.CatchSuccess)
  CatchSuccessState:AddLazyAction("BattleShowSceneTreesAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowSceneTreesAction")
  CatchSuccessState:AddLazyAction("BattleShowSceneActorAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowSceneActorAction")
end

function BattleFsmEnv:CatchSuccessStateTransition()
  self:AddTransitionToState("CatchSuccessState", "DestroyState", FINISHED)
  self:AddTransitionToState("CatchSuccessState", "DirectOverState", FINISHED)
end

function BattleFsmEnv:EnemyEscapeStateBuilder()
  self.EnemyEscapeState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.EnemyEscape)
  self.EnemyEscapeState:AddLazyAction("BattleCloseCriticalRedPanelAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleCloseCriticalRedPanelAction")
  self.EnemyEscapeState:AddLazyAction("BattleShowSceneTreesAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowSceneTreesAction")
  self.EnemyEscapeState:AddLazyAction("BattleShowSceneActorAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowSceneActorAction")
  self.EnemyEscapeState:AddLazyAction("HideMainWindow", "NewRoco.Modules.Core.Battle.Fsm.Actions.HideBattleMainWindowAction")
  self.EnemyEscapeState:AddLazyAction("EnemyPetEscapeAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.EnemyPetEscapeAction")
end

function BattleFsmEnv:EnemyEscapeStateTransition()
  self:AddTransitionToState("EnemyEscapeState", "DestroyState", FINISHED)
  self:AddTransitionToState("EnemyEscapeState", "DirectOverState", FINISHED)
end

function BattleFsmEnv:LeaveBattlePureBlackOutStateBuilder()
  self.LeaveBattlePureBlackOutState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.LeaveBattlePureBlackOut)
  self.LeaveBattlePureBlackOutState:AddLazyAction("OpenBlackScreenAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.OpenBlackScreenAction")
  self.LeaveBattlePureBlackOutState:AddLazyAction("BattleShowSceneTreesAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowSceneTreesAction")
  self.LeaveBattlePureBlackOutState:AddLazyAction("BattleShowSceneActorAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowSceneActorAction")
  self.LeaveBattlePureBlackOutState:AddLazyAction("BattlePureBlackOutSendReqAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattlePureBlackOutSendReqAction")
end

function BattleFsmEnv:LeaveBattlePureBlackOutStateTransition()
  self:AddTransitionToState("LeaveBattlePureBlackOutState", "StandbyState", FINISHED)
end

function BattleFsmEnv:BattleFsmBuilder()
end

function BattleFsmEnv:BattleFsmEnvTransition()
  self:AddTransitionToState("BattleFsm", "DestroyState", BattleEvent.ExitBattle)
  self:AddTransitionToState("BattleFsm", "DirectOverState", BattleEvent.DirectOverBattle)
  self:AddTransitionToState("BattleFsm", "NormalOverState", BattleEvent.EnterNormalOver)
  self:AddTransitionToState("BattleFsm", "WorldLeaderRunAwayState", BattleEvent.EnterRunAwayLeadFight)
  self:AddTransitionToState("BattleFsm", "FailOverState", BattleEvent.EnterFailOver)
  self:AddTransitionToState("BattleFsm", "NpcChallengeOver", BattleEvent.EnterNpcChallengeOver)
  self:AddTransitionToState("BattleFsm", "TeamBloodBattleOver", BattleEvent.EnterBloodTeamBattleOver)
  self:AddTransitionToState("BattleFsm", "TeamBeastBattleOver", BattleEvent.EnterBeastTeamBattleOver)
  self:AddTransitionToState("BattleFsm", "PlayerSkillEscapeState", BattleEvent.EnterPlayerSkillEscape)
  self:AddTransitionToState("BattleFsm", "EnemyEscapeState", BattleEvent.EnterEnemyEscape)
  self:AddTransitionToState("BattleFsm", "PvpPlayerPerform", BattleEvent.EnterPvpPlayerPerform)
end

function BattleFsmEnv:DestroyStateBuilder()
  self.DestroyState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.Destroy)
  self.DestroyState:AddLazyAction("BattleUnlockLodAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleUnlockLodAction")
  self.DestroyState:AddLazyAction("BattleUnlockTeleportAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.Teleport.BattleUnlockTeleportAction")
  self.DestroyState:AddLazyAction("BattleDestroyAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleDestroyAction")
  self.DestroyState:AddLazyAction("TeleportBackAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.TeleportBackAction")
  self.DestroyState:AddLazyAction("CloseBlackScreenAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.CloseBlackScreenAction")
  self.DestroyState:AddLazyAction("CloseLoadingCurtainAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.CloseLoadingCurtainAction")
  self.DestroyState:AddLazyAction("SendBattleFinishAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.SendBattleFinishAction")
end

function BattleFsmEnv:DestroyStateTransition()
  self:AddTransitionToState("DestroyState", "StandbyState", FINISHED)
end

function BattleFsmEnv:DirectOverStateBuilder()
  self.DirectOverState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.DirectOver)
  self.DirectOverState:AddLazyAction("BattleUnlockLodAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleUnlockLodAction")
  self.DirectOverState:AddLazyAction("BattleCloseCriticalRedPanelAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleCloseCriticalRedPanelAction")
  self.DirectOverState:AddLazyAction("BattleShowSceneTreesAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowSceneTreesAction")
  self.DirectOverState:AddLazyAction("BattleShowSceneActorAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowSceneActorAction")
  self.DirectOverState:AddLazyAction("BattleUnlockTeleportAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.Teleport.BattleUnlockTeleportAction")
  self.DirectOverState:AddLazyAction("BattleDestroyAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleDestroyAction")
  self.DirectOverState:AddLazyAction("TeleportBackAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.TeleportBackAction")
  self.DirectOverState:AddLazyAction("CloseBlackScreenAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.CloseBlackScreenAction")
  self.DirectOverState:AddLazyAction("SendBattleFinishAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.SendBattleFinishAction")
end

function BattleFsmEnv:DirectOverStateTransition()
end

function BattleFsmEnv:EnemyNpcEscapeStateBuilder()
  self.EnemyNpcEscapeState = self.BattleFsm:CreateSequentialState(BattleEnum.StateNames.EnemyNpcEscape)
  self.EnemyNpcEscapeState:AddLazyAction("BattleCloseCriticalRedPanelAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleCloseCriticalRedPanelAction")
  self.EnemyNpcEscapeState:AddLazyAction("HideMainWindow", "NewRoco.Modules.Core.Battle.Fsm.Actions.HideBattleMainWindowAction")
  self.EnemyNpcEscapeState:AddLazyAction("EnemyNpcEscapeAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.EnemyNpcEscapeAction", {
    RoundState = self.RoundStateVar
  })
  self.EnemyNpcEscapeState:AddLazyAction("OpenBlackScreenAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.OpenBlackScreenAction")
  self.EnemyNpcEscapeState:AddLazyAction("BattleShowSceneTreesAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowSceneTreesAction")
  self.EnemyNpcEscapeState:AddLazyAction("BattleShowSceneActorAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleShowSceneActorAction")
end

function BattleFsmEnv:EnemyNpcEscapeStateTransition()
  self:AddTransitionToState("EnemyNpcEscapeState", "DestroyState", FINISHED)
  self:AddTransitionToState("EnemyNpcEscapeState", "DirectOverState", FINISHED)
end

return BattleFsmEnv
