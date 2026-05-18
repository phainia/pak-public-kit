local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local EventDispatcher = require("Common.EventDispatcher")
local BattlePlayerBase = require("NewRoco.Modules.Core.Battle.BattleCore.BattlePlayerBase")
local BattleTaskStatePlayer = BattlePlayerBase:Extend()
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")

function BattleTaskStatePlayer:Ctor(owner)
  BattlePlayerBase.Ctor(self)
end

function BattleTaskStatePlayer:Play(performNode)
  self.performNode = performNode
  self.performInfo = performNode:GetInfo()
  self:PlayEscape()
end

function BattleTaskStatePlayer:PlayEscape()
  self:Clear()
  do return end
  local performInfo = self.performInfo
  local taskInfo = performInfo.sync_data and performInfo.sync_data.task_infos or nil
  if taskInfo then
    _G.BattleManager.battleRuntimeData:UpdateBattleTaskInfo(taskInfo)
    local newTaskInfo = _G.BattleManager.battleRuntimeData:GetBattleTaskInfo() or {}
    local taskMap = {}
    for _, oneTaskInfo in pairs(newTaskInfo) do
      taskMap[oneTaskInfo.task_id] = oneTaskInfo
    end
    _G.BattleEventCenter:Dispatch(BattleEvent.RefreshSilhouetteTaskState, taskMap)
  end
  self:Clear()
end

function BattleTaskStatePlayer:Clear()
  if self.performNode then
    self.performNode:PerformComplete()
  end
  self.asyncData = nil
  self.performNode = nil
  self.performInfo = nil
end

return BattleTaskStatePlayer
