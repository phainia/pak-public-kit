local ActivityProfilerLog = {}
local ProfilerStage = {
  Open_Start = 2,
  Open_End = 4,
  Load_Start = 8,
  Load_End = 16,
  Create_Start = 32,
  Create_End = 64,
  AddToViewport_Start = 128,
  AddToViewport_End = 256,
  Construct_Start = 512,
  Construct_End = 1024
}
local ActivityPanelNames = {}
local ActivityProfilerRecords = {}

local function CheckCanProfiler(activityInst, stage)
  local activityPanelName = activityInst and activityInst:GetUmgName()
  if string.IsNilOrEmpty(activityPanelName) then
    return false
  end
  local recordStage = ActivityProfilerRecords[activityPanelName] or 0
  if 0 ~= recordStage & stage then
    return false
  end
  ActivityProfilerRecords[activityPanelName] = recordStage | stage
  return true, activityPanelName
end

function ActivityProfilerLog.ProfilerOpen(activityInst, start)
  local canProfiler, activityPanelName = CheckCanProfiler(activityInst, start and ProfilerStage.Open_Start or ProfilerStage.Open_End)
  if canProfiler then
    _G.NRCProfilerLog:NRCPanelProfilerLog(true, start, activityPanelName)
  end
end

function ActivityProfilerLog.ProfilerLoad(activityInst, start)
  local canProfiler, activityPanelName = CheckCanProfiler(activityInst, start and ProfilerStage.Load_Start or ProfilerStage.Load_End)
  if canProfiler then
    _G.NRCProfilerLog:NRCPanelLoad(start, activityPanelName)
  end
end

function ActivityProfilerLog.ProfilerCreate(activityInst, start)
  local canProfiler, activityPanelName = CheckCanProfiler(activityInst, start and ProfilerStage.Create_Start or ProfilerStage.Create_End)
  if canProfiler then
    _G.NRCProfilerLog:NRCPanelCreate(start, activityPanelName)
  end
end

function ActivityProfilerLog.ProfilerAddToViewport(activityInst, start)
  local canProfiler, activityPanelName = CheckCanProfiler(activityInst, start and ProfilerStage.AddToViewport_Start or ProfilerStage.AddToViewport_End)
  if canProfiler then
    _G.NRCProfilerLog:NRCPanelAddToViewport(start, activityPanelName)
  end
end

function ActivityProfilerLog.ProfilerConstruct(activityInst, start)
  local canProfiler, activityPanelName = CheckCanProfiler(activityInst, start and ProfilerStage.Construct_Start or ProfilerStage.Construct_End)
  if canProfiler then
    _G.NRCProfilerLog:NRCPanelConstruct(start, activityPanelName)
  end
end

return ActivityProfilerLog
