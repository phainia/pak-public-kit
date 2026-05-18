local TipUtils = require("NewRoco.Modules.System.TipsModule.Utils.TipUtils")
local TipObject = require("NewRoco.Modules.System.TipsModule.Utils.TipObject")
local TipsModuleEvent = require("NewRoco.Modules.System.TipsModule.TipsModuleEvent")
local TaskModuleEvent = reload("NewRoco.Modules.Core.Task.TaskModuleEvent")
local InMemoryProtocolPlayer = require("Core.Service.NetManager.InMemoryProtocolPlayer")
local NpcOption = require("NewRoco.Modules.Core.NPC.Executors.NpcOption")
local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local DialogueUtils = require("NewRoco.Modules.System.Dialogue.DialogueUtils")
local InMemoryProtocolRecorder = require("Core.Service.NetManager.InMemoryProtocolRecorder")
local TaskObject = require("NewRoco.Modules.Core.Task.TaskObject")
local Base = DebugTabBase
local DebugTabTask = Base:Extend("DebugTabTask")

function DebugTabTask:Ctor()
  Base.Ctor(self)
end

function DebugTabTask:SetupTabs()
  self:Add("\229\133\137\231\144\131\229\143\175\232\167\134\229\140\150", self.EnableTaskGuideVisualize, self)
  self:Add("\230\183\187\229\138\160\230\151\165\229\191\151\230\150\173\231\130\185", self.AddLogBreakpoint, self)
  self:Add("\229\133\179\233\151\173\230\151\160\229\133\179\230\151\165\229\191\151", self.DisableLogs, self)
  self:Add("\229\188\128\229\144\175\230\137\128\230\156\137\230\151\165\229\191\151", self.EnableLogs, self)
  self:Add("\230\137\147\229\188\128\228\187\187\229\138\161\230\139\141\231\133\167", self.OpenTaskPhoto, self, nil, "", "", nil, "", "")
  self:Add("\233\128\154\232\191\135\231\171\160\232\138\130id\230\137\147\229\188\128\228\187\187\229\138\161", self.OpenTaskPanelByParagraphList, self, nil, "", "", nil, "", "")
  self:Add("\230\137\139\229\134\140\228\187\187\229\138\161\232\183\179\232\189\172\231\171\160\232\138\130ID", self.GMGoToMagicAdventureByChapterId, self, nil, "", "", nil, "", "")
  self:Add("\229\188\186\229\136\183NPC", self.ForceCreateNPC, self)
  self:Add("\228\187\187\229\138\161\231\178\190\231\129\181\232\183\159\233\154\143", self.TrySummonPetFollow, self)
  self:Add("\229\155\158\230\148\182\228\187\187\229\138\161\231\178\190\231\129\181", self.TryRecycleFollowedPet, self)
  self:Add("\229\136\135\230\141\162\228\187\187\229\138\161ID\230\152\190\231\164\186", self.ToggleEditorTaskID, self, nil, "", "", nil, "", "")
  self:Add("\229\136\135\230\141\162\228\187\187\229\138\161\232\191\189\232\184\170\230\151\165\229\191\151", self.ToggleShowNpcDebugLog, self, nil, "", "", nil, "", "")
  self:Add("\228\187\187\229\138\161\232\191\189\232\184\170\230\181\139\232\175\149", self.TaskTrackTest, self, nil, "", "", nil, "", "")
  self:Add("\230\137\147\229\188\128\229\138\160\232\189\189\231\149\140\233\157\162\230\181\139\232\175\149", self.OpenLoadingTest, self, nil, "", "", nil, "", "")
  self:Add("\229\133\179\233\151\173\229\138\160\232\189\189\231\149\140\233\157\162\230\181\139\232\175\149", self.CloseLoadingTest, self, nil, "", "", nil, "", "")
  self:Add("\229\188\128\229\144\175\232\181\155\229\173\163\230\137\139\229\134\140\231\171\160\232\138\130", self.OpenSeasonManualChapter, self, nil, "", "", nil, "", "")
  self:Add("\232\174\190\231\189\174\232\181\155\229\173\163\229\190\189\231\171\160\231\173\137\231\186\167", self.SetSeasonBadgeLevel, self, nil, "", "", nil, "", "")
  local States = ProtoEnum.EMTaskState
  for Name, State in pairs(States) do
    self:Add(string.format("\228\187\187\229\138\161\231\138\182\230\128\129:\n%s", Name), function(caller, name, panel)
      caller:ShowTaskByState(Name, State)
    end, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "\228\187\187\229\138\161\231\138\182\230\128\129")
  end
  local Module = NRCModuleManager:GetModule("TaskModule")
  local MagicManualModule = NRCModuleManager:GetModule("MagicManualModule")
  if MagicManualModule then
    local TaskConf = MagicManualModule.data:GetMagicManualTaskPanelInfo()
    if TaskConf.LeftPanelInfo ~= nil then
      local OpenTaskIdList = TaskConf.LeftPanelInfo.tasks
      local TASK_CONF = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.TASK_CONF):GetAllDatas()
      for id, conf in pairs(TASK_CONF) do
        for j = 1, #OpenTaskIdList do
          if OpenTaskIdList[j] == conf.id then
            self:Add(string.format("\229\174\140\230\136\144\230\137\139\229\134\140\229\189\147\229\137\141\231\171\160\232\138\130\228\187\187\229\138\161:\n%s", conf.name), function()
              self:FinishCurTask(conf.id)
            end, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "\229\174\140\230\136\144\230\137\139\229\134\140\229\189\147\229\137\141\231\171\160\232\138\130\228\187\187\229\138\161")
          end
        end
      end
    end
  end
  if Module then
    local AllTasks = Module.data.TaskMap
    for ID, TaskObject in pairs(AllTasks) do
      if TaskObject.Info.state == ProtoEnum.EMTaskState.EM_TASK_STATE_OPEN then
        local Text = ""
        for _, Value in ipairs(TaskObject.Config.task_condition) do
          if string.IsNilOrEmpty(Text) then
            Text = Value.text
            break
          end
        end
        self:Add(string.format("\229\174\140\230\136\144\228\187\187\229\138\161 %d\n%s", TaskObject.Config.id, Text), function(caller, name, panel)
          self:FinishCurTask(ID)
        end, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "\229\174\140\230\136\144\228\187\187\229\138\161")
      end
    end
  end
  local TASK_CONF = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.TASK_CONF):GetAllDatas()
  local MainTasks = {}
  for id, conf in pairs(TASK_CONF) do
    if conf.task_class == Enum.TaskClassType.TCT_JOURNEY then
      table.insert(MainTasks, conf)
    end
  end
  table.sort(MainTasks, function(a, b)
    return a.id < b.id
  end)
  for _, conf in ipairs(MainTasks) do
    self:Add(string.format("\230\142\165\228\187\187\229\138\161 %d\n%d\n%s", conf.id, conf.paragraph_id, conf.name), function(caller, name, panel)
      self:AcceptTaskByID(conf.id)
    end, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "\230\142\165\228\187\187\229\138\161")
  end
