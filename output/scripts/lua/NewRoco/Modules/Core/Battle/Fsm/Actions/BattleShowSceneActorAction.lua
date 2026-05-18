local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattleActionBase
local BattleShowSceneActorAction = Base:Extend("BattleShowSceneActorAction")
FsmUtils.MergeMembers(Base, BattleShowSceneActorAction, {})

function BattleShowSceneActorAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleShowSceneActorAction:OnEnter()
  Log.Debug("BattleShowSceneTreesAction OnEnter")
  NRCModeManager:DoCmd(PlayerModuleCmd.HIDE_ALL, false)
  local localPlayer = NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if localPlayer and localPlayer.viewObj then
    localPlayer.viewObj:SetActorHiddenInGame(false)
  end
  self:Finish()
end

function BattleShowSceneActorAction:OnExit()
end

return BattleShowSceneActorAction
