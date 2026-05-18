local Base = require("NewRoco.AI.BehaviorTree.LuaServiceBase")
local FVector2DUtils = require("NewRoco.Utils.FVector2DUtils")
local LuaServiceCalculateLeaveAngle = Base:Extend("LuaServiceCalculateLeaveAngle")

function LuaServiceCalculateLeaveAngle:OnUpdateService(OwnerController, DeltaTime, ...)
  local owner = OwnerController
  local player = owner:GetBlackboardValue("LocalPlayer")
  local playerPos = player:GetActorLocation()
  local selfPos = owner.Npc:GetActorLocation()
  local playerForward = player.viewObj:GetActorForwardVector()
  local dirPlayerToSelf = selfPos - playerPos
  local angle = FVector2DUtils.AngleBetweenRelative(playerForward, dirPlayerToSelf)
  if self.DirSensitive and self.DirSensitive:GetValue(owner) then
  else
    angle = math.abs(angle)
  end
  self.OutAngle:SetValue(owner, angle)
end

return LuaServiceCalculateLeaveAngle