end

function DebugTabTask:ClearAllTask(Name, Panel)
  local Req = _G.ProtoMessage:newZoneGmTaskClearReq()
  ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_TASK_CLEAR_REQ, Req, self, self.OnAllTaskCleared)
end

function DebugTabTask:OnAllTaskCleared(rsp)
  self:ClosePanel()
end

function DebugTabTask:FinishCurrentTask(Name, Panel)
  local Module = NRCModuleManager:GetModule("TaskModule")
  local AllTasks = Module.data.TaskMap
  local TrackTask
  for _, TaskObject in pairs(AllTasks) do
    if TaskObject.isTrack then
      TrackTask = TaskObject
    end
  end
  if not TrackTask then
    self:ShowTips("\231\142\176\229\156\168\230\178\161\230\156\137\229\188\186\232\191\189\232\184\170\228\184\173\231\154\132\228\187\187\229\138\161")
    return
  end
  local MaxValue = 1
  for _, Value in ipairs(TrackTask.Config.task_condition) do
    MaxValue = math.max(Value.count, MaxValue)
  end
  self:ModifyTaskProgressByID(TrackTask.Info.id, MaxValue)
end

function DebugTabTask:ShowTaskByState(Name, State)
  local Filtered = {}
  local Module = NRCModuleManager:GetModule("TaskModule")
  if Module then
    local AllTasks = Module.data.TaskMap
    for ID, TaskObject in pairs(AllTasks) do
      if TaskObject.Info.state == State then
        Filtered[ID] = TaskObject
      end
    end
  end
  self:Inspect(Filtered, Name)
  self:ClosePanel()
end

function DebugTabTask:StartInterceptTask()
  if not _G.TaskRecorder then
    _G.TaskRecorder = InMemoryProtocolRecorder("\228\187\187\229\138\161\230\149\176\230\141\174")
    _G.TaskRecorder:AddCmd(_G.ProtoCMD.ZoneSvrCmd.ZONE_TASK_INFO_NOTIFY)
    _G.TaskRecorder:AddCmd(_G.ProtoCMD.ZoneSvrCmd.ZONE_TASK_TRACE_RSP)
    _G.TaskRecorder:AddCmd(_G.ProtoCMD.ZoneSvrCmd.ZONE_TASK_STATE_RSP)
    _G.TaskRecorder:AddCmd(_G.ProtoCMD.ZoneSvrCmd.ZONE_TASK_REWARD_RSP)
    _G.TaskRecorder:AddCmd(_G.ProtoCMD.ZoneSvrCmd.ZONE_RANDOM_SUB_TASK_NOTIFY)
    _G.TaskRecorder:AddCmd(_G.ProtoCMD.ZoneSvrCmd.ZONE_SCENE_NPC_NEXT_ACT_RSP)
  end
  if not _G.TaskRecorder then
    Log.Error("\230\151\160\230\179\149\229\188\128\229\167\139\229\189\149\229\136\182\228\187\187\229\138\161\230\149\176\230\141\174")
    return
  end
  if _G.TaskRecorder.bIsRecording then
    Log.Error("\229\189\149\229\136\182\228\184\173...")
    return
  end
  Log.Error("\229\188\128\229\167\139\229\189\149\229\136\182\228\187\187\229\138\161\229\155\158\229\140\133\239\188\129")
  TipUtils.SetDebugLogEnable(true)
  self:DisableLogs()
  _G.TaskRecorder:Start()
