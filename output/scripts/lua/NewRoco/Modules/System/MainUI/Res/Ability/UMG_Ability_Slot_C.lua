require("UnLuaEx")
local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local AbilityErrorCode = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityErrorCode")
local AbilityEvent = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityEvent")
local AbilityID = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityID")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local UMG_Ability_Slot_C = _G.NRCViewBase:Extend("UMG_Ability_Slot_C")
local SlotStatus = {
  SLOT_STATUS_NORMAL = 0,
  SLOT_STATUS_PRESSD = 1,
  SLOT_STATUS_OPENED = 2,
  SLOT_STATUS_BLOCK = 3,
  SLOT_STATUS_HIDE = 4
}

function UMG_Ability_Slot_C:OnConstruct()
  Log.Debug("UMG_Ability_Slot_C:OnConstruct")
  self.Btn_Slot.OnPressed:Add(self, self.OnSlotPressed)
  self.Btn_Slot.OnReleased:Add(self, self.OnSlotReleased)
  self.Btn_Slot.OnClicked:Add(self, self.OnSlotClicked)
  self.Btn_Slot.OnNxLongPressed:Add(self, self.OnSlotLongPressed)
  self._isVisible = true
  self:ReBindPlayer()
  self.CurSlotStatus = SlotStatus.SLOT_STATUS_NORMAL
  self._activated = false
  self:RegisterEvent(self, MainUIModuleEvent.SlotVisibilityChange, self.SlotVisibilityChangeFunc)
end

function UMG_Ability_Slot_C:OnDestruct()
  if self.localPlayer then
    self.localPlayer:RemoveEventListener(self, PlayerModuleEvent.ON_STATUS_CHANGED, self.OnPlayerStatusChanged)
    self.localPlayer:RemoveEventListener(self, PlayerModuleEvent.ON_ENV_MASK_CHANGED, self.OnEnvMask)
    self.localPlayer = nil
  end
end

function UMG_Ability_Slot_C:IsHiddenByUser()
  return self.HiddenByUserReasons and next(self.HiddenByUserReasons)
end

function UMG_Ability_Slot_C:AddVisibilityByUser(bVisible, Reason)
  assert(Reason)
  local bOldHidden = self:IsHiddenByUser()
  if not bVisible then
    if not self.HiddenByUserReasons then
      self.HiddenByUserReasons = {}
    end
    self.HiddenByUserReasons[Reason] = true
  else
    self.HiddenByUserReasons[Reason] = nil
  end
  local bNewHidden = self:IsHiddenByUser()
  if bOldHidden ~= bNewHidden then
    self:OnRefreshByUserReasonChanged()
  end
end

function UMG_Ability_Slot_C:OnRefreshByUserReasonChanged()
  if self:IsHiddenByUser() then
    self:PlayAnimationForward(self.out, math.maxinteger)
  end
end

function UMG_Ability_Slot_C:SlotVisibilityChangeFunc(visible, slotIndex, slotSubIndex)
  if visible and slotIndex == self.slotIndex and slotSubIndex ~= self.slotSubIndex then
    if self.out ~= nil and self:IsAnimationPlaying(self.out) then
      self:StopAnimation(self.out)
    end
    if nil ~= self.show and self:IsAnimationPlaying(self.show) then
      self:StopAnimation(self.show)
    end
    if nil ~= self.press and self:IsAnimationPlaying(self.press) then
      self:StopAnimation(self.press)
    end
    if 2 == self.slotIndex and 1 == self.slotSubIndex then
      if UE4Helper.IsPCMode() then
        if self.FoundationPCKey then
          self.FoundationPCKey:SetKeyVisibility(false)
        end
        if self.ParentPanel then
          self.ParentPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
        end
      end
      self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      if UE4Helper.IsPCMode() then
        if self.FoundationPCKey then
          self.FoundationPCKey:SetKeyVisibility(false)
        end
        if self.ParentPanel then
          self.ParentPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
        end
      end
      self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_Ability_Slot_C:BindAbility(abilityHelper)
  self._abilityHelper = abilityHelper
end

function UMG_Ability_Slot_C:UnbindAbility(abilityHelper)
  self._abilityHelper = nil
end

