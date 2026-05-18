local Base = require("NewRoco.AI.BehaviorTree.LuaServiceBase")
local FVector2DUtils = require("NewRoco.Utils.FVector2DUtils")
local LuaServiceCalcObjectToSelfAngle = Base:Extend("LuaServiceCalcObjectToSelfAngle")

function LuaServiceCalcObjectToSelfAngle:OnUpdateService(OwnerController, DeltaTime, ...)
  local owner = OwnerController
  local obj = self.Object:GetValue(owner)
  if obj and obj.viewObj then
    local playerPos = obj:GetActorLocation()
    local selfPos = owner.Npc:GetActorLocation()
    local playerForward = obj.viewObj:GetActorForwardVector()
    local dirPlayerToSelf = selfPos - playerPos
    local angle = FVector2DUtils.AngleBetweenRelative(playerForward, dirPlayerToSelf)
    if self.DirSensitive and self.DirSensitive:GetValue(owner) then
    else
      angle = math.abs(angle)
    end
    self.OutAngle:SetValue(owner, angle)
  end
end

return LuaServiceCalcObjectToSelfAngle
