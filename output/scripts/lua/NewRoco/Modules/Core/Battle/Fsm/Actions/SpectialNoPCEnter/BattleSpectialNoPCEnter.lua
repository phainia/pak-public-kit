local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleActionBase = require("NewRoco.Modules.Core.Battle.Fsm.Actions.Base.BattleActionBase")
local Base = BattleActionBase
local BattleSpectialNoPCEnter = Base:Extend("BattleSpectialNoPCEnter")
FsmUtils.MergeMembers(Base, BattleSpectialNoPCEnter, {})

function BattleSpectialNoPCEnter:OnEnter()
  NRCEventCenter:DispatchEvent(BattleEvent.EnterBattle)
  _G.BattleManager.battleRuntimeData:SetContactEnterType(BattleEnum.ContactEnterType.None)
  _G.BattleManager:OpenBattleMainWindow()
  self:Finish()
end

return BattleSpectialNoPCEnter
