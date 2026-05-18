local Base = require("NewRoco.Modules.Core.Scene.Component.Vitality.VitalityCost.BasicMovementVitalityCostBase")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local VitalityUtil = require("NewRoco.Modules.Core.Scene.Component.Vitality.VitalityUtil")
local RideAllVitalityCost = Base:Extend("RideAllVitalityCost")

function RideAllVitalityCost:Ctor(vitalityComp)
  Base.Ctor(self, vitalityComp)
  self.vitalityComp.owner:AddEventListener(self, PlayerModuleEvent.ON_VITALITY_OVER, self.OnVitalityOver)
  self.vitalityComp.owner:AddEventListener(self, PlayerModuleEvent.ON_RIDE_SET_VIEWOBJ_END, self.OnRide)
end

function RideAllVitalityCost:Destroy()
  self.vitalityComp.owner:RemoveEventListener(self, PlayerModuleEvent.ON_VITALITY_OVER, self.OnVitalityOver)
  self.vitalityComp.owner:RemoveEventListener(self, PlayerModuleEvent.ON_RIDE_SET_VIEWOBJ_END, self.OnRide)
end

function RideAllVitalityCost:SetID(inID)
  local basicMovementId = self:MoveModeToMovementId()
  Base.SetID(self, basicMovementId)
  if self._id then
    self._curConfig = DataConfigManager:GetRideBasicMovement(self._id)
  end
end

function RideAllVitalityCost:OnRide(playerPet)
  self.playerPet = playerPet
  self._movement_config = {}
  local movementList = playerPet.rideConfig.basic_movement_list
  for i = 1, #movementList do
    local movementId = movementList[i]
    local movementConfig = DataConfigManager:GetRideBasicMovement(movementId)
    self._movement_config[movementId] = movementConfig
  end
  local movementId = self:MoveModeToMovementId()
  self:SetID(movementId)
  self:BindListener()
end

function RideAllVitalityCost:BindListener()
  local viewObj = self.playerPet.viewObj
  if UE.UObject.IsValid(viewObj) then
    viewObj.MovementModeChangedDelegate:Remove(viewObj, self.OnMovementModeUpdate)
  end
  if UE.UObject.IsValid(viewObj) then
    viewObj.MovementModeChangedDelegate:Add(viewObj, self.OnMovementModeUpdate)
  end
end

function RideAllVitalityCost:UnBindListener()
  if self.playerPet then
    local viewObj = self.playerPet.viewObj
    if UE.UObject.IsValid(viewObj) then
      viewObj.MovementModeChangedDelegate:Remove(viewObj, self.OnMovementModeUpdate)
    end
  end
end

function RideAllVitalityCost:OnMovementModeUpdate(character, preMoveMode, preCustomMode)
  local rider = character.Rider
  if rider and rider.sceneCharacter then
    rider.sceneCharacter:SendEvent(PlayerModuleEvent.ON_UPDATE_VITALITY_COST, ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL)
  end
  if self.playerPet then
    self.playerPet:SendEvent(PlayerModuleEvent.ON_RIDE_MOVE_MODE_CHANGE)
  end
end

function RideAllVitalityCost:OnVitalityOver()
  if self:IsRunning() and self.playerPet then
    local ownerPlayer = self.playerPet.owner
    local viewObj = self.playerPet.viewObj
    local isInAir = self:IsInAir()
    if not isInAir then
      ownerPlayer:SendEvent(PlayerModuleEvent.ON_OFF_RIDE_PET)
    elseif not self.bLazyMode and UE.UObject.IsValid(viewObj) then
      viewObj.CharacterMovement:SetMovementParamByName(6, "bLazyMode", "true")
      self.bLazyMode = true
    end
  end
end

function RideAllVitalityCost:IsInAir()
  local viewObj = self.playerPet.viewObj
  if not viewObj or not viewObj then
    Log.Error("RideAllVitalityCost viewObj is nil")
    return
  end
  local curMovementMode
  if viewObj.CharacterMovement.MovementMode >= 6 then
    curMovementMode = viewObj.CharacterMovement.CustomMovementMode
  else
    curMovementMode = viewObj.CharacterMovement.MovementMode
  end
  local isInAir = 3 == curMovementMode or 6 == curMovementMode
  return isInAir
end

function RideAllVitalityCost:MoveModeToMovementId()
  local viewObj = self.playerPet.viewObj
  if viewObj.CharacterMovement.MovementMode >= 6 then
    self._curMovementMode = viewObj.CharacterMovement.CustomMovementMode
  else
    self._curMovementMode = viewObj.CharacterMovement.MovementMode
  end
  for i, v in pairs(self._movement_config) do
    if self._curMovementMode == v.move_type then
      self._curConfig = v
      return v.id
    end
  end
end

function RideAllVitalityCost:Pause(bPause)
  Base.Pause(self, bPause)
  if not self:IsRunning() then
    self:UnBindListener()
    self._movement_config = nil
    self._curConfig = nil
    self._id = nil
    self.playerPet = nil
    self.bLazyMode = false
  end
end

function RideAllVitalityCost:ShouldCost()
  if not (self.playerPet and self.playerPet.owner) or not self._curConfig then
    return false
  end
  if self.playerPet.owner.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL_ABILITY) then
    return false
  end
  local isIdle = not self._curConfig.vitality_cost.idle_cost and UE.UObject.IsValid(self.playerPet.owner.ueController) and self.playerPet.owner.ueController:IsIdle() and not self:IsInAir()
  if isIdle then
    return false
  end
  if self:IsSafeAndMoveOnGround() then
    return false
  end
  return Base.ShouldCost(self)
end

function RideAllVitalityCost:IsSafeAndMoveOnGround()
  local player = self.playerPet.owner
  if not player.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_EXPOSED) then
    return self._curConfig and self._curConfig.move_type == ProtoEnum.SceneRideAllType.SRAT_GROUND
  end
  return false
end

function RideAllVitalityCost:OnUpdate(deltaTime)
  if self:ShouldCost() then
    local costSuccess = self:CostByID(VitalityUtil.VitalityCostType.Duration, deltaTime)
    if not costSuccess then
      self:OnVitalityOver()
      return
    end
  end
  if self.bLazyMode and self.playerPet then
    local viewObj = self.playerPet.viewObj
    if UE.UObject.IsValid(viewObj) then
      viewObj.CharacterMovement:SetMovementParamByName(6, "bLazyMode", "false")
      self.bLazyMode = false
    end
  end
end

return RideAllVitalityCost
