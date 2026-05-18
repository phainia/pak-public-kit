local Base = require("NewRoco.AI.BehaviorTree.SimpleTask.SimpleTaskBase")
local SimpleTaskPauseOrResumeAnimation = Base:Extend("SimpleTaskPauseOrResumeAnimation")

function SimpleTaskPauseOrResumeAnimation.Execute(...)
  local args = {
    ...
  }
  local ownerController = args[1]
  local isPause = args[2]
  local pawn = ownerController:K2_GetPawn()
  if isPause then
    pawn:GetAnimComponent():PauseCurrentAnim()
    return 0
  else
    return pawn:GetAnimComponent():ResumeCurrentAnim()
  end
end

return SimpleTaskPauseOrResumeAnimation
