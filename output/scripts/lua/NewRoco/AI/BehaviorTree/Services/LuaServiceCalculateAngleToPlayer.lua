local Base = require("NewRoco.AI.BehaviorTree.LuaServiceBase")
local FVector2DUtils = require("NewRoco.Utils.FVector2DUtils")
local LuaServiceCalculateAngleToPlayer = Base:Extend("LuaServiceCalculateAngleToPlayer")

function LuaServiceCalculateAngleToPlayer:OnUpdateService(OwnerController, DeltaTime, ...)
  local player = OwnerController:GetBlackboardValue("LocalPlayer")
  local playerPos = player:GetActorLocation()
  local selfPos = OwnerController.Npc:GetActorLocation()
  local selfForward = OwnerController.Npc.viewObj:GetActorForwardVector()
  local dirToPlayer = playerPos - selfPos
  local angle = FVector2DUtils.AngleBetweenRelative(selfForward, dirToPlayer)
  self.OutAngle:SetValue(OwnerController, angle)
  if self.DirToPlayer then
    self.DirToPlayer:SetValue(OwnerController, dirToPlayer)
  end
end

return LuaServiceCalculateAngleToPlayer
