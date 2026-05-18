local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionGeneratePlatoonMoveTarget = Base:Extend("LuaActionGeneratePlatoonMoveTarget")

function LuaActionGeneratePlatoonMoveTarget:OnStart(AIController, ...)
  LuaBTUtils.LogDebug("LuaActionGeneratePlatoonMoveTarget Start")
  self:Finish(true)
end

function LuaActionGeneratePlatoonMoveTarget:OnUpdate(AIController, DeltaTime)
end

function LuaActionGeneratePlatoonMoveTarget:OnSuccess(MovementResult)
  LuaBTUtils.LogDebug("LuaActionGeneratePlatoonMoveTarget Success")
  self:Finish(true)
end

function LuaActionGeneratePlatoonMoveTarget:OnFail(MovementResult)
  LuaBTUtils.LogDebug("LuaActionGeneratePlatoonMoveTarget Fail")
  self:Finish(false)
end

function LuaActionGeneratePlatoonMoveTarget:OnInterrupt(AIController, ...)
  LuaBTUtils.LogDebug("LuaActionGeneratePlatoonMoveTarget Interrupt")
  self:OnFail(nil)
end

return LuaActionGeneratePlatoonMoveTarget
