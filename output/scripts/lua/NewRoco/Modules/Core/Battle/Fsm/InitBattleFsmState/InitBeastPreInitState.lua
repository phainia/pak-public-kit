local InitBeastPreInitState = {}

function InitBeastPreInitState.FillState(state, ...)
  if not state then
    return
  end
  state:AddLazyAction("BattlePreloadEssentailResAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.Res.BattlePreloadEssentailResAction")
  state:AddLazyAction("BeastPreloadStart", "NewRoco.Modules.Core.Battle.Fsm.Actions.TeamBeastEnter.BeastPreloadStart")
  state:AddLazyAction("BeastPreloadField", "NewRoco.Modules.Core.Battle.Fsm.Actions.TeamBeastEnter.BeastPreloadField", {IsAsync = true})
  state:AddLazyAction("BattlePreloadMainWindowAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.Res.BattlePreloadMainWindowAction")
  state:AddLazyAction("BattlePreloadResAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.Res.BattlePreloadResAction", {IsAsync = true})
  state:AddLazyAction("BeastStartPerform", "NewRoco.Modules.Core.Battle.Fsm.Actions.TeamBeastEnter.BeastStartPerform")
  state:AddLazyAction("BeastCheckFieldReady", "NewRoco.Modules.Core.Battle.Fsm.Actions.TeamBeastEnter.BeastCheckFieldReady")
  state:AddLazyAction("BeastInitField", "NewRoco.Modules.Core.Battle.Fsm.Actions.TeamBeastEnter.BeastInitField")
  state:AddLazyAction("BattleFindNearbyBattleLocation", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleFindNearbyBattleLocation")
  state:AddLazyAction("BattleConstructNearbyBattleEnvAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleConstructNearbyBattleEnvAction")
  state:AddLazyAction("BattleHideSceneTreesAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleHideSceneTreesAction")
  state:AddLazyAction("BeastPreloadBattleActor", "NewRoco.Modules.Core.Battle.Fsm.Actions.TeamBeastEnter.BeastPreloadBattleActor", {IsAsync = true})
  state:AddLazyAction("BeastPlaySequence", "NewRoco.Modules.Core.Battle.Fsm.Actions.TeamBeastEnter.BeastPlaySequence")
  state:AddLazyAction("BeastCheckBattleActor", "NewRoco.Modules.Core.Battle.Fsm.Actions.TeamBeastEnter.BeastCheckBattleActor")
  state:AddLazyAction("BeastPlayEnterPerform", "NewRoco.Modules.Core.Battle.Fsm.Actions.TeamBeastEnter.BeastPlayEnterPerform")
  state:AddLazyAction("BattleHideScenePetAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleHideScenePetAction")
  state:AddLazyAction("ShowBattlePawnsAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.ShowBattlePawnsAction")
  state:AddLazyAction("CloseBlackScreenAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.CloseBlackScreenAction")
  state:AddLazyAction("BattleReconnectShowEnterBuffAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleReconnectShowEnterBuffAction")
  state:AddLazyAction("BattleOpenCriticalRedPanelAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.BattleOpenCriticalRedPanelAction")
  state:AddLazyAction("SendLoadFinishReqAction", "NewRoco.Modules.Core.Battle.Fsm.Actions.SendLoadFinishReqAction")
end

return InitBeastPreInitState
