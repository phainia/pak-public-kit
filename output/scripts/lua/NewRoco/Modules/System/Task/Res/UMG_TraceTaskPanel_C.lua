require("UnLuaEx")
local OnlineState = require("Core.Service.NetManager.OnlineState")
local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local TaskModuleEvent = reload("NewRoco.Modules.Core.Task.TaskModuleEvent")
local LoadingUIModuleEvent = require("NewRoco.Modules.System.LoadingUIModule.LoadingUIModuleEvent")
local FVector2DUtils = require("NewRoco.Utils.FVector2DUtils")

local function GetNumberFromMapConf(Key, Default)
  local Conf = _G.DataConfigManager:GetMapGlobalConfig(Key)
  if not Conf then
    return Default
  end
  local Num = Conf.num
  if not Num then
    return Default
  end
  return Num
end

local XAxisFactor = GetNumberFromMapConf("hud_x_axis_scale", 70) / 100
local YAxisFactor = GetNumberFromMapConf("hud_y_axis_scale", 70) / 100
local UMG_TraceTaskPanel_C = NRCViewBase:Extend("UMG_TraceTaskPanel_C")
local MiniGameModuleEvent = reload("NewRoco.Modules.System.MiniGame.MiniGameModuleEvent")

function UMG_TraceTaskPanel_C:OnAddEventListener()
  Log.Debug("Track Task UMG_TraceTaskPanel_C:OnAddEventListener")
  NRCEventCenter:RegisterEvent("UMG_TraceTaskPanel_C", self, TaskModuleEvent.ON_START_TRACK, self.StartTrack)
  NRCEventCenter:RegisterEvent("UMG_TraceTaskPanel_C", self, TaskModuleEvent.ON_STOP_TRACK, self.StopTrack)
  NRCEventCenter:RegisterEvent("UMG_TraceTaskPanel_C", self, TaskModuleEvent.ON_STOP_TRACK_TASK_ITEM, self.StopTrackTaskItem)
  NRCEventCenter:RegisterEvent("UMG_TraceTaskPanel_C", self, TaskModuleEvent.ON_UPDATE_TRACK, self.UpdateTrack)
  NRCEventCenter:RegisterEvent("UMG_TraceTaskPanel_C", self, TaskModuleEvent.TASK_DATA_CHANGE, self.UpdateTasks)
  NRCEventCenter:RegisterEvent("UMG_TraceTaskPanel_C", self, SceneEvent.PlayerBornFinish, self.UpdateCached)
  NRCEventCenter:RegisterEvent("UMG_TraceTaskPanel_C", self, SceneEvent.OnTeleportNotify, self.OnLoadMapStart)
  NRCEventCenter:RegisterEvent("UMG_TraceTaskPanel_C", self, SceneEvent.OnEnterSceneFinishNtyAckEnd, self.OnPlayerTeleportFinish)
  NRCEventCenter:RegisterEvent("UMG_TraceTaskPanel_C", self, LoadingUIModuleEvent.LOADING_UI_CLOSED, self.OnLoadingClosed)
  NRCEventCenter:RegisterEvent("UMG_TraceTaskPanel_C", self, MiniGameModuleEvent.OnMiniGameExit, self.OnMiniGameExit)
end

function UMG_TraceTaskPanel_C:OnDestruct()
  Log.Debug("Track Task UMG_TraceTaskPanel_C:OnRemoveEventListener")
  NRCEventCenter:UnRegisterEvent(self, TaskModuleEvent.ON_START_TRACK, self.StartTrack)
  NRCEventCenter:UnRegisterEvent(self, TaskModuleEvent.ON_STOP_TRACK, self.StopTrack)
  NRCEventCenter:UnRegisterEvent(self, TaskModuleEvent.ON_STOP_TRACK_TASK_ITEM, self.StopTrackTaskItem)
  NRCEventCenter:UnRegisterEvent(self, TaskModuleEvent.ON_UPDATE_TRACK, self.UpdateTrack)
  NRCEventCenter:UnRegisterEvent(self, TaskModuleEvent.TASK_DATA_CHANGE, self.UpdateTasks)
  NRCEventCenter:UnRegisterEvent(self, SceneEvent.PlayerBornFinish, self.UpdateCached)
  NRCEventCenter:UnRegisterEvent(self, SceneEvent.OnTeleportNotify, self.OnLoadMapStart)
  NRCEventCenter:UnRegisterEvent(self, SceneEvent.OnEnterSceneFinishNtyAckEnd, self.OnPlayerTeleportFinish)
  NRCEventCenter:UnRegisterEvent(self, LoadingUIModuleEvent.LOADING_UI_CLOSED, self.OnLoadingClosed)
  if self.Items then
    for _, v in pairs(self.Items) do
      v:Destruct()
      v:ReleaseForce()
    end
    table.clear(self.Items)
  end
