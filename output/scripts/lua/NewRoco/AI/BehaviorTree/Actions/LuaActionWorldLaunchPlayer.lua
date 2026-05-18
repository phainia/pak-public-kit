local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionWorldLaunchPlayer = Base:Extend("LuaActionWorldLaunchPlayer")

function LuaActionWorldLaunchPlayer:OnStart(AIController, ...)
  local owner = AIController
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local AttackedInteractionComp = localPlayer and localPlayer.playerAttackedInteractionComponent
  if AttackedInteractionComp and AttackedInteractionComp:CanLaunchByNpc() then
    local ForceXY = self.ForceXY:GetValue(owner)
    local ForceZ = self.ForceZ:GetValue(owner)
    local Direction = self.Direction:GetValue(owner)
    local Cooldown = self.Cooldown:GetValue(owner)
    Direction.Z = 0
    Direction:Normalize()
    Direction:Mul(ForceXY)
    Direction.Z = ForceZ
    AttackedInteractionComp:OnLaunchByNpc(owner.Npc, Direction, Cooldown, true)
  end
  self:Finish(true)
end

return LuaActionWorldLaunchPlayer
