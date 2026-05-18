local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local HiddenComponent = require("NewRoco.Modules.Core.Scene.Component.Hidden.HiddenComponent")
local BattleDelayExecuteActionBase = require("NewRoco.Modules.Core.Battle.Fsm.Actions.Base.BattleDelayExecuteActionBase")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattleDelayExecuteActionBase
local BattleHideScenePetAction = Base:Extend("BattleHideScenePetAction")
FsmUtils.MergeMembers(Base, BattleHideScenePetAction, {})

function BattleHideScenePetAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleHideScenePetAction:OnEnter()
  Log.Debug("BattleHideScenePetAction OnEnter")
  Base.OnEnter(self)
  self:Finish()
end

function BattleHideScenePetAction:DelayRun()
  Base.DelayRun(self)
  local Caches = BattleUtils.GetAllTraceNpc()
  if Caches then
    for _, Cache in ipairs(Caches) do
      if Cache and Cache.npc then
        if Cache.npc.AIComponent then
          Cache.npc.AIComponent:LockForBattleReason()
        end
        Cache.npc:SetVisibleForBattleReason(false)
      end
    end
  end
  NRCModeManager:DoCmd(PlayerModuleCmd.HIDE_LOCAL_PLAYER, true)
  NRCModeManager:DoCmd(PlayerModuleCmd.HIDE_OTHER_PLAYER, true)
  BattleUtils.SetPlayerSkmTickable(false)
  local battleCenter = BattleManager.battleRuntimeData.NearbyValidBattleLocation
  local battleFieldRange = _G.BattleManager.vBattleField:GetBattleFieldRange()
  NRCModeManager:DoCmd(NPCModuleCmd.EnterBattle, battleCenter, battleFieldRange)
  BattleUtils.PinOnTheGroundForAllPawn()
  self:DelayComplete()
end

function BattleHideScenePetAction:OnExit()
end

return BattleHideScenePetAction
