local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local ENUM_TELEPORT_LOCK_TYPE = require("NewRoco.Modules.Core.Scene.Component.RoleHP.TeleportLockEnum")
local BattleHandleTeleportBaseAction = require("NewRoco.Modules.Core.Battle.Fsm.Actions.Base.BattleHandleTeleportBaseAction")
local Base = BattleHandleTeleportBaseAction
local BattleUnlockTeleportAction = Base:Extend("BattleUnlockTeleportAction")
FsmUtils.MergeMembers(Base, BattleUnlockTeleportAction, {})

function BattleUnlockTeleportAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleUnlockTeleportAction:OnEnter()
  self:Unlock()
  self:Finish()
end

function BattleUnlockTeleportAction:OnExit()
end

return BattleUnlockTeleportAction
