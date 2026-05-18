local AIComponent = require("NewRoco.Modules.Core.Scene.Component.AI.AIComponent")
local InstanceUtils = {}
InstanceUtils.MechanismTags = {
  Portal = 0,
  Rampart = 1,
  Plate = 2,
  Fence = 3,
  Lamp = 4,
  Hearth = 5
}

function InstanceUtils.LockAI(Actor)
  local Comp = Actor:EnsureComponent(AIComponent)
  Comp:ForceLockForReason(true, false, AIDefines.LockReason.INTERACT)
end

return InstanceUtils
