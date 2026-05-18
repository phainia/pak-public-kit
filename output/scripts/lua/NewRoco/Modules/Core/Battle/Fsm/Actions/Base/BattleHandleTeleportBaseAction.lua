local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local TeleportLockEnum = require("NewRoco.Modules.Core.Scene.Component.RoleHP.TeleportLockEnum")
local BattleHandleTeleportBaseAction = BattleActionBase:Extend("BattleHandleTeleportBaseAction")
FsmUtils.MergeMembers(BattleActionBase, BattleHandleTeleportBaseAction, {})

function BattleHandleTeleportBaseAction:Ctor(name, properties)
  BattleActionBase.Ctor(self, name, properties)
end

function BattleHandleTeleportBaseAction:OnEnter()
end

function BattleHandleTeleportBaseAction:Lock()
end

function BattleHandleTeleportBaseAction:Unlock()
  NRCModuleManager:DoCmd(PlayerModuleCmd.UnLockTeleport, TeleportLockEnum.LockType.BATTLE)
end

function BattleHandleTeleportBaseAction:OnExit()
end

return BattleHandleTeleportBaseAction
