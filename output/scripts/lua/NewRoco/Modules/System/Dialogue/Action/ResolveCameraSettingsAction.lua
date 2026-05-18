local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local DialogueCameraSettings = require("NewRoco.Modules.System.Dialogue.DialogueCameraSettings")
local DialogueActionBase = require("NewRoco.Modules.System.Dialogue.Action.DialogueActionBase")
local Base = DialogueActionBase
local ResolveCameraSettingsAction = Base:Extend("ResolveCameraSettingsAction")
FsmUtils.MergeMembers(Base, ResolveCameraSettingsAction, {
  {
    name = "DialogueConf",
    type = "var"
  },
  {
    name = "CameraSettingFirst",
    type = "var"
  },
  {
    name = "CameraSettingSecond",
    type = "var"
  }
})

function ResolveCameraSettingsAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function ResolveCameraSettingsAction:OnEnter()
  self:InjectProperties()
  local DialogueConf = self:GetProperty("DialogueConf")
  if not DialogueConf then
    self:Finish()
    return
  end
  local Camera1 = DialogueCameraSettings:newCameraSetting()
  Camera1.camera_switch_type = DialogueConf.camera_switch_type
  Camera1.interact_camera_type = DialogueConf.interact_camera_type
  Camera1.interact_camera_param1 = DialogueConf.interact_camera_param1
  Camera1.interact_camera_param2 = DialogueConf.interact_camera_param2
  Camera1.interact_camera_param3 = DialogueConf.interact_camera_param3
  Camera1.interact_camera_param4 = DialogueConf.interact_camera_param4
  Camera1.unskippable_duration = DialogueConf.unskippable_duration
  Camera1.ui_camera_focus_socketname = DialogueConf.interact_camera_param4
  Camera1.camera_motion_type = DialogueConf.camera_motion_type
  Camera1.camera_motion_direction = DialogueConf.camera_motion_direction or ""
  Camera1.camera_motion_distance = DialogueConf.camera_motion_distance
  Camera1.camera_motion_time = DialogueConf.camera_motion_time
  Camera1.CameraNumber = 1
  self:SetProperty("CameraSettingFirst", Camera1)
  local Camera2 = DialogueCameraSettings:newCameraSetting()
  Camera2.camera_switch_type = Enum.CameraSwitchType.CAMST_INSTANT
  Camera2.interact_camera_type = DialogueConf.interact_camera_type_2
  Camera2.interact_camera_param1 = DialogueConf.interact_camera2_param1
  Camera2.interact_camera_param2 = DialogueConf.interact_camera2_param2
  Camera2.interact_camera_param3 = DialogueConf.interact_camera2_param3
  Camera2.interact_camera_param4 = DialogueConf.interact_camera2_param4
  Camera2.unskippable_duration = DialogueConf.unskippable_duration2
  Camera2.ui_camera_focus_socketname = DialogueConf.interact_camera2_param4
  Camera2.camera_motion_type = DialogueConf.camera2_motion_type
  Camera2.camera_motion_direction = DialogueConf.camera2_motion_direction or ""
  Camera2.camera_motion_distance = DialogueConf.camera2_motion_distance
  Camera2.camera_motion_time = DialogueConf.camera2_motion_time
  Camera2.CameraNumber = 2
  self:SetProperty("CameraSettingSecond", Camera2)
  self:Finish()
end

function ResolveCameraSettingsAction:OnExit()
end

return ResolveCameraSettingsAction
