local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionAnimPauseOrResume = Base:Extend("LuaActionAnimPauseOrResume")

function LuaActionAnimPauseOrResume:OnStart(AIController, ...)
  local args = {
    ...
  }
  local owner = AIController
  local isPauseAnim = self.IsPauseAnim:GetValue(owner)
  local task = LuaBTUtils.SPT_PauseOrResumeAnimation
  self.leftAnimLen = task.Execute(owner, isPauseAnim) or 0
  if isPauseAnim then
    self:Finish(true)
  end
end

function LuaActionAnimPauseOrResume:OnUpdate(AIController, DeltaTime)
  self.leftAnimLen = self.leftAnimLen - DeltaTime
  if self.leftAnimLen < 0 then
    self:Finish(true)
  end
end

return LuaActionAnimPauseOrResume
