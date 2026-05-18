require("UnLuaEx")
local LuaActionBase = NRCClass()

function LuaActionBase:Ctor(LuaBTNodeBase)
  self.BTNodeBase = LuaBTNodeBase
end

function LuaActionBase:OnStart(owner, ...)
end

function LuaActionBase:OnUpdate(AIController, DeltaTime, ...)
end

function LuaActionBase:OnInterrupt(owner, Finalized)
end

function LuaActionBase:OnEnd(owner, ...)
end

function LuaActionBase:Finish(...)
  self.BTNodeBase:Finish(...)
end

return LuaActionBase
