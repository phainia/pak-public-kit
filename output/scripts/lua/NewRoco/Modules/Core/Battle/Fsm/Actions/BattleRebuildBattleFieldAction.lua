local ProtoMessage = require("Data.PB.ProtoMessage")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleExitHelper = require("NewRoco.Modules.Core.Battle.Players.BattleExitHelper")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleRebuildBattleFieldAction = BattleActionBase:Extend("BattleRebuildBattleFieldAction")
FsmUtils.MergeMembers(BattleActionBase, BattleRebuildBattleFieldAction, {})

function BattleRebuildBattleFieldAction:OnEnter()
  _G.BattleEventCenter:Bind(self, BattleEvent.PET_SPAWNED, BattleEvent.PLAYER_SPAWNED)
  self.BattleManager = _G.BattleManager
  self.PawnManger = self.BattleManager.battlePawnManager
  self:DestroyBattleField()
  self:CreateBattleField()
end

function BattleRebuildBattleFieldAction:StopBattlePerform()
  if self.BattleManager.instantFsm then
    self.BattleManager.instantFsm:Stop()
  end
  if self.BattleManager.teamBattlePerformFsm then
    self.BattleManager.teamBattlePerformFsm:Stop()
  end
  self.BattleManager.TeamBattleNotifyQueue = {}
  self.BattleManager.CurTeamBattlePerformNotify = nil
  self.BattleManager.LastSequencePerformNotify = nil
  self.BattleManager.ComboSkillInfo = {}
end

function BattleRebuildBattleFieldAction:DestroyBattleField()
  self:StopBattlePerform()
  self.BattleManager.vBattleField:ClearWaterPlatform()
  self.PawnManger:ClearPawnObj(true)
  _G.BattleManager.vBattleField.battleFieldConf = nil
  _G.BattleManager.vBattleField:ResetAttachPoint()
  _G.BattleManager.vBattleField:Init(_G.BattleManager.battleRuntimeData.battleStartParam.battleInitInfo)
end

function BattleRebuildBattleFieldAction:CreateBattleField()
  self.PrepareTable = {self}
  self.PawnManger:SetBattleInitInfo(BattleUtils.GetBattleInitInfo(), self.PrepareTable)
  self:LoadOver(self)
end

function BattleRebuildBattleFieldAction:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.PET_SPAWNED or eventName == BattleEvent.PLAYER_SPAWNED then
    self:LoadOver(...)
    return true
  end
end

function BattleRebuildBattleFieldAction:LoadOver(object)
  if self.PrepareTable and #self.PrepareTable > 0 then
    for i, v in ipairs(self.PrepareTable) do
      if v == object then
        table.remove(self.PrepareTable, i)
        break
      end
    end
    if 0 == #self.PrepareTable then
      self:Finish()
    end
  end
end

function BattleRebuildBattleFieldAction:OnFinish()
  _G.BattleEventCenter:UnBind(self)
end

return BattleRebuildBattleFieldAction
