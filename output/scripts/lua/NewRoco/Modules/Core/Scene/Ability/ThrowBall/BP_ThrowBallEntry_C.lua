require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityBase")
local AbilityID = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityID")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local AbilityErrorCode = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityErrorCode")
local AbilityEvent = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityEvent")
local ABEnum = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityEnum")
local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local BP_ThrowBallEntry_C = Base:Extend("BP_ThrowBallEntry_C")

function BP_ThrowBallEntry_C:AwakeFromPool(owner)
  Base.AwakeFromPool(self, owner)
  self.caster:AddEventListener(self, PlayerModuleEvent.ON_STATUS_CHANGED, self.OnStatusChanged)
  self.UIModule = NRCModuleManager:GetModule("MainUIModule")
  if self.UIModule then
    self.UIModule:RegisterEvent(self, MainUIModuleEvent.UI_SetThrowItem, self.UpdateThrowItem)
  end
  local ability = self.caster.abilityComponent:GetAbility(AbilityID.AIM_THROW, true)
  if nil ~= ability then
    self._curAbility = ability
    self._hasAbility = true
  end
  self:OnStatusChanged()
end

function BP_ThrowBallEntry_C:Start(OnFinished, ThrowInfo, ...)
  Log.DebugFormat("BP_ThrowBallEntry_C Start")
  NRCModuleManager:DoCmd(MainUIModuleCmd.ShowFrontSight, true)
  local statusComponent = self.caster.statusComponent
  if statusComponent:HasStatus(Enum.WorldPlayerStatusType.WPST_AIMTHROWING) then
    self.caster:SendEvent(PlayerModuleEvent.ON_END_THROW, true)
  end
  if self._hasAbility then
    function self._curAbility.onFinished()
      if OnFinished then
        OnFinished()
      end
      self:Finish()
    end
    
    self:AddStatus(ThrowInfo)
  else
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, "\230\140\137\233\146\174\228\184\138\230\178\161\230\156\137\231\187\145\229\174\154\230\138\128\232\131\189")
  end
  self:EnterState(ABEnum.AbilityState.Casting)
end

function BP_ThrowBallEntry_C:Finish()
  Base.Finish(self)
end

function BP_ThrowBallEntry_C:ReturnToPool()
  self.caster:RemoveEventListener(self, PlayerModuleEvent.ON_STATUS_CHANGED, self.OnStatusChanged)
  self.UIModule = NRCModuleManager:GetModule("MainUIModule")
  if self.UIModule then
    self.UIModule:UnRegisterEvent(self, MainUIModuleEvent.UI_SetThrowItem, self.UpdateThrowItem)
  end
  if self._hasAbility then
    local abilityComponent = self.caster.abilityComponent
    abilityComponent:RecycleAbility(self._curAbility)
    self._curAbility = nil
    self._hasAbility = false
  end
  if self.scenePet then
    self.scenePet:RemoveEventListener(self, PlayerModuleEvent.ON_STATUS_CHANGED, self.OnPetStatusChanged)
    self.scenePet = nil
  end
  Base.ReturnToPool(self)
end

function BP_ThrowBallEntry_C:UnInit()
  self.caster:RemoveEventListener(self, PlayerModuleEvent.ON_STATUS_CHANGED, self.OnStatusChanged)
  self.UIModule = NRCModuleManager:GetModule("MainUIModule")
  if self.UIModule then
    self.UIModule:UnRegisterEvent(self, MainUIModuleEvent.UI_SetThrowItem, self.UpdateThrowItem)
  end
end

function BP_ThrowBallEntry_C:AddStatus(ThrowInfo)
  if self._hasAbility then
    local statusComponent = self.caster.statusComponent
    for _, v in pairs(self._curAbility.helper.config.add_status) do
      statusComponent:ApplyStatus(v, ProtoEnum.WPST_OpCode.WPST_OPCODE_ADD, 1, ThrowInfo)
    end
  end
end

