local Base = require("NewRoco.AI.BehaviorTree.LuaServiceBase")
local AIStateLookAtCamera = require("NewRoco.AI.State.AIStateLookAtCamera")
local LuaServiceLookAtCamera = Base:Extend("LuaServiceLookAtCamera")

function LuaServiceLookAtCamera:OnStart(owner, ...)
  local Fallback = self.Target and self.Target:GetValue(owner) or nil
  local Immediately = self.Immediately and self.Immediately:GetValue(owner) or false
  owner.Npc.AIComponent:TryAppendState(AIStateLookAtCamera, Immediately, Fallback.viewObj)
end

function LuaServiceLookAtCamera:OnEnd(owner, Finalizing)
  owner.Npc.AIComponent:TryRemoveState(AIStateLookAtCamera)
end

return LuaServiceLookAtCamera