end

function DebugTabTask:StopInterceptTask()
  if not _G.TaskRecorder then
    Log.Error("\228\185\139\229\137\141\230\178\161\230\156\137\229\188\128\229\144\175\232\191\135\228\187\187\229\138\161\229\189\149\229\136\182")
    return
  end
  if not _G.TaskRecorder.bIsRecording then
    Log.Error("\231\142\176\229\156\168\230\178\161\229\156\168\229\189\149\229\131\143\228\184\173...")
    return
  end
  TipUtils.SetDebugLogEnable(false)
  self:EnableLogs()
  _G.TaskRecorder:Stop()
  Log.Error("\229\129\156\230\173\162\229\189\149\229\136\182\228\187\187\229\138\161\229\155\158\229\140\133\239\188\129")
end

function DebugTabTask:AcceptTask(name, panel, id)
  if panel then
    local taskId = panel:GetInputNumber()
    if 0 == taskId then
      taskId = tonumber(id)
    end
    Log.DebugFormat("Accept task %s", taskId)
    self:AcceptTaskByID(taskId)
  else
    self:AcceptTaskByID(id)
  end
end

function DebugTabTask:AcceptTaskByID(id)
  local acceptTaskReq = ProtoMessage.newZoneGmTaskAddReq()
  acceptTaskReq.uin = DataModelMgr.PlayerDataModel:GetPlayerUin()
  acceptTaskReq.task_id = id
  ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_TASK_ADD_REQ, acceptTaskReq, self, self._OnAcceptTaskRsp)
end

function DebugTabTask:_OnAcceptTaskRsp(rsp)
  if 0 ~= rsp.ret_info.ret_code then
    Log.Error("Accept task failed!")
  else
    Log.Debug("Accept task succeed")
    self:ClosePanel()
  end
end

function DebugTabTask:RemoveTask(name, panel, id)
  if panel then
    local taskId = panel:GetInputNumber()
    if taskId <= 0 then
      Log.Warning("Please input valid taskId to remove!")
      return
    end
    Log.DebugFormat("Remove task %s", taskId)
    local removeTaskReq = ProtoMessage.newZoneGmTaskRemoveReq()
    removeTaskReq.uin = DataModelMgr.PlayerDataModel:GetPlayerUin()
    removeTaskReq.task_id = taskId
    ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_TASK_REMOVE_REQ, removeTaskReq, self, self._OnRemoveTaskRsp)
  elseif id then
    local taskId = id
    if taskId <= 0 then
      Log.Warning("Please input valid taskId to remove!")
      return
    end
    Log.DebugFormat("Remove task %s", taskId)
    local removeTaskReq = ProtoMessage.newZoneGmTaskRemoveReq()
    removeTaskReq.uin = DataModelMgr.PlayerDataModel:GetPlayerUin()
    removeTaskReq.task_id = taskId
    ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_TASK_REMOVE_REQ, removeTaskReq, self, self._OnRemoveTaskRsp)
  end
end

function DebugTabTask:_OnRemoveTaskRsp(rsp)
  if 0 ~= rsp.ret_info.ret_code then
    Log.Error("Remove task failed!")
  else
    Log.Debug("Remove task succeed")
  end
end

function DebugTabTask:ModifyTaskProgress(name, panel, InputText)
  local warnMsg = "Please input valid GM params to modify task progress, eg: 10086 100"
  local taskIdAndNewProgress
  if panel then
    taskIdAndNewProgress = panel:GetInputString()
  else
    taskIdAndNewProgress = InputText
  end
  if nil == taskIdAndNewProgress or "" == taskIdAndNewProgress then
    Log.Warning("Please input valid taskId to modify progress")
    return
  end
  local inputPair = string.split(taskIdAndNewProgress, " ")
  if 2 ~= #inputPair then
    Log.Warning(warnMsg)
    return
  end
  local taskId = tonumber(inputPair[1])
  local newProgress = tonumber(inputPair[2])
  if taskId <= 0 or newProgress < 0 then
    Log.Warning(warnMsg)
    return
  end
  Log.DebugFormat("Modify task %s progress to %s", taskId, newProgress)
  self:ModifyTaskProgressByID(taskId, newProgress)
end

function DebugTabTask:ModifyTaskProgressByID(id, progress)
  local modifyTaskProgReq = ProtoMessage.newZoneGmTaskModifyProgressReq()
  modifyTaskProgReq.uin = DataModelMgr.PlayerDataModel:GetPlayerUin()
  modifyTaskProgReq.task_id = id
  modifyTaskProgReq.task_progress = progress
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_TASK_MODIFY_PROGRESS_REQ, modifyTaskProgReq, self, self._OnModifyTaskProgressRsp)
end

function DebugTabTask:AcceptRoleSpecialTask(name, panel)
  local _DCM = DataConfigManager
  local cfgTableId = _DCM.ConfigTableId.ROLE_GLOBAL_CONFIG
  local specTaskId = _DCM:GetGlobalConfigByKeyType("special_role_task", cfgTableId).num
  Log.DebugFormat("Accept special task %s", specTaskId)
  local acceptTaskReq = ProtoMessage.newZoneGmTaskAddReq()
  acceptTaskReq.uin = DataModelMgr.PlayerDataModel:GetPlayerUin()
  acceptTaskReq.task_id = specTaskId
  ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_TASK_ADD_REQ, acceptTaskReq, self, self._OnAcceptTaskRsp)
