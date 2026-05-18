local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionReleaseNpc = Base:Extend("LuaActionReleaseNpc")

function LuaActionReleaseNpc:OnStart(AIController, ...)
  local args = {
    ...
  }
  local owner = AIController
  self.curFleeCompleteTime = self.FleeCompleteTime:GetValue(owner)
  self.released = false
end

function LuaActionReleaseNpc:OnUpdate(AIController, DeltaTime, ...)
  local args = {
    ...
  }
  local owner = AIController
  self.curFleeCompleteTime = self.curFleeCompleteTime - DeltaTime
  if not self.released and self.curFleeCompleteTime < 0 then
    Log.Error("\232\175\165\229\141\143\232\174\174\229\183\178\228\189\156\229\186\159\239\188\140\232\175\183\228\189\191\231\148\168SceneCommand\232\138\130\231\130\185\229\143\145\233\128\129release\228\191\161\230\129\175")
    self.released = true
  end
end

return LuaActionReleaseNpc
