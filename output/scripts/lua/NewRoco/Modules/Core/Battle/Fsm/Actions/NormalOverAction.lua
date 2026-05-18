local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local NormalOverAction = BattleActionBase:Extend("NormalOverAction")
FsmUtils.MergeMembers(BattleActionBase, NormalOverAction, {})

function NormalOverAction:Ctor(name, properties)
  BattleActionBase.Ctor(self, name, properties)
end

function NormalOverAction:OnEnter()
  if BattleUtils.IsReplayMode() then
    Log.Error("NormalOverAction:OnEnter() IsReplayMode")
    BattleReplayCachePool:Reset()
    Log.PrintScreenMsg("Lua:::" .. collectgarbage("count"))
  end
  self.timeout = 10
  local finishData = _G.BattleManager.battleRuntimeData.battleSettleData.data
  FsmUtils.ClearAllProperties(self.fsm)
  _G.BattleManager:LeaveBattle()
  if finishData and finishData.will_leave_visit then
    _G.NRCEventCenter:RegisterEvent("NormalOverAction", self, SceneEvent.OnEnterMapForLeaveVisit, self.OnEnterMap)
  else
    self:Finish()
  end
end

function NormalOverAction:OnEnterMap()
  _G.NRCEventCenter:UnRegisterEvent(self, SceneEvent.OnEnterMapForLeaveVisit, self.OnEnterMap)
  self:Finish()
end

return NormalOverAction
