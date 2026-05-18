local NRCModeAction = require("Core.NRCMode.NRCModeAction")
local PlayerModuleCmd = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleCmd")
local DisplayTaskObject = require("NewRoco.Modules.Core.Task.DisplayTaskObject")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local DisplayTaskTypeEnum = require("NewRoco.Modules.Core.Task.DisplayTaskTypeEnum")
local ProtoMessage = require("Data.PB.ProtoMessage")
local Base = NRCModeAction
local AddCreatePlayerTaskAction = Base:Extend("AddCreatePlayerTaskAction")
FsmUtils.MergeMembers(Base, AddCreatePlayerTaskAction, {
  {
    name = "ParentModule",
    type = "var"
  }
})

function AddCreatePlayerTaskAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.properties = properties
end

function AddCreatePlayerTaskAction:OnEnter()
  self:InjectProperties()
  if self.ParentModule:HasPanel("PlayerMain") then
    local DimoControlPanel = self.ParentModule:GetPanel("PlayerMain")
    if DimoControlPanel then
      if DimoControlPanel.UMG_TaskTrack then
        local Info = ProtoMessage:newPlayerTaskInfo()
        Info.task_target_list[1] = 0
        Info.is_trace = true
        Info.is_track = true
        Info.id = 60010001
        Info.done_count = 0
        Info.state = ProtoEnum.EMTaskState.EM_TASK_STATE_OPEN
        local Notify = ProtoMessage:newZoneTaskInfoNotify()
        Notify.task_info_list = {Info}
        local TaskModule = NRCModuleManager:GetModule("TaskModule")
        if TaskModule then
          TaskModule:_OnTaskInfoNotify(Notify)
          local TaskObjects = TaskModule:GetAllTraceTask()
          local TaskObject = TaskObjects and #TaskObjects > 0 and TaskObjects[1]
          if TaskObject then
            DimoControlPanel.UMG_TaskTrack:SetData(TaskObject)
            DimoControlPanel.UMG_TaskTrack:ConsumeShow()
            DimoControlPanel.UMG_TaskTrack:SkipShowAnimation()
          else
            Log.Debug("AddCreatePlayerTaskAction: No valid task objects after manual notify!")
          end
        else
          Log.Debug("AddCreatePlayerTaskAction: Cannot get valid TaskModule!")
        end
      else
        Log.Debug("AddCreatePlayerTaskAction: Can not find DimoControlPanel!")
      end
    else
      Log.Debug("AddCreatePlayerTaskAction: DimoControlPanel is not open for now!")
    end
  end
  self:Finish()
end

return AddCreatePlayerTaskAction
