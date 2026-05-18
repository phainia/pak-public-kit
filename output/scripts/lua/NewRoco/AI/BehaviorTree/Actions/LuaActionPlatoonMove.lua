local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionPlatoonMove = Base:Extend("LuaActionPlatoonMove")

function LuaActionPlatoonMove:OnStart(AIController, ...)
  LuaBTUtils.LogDebug("LuaActionPlatoonMove Start")
  self:Finish(true)
end

function LuaActionPlatoonMove:OnUpdate(AIController, DeltaTime)
end

function LuaActionPlatoonMove:OnSuccess(MovementResult)
  LuaBTUtils.LogDebug("LuaActionPlatoonMove Success")
  self:Finish(true)
end

function LuaActionPlatoonMove:OnFail(MovementResult)
  LuaBTUtils.LogDebug("LuaActionPlatoonMove Fail")
  self:Finish(false)
end

function LuaActionPlatoonMove:OnInterrupt(AIController, ...)
  LuaBTUtils.LogDebug("LuaActionPlatoonMove Interrupt")
  self:OnFail(nil)
end

return LuaActionPlatoonMove