end

function UMG_TraceTaskPanel_C:OnPlayerTeleportStart()
  self.Teleported = false
end

function UMG_TraceTaskPanel_C:OnPlayerTeleportFinish()
  self.Teleported = true
end

function UMG_TraceTaskPanel_C:OnLoadingClosed()
  if not self.Teleported then
    return
  end
  self.Teleported = false
  if not self.Items then
    return
  end
  for Tracker, _ in pairs(self.Items) do
    Tracker:Focus()
  end
end

function UMG_TraceTaskPanel_C:UpdateTrack(tracker)
  local TaskObjects = NRCModuleManager:DoCmd(_G.TaskModuleCmd.GetTaskMap)
  for trackerItem, v in pairs(self.Items) do
    local TO = TaskObjects[trackerItem.TaskInfo.id]
    if TO and not TO:IsTrack() then
      self:RemoveTraceTask(trackerItem)
    end
  end
  if not tracker then
    return
  end
  local tracked = self.Items[tracker] ~= nil
  if not tracked then
    return
  end
  self:AddTraceTask(tracker)
end

function UMG_TraceTaskPanel_C:StartTrack(tracker)
  self:AddTraceTask(tracker)
end

function UMG_TraceTaskPanel_C:StopTrack(tracker)
  self:RemoveTraceTask(tracker)
end

function UMG_TraceTaskPanel_C:StopTrackTaskItem(tracker)
  for trackerItem, v in pairs(self.Items) do
    if not trackerItem.TaskInfo.is_track then
      self:RemoveTraceTask(trackerItem)
    end
  end
end

function UMG_TraceTaskPanel_C:UpdateViewport()
  local Size = UE4.UWidgetLayoutLibrary.GetViewportSize(self.World)
  local Scale = UE4.UWidgetLayoutLibrary.GetViewportScale(self.World)
  self.DpiScaleY = 1
  self.ViewportCenter = Size / Scale / 2
  self.Axis = UE.FVector2D(self.ViewportCenter.X * XAxisFactor, self.ViewportCenter.Y * YAxisFactor)
end

function UMG_TraceTaskPanel_C:UpdateCached()
  self.World = _G.UE4Helper.GetCurrentWorld()
  self.playerController = UE4.UGameplayStatics.GetPlayerController(self.World, 0)
  self.playerCameraManager = self:GetOwningPlayerCameraManager()
  self.localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  self:UpdateViewport()
end

function UMG_TraceTaskPanel_C:OnLoadMapStart()
  self:ClearCached()
  self:OnPlayerTeleportStart()
end

function UMG_TraceTaskPanel_C:ClearCached()
  Log.Debug("[TaskFlow] UMG_TraceTaskPanel_C:ClearCached")
  self.World = false
  self.playerController = false
  self.playerCameraManager = false
  self.localPlayer = false
end

function UMG_TraceTaskPanel_C:OnConstruct()
  Log.Debug("[TaskFlow] UMG_TraceTaskPanel_C:OnConstruct")
  self.Items = {}
  self.Teleported = true
  self.lastItemShow = false
  self:OnAddEventListener()
  self:UpdateCached()
  self.TaskDistance = _G.DataConfigManager:GetMapGlobalConfig("task_distance").num
  self.TaskDistance = self.TaskDistance * self.TaskDistance * 10000
  if not self.localPlayer then
    Log.Error("Can't find a valid local player!")
  end
  self:UpdateTasks()
  self:UpdateCanTick()
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.bIsCheckBan = true
  local CurMode = NRCModeManager:GetCurMode()
  if CurMode then
    self.InCreatePlayerMode = CurMode.modeName == "CreatePlayerMode"
  else
    self.InCreatePlayerMode = false
  end
end