end

function DebugTabTask:_OnModifyTaskProgressRsp(rsp)
  if 0 ~= rsp.ret_info.ret_code then
    Log.Error("Modify task progress failed!")
  else
    Log.Debug("Modify task progress succeed")
    self:ClosePanel()
  end
end

function DebugTabTask:Warp()
  local TaskModule = NRCModuleManager:GetModule("TaskModule")
  for _, TO in pairs(TaskModule.data.TaskMap) do
    if TO.isTrack then
      for _, tracker in ipairs(TO.Trackers) do
        if tracker and tracker.Position then
          local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
          self:SetPlayerLocation(tracker.Position.X, tracker.Position.Y, tracker.Position.Z + 150)
          return
        end
      end
    end
  end
end

function DebugTabTask:FakeAcceptSubsequent(Conf, name, panel)
  local infos = {}
  local Info1 = ProtoMessage:newPlayerTaskInfo()
  Info1.task_target_list[1] = 1
  Info1.is_trace = true
  Info1.is_track = false
  Info1.id = Conf.id
  Info1.done_count = 0
  Info1.state = ProtoEnum.EMTaskState.EM_TASK_STATE_DONE
  table.insert(infos, Info1)
  for _, task in ipairs(Conf.next_task) do
    local Info = ProtoMessage:newPlayerTaskInfo()
    Info.task_target_list[1] = 0
    Info.is_trace = true
    if DataConfigManager:GetTaskConf(task).task_class == ProtoEnum.TaskClassType.TCT_MAIN then
      Info.is_track = true
    else
      Info.is_track = false
    end
    Info.id = task
    Info.done_count = 1
    Info.state = ProtoEnum.EMTaskState.EM_TASK_STATE_OPEN
    table.insert(infos, Info)
  end
  self:AddTaskInternalArray(infos)
end

function DebugTabTask:FakeAcceptTask(id)
  local Info = ProtoMessage:newPlayerTaskInfo()
  Info.task_target_list[1] = 1
  Info.is_trace = true
  Info.is_track = true
  Info.id = id
  Info.done_count = 0
  Info.state = ProtoEnum.EMTaskState.EM_TASK_STATE_OPEN
  self:AddTaskInternal(Info)
end

function DebugTabTask:AddTaskInternal(TaskInfo)
  local Tasks = NRCModuleManager:DoCmd(_G.TaskModuleCmd.getAllTraceTask, true)
  local Module = NRCModuleManager:GetModule("TaskModule")
  local Raw = {}
  for _, taskObj in ipairs(Tasks) do
    local task = taskObj.Info
    local Fake = ProtoMessage:newPlayerTaskInfo()
    Fake.is_track = false
    Fake.is_trace = true
    Fake.state = ProtoEnum.EMTaskState.EM_TASK_STATE_DONE
    Fake.id = task.id
    Fake.pet_gid = task.pet_gid
    Fake.done_count = task.done_count
    Fake.done_time = task.done_time
    table.insert(Raw, Fake)
  end
  table.insert(Raw, TaskInfo)
  local Notify = ProtoMessage:newZoneTaskInfoNotify()
  Notify.task_info_list = Raw
  Module:_OnTaskInfoNotify(Notify)
end

function DebugTabTask:AddTaskInternalArray(TaskInfos)
  local Tasks = NRCModuleManager:DoCmd(_G.TaskModuleCmd.getAllTraceTask, true)
  local Module = NRCModuleManager:GetModule("TaskModule")
  local Raw = {}
  for _, taskObj in ipairs(Tasks) do
    local task = taskObj.Info
    local Fake = ProtoMessage:newPlayerTaskInfo()
    Fake.is_track = false
    Fake.is_trace = task.is_trace
    Fake.state = task.state
    Fake.id = task.id
    Fake.pet_gid = task.pet_gid
    Fake.done_count = task.done_count
    Fake.done_time = task.done_time
    if taskObj.isTrack then
      table.insert(Raw, Fake)
    end
  end
  for _, Taskinfo in ipairs(TaskInfos) do
    table.insert(Raw, Taskinfo)
  end
  local Notify = ProtoMessage:newZoneTaskInfoNotify()
  Notify.task_info_list = Raw
  Module:_OnTaskInfoNotify(Notify)
end

function DebugTabTask:PrintTaskStatus()
  local Module = NRCModuleManager:GetModule("TaskModule")
  local Data = Module:GetData("TaskModuleData")
  local DumpData = {}
  for Key, Task in pairs(Data.TaskMap) do
    DumpData[tostring(Key)] = Task
  end
  self:Inspect(DumpData, "Tasks")
end

function DebugTabTask:ToggleEditorTaskID()
  if _G.GlobalConfig.bIsEditorShowTaskID then
    _G.GlobalConfig.bIsEditorShowTaskID = false
  else
    _G.GlobalConfig.bIsEditorShowTaskID = true
  end
  _G.NRCEventCenter:DispatchEvent(TaskModuleEvent.ToggleShowEditorTaskID, tip)
end

