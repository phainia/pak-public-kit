local DialogueCameraSettings = {}

function DialogueCameraSettings:newCameraSetting()
  return {
    camera_switch_type = nil,
    interact_camera_type = nil,
    interact_camera_param1 = "",
    interact_camera_param2 = 0,
    interact_camera_param3 = 0,
    interact_camera_param4 = 0,
    unskippable_duration = 0,
    camera_motion_type = nil,
    camera_motion_direction = nil,
    camera_motion_distance = 0,
    camera_motion_time = 0,
    CameraNumber = 0,
    ui_camera_focus_socketname = nil
  }
end

return DialogueCameraSettings