function UMG_TraceTaskPanel_C:UpdateTasks()
  local taskObjects = NRCModuleManager:DoCmd(_G.TaskModuleCmd.GetTaskMap)
  if not taskObjects then
    Log.Error("\228\187\142taskmap\233\135\140\233\157\162\230\139\191\228\184\141\229\136\176\229\144\136\231\144\134\231\154\132\229\175\185\232\177\161...")
    return
  end
  self.bIsCheckBan = true
  if _G.MiniGameModuleCmd and _G.NRCModuleManager:DoCmd(_G.MiniGameModuleCmd.IsPlaying) then
    local MiniGameModule = _G.NRCModuleManager:GetModule("MiniGameModule")
    if MiniGameModule then
      local MiniGameConfigID = MiniGameModule.ConfigId
      Log.Debug("[TaskFlow] UMG_TraceTaskPanel_C:UpdateTasks In MiniGame ", MiniGameConfigID)
      local RuleConf = _G.DataConfigManager:GetMinigameRuleConf(MiniGameConfigID)
      if RuleConf then
        self.bIsCheckBan = not RuleConf.show_target
      end
    end
  end
  for trackerItem, v in pairs(self.Items) do
    local TO = taskObjects[trackerItem.TaskInfo.id]
    if TO and not TO:IsTrack() then
      self:RemoveTraceTask(trackerItem)
    end
  end
  for _, TO in pairs(taskObjects) do
    if TO.Trackers and TO:IsTrack() then
      for _, tracker in ipairs(TO.Trackers) do
        self:AddTraceTask(tracker)
      end
    end
  end
end

function UMG_TraceTaskPanel_C:AddTraceTask(Tracker)
  if not Tracker then
    return
  end
  if not Tracker.TaskInfo then
    return
  end
  local TaskObjects = NRCModuleManager:DoCmd(_G.TaskModuleCmd.GetTaskMap)
  local TO = TaskObjects[Tracker.TaskInfo.id]
  if not TO then
    Log.Debug("[TaskFlow] AddTraceTask skipped, task not found,Task %d, Go Index %d", Tracker.TaskInfo.id, Tracker.go_index)
    return
  end
  if not TO:IsTrack() then
    Log.Debug("[TaskFlow] AddTraceTask skipped, task not tracked,Task %d, Go Index %d", Tracker.TaskInfo.id, Tracker.go_index)
    return
  end
  if TO:CheckConditionDone(Tracker.go_index) then
    Log.Debug("[TaskFlow] AddTraceTask skipped, condition done,Task %d, Go Index %d", Tracker.TaskInfo.id, Tracker.go_index)
    return
  end
  local TaskItem = self.Items[Tracker]
  if not TaskItem then
    Log.DebugFormat("[TaskFlow] Add Track Task %d, Go Index %d", Tracker.TaskInfo.id, Tracker.go_index)
    TaskItem = UE4.UWidgetBlueprintLibrary.Create(self, self.TaskItem)
    self.TrackPanel:AddChildToCanvas(TaskItem)
  end
  TaskItem:SetTracker(Tracker)
  self.Items[Tracker] = TaskItem
  self:UpdateCanTick()
  local CurrentlyVisible = self.GetIsVisible and self:GetIsVisible()
  if not CurrentlyVisible then
    local Info = Tracker and Tracker.Info
    if Info then
      local TaskID = Info and Info.id or 0
      local GoIndex = Tracker and Tracker.go_index
      Log.ErrorFormat("[TaskFlow] UMG_TraceTaskPanel_C Task Track Panel not visible, Task %d, Go Index %d", TaskID, GoIndex)
    end
  end
end

function UMG_TraceTaskPanel_C:RemoveTraceTask(Tracker)
  local TaskItem = self.Items[Tracker]
  if not TaskItem then
    return
  end
  self.Items[Tracker] = nil
  self.TrackPanel:RemoveChild(TaskItem)
  self:UpdateCanTick()
  Log.DebugFormat("[TaskFlow] Remove Track Task %d, Go Index %d", Tracker.TaskInfo.id, Tracker.go_index)
end

function UMG_TraceTaskPanel_C:UpdateCanTick()
  for _, v in pairs(self.Items) do
    if v then
      _G.UpdateManager:Register(self)
      return
    end
  end
  _G.UpdateManager:UnRegister(self)
end

local Collapsed = UE4.ESlateVisibility.Collapsed
local HitTestInvisible = UE4.ESlateVisibility.HitTestInvisible