function DebugTabTask:ToggleShowNpcDebugLog()
  if _G.GlobalConfig.bIsShowFindNpcLog then
    _G.GlobalConfig.bIsShowFindNpcLog = false
  else
    _G.GlobalConfig.bIsShowFindNpcLog = true
  end
end

function DebugTabTask:PlaySequence()
  local Module = NRCModuleManager:GetModule("TaskModule")
  local Data = Module:GetData("TaskModuleData")
  for ID, Task in pairs(Data.TaskMap) do
    if Task.ShouldPlayOpenSequence then
      Task:ConsumeOpenPlaySequence()
      break
    elseif Task.ShouldPlayDoneSequence then
      Task:ConsumeDonePlaySequence()
      break
    end
  end
end

function DebugTabTask:OpenTaskPanel(name, panel)
  local TaskModuleCmd = require("NewRoco.Modules.Core.Task.TaskModuleCmd")
  NRCModuleManager:DoCmd(TaskModuleCmd.OpenTaskPanel)
end

function DebugTabTask:ShowCheckers()
  local Module = NRCModuleManager:GetModule("TaskModule")
  self:Inspect(Module.StatusChecker, "StatusCheckerGroup")
  if self.Panel then
    self.Panel:DoClose()
  end
end

function DebugTabTask:StopSequence(Name, Panel)
  local Cinema = NRCModuleManager:GetModule("CinematicModule")
  Cinema.CinematicPlayer:Stop()
  self:ClosePanel()
end

function DebugTabTask:StopMP4(Name, Panel)
  NRCModeManager:GetCurMode():DisablePanelByLayer(Enum.UILayerType.UI_LAYER_MAIN)
  local DialogueModule = _G.NRCModuleManager:GetModule("DialogueModule")
  local DialogueVideo = DialogueModule:GetPanel("DialogueVideo")
  if DialogueVideo then
    DialogueVideo:MovieDone()
  end
  self:ClosePanel()
end

function DebugTabTask:GetNPCByID(ID)
  local Module = _G.NRCModuleManager:GetModule("NPCModule")
  return Module:GetNpcsByFilter(nil, function(NPC)
    return NPC.config.id == ID
  end)
end

function DebugTabTask:WhyStuck(Name, Panel)
  local Main = _G.NRCModuleManager:GetModule("MainUIModule"):GetPanel("LobbyMain")
  local Task = Main.UMG_Task_Track
  local Widgets = {}
  for _, Widget in wpairs(Task.TaskList1) do
    if Widget and Widget.data then
      local ID = Widget.data.Info.id
      local Trackers = {}
      local TrackerData = Widget.data.Trackers
      if TrackerData then
        for _, Tracker in ipairs(TrackerData) do
          local AllNPCs = {}
          if Enum.TaskGoActionType.TGAT_NPC == Tracker.GoCondition.type then
            local NPCOptionState = self:GetNPCByID(Tracker.GoCondition.data1[1])
            for _, npc in ipairs(NPCOptionState) do
              local InterComp = npc.InteractionComponent
              local Count = 0
              if InterComp._options then
                for _, Opt in ipairs(InterComp._options) do
                  if Opt:IsOptionEnable() then
                    Count = Count + 1
                  end
                end
              end
              table.insert(AllNPCs, {
                ["\232\183\157\231\166\187"] = npc.squaredDis2Local,
                ["\229\143\175\231\148\168\233\128\137\233\161\185\230\149\176\233\135\143"] = Count
              })
            end
          end
          table.insert(Trackers, {
            ["\230\152\175\229\144\166\230\156\137\230\149\136?"] = Tracker.Valid,
            ["\229\174\162\230\136\183\231\171\175\229\157\144\230\160\135"] = Tracker.Position,
            ["\230\156\141\229\138\161\229\153\168\229\157\144\230\160\135"] = Tracker.Server_Position,
            ["\232\191\189\232\184\170\231\177\187\229\158\139"] = table.getKeyName(Enum.TaskGoActionType, Tracker.GoCondition.type),
            ["\232\191\189\232\184\170\230\149\176\230\141\174"] = Tracker.GoCondition,
            ["\232\191\189\232\184\170NPC"] = AllNPCs
          })
        end
      end
      Widgets[ID] = {
        ["\228\187\187\229\138\161ID"] = ID,
        ["\228\187\187\229\138\161\230\150\135\230\156\172"] = Widget.TxtTaskDesc:GetText(),
        ["\230\152\175\229\144\166\232\191\189\232\184\170?"] = Widget.data.isTrack,
        ["\230\152\175\229\144\166\229\143\175\232\167\129?"] = Widget:GetIsVisible(),
        ["\229\138\168\231\148\187\230\146\173\230\148\190\228\184\173?"] = Widget:IsAnyAnimationPlaying(),
        ["\230\152\175\229\144\166\232\166\129\231\167\187\233\153\164?"] = Widget:ShouldRemove(),
        ["\230\152\175\229\144\166\230\173\163\229\156\168\230\146\173\231\167\187\233\153\164\229\138\168\231\148\187?"] = Widget:IsAnimationPlaying(Widget.Taskcomplete),
        ["\230\152\175\229\144\166\232\166\129\230\183\187\229\138\160"] = Widget:ShouldShow(),
        ["\230\152\175\229\144\166\230\173\163\229\156\168\230\146\173\230\148\190\230\183\187\229\138\160\229\138\168\231\148\187?"] = Widget:IsAnimationPlaying(Widget.NewTask),
        ["\232\191\189\232\184\170\228\191\161\230\129\175"] = Trackers and Trackers or "\230\151\160"
      }
    end
  end
  local Payload = {
    ["\229\189\147\229\137\141\229\177\149\231\164\186\231\154\132\230\182\136\230\129\175"] = Task.CurrentTip and Task.CurrentTip or "\230\151\160",
    ["\230\152\175\229\144\166\229\156\168\230\146\173\231\167\187\233\153\164\229\138\168\231\148\187?"] = Task.IsRemovePass,
    ["\230\146\173\230\148\190\229\136\176\231\172\172\229\135\160\228\184\170?"] = Task.PlayIndex,
    ["\228\187\187\229\138\161\230\160\143"] = Widgets,
    ["\231\173\137\229\190\133NPC\228\186\164\228\186\146\229\155\158\229\140\133\239\188\159"] = NpcOption:NeedStatusNotify()
  }
  self:Inspect(Payload, "\228\187\187\229\138\161\230\149\176\230\141\174")
