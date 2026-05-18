local Base = require("NewRoco.AI.BehaviorTree.LuaServiceBase")
local LuaServiceUpdateDistance = Base:Extend("LuaServiceUpdateDistance")

function LuaServiceUpdateDistance:OnUpdateService(OwnerController, ...)
  local args = {
    ...
  }
  local owner = OwnerController
  local targetVec
  if self.Target.type == LuaParamType.Object then
    local targetObj = self.Target:GetValue(owner)
    targetVec = targetObj:GetActorLocation()
  elseif self.Target.type == LuaParamType.Vector then
    targetVec = self.Target:GetValue(owner)
  end
  local selfPos = owner.Npc:GetActorLocation()
  if nil ~= targetVec then
    local dist = UE4.UKismetMathLibrary.Vector_Distance(targetVec, selfPos)
    self.OutDist:SetValue(owner, dist)
  end
end

return LuaServiceUpdateDistance
