local Base = require("NewRoco.AI.BehaviorTree.SimpleTask.SimpleTaskBase")
local SimpleTaskPlayAnimation = Base:Extend("SimpleTaskPlayAnimation")

function SimpleTaskPlayAnimation.Execute(...)
  local args = {
    ...
  }
  local ownerController = args[1]
  local animName = args[2]
  local playRate = args[3]
  local startPos = args[4]
  local blendInTime = args[5]
  local blendOutTime = args[6] or 0
  local loopCount = args[7] or 1
  if loopCount <= 0 then
    loopCount = 1
  end
  local pawn = ownerController:K2_GetPawn()
  local animLen = pawn:GetAnimComponent():PlayAnimByName(animName, playRate, startPos, blendInTime, blendOutTime, loopCount) or 0
  return animLen
end

return SimpleTaskPlayAnimation