end

function DebugTabTask:ShowExtraTrackingInfo(Name, Panel)
  local TaskModule = self:GetModule("TaskModule")
  self:Inspect(TaskModule.ExtraTrackingInfo, "TrackingInfo")
end

function DebugTabTask:SwitchSkipDialogue(Name, Panel)
  DialogueUtils.SkipDialogue = true
  _G.UserSettingManager:SetDialogueAutoPlay(false)
  NRCModuleManager:DoCmd(DialogueModuleCmd.ShowStoryDebugCenter, true)
end

function DebugTabTask:SwitchFastDialogue()
  DialogueUtils.SkipTyping = true
  if DialogueUtils.SkipTyping then
    NRCModuleManager:DoCmd(DialogueModuleCmd.ShowStoryDebugCenter, true)
  end
end

function DebugTabTask:OpenNewTaskPanel()
  _G.NRCModuleManager:DoCmd(TaskModuleCmd.OpenNewTaskPanel)
end

function DebugTabTask:FreezeWorldComposition(Name, Panel)
  local Text = self.Panel.InputBox:GetText()
  UE4.UNRCStatics.FreezeWorldComposition()
end

function DebugTabTask:GetMagicManualInfo(_CurChapterId)
  local PlayerUin = DataModelMgr.PlayerDataModel:GetPlayerUin()
  local MagicManualChapterReq = _G.ProtoMessage:newZoneGmOpenAdventureChapterReq()
  MagicManualChapterReq.uin = PlayerUin
  MagicManualChapterReq.chapter_id = _CurChapterId
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_OPEN_ADVENTURE_CHAPTER_REQ, MagicManualChapterReq, self, self.GetMagicManualChapterInfo)
end

function DebugTabTask:FinishCurTask(_taskid)
  local PlayerUin = DataModelMgr.PlayerDataModel:GetPlayerUin()
  local DoneTaskReq = _G.ProtoMessage:newZoneGmTaskDoneReq()
  DoneTaskReq.uin = PlayerUin
  DoneTaskReq.task_id = _taskid
  Log.Dump(DoneTaskReq, 6, "DebugTabTask:SetupTabs")
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_TASK_DONE_REQ, DoneTaskReq, self, self.DoneCurMagicManualTask)
end

function DebugTabTask:ReplayOne()
  local TaskModule = self:GetModule("TaskModule")
  for _, Task in pairs(TaskModule.data.TaskMap) do
    Task:Destroy()
  end
  table.clear(TaskModule.data.TaskMap)
  TaskObject.SetShouldSkipSendRequest(true)
  local Path = UE.UBlueprintPathsLibrary.ConvertRelativePathToFull(UE.UBlueprintPathsLibrary.ProjectLogDir())
  Path = UE.UBlueprintPathsLibrary.ConvertRelativePathToFull(string.format("%s%s", Path, self:GetInputString()))
  local Player = InMemoryProtocolPlayer()
  Player:Play(Path, 150, 300, 3)
end

function DebugTabTask:ShowTaskTips(Name, Panel, InputNumber)
  local inputId
  if Panel then
    inputId = Panel:GetInputNumber(70111001)
  else
    inputId = tonumber(InputNumber) or 70111001
  end
  _G.NRCEventCenter:DispatchEvent(TipsModuleEvent.Tips_LobbyMainTaskNew, TipObject.FromTaskAccept({id = inputId}))
end

function DebugTabTask:finishTask(Name, panel, ID)
  if panel then
    local req = ProtoMessage:newZoneGmClientTaskFinishReq()
    req.task_id = panel:GetInputNumber() or ID
    if 0 == req.task_id then
      req.task_id = nil
    end
    _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_CLIENT_TASK_FINISH_REQ, req, self, self.GetRsp)
  elseif ID then
    local req = ProtoMessage:newZoneGmClientTaskFinishReq()
    local taskIDNum = tonumber(ID)
    req.task_id = taskIDNum
    _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_CLIENT_TASK_FINISH_REQ, req, self, self.GetRsp)
  end
end