function UMG_Ability_Slot_C:ReBindPlayer()
  if self.localPlayer then
    self.localPlayer:RemoveEventListener(self, PlayerModuleEvent.ON_STATUS_CHANGED, self.OnPlayerStatusChanged)
    self.localPlayer:RemoveEventListener(self, PlayerModuleEvent.ON_ENV_MASK_CHANGED, self.OnEnvMask)
  end
  self.localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if self.localPlayer then
    self.localPlayer:AddEventListener(self, PlayerModuleEvent.ON_STATUS_CHANGED, self.OnPlayerStatusChanged)
    self.localPlayer:AddEventListener(self, PlayerModuleEvent.ON_ENV_MASK_CHANGED, self.OnEnvMask)
  end
end

function UMG_Ability_Slot_C:RefreshView()
end

function UMG_Ability_Slot_C:OnPlayerStatusChanged(status, value, opCode)
  if not self._abilityHelper then
    return
  end
  local isNowBlocked
  if self.IsBlock then
    isNowBlocked = self:IsBlock()
  else
    isNowBlocked = self._abilityHelper:IsBlock(self.localPlayer)
  end
  if isNowBlocked ~= self.isBlock then
    self.isBlock = isNowBlocked
    self:RefreshView()
  end
end

function UMG_Ability_Slot_C:OnEnvMask()
  if not self._abilityHelper then
    return
  end
  local isNowBlocked
  if self.IsBlock then
    isNowBlocked = self:IsBlock()
  else
    isNowBlocked = self._abilityHelper:IsBlock(self.localPlayer)
  end
  if isNowBlocked ~= self.isBlock then
    self.isBlock = isNowBlocked
    self:RefreshView()
  end
end

function UMG_Ability_Slot_C:OnCast(isPress)
  if not self._abilityHelper or not self.localPlayer then
    return
  end
  local castType = isPress and Enum.SceneAbilitySlotCastType.SASCT_PRESS or Enum.SceneAbilitySlotCastType.SASCT_CLICK
  if self._abilityHelper.config.scene_ability_slot_cast_type ~= castType then
    return
  end
  local caster = self.localPlayer
  local errorCode = self._abilityHelper:CanCastAbility(caster)
  if errorCode == AbilityErrorCode.VITALITY_NOT_ENOUGH and MainUIModuleCmd then
    NRCModuleManager:DoCmd(MainUIModuleCmd.UI_OnDashAbilityVitalityDeficiency)
  end
  if errorCode ~= AbilityErrorCode.NO_ERROR then
    Log.Debug(AbilityErrorCode.ToString(errorCode))
  end
  return errorCode
end

function UMG_Ability_Slot_C:OnStopCast()
  if not self._abilityHelper or not self.localPlayer then
    return
  end
  local caster = self.localPlayer
  caster.abilityComponent:StopAbility(false, self._abilityHelper.config.id)
end

function UMG_Ability_Slot_C:OnSlotPressed(bind)
  if self.CurSlotStatus == SlotStatus.SLOT_STATUS_BLOCK or self.CurSlotStatus == SlotStatus.SLOT_STATUS_HIDE then
    return
  end
  self.isInAimingState = false
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(self.SoundID, "UMG_Ability_Slot_C:OnSlotPressed")
  local errorCode = self:OnCast(true)
  if (errorCode == AbilityErrorCode.NOT_CASTTYPE or errorCode == AbilityErrorCode.NO_ERROR) and self.press then
    self:PlayAnimation(self.press)
  end
  self.CurSlotStatus = SlotStatus.SLOT_STATUS_PRESSD
end

function UMG_Ability_Slot_C:OnSlotReleased(bind)
  if not self._abilityHelper then
    return
  end
  if self._abilityHelper.config.scene_ability_slot_cast_type == Enum.SceneAbilitySlotCastType.SASCT_PRESS then
    self.localPlayer.abilityComponent:StopAbility(false, self._abilityHelper.config.id)
  end
  self.CurSlotStatus = SlotStatus.SLOT_STATUS_NORMAL
end

function UMG_Ability_Slot_C:OnSlotClicked(bind)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(self.SoundID, "UMG_Ability_Slot_C:OnSlotPressed")
  local errorCode = self:OnCast(false)
  return errorCode
end

