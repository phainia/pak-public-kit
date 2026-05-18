local traceback = debug.traceback
local BattleBudget = _G.MakeSimpleClass()
BattleBudget.MemLevel = {
  SuperHigh,
  High,
  Middle,
  Low
}
BattleBudget.CPULevel = {
  SuperHigh,
  High,
  Middle,
  Low
}

function BattleBudget:Init()
  self.memLevel = BattleBudget.MemLevel.Middle
  self.cpuLevel = BattleBudget.CPULevel.Middle
  self.cacheConf = {}
  self.classPool = {}
  self.enableCacheConf = true
  self.enableCacheSkill = true
  self.enableCachePlayer = true
  self.enableCachePet = true
  self.enableCacheNPC = true
  self.taskLst = {}
  self.budetMsTime = 10
  self.shouldStopTick = false
  self.performPlayer = nil
  self.battleFsm = nil
  self.clusterDelayTime = 0
  self.tickControlDict = {}
  WeakTable(self.tickControlDict)
  self.currentTickTime = UE4.UNRCStatics.GetMilliSeconds()
  self.timeStepSize = 33
  self.isBattleGC = false
  self.isSkipFrame = 0
end

function BattleBudget:Dctor()
end

function BattleBudget:Reset()
  self.isBattleGC = false
end

function BattleBudget:Pause()
  self.isSkipFrame = 1
end

function BattleBudget:EnterBattle()
  self.shouldStopTick = false
  self.isBattleGC = false
  UE4.UNRCStatics.EnableDotTick(false)
  local localPlayer = _G.NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  localPlayer:GetUEController().BP_RocoCameraControlComponent:SetTickEnable(false)
  _G.UpdateManager:Register(self)
  self:ProcessAll()
end

function BattleBudget:LeaveBattle()
  self.shouldStopTick = true
  UE4.UNRCStatics.EnableDotTick(true)
  local localPlayer = _G.NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if localPlayer and UE4.UObject.IsValid(localPlayer:GetUEController()) then
    localPlayer:GetUEController().BP_RocoCameraControlComponent:SetTickEnable(true)
  else
    Log.Error("BattleBudget LeaveBattle localPlayer is invalid")
  end
  if not _G.RocoEnv.IS_EDITOR then
    debug.traceback = traceback
  end
end

function BattleBudget:PushTask(target, func, arg1, arg2, arg3)
  local task = {}
  task.target = target
  task.func = func
  task.isDelay = false
  if arg1 then
    task.args = {
      arg1,
      arg2,
      arg3
    }
  end
  table.insert(self.taskLst, task)
end

function BattleBudget:PushDelayTask(target, func, arg1, arg2, arg3)
  local task = {}
  task.target = target
  task.func = func
  task.isDelay = true
  if arg1 then
    task.args = {
      arg1,
      arg2,
      arg3
    }
  end
  table.insert(self.taskLst, task)
end

function BattleBudget:HasTask()
  return #self.taskLst > 0
end

function BattleBudget:ProcessingNext()
  local isDelay = false
  if self:HasTask() then
    local task = table.remove(self.taskLst, 1)
    local target = task.target
    local func = task.func
    local args = task.args
    isDelay = task.isDelay
    local err
    if args then
      _, err, _ = tcallForBattle(target, func, table.unpack(args))
    else
      _, err, _ = tcallForBattle(target, func)
    end
    if err then
      Log.Error(err)
      BattleReplayCachePool:UploadBattleDataTOCrashSight(err)
    end
  end
  return UE4.UNRCStatics.GetMilliSeconds(), isDelay
end

function BattleBudget:ProcessAll()
  while self:HasTask() do
    self:ProcessingNext()
  end
end

function BattleBudget:ControlTick(target, stepTime)
  if not self.tickControlDict[target] then
    self.tickControlDict[target] = self.currentTickTime
    return false
  end
  if self.currentTickTime - self.tickControlDict[target] >= self.timeStepSize * stepTime then
    self.tickControlDict[target] = self.currentTickTime
    return true
  end
  return true
end

function BattleBudget:OnTick()
  if self.isSkipFrame > 0 then
    self.isSkipFrame = self.isSkipFrame - 1
    return
  end
  self.currentTickTime = UE4.UNRCStatics.GetMilliSeconds()
  local bForceStop = false
  if self:HasTask() and not bForceStop then
    local beginTaskTime = UE4.UNRCStatics.GetMilliSeconds()
    local afterTaskTime = beginTaskTime
    while afterTaskTime - beginTaskTime < self.budetMsTime and self:HasTask() do
      afterTaskTime, bForceStop = self:ProcessingNext()
    end
  elseif self.shouldStopTick then
    _G.UpdateManager:UnRegister(self)
  end
end

function BattleBudget:GC(force)
  if not self.isBattleGC then
    self.isBattleGC = NRCGCManager:TryGC(force)
    if self.isBattleGC then
      self.isSkipFrame = 2
    end
  end
end

return BattleBudget