function DebugTabTask:finishTaskTarget(name, panel, ID)
  if panel then
    local req = ProtoMessage:newZoneGmClientTaskTktDoneReq()
    req.num = panel:GetInputNumber()
    _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_CLIENT_TASK_TKT_DONE_REQ, req, self, self.GetRsp)
  elseif ID then
    local req = ProtoMessage:newZoneGmClientTaskTktDoneReq()
    local taskIDNum = tonumber(ID)
    req.num = taskIDNum
    _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_CLIENT_TASK_TKT_DONE_REQ, req, self, self.GetRsp)
  end
end

function DebugTabTask:GetRsp(rsp)
end

function DebugTabTask:clearTask(name, panel, taskID)
  if panel then
    local req = ProtoMessage:newZoneGmClientTaskClearReq()
    local taskIDNum = panel:GetInputNumber()
    if 0 ~= taskIDNum then
      req.task_id = taskIDNum
    end
    _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_CLIENT_TASK_CLEAR_REQ, req, self, self.GetRsp)
  elseif taskID then
    local req = ProtoMessage:newZoneGmClientTaskClearReq()
    local taskIDNum = tonumber(taskID)
    if 0 ~= taskIDNum then
      req.task_id = taskIDNum
    end
    _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_CLIENT_TASK_CLEAR_REQ, req, self, self.GetRsp)
  end
end

function DebugTabTask:UnlockMappoint(Name, Panel)
  local req = ProtoMessage:newZoneGmClientUnlockAllCampReq()
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_CLIENT_UNLOCK_ALL_CAMP_REQ, req, self, self.GetRsp)
end

function DebugTabTask:OpenTaskPhoto(name, panel, id)
  self.player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local taskId
  if panel then
    taskId = panel:GetInputNumber()
  else
    taskId = tonumber(id)
  end
  if 0 == taskId then
    taskId = tonumber(id)
  end
  local TaskConf = _G.DataConfigManager:GetTaskConf(taskId)
  local summary_id
  for _, Condition in ipairs(TaskConf.finish_action) do
    if Condition.type == Enum.TaskStateChangeActionType.TSCAT_TASK_SUMMARY then
      summary_id = Condition.data1[1]
    end
  end
  local uiData = {
    summary_id = summary_id,
    tod = Enum.TimeOfDay.TOD_TWILIGHT,
    weather = Enum.WeatherType.WT_SUNNY,
    fashion = {
      fashion_id = self.player:GetFashionIds(),
      salon_item_data = self.player:GetSalonIds()
    },
    Weather2 = 1734356451
  }
  _G.NRCModuleManager:DoCmd(TaskModuleCmd.OpenTaskPhoto, TipObject.CreateTaskSummaryTips(uiData))
end

function DebugTabTask:OpenTaskPanelByParagraphList(name, panel, id, InputText)
  local InputInfo
  if panel then
    InputInfo = panel:GetInputNumber(nil, true)
  else
    InputInfo = InputText
  end
  local ParagraphList = string.split(InputInfo, ",")
  local List = {}
  for i, Paragraph in ipairs(ParagraphList) do
    table.insert(List, tonumber(Paragraph))
  end
  _G.NRCModeManager:DoCmd(TaskModuleCmd.TraceParagraphOpenTaskPanel, List)
  if panel then
    panel:DoClose()
  end
end

function DebugTabTask:GMGoToMagicAdventureByChapterId(name, panel, InputText)
  local InputInfo
  if panel then
    InputInfo = panel:GetInputNumber(nil, true)
  else
    InputInfo = InputText
  end
  local req = ProtoMessage:newZoneGmAdventureSettingReq()
  req.uin = DataModelMgr.PlayerDataModel:GetPlayerUin()
  req.chapter_id = tonumber(InputInfo)
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_ADVENTURE_SETTING_REQ, req, self, self.GetRsp)
  if panel then
    panel:DoClose()
  end
end

local NonRelatedCategories = {
  "LogSerialization",
  "LogTemp",
  "LogNRCQuality",
  "LogRHI",
  "LogGPMStatics",
  "LogAkAudio",
  "LogNetworkManager",
  "LogBlueprintUserMessages",
  "LogUObjectGlobals",
  "LogTexture",
  "LogStaticMesh",
  "LogMaterial",
  "LogGenericStorages",
  "LogNiagara",
  "LogMetal",
  "LogHttp"
}

function DebugTabTask:DisableLogs(Name, Panel)
  if RocoEnv.IS_EDITOR then
    return
  end
  UE4.UNRCStatics.SetLogLevel(7)
  Log.SetLogLevel(Log.LOG_LEVEL.ELogDebug)
  for _, Cat in ipairs(NonRelatedCategories) do
    UE4.UNRCStatics.ExecConsoleCommand(string.format("log %s error", Cat))
  end
end

function DebugTabTask:EnableLogs(Name, Panel)
  if RocoEnv.IS_EDITOR then
    return
  end
  UE4.UNRCStatics.SetLogLevel(7)
  Log.SetLogLevel(Log.LOG_LEVEL.ELogDebug)
  for _, Cat in ipairs(NonRelatedCategories) do
    UE4.UNRCStatics.ExecConsoleCommand(string.format("log %s display", Cat))
  end
end