function UMG_Ability_Slot_C:SetSlotOpened(isOpen)
  if isOpen then
    self.CurSlotStatus = SlotStatus.SLOT_STATUS_OPENED
  else
    self.CurSlotStatus = SlotStatus.SLOT_STATUS_NORMAL
  end
end

function UMG_Ability_Slot_C:SetSlotBlock(isOpen)
  if isOpen then
    self.CurSlotStatus = SlotStatus.SLOT_STATUS_BLOCK
  else
    self.CurSlotStatus = SlotStatus.SLOT_STATUS_NORMAL
  end
end

function UMG_Ability_Slot_C:OnSlotLongPressed()
end

function UMG_Ability_Slot_C:ShowPetSwitch(visible)
  if visible then
    self.Petswitch:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.Petswitch:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Ability_Slot_C:SetPetSwitchShow(itemType, itemInfo, recycleState, session)
  self.Petswitch:SetIcon(itemType, itemInfo)
  self.ThrowItemType = itemType
  self.ThrowItemInfo = itemInfo
  self.RecycleSession = session
end

function UMG_Ability_Slot_C:SetVisible(visible, focusChanges)
  if not _G.NRCModuleManager:GetModule("MainUIModule") then
    return
  end
  if UE4Helper.IsPCMode() then
    if visible then
      _G.NRCModuleManager:GetModule("MainUIModule"):DispatchEvent(MainUIModuleEvent.SlotVisibilityChange, true, self.slotIndex, self.slotSubIndex)
      if self.FoundationPCKey then
        self.FoundationPCKey:SetKeyVisibility(true)
      end
      if self.ParentPanel and 0 ~= self.RenderOpacity then
        self.ParentPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
      self:SetVisibility(UE4.ESlateVisibility.Visible)
      self.CurSlotStatus = SlotStatus.SLOT_STATUS_NORMAL
    else
      if self.press and self:IsAnimationPlaying(self.press) then
        self:StopAnimation(self.press)
      end
      _G.NRCModuleManager:GetModule("MainUIModule"):DispatchEvent(MainUIModuleEvent.SlotVisibilityChange, false, self.slotIndex, self.slotSubIndex)
      if self.FoundationPCKey then
        self.FoundationPCKey:SetKeyVisibility(false)
      end
      if self.ParentPanel then
        self.ParentPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
      self:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.CurSlotStatus = SlotStatus.SLOT_STATUS_HIDE
    end
  elseif visible then
    if self.out ~= nil and self:IsAnimationPlaying(self.out) then
      self:StopAnimation(self.out)
    end
    _G.NRCModuleManager:GetModule("MainUIModule"):DispatchEvent(MainUIModuleEvent.SlotVisibilityChange, true, self.slotIndex, self.slotSubIndex)
    if focusChanges then
      self:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      if self.Visibility ~= UE4.ESlateVisibility.Visible and nil ~= self.show then
        self:SetVisibility(UE4.ESlateVisibility.Visible)
        self:PlayAnimation(self.show)
      end
      self.CurSlotStatus = SlotStatus.SLOT_STATUS_NORMAL
    end
  elseif self.Visibility == UE4.ESlateVisibility.Visible or self.Visibility == UE4.ESlateVisibility.HitTestInvisible or self.Visibility == UE4.ESlateVisibility.SelfHitTestInvisible then
    _G.NRCModuleManager:GetModule("MainUIModule"):DispatchEvent(MainUIModuleEvent.SlotVisibilityChange, false, self.slotIndex, self.slotSubIndex)
    if self.press and self:IsAnimationPlaying(self.press) then
      self:StopAnimation(self.press)
    end
    if self.out and not focusChanges then
      if not self:IsAnimationPlaying(self.out) then
        local Speed = 1
        if self.bInBanCondition then
          Speed = 999
        end
        self:PlayAnimation(self.out, 0, 1, UE.EUMGSequencePlayMode.Forward, Speed, false)
      end
    else
      self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self.CurSlotStatus = SlotStatus.SLOT_STATUS_HIDE
  end
end

function UMG_Ability_Slot_C:OnAnimationFinished(anim)
  if self._isVisible == false and self.out and anim == self.out then
    if UE4Helper.IsPCMode() then
      if self.FoundationPCKey then
        self.FoundationPCKey:SetKeyVisibility(false)
      end
      if self.ParentPanel then
        self.ParentPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

return UMG_Ability_Slot_C
