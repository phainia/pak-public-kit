local NPCModuleEnum = require("NewRoco.Modules.Core.NPC.NPCModuleEnum")
local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionCollisionCancelOrRecover = Base:Extend("LuaActionCollisionCancelOrRecover")

function LuaActionCollisionCancelOrRecover:OnStart(AIController, ...)
  local args = {
    ...
  }
  local owner = AIController
  local isCollisionCancel = self.IsCollisionCancel:GetValue(owner)
  owner.Npc:SetCollisionDisable(isCollisionCancel, NPCModuleEnum.NpcReasonFlags.AI)
  self:Finish(true)
end

return LuaActionCollisionCancelOrRecover
