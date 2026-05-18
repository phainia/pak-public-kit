local CinematicDataUtils = {}

function CinematicDataUtils:NewSequenceSettings()
  return {
    Disable_MovementInput = true,
    Disable_Look_At_Input = true,
    Disable_Camera_Cuts = false,
    Hide_Hud = true,
    Sequence_Origin = nil,
    Caller = nil,
    Callback = nil
  }
end

return CinematicDataUtils
