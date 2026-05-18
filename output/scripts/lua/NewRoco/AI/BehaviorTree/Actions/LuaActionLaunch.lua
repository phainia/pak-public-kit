local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionLaunch = Base:Extend("LuaActionLaunch")

function LuaActionLaunch:OnStart(AIController, ...)
  local owner = AIController
  local npc = owner.Npc
  if npc.LaunchCharacter then
    local moveComp = npc.viewObj and npc.viewObj.CharacterMovement
    local gravity = moveComp and moveComp:GetGravityZ() or 980
    gravity = math.abs(gravity)
    local source = npc:GetActorLocation()
    local target = self.Target:GetValue(owner)
    local height = self.Height:GetValue(owner)
    local launchVel = SceneUtils.CalcLaunchVelocity(source, target, height, gravity)
    npc:AddEventListener(self, NPCModuleEvent.ON_NPC_LAUNCH_END, self.OnLaunchEnd)
    npc:LaunchCharacter(launchVel, true, true, true)
  else
    self:Finish(false)
  end
end

function LuaActionLaunch:OnInterrupt(AIController, Interrupt)
  local owner = AIController
  local npc = owner.Npc
  npc:RemoveEventListener(self, NPCModuleEvent.ON_NPC_LAUNCH_END, self.OnLaunchEnd)
  npc:Stop()
end

function LuaActionLaunch:OnLaunchEnd(npc)
  npc:RemoveEventListener(self, NPCModuleEvent.ON_NPC_LAUNCH_END, self.OnLaunchEnd)
  self:Finish(true)
end

return LuaActionLaunch
