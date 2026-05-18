local HiddenComponent = require("NewRoco.Modules.Core.Scene.Component.Hidden.HiddenComponent")
local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionWorldHidden = Base:Extend("LuaActionWorldHidden")

function LuaActionWorldHidden:OnStart(AIController, ...)
  local owner = AIController
  if not owner.Npc.viewObj.resourceLoaded then
    return self:Finish(false)
  end
  local hideComp = owner.Npc:GetComponent(HiddenComponent)
  if not hideComp or not hideComp:CanHide() then
    if GlobalConfig.DebugLuaBTree then
      Log.Debug("[LuaActionWorldHidden] \228\184\128\228\184\170\228\184\141\232\131\189\229\140\191\232\184\170\231\154\132\231\178\190\231\129\181\229\176\157\232\175\149\229\140\191\232\184\170", owner.Npc.config.name)
    end
    return self:Finish(false)
  end
  if not hideComp:BeginHide() then
    return self:Finish(false)
  end
  self:Finish(true)
end

return LuaActionWorldHidden
