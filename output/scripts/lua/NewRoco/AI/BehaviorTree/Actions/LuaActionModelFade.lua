local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionModelFade = Base:Extend("LuaActionModelFade")

function LuaActionModelFade:OnStart(AIController, ...)
  local args = {
    ...
  }
  local owner = AIController
  local fadeOut = self.FadeOut:GetValue(owner)
  local Time = self.Time:GetValue(owner)
  owner.Npc.viewObj:SetActorHiddenInGame(fadeOut)
  self:Finish(true)
end

return LuaActionModelFade