function UMG_TraceTaskPanel_C:OnTick()
  if not UE.UObject.IsValid(self) then
    return
  end
  self.hasItemShow = false
  local State = _G.ZoneServer:GetOnlineState()
  local ShouldTick = true
  if self.bIsCheckBan then
    if ShouldTick then
      ShouldTick = not _G.FunctionBanManager:GetFunctionState(Enum.PlayerFunctionBanType.PFBT_TASK_TRACK_UI, false, false, false)
    end
  elseif _G.MiniGameModuleCmd and _G.NRCModuleManager:DoCmd(_G.MiniGameModuleCmd.IsPlaying) then
    local AllCond = _G.FunctionBanManager:GetPlayerConditions()
    if AllCond[Enum.PlayerConditionType.PCT_WORLD_COMBATING] then
      ShouldTick = false
    end
  end
  ShouldTick = ShouldTick and self.localPlayer
  ShouldTick = ShouldTick and self.World
  if not self.InCreatePlayerMode then
    ShouldTick = ShouldTick and State == OnlineState.EnteredCell
  end
  if not self.InCreatePlayerMode and State == OnlineState.EnteredCell and (not self.localPlayer or not self.World) then
    Log.Debug("[TaskFlow] UMG_TraceTaskPanel_C try to get player and world again")
    self:UpdateCached()
  end
  if ShouldTick then
    self.playerPosition = self.localPlayer:GetActorLocationFrameCache()
    if self.Items then
      for _, v in pairs(self.Items) do
        self:TickItem(v)
      end
    end
  elseif self.Items then
    for _, v in pairs(self.Items) do
      v:SetVisibility(Collapsed)
    end
  end
  if self.lastItemShow ~= self.hasItemShow then
    if self.hasItemShow then
      self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self.lastItemShow = self.hasItemShow
  end
end

local TickItemTempParameterVector3D = UE4.FVector(0, 0, 0)
local TickItemScreenPosCache = UE4.FVector2D()
local TickItemViewportPosCache = UE4.FVector2D()
local TickItemDeltaCache = UE4.FVector2D()
local TickItemOnPosCache = UE4.FVector2D()

function UMG_TraceTaskPanel_C:TickItem(item)
  local DistSqrt = 1
  local TargetPosition = item:GetPosition()
  if item:HasPosition() then
    TargetPosition:SubInto(self.playerPosition, TickItemTempParameterVector3D)
    DistSqrt = TickItemTempParameterVector3D:SizeSquared()
    local WithInRange = DistSqrt <= self.TaskDistance
    local InSameGroup = item:CheckInSameGroup()
    local ForceShow = item:ShouldForceShow()
    local IsValid = item:CheckValid()
    if not InSameGroup then
      item:SetVisibility(Collapsed)
      return
    elseif ForceShow then
    elseif not IsValid or not WithInRange then
      item:SetVisibility(Collapsed)
      return
    end
  else
    item:SetVisibility(Collapsed)
    return
  end
  item:SetVisibility(HitTestInvisible)
  self.hasItemShow = true
  local ScreenPos = TickItemScreenPosCache
  local ViewportPos = TickItemViewportPosCache
  local result = UE4.UNRCStatics.Abs_ProjectWorldToScreen(self.playerController, TargetPosition, ScreenPos)
  UE4.USlateBlueprintLibrary.ScreenToViewportConsiderBorder(self.World, ScreenPos, ViewportPos)
  ViewportPos:SubInto(self.ViewportCenter, TickItemDeltaCache)
  local delta = TickItemDeltaCache
  local theta = math.atan(delta.Y, delta.X)
  if not result then
    theta = theta - math.pi
  end
  FVector2DUtils.GetEllipseInplace(self.Axis, theta, TickItemOnPosCache)
  local onPos = TickItemOnPosCache
  if result then
    local CenterLength = delta:SizeSquared()
    local CircleRadius = onPos:SizeSquared()
    if CenterLength > CircleRadius then
      onPos:AddInto(self.ViewportCenter, ViewportPos)
      item:UpdateArrow(theta)
    else
      item:ToggleArrow(false, math.sqrt(DistSqrt))
    end
  else
    onPos:AddInto(self.ViewportCenter, ViewportPos)
    item:UpdateArrow(theta)
  end
  ViewportPos.X = ViewportPos.X * self.DpiScaleY
  ViewportPos.Y = ViewportPos.Y * self.DpiScaleY - 30
  item:SetPosition(ViewportPos)
  item:UpdateAnimation()
end

function UMG_TraceTaskPanel_C:OnMiniGameExit()
  self:UpdateTasks()
end

return UMG_TraceTaskPanel_C
