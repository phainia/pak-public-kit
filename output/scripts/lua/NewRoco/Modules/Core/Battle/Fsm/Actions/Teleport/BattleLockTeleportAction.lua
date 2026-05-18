local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local ENUM_TELEPORT_LOCK_TYPE = require("NewRoco.Modules.Core.Scene.Component.RoleHP.TeleportLockEnum")
local BattleHandleTeleportBaseAction = require("NewRoco.Modules.Core.Battle.Fsm.Actions.Base.BattleHandleTeleportBaseAction")
local Base = BattleHandleTeleportBaseAction
local BattleLockTeleportAction = Base:Extend("BattleLockTeleportAction")
FsmUtils.MergeMembers(Base, BattleLockTeleportAction, {})

function BattleLockTeleportAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleLockTeleportAction:OnEnter()
  self:Lock()
  self:Finish()
end

function BattleLockTeleportAction:OnExit()
end

return BattleLockTeleportAction
