local Base = NRCClass
local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local AbilityID = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityID")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local AbilityHelperManager = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityHelperManager")
local FunctionBanModuleEvent = require("NewRoco.Modules.System.FunctionBan.FunctionBanModuleEvent")
local RelationTreeRidePetItem = Base:Extend("RelationTreeRidePetItem")
RelationTreeRidePetItem.IconType = {
  None = 0,
  Land = 1,
  Swim = 2,
  Air = 3
}

function RelationTreeRidePetItem:Ctor(pet, onIconChangedCallback)
  self.rider = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not self.rider or not pet then
    Log.Error("RelationTreeRidePetItem rider or pet is nil")
    return
  end
  self.pet = pet
  self.onIconChangedCallback = onIconChangedCallback
  local allRideConf = DataConfigManager:GetAllRidePet(pet.config.id, true)
  if not allRideConf or allRideConf.not_use_for_ride then
    Log.DebugFormat("pet id = %d no ride ability", pet.config.id)
    self._icon = RelationTreeRidePetItem.IconType.None
    self._isBlock = false
    return
  end
  self._abilityHelper = AbilityHelperManager.GetHelper(AbilityID.RIDE_ALL)
  _G.UpdateManager:Register(self)
  pet:AddEventListener(self, PlayerModuleEvent.ON_STATUS_CHANGED, self.OnNotifyPetStatus)
  self:UIBan(Enum.FunctionEntrance.FE_RIDE)
  _G.NRCEventCenter:RegisterEvent("RelationTreeRidePetItem", self, FunctionBanModuleEvent.OnUIFuncVisibilityChange, self.UIBan)
  self.rider:AddEventListener(self, PlayerModuleEvent.ON_WATER_STATUS_CHANGE, self.Refresh)
  self.rider:AddEventListener(self, PlayerModuleEvent.ON_STATUS_CHANGED, self.Refresh)
  local mainUIModule = NRCModuleManager:GetModule("MainUIModule")
  if mainUIModule then
    if UE4Helper.IsPCMode() then
      mainUIModule:RegisterEvent(self, MainUIModuleEvent.ChangePCCancelChargeBtnVisibility, self.RideSkillAim)
    else
      mainUIModule:RegisterEvent(self, MainUIModuleEvent.UI_SHOW_ABILITY_AIM_JOYSTICK, self.RideSkillAim)
    end
  end
  self._rideSkillAim = false
  self:Refresh()
end

function RelationTreeRidePetItem:Dctor()
  _G.UpdateManager:UnRegister(self)
  _G.NRCEventCenter:UnRegisterEvent(self, FunctionBanModuleEvent.OnUIFuncVisibilityChange, self.UIBan)
  if self.rider then
    self.rider:RemoveEventListener(self, PlayerModuleEvent.ON_WATER_STATUS_CHANGE, self.Refresh)
    self.rider:RemoveEventListener(self, PlayerModuleEvent.ON_STATUS_CHANGED, self.Refresh)
  end
  local mainUIModule = NRCModuleManager:GetModule("MainUIModule")
  if mainUIModule then
    if UE4Helper.IsPCMode() then
      mainUIModule:UnRegisterEvent(self, MainUIModuleEvent.ChangePCCancelChargeBtnVisibility, self.RideSkillAim)
    else
      mainUIModule:UnRegisterEvent(self, MainUIModuleEvent.UI_SHOW_ABILITY_AIM_JOYSTICK, self.RideSkillAim)
    end
  end
end

function RelationTreeRidePetItem:OnNotifyPetStatus(pet, petStatus)
  if self.pet == pet then
    local isPetInteracting = petStatus == ProtoEnum.WorldPlayerPetStatusType.WPPST_IN_INTERACT
    local isRiding = petStatus == ProtoEnum.WorldPlayerPetStatusType.WPPST_IN_RIDE
    self._isPetBlock = isPetInteracting or isRiding
  end
end

function RelationTreeRidePetItem:UIBan(funcId)
  if funcId == Enum.FunctionEntrance.FE_RIDE then
    self._bInBanCondition = _G.NRCModuleManager:DoCmd(FunctionBanModuleCmd.CheckUIFunctionHide, Enum.FunctionEntrance.FE_RIDE)
  end
end

function RelationTreeRidePetItem:RideSkillAim(inAim)
  self._rideSkillAim = inAim
end

function RelationTreeRidePetItem:GetIconInfo()
  return self._icon, self._isBlock
end

function RelationTreeRidePetItem:OnTick(deltaTime)
  self._tickTime = self._tickTime + deltaTime
  if self._tickTime > 0.5 then
    self._tickTime = 0
    self:Refresh()
  end
end

function RelationTreeRidePetItem:Refresh()
  if not (self._abilityHelper and self.rider) or not self.pet then
    return
  end
  self._tickTime = 0
  local nowBlock = self._isPetBlock or self._rideSkillAim or self._bInBanCondition
  for i = 1, 1 do
    if nowBlock then
    else
      local abilityIsBlock = self._abilityHelper:IsBlock(self.rider, self.pet)
      if abilityIsBlock then
        nowBlock = true
      else
        local onPetBtnBlock = self.rider.petAbilitySlotManager:GetOnPetBtnBlock(self.pet)
        if onPetBtnBlock then
          nowBlock = true
        else
          local togetherBlock = false
          if self.rider:IsInTogetherMove() then
            togetherBlock = true
            local rideComponent = self.rider.viewObj.BP_RideComponent
            if rideComponent and not rideComponent.bIsDoubleRide2p and rideComponent:IsDoubleRidePet(self.pet, false) then
              togetherBlock = false
            end
          end
          nowBlock = togetherBlock
        end
      end
    end
  end
  local newIconType = self._abilityHelper:GetRideMoveType(self.rider, self.pet)
  local nowIcon = RelationTreeRidePetItem.IconType.None
  if newIconType == ProtoEnum.SceneRideAllType.SRAT_GROUND then
    nowIcon = RelationTreeRidePetItem.IconType.Land
  elseif newIconType == ProtoEnum.SceneRideAllType.SRAT_FLY then
    nowIcon = RelationTreeRidePetItem.IconType.Air
  elseif newIconType == ProtoEnum.SceneRideAllType.SRAT_SWIM then
    nowIcon = RelationTreeRidePetItem.IconType.Swim
  end
  if nowIcon ~= self._icon or nowBlock ~= self._isBlock then
    self._icon = nowIcon
    self._isBlock = nowBlock
    if self.onIconChangedCallback then
      self.onIconChangedCallback(self._icon, self._isBlock)
    end
  end
end

return RelationTreeRidePetItem
