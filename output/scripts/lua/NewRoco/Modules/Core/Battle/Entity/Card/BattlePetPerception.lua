local LineTraceUtils = require("NewRoco.Modules.Core.Battle.Common.LineTraceUtils")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattlePetPerception = NRCClass()

function BattlePetPerception:Ctor(owner)
  self.owner = owner
  self.isShowDebugLine = false
  self.posZ = 0
  self.canSwimOnTheWaterSurface = false
end

function BattlePetPerception:PinOnTheGround()
  if not self.owner.model then
    Log.Error("BattlePetPerception:PinOnTheGround ", self.owner.card:GetHp(), self.owner.card:IsBeCatch())
    return
  end
  self:SetIKEnable(true)
  local pos = self:GetPetPos()
  local posNew = UE4.UNRCStatics.PinActorOnGround(nil, self.owner.model, pos, self.owner.model)
  self.owner.model:K2_SetActorLocation(posNew, false, nil, false)
end

function BattlePetPerception:SetIKEnable(value)
  if self.owner.card:CheckIsMimic() then
    return
  end
  if not self.owner.model or not UE.UObject.IsValid(self.owner.model) then
    Log.Error("BattlePetPerception SetIKEnable no model!")
    return
  end
  if not self.owner.model.SetIKEnable then
    Log.Error("BattlePetPerception SetIKEnable no SetIKEnable function!")
    return
  end
  if BattleUtils.IsDeepWater() then
    self.owner.model:SetIKEnable(false)
  else
    self.owner.model:SetIKEnable(value)
  end
  return 0
end

function BattlePetPerception:GetPetPos()
  Log.Debug("self.owner.model:K2_GetActorLocation():", self.owner.model:K2_GetActorLocation(), self.owner.model:Abs_K2_GetActorLocation())
  return self.owner.model:K2_GetActorLocation()
end

function BattlePetPerception:EnableGravity()
end

function BattlePetPerception:OnTick()
end

return BattlePetPerception