function BP_ThrowBallEntry_C:RemoveStatus()
  if self._hasAbility then
    local statusComponent = self.caster.statusComponent
    for _, v in pairs(self._curAbility.helper.config.add_status) do
      statusComponent:RemoveStatus(v)
    end
  end
end

function BP_ThrowBallEntry_C:GetIcon()
  if self._hasAbility then
    return self._curAbility:GetIcon()
  end
end

function BP_ThrowBallEntry_C:UpdateThrowItem(type, itemInfo, recycleState, Session)
  if self.scenePet then
    self.scenePet:RemoveEventListener(self, PlayerModuleEvent.ON_STATUS_CHANGED, self.OnPetStatusChanged)
    self.scenePet = nil
  end
  if type == _G.MainUIModuleEnum.MainUIChooseType.PET then
    self.scenePet = self.caster:GetPetByGid(itemInfo.gid)
    if self.scenePet then
      self.scenePet:AddEventListener(self, PlayerModuleEvent.ON_STATUS_CHANGED, self.OnPetStatusChanged)
    end
  end
  self:OnPetStatusChanged()
end

function BP_ThrowBallEntry_C:OnPetStatusChanged(status)
  local isNowBlocked = self:IsBlock()
  local abilityStatusChanged = false
  if self._hasAbility and isNowBlocked ~= self._curAbility.isBlock then
    self._curAbility.isBlock = isNowBlocked
    abilityStatusChanged = true
  end
  if abilityStatusChanged then
    self.caster.abilityComponent:SendEvent(AbilityEvent.ON_ABILITY_CHANGED)
  end
end

function BP_ThrowBallEntry_C:CanCastAbility()
  if self.scenePet and self.scenePet:GetStatus() ~= ProtoEnum.WorldPlayerPetStatusType.WPPST_IN_BAG then
    return AbilityErrorCode.NO_MOVE_INPUT
  end
  if self._hasAbility then
    return self._curAbility:CanCastAbility()
  end
  return AbilityErrorCode.CAN_NOT_FIND_ABILITY
end

function BP_ThrowBallEntry_C:GetCurrentAbility()
  return self._curAbility
end

function BP_ThrowBallEntry_C:OnStatusChanged(status, value, opCode)
  local abilityStatusChanged = false
  if not self._hasAbility or self._curAbility.helper.config.id ~= AbilityID.AIM_THROW then
    local ability = self.caster.abilityComponent:GetAbility(AbilityID.AIM_THROW, true)
    if nil ~= ability then
      self._hasAbility = true
      self._curAbility = ability
      abilityStatusChanged = true
    end
  end
  if self._hasAbility then
    local isNowBlocked = self:IsBlock()
    if isNowBlocked ~= self._curAbility.isBlock then
      self._curAbility.isBlock = isNowBlocked
      abilityStatusChanged = true
    end
    local oldStat = self._curAbility.throwStat
    self._curAbility:RefreshThrowAbility()
    local buffComp = self.caster.buffComponent
    if oldStat ~= self._curAbility.throwStat and buffComp:HasBuff("ThrowBuff") then
      self.caster.statusComponent:RemoveStatus(Enum.WorldPlayerStatusType.WPST_AIMTHROWING, Enum.WPST_OpCode.WPST_OPCODE_REMOVE, 1)
    end
  end
  if abilityStatusChanged then
    self.caster.abilityComponent:SendEvent(AbilityEvent.ON_ABILITY_CHANGED)
  end
end

function BP_ThrowBallEntry_C:IsBlock()
  if self._hasAbility then
    local isOwnerBlocked = self._curAbility.helper:IsBlock(self.caster)
    if self.scenePet then
      local isPetBlocked = self.scenePet:GetStatus() ~= ProtoEnum.WorldPlayerPetStatusType.WPPST_IN_BAG
      return isOwnerBlocked or isPetBlocked
    end
    return isOwnerBlocked
  end
end

return BP_ThrowBallEntry_C
