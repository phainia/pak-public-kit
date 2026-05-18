local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityHelper")
local AbilityErrorCode = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityErrorCode")
local OffRideAllHelper = Base:Extend("OffRideAllHelper")

function OffRideAllHelper:GetIcon(caster, isBlock)
  if nil == isBlock then
    isBlock = self:IsBlock(caster)
  end
  local moveType = self:GetCachedMoveType(caster)
  if 0 == moveType then
    return Base.GetIcon(self, caster, isBlock)
  end
  local UIconf = DataConfigManager:GetAllRideUiConf(moveType)
  if isBlock then
    local blockIcon = UIconf.off_button_block_icon
    if not string.IsNilOrEmpty(blockIcon) then
      return blockIcon
    end
  end
  return UIconf.off_button_icon
end

function OffRideAllHelper:GetPressIcon(caster)
  local moveType = self:GetCachedMoveType(caster)
  if 0 == moveType then
    return Base.GetPressIcon(self, caster)
  end
  local UIconf = DataConfigManager:GetAllRideUiConf(moveType)
  return UIconf.off_button_press_icon
end

function OffRideAllHelper:GetCachedMoveType(caster)
  if not (caster and UE.UObject.IsValid(caster.viewObj)) or not UE.UObject.IsValid(caster.viewObj.BP_RideComponent) then
    return self:ReturnFailedType()
  end
  local RideComponent = caster.viewObj.BP_RideComponent
  local curPet = RideComponent.ScenePet
  if self._lastPet ~= curPet then
    self._lastPet = curPet
    self._lastMoveType = 0
  end
  if self._lastPet == nil or not self._lastPet.config then
    return self:ReturnFailedType()
  end
  if 0 ~= RideComponent.RideMoveType then
    self._lastMoveType = RideComponent.RideMoveType
  end
  if 0 == self._lastMoveType or self._lastMoveType == nil then
    local petId = self._lastPet.config.id
    local RideConf = DataConfigManager:GetAllRidePet(petId, true)
    if nil == RideConf then
      return self:ReturnFailedType()
    end
    local SkillId = RideConf.active_skill_list[1]
    if nil == SkillId then
      return self:ReturnFailedType()
    end
    local SkillConf = DataConfigManager:GetRideBasicMovement(SkillId, true)
    if nil == SkillConf then
      return self:ReturnFailedType()
    end
    self._lastMoveType = SkillConf.active_type
    if self._lastMoveType == nil then
      return self:ReturnFailedType()
    end
  end
  return self._lastMoveType
end

function OffRideAllHelper:ReturnFailedType()
  self._lastPet = nil
  self._lastMoveType = 0
  return self._lastMoveType
end

function OffRideAllHelper:HandleStatus(caster, needReCall, ManualOff)
  if ManualOff and caster and caster.viewObj then
    local rideComp = caster.viewObj.BP_RideComponent
    if rideComp and rideComp:TryChangeToLink() then
      return
    end
  end
  Base.HandleStatus(self, caster, needReCall, ManualOff)
end

return OffRideAllHelper