function DebugTabTask:ForceCreateNPC(Name, Panel)
  local ID = self:GetInputNumber()
  Log.Error("\229\174\162\230\136\183\231\171\17510\231\167\146\233\146\159\229\134\133\230\178\161\230\156\137\230\148\182\229\136\176\232\191\153\228\184\170NPC\231\154\132\230\182\136\230\129\175\239\188\140\229\188\186\229\136\182\232\175\183\230\177\130\229\144\142\229\143\176...", ID)
  local Req = _G.ProtoMessage:newZoneTryInstantiateNpcReq()
  Req.content_cfg_id = ID
  _G.ZoneServer:SendWithHandler(_G.ProtoEnum.ZoneSvrCmd.ZONE_TRY_INSTANTIATE_NPC_REQ, Req, self, self.OnReported, false, false)
end

function DebugTabTask:OnReported(rsp)
  Log.Error("\229\188\186\229\136\183NPC\231\154\132\229\155\158\229\140\133", rsp.ret_info.ret_code)
end

function DebugTabTask:EnableTaskGuideVisualize(Name, Panel)
  local BP_TaskGuideSpline_C = require("NewRoco.Modules.Core.Task.BP_TaskGuideSpline_C")
  BP_TaskGuideSpline_C.EnableTaskGuideVisualize()
end

function DebugTabTask:AddLogBreakpoint(Name, Panel)
  if not RocoEnv.IS_EDITOR then
    Log.Error("\229\143\170\230\156\137Editor\230\137\141\232\131\189\228\189\191\231\148\168\230\173\164\229\138\159\232\131\189")
    return
  end
  if not Panel then
    Log.Error("\232\191\153\228\184\170\229\138\159\232\131\189\230\151\160\230\179\149GM\229\140\150")
    return
  end
  local Input = self:GetInputString()
  if string.IsNilOrEmpty(Input) then
    return
  end
  table.insert(Log.Breakpoints, Input)
end

function DebugTabTask:TrySummonPetFollow(_, _)
  if not _G.NRCModuleManager:IsModuleActive("TaskPetFollowModule") then
    _G.NRCModuleManager:ActiveModule("TaskPetFollowModule")
  end
  local Input = self:GetInputString()
  local PetConfID = tonumber(Input) or 2000670
  local TrackTaskObject = _G.NRCModuleManager:DoCmd(_G.TaskModuleCmd.GetTrackTask)
  local TaskID = TrackTaskObject and TrackTaskObject.Config.id
  _G.NRCModeManager:DoCmd(_G.TaskPetFollowModuleCmd.TrySummonPetFollow, PetConfID, TaskID)
end

function DebugTabTask:OpenSeasonManualChapter(_, _)
  if not _G.NRCModuleManager:IsModuleActive("MagicManualModule") then
    _G.NRCModuleManager:ActiveModule("MagicManualModule")
  end
  local Input = self:GetInputString()
  if string.IsNilOrEmpty(Input) then
    return
  end
  _G.NRCModeManager:DoCmd(_G.MagicManualModuleCmd.OnGMOpenSeasonManualChapter, tonumber(Input), nil)
end

function DebugTabTask:SetSeasonBadgeLevel(_, _)
  if not _G.NRCModuleManager:IsModuleActive("MagicManualModule") then
    _G.NRCModuleManager:ActiveModule("MagicManualModule")
  end
  local Input = self:GetInputString()
  if string.IsNilOrEmpty(Input) then
    return
  end
  _G.NRCModeManager:DoCmd(_G.MagicManualModuleCmd.OnGMOpenSeasonManualChapter, nil, tonumber(Input))
end

function DebugTabTask:TryRecycleFollowedPet(_, _)
  _G.NRCModeManager:DoCmd(_G.TaskPetFollowModuleCmd.RecycleFollowedPets)
end

function DebugTabTask:TaskTrackTest(_, Panel, InputText)
  local InputInfo
  if Panel then
    InputInfo = Panel:GetInputNumber(0)
  else
    InputInfo = InputText
  end
  local PosList = {}
  PosList = NRCModeManager:DoCmd(TaskModuleCmd.GetTrackerPos, InputInfo)
  if PosList and table.len(PosList) > 0 then
    for i, Pos in ipairs(PosList) do
      Log.Debug("DebugTabTask:TaskTrackTest Pos", InputInfo, Pos)
    end
  else
    Log.Debug("DebugTabTask:TaskTrackTest PosList is nil", InputInfo)
  end
end

function DebugTabTask:OpenLoadingTest(_, Panel, InputText)
  Log.Debug("DebugTabTask:OpenLoadingTest")
  NRCModuleManager:DoCmd(LoadingUIModuleCmd.OpenLoadingUI, InputText, 1)
end

function DebugTabTask:CloseLoadingTest(_, Panel, InputText)
  Log.Debug("DebugTabTask:CloseLoadingTest")
  local InputInfo
  if Panel then
    InputInfo = Panel:GetInputNumber(2)
  else
    InputInfo = InputText
  end
  NRCModuleManager:DoCmd(LoadingUIModuleCmd.CloseLoadingUI, InputInfo)
  _G.DelayManager:DelaySeconds(2.1, function()
    NRCModuleManager:DoCmd(LoadingUIModuleCmd.OpenLoadingUI, InputText, 0.8)
  end, self)
end

return DebugTabTask
