require("UnLuaEx")
local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local AbilityErrorCode = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityErrorCode")
local AbilityEvent = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityEvent")
local AbilityID = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityID")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local StatusUtils = require("NewRoco.Modules.Core.Scene.Component.Status.StatusUtils")
local Base = require("NewRoco.Modules.System.MainUI.Res.Ability.UMG_Ability_Slot_C")
local AbilityHelperManager = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityHelperManager")
local UMG_Ability_Slot_Perception_C = Base:Extend("UMG_Ability_Slot_Perception_C")

function UMG_Ability_Slot_Perception_C:OnInit()
  self:ReBindPlayer()
  self.isShortCut = false
  self._curTime = 0
  self._shouldTick = false
  self.Btn_Slot.LongPressTriggerTime = 0.81
  self.slotIndex = 4
  self.slotSubIndex = 3
  if not self._activated then
    local caster = self.localPlayer
    if caster then
      caster.abilityComponent:AddEventListener(self, AbilityEvent.ON_PERCEPTION_BEGIN, self.StartLoopAnim)
      caster.abilityComponent:AddEventListener(self, AbilityEvent.ON_PERCEPTION_END, self.StopLoopAnim)
    end
    self._activated = true
  end
  _G.NRCEventCenter:RegisterEvent("UMG_Ability_Slot_C", self, NRCGlobalEvent.OnApplicationHasEnteredForeground, self.EnterForeground)
  FunctionBanManager:AddFunctionStateListener(Enum.PlayerFunctionBanType.PFBT_PET_GANZHI, self, self.RefreshUI)
end

function UMG_Ability_Slot_Perception_C:OnUnInit()
  if self._abilityHelper then
    self._abilityHelper = nil
    self._focusStatus = {}
  end
  if self._activated then
    local caster = self.localPlayer
    if caster then
      caster.abilityComponent:RemoveEventListener(self, AbilityEvent.ON_PERCEPTION_BEGIN, self.StartLoopAnim)
      caster.abilityComponent:RemoveEventListener(self, AbilityEvent.ON_PERCEPTION_END, self.StopLoopAnim)
    end
    self._activated = false
  end
  _G.NRCEventCenter:UnRegisterEvent(self, NRCGlobalEvent.OnApplicationHasEnteredForeground, self.EnterForeground)
  FunctionBanManager:RemoveFunctionStateListener(Enum.PlayerFunctionBanType.PFBT_PET_GANZHI, self, self.RefreshUI)
  self.localPlayer = nil
  self._isAbilityBlock = false
  self._isBlock = false
  self._curTime = 0
  self._shouldTick = false
end

function UMG_Ability_Slot_Perception_C:EnterForeground()
  if self.IsPress then
    self.Btn_Slot:OnRelease()
    self:OnSlotReleased()
  end
end

function UMG_Ability_Slot_Perception_C:BindAbility()
  local abilityID = AbilityID.PERCEPTION
  if abilityID then
    if self._abilityHelper then
      if self._abilityHelper.config.id == abilityID then
        return
      end
      self:UnBindAbility()
    end
    local helper = AbilityHelperManager.GetHelper(abilityID)
    if helper then
      self._abilityHelper = helper
      self._focusStatus = {
        status = helper.config.add_status[1],
        subStatus = helper.config.add_sub_status
      }
    end
    self.vitalityComponent = self.localPlayer.vitalityComponent
    self:RefreshUI()
  end
end

function UMG_Ability_Slot_Perception_C:UnBindAbility()
  if self._abilityHelper then
    self._abilityHelper = nil
    self._focusStatus = {}
  end
  self._isVisible = false
  self.vitalityComponent = nil
  self:RefreshUI()
end

function UMG_Ability_Slot_Perception_C:AddPet(pet)
  if self._pet == pet then
    return
  end
  self._pet = pet
  self._isVisible = nil ~= pet
  self:RefreshUI()
  local buff = self:GetBuff()
  if buff then
    self._shouldTick = false
  end
end

function UMG_Ability_Slot_Perception_C:RemovePet()
  self._pet = nil
  self._isVisible = false
  self:RefreshUI()
end

function UMG_Ability_Slot_Perception_C:NotifyPetStatus(pet, petStatus)
  if pet == self._pet then
    local isBlock = petStatus ~= ProtoEnum.WorldPlayerPetStatusType.WPPST_IN_BAG and petStatus ~= ProtoEnum.WorldPlayerPetStatusType.WPPST_IN_SCENE
    if self._isBlock ~= isBlock then
      self._isBlock = isBlock
      self:RefreshUI()
    end
  end
end

function UMG_Ability_Slot_Perception_C:OnSlotPressed(bind)
  if not self._isVisible then
    return
  end
  local isSelectLimit = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.IsSpecialSelectLimit, "SelectLimit1")
  if isSelectLimit then
    return
  end
  local reason = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetSpecialSelectLimitReason, "SelectLimit1")
  if reason then
    _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.SetSpecialSelectLimit, "SelectLimit1", reason.GANZHI, true)
  end
  local buff = self:GetBuff()
  if buff and buff._stat ~= buff.StatEnum.Finishing and buff._stat ~= buff.StatEnum.WaittingSkill and buff._pet == self._pet then
    buff:OnCmdFinish()
  else
    local succeed = self:OnCast()
    if succeed and self.press then
      self:PlayAnimation(self.press)
    end
  end
  self.IsPress = true
  self._shouldTick = true
end

function UMG_Ability_Slot_Perception_C:OnSlotClicked(bind)
end

function UMG_Ability_Slot_Perception_C:OnSlotReleased(bind)
  self.IsPress = false
  self._shouldTick = false
  local reason = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetSpecialSelectLimitReason, "SelectLimit1")
  if reason then
    _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.SetSpecialSelectLimit, "SelectLimit1", reason.GANZHI, false)
  end
end

function UMG_Ability_Slot_Perception_C:OnSlotLongPressed()
end

function UMG_Ability_Slot_Perception_C:OnTick(deltaTime)
  if self.vitalityComponent then
    self.Progress_State:SetPercent(self.vitalityComponent:GetVitalityPercent())
  end
  if not self._shouldTick then
    return
  end
end

function UMG_Ability_Slot_Perception_C:OnCast(isPress)
  if not self._abilityHelper then
    return false
  end
  local buff = self:GetBuff()
  if buff and not self.localPlayer.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_GANZHI) then
    self._abilityHelper:HandleStatus(self.localPlayer, self._pet)
    buff = self:GetBuff()
  end
  if buff then
    if buff and buff._stat ~= buff.StatEnum.WaittingSkill then
      buff:OnCmdOverride(self._pet)
      self._curTime = 0
    end
    return false
  end
  if self:IsBlock() then
    if self._abilityHelper:IsEnvBlock() then
      NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_ability_slot_perception_1)
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(1009, "UMG_Ability_Slot_C:OnSlotPressed")
    end
    return false
  end
  local errorCode = self._abilityHelper:CanCastAbility(self.localPlayer)
  if errorCode == AbilityErrorCode.NO_ERROR then
    local abilityComponent = self.localPlayer.abilityComponent
    errorCode = abilityComponent:CanCastAbility(self._abilityHelper)
    if errorCode == AbilityErrorCode.NO_ERROR and self.localPlayer.inputComponent:GetInputEnable() then
      if self._abilityHelper.config.cooldown_type ~= ProtoEnum.SceneAbilityCooldownType.SCDT_FROMEND then
        self.lastCastTime = UE4.UGameplayStatics.GetAccurateRealTime(self)
      end
      self._abilityHelper:HandleStatus(self.localPlayer, self._pet)
      self._curTime = 0
      local newbuff = self:GetBuff()
      if newbuff then
        newbuff:OnCmdInitPetInfo(self._pet)
      else
        return false
      end
      self:RefreshUI()
    end
  end
  if errorCode ~= AbilityErrorCode.NO_ERROR or not self.localPlayer.inputComponent:GetInputEnable() then
    return false
  end
  return true
end

function UMG_Ability_Slot_Perception_C:RefreshUI()
  if not self._abilityHelper or self._pet == nil then
    self:SetVisible(false)
    return
  end
  local bBan = _G.NRCModuleManager:DoCmd(FunctionBanModuleCmd.GetFunctionState, Enum.PlayerFunctionBanType.PFBT_PET_GANZHI)
  if bBan then
    self._isVisible = false
    self:SetVisible(false)
    return
  else
    self._isVisible = self._pet ~= nil
  end
  local isInTransform = self.localPlayer.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_TRANSFORM)
  if self._isVisible ~= not isInTransform then
    self._isVisible = not isInTransform
    self:SetVisible(self._isVisible)
    return
  end
  if self._isVisible then
    local petBaseInfo = self._pet.config
    if petBaseInfo then
      local modelConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.PET_SCENE_ABILITY_GANZHI):GetData(petBaseInfo.id)
      if modelConf then
        self.Petswitch.BallIcon:SetPath(modelConf.ability_icon)
        self.Petswitch.PetIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
        self.Petswitch.UMG_ColorfulHeadIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
        self.Petswitch.BallIcon:SetVisibility(UE4.ESlateVisibility.Visible)
      else
        self._isVisible = false
      end
    end
    local isBlock = true
    local buff = self:GetBuff()
    if buff then
      isBlock = false
      if self._pet == buff._pet then
        self:StartLoopAnim()
      else
        self:StopLoopAnim()
      end
    else
      isBlock = self._abilityHelper:IsBlock(self.localPlayer)
      self:StopLoopAnim()
    end
    local IconPath = self._abilityHelper:GetIcon(self.localPlayer, isBlock)
    if nil ~= IconPath and "" ~= IconPath then
      self.BP_UIIcon:SetPath(IconPath)
      local pressIcon = self._abilityHelper:GetPressIcon(self.localPlayer)
      if nil ~= pressIcon and "" ~= pressIcon then
        self.Image_Bg:SetPath(pressIcon)
      end
    end
    self._isAbilityBlock = isBlock
  end
  self:SetVisible(self._isVisible)
end

function UMG_Ability_Slot_Perception_C:RefreshView()
  self:RefreshUI()
end

function UMG_Ability_Slot_Perception_C:IsBlock()
  if self._abilityHelper then
    local abilityIsBlock = self._abilityHelper:IsBlock(self.localPlayer)
    if self._isAbilityBlock ~= abilityIsBlock then
      self._isAbilityBlock = abilityIsBlock
    end
  end
  return self._isBlock or self._isAbilityBlock
end

function UMG_Ability_Slot_Perception_C:GetVisible()
  return self._isVisible
end

function UMG_Ability_Slot_Perception_C:GetFocusStatus()
  return self._focusStatus
end

function UMG_Ability_Slot_Perception_C:GetBuff()
  return self.localPlayer.buffComponent:GetBuff("PerceptionBuff")
end

function UMG_Ability_Slot_Perception_C:StartLoopAnim()
  if self.inAnim and not self:IsAnimationPlaying(self.inAnim) and self.loopAnim and not self:IsAnimationPlaying(self.loopAnim) then
    self:PlayAnimation(self.inAnim)
    self:PlayAnimation(self.Show_change)
  end
end

function UMG_Ability_Slot_Perception_C:StopLongPressMode()
  self:StopAnimation(self.inAnim)
  self:StopAnimation(self.outAnim)
  self:StopAnimation(self.loopAnim)
  self:stopAnimation(self.press)
  self:PlayAnimation(self.outAnim)
end

function UMG_Ability_Slot_Perception_C:StopLoopAnim()
  if self.loopAnim and self:IsAnimationPlaying(self.loopAnim) then
    self:StopLongPressMode()
  end
end

function UMG_Ability_Slot_Perception_C:OnAnimationFinished(anim)
  if anim == self.inAnim and self.loopAnim and not self:IsAnimationPlaying(self.loopAnim) then
    self:PlayAnimation(self.loopAnim, 0.0, 9999)
  end
  Base.OnAnimationFinished(self, anim)
end

function UMG_Ability_Slot_Perception_C:OnPlayerStatusChanged(...)
  if not self._abilityHelper then
    return
  end
  local isNowBlocked = self._abilityHelper:IsBlock(self.localPlayer)
  if isNowBlocked ~= self._isAbilityBlock then
    self._isAbilityBlock = isNowBlocked
    self:RefreshView()
  end
  if not self:GetBuff() and self:IsAnyAnimationPlaying() and not self:IsAnimationPlaying(self.show) then
    self:StopAllAnimations()
    self:PlayAnimation(self.outAnim)
  end
end

function UMG_Ability_Slot_Perception_C:SetVisible(visible)
  if not visible then
    self.Btn_Slot:OnRelease()
    self:OnSlotReleased()
  end
  Base.SetVisible(self, visible)
end

function UMG_Ability_Slot_Perception_C:OnPCKey(action_type)
  if self.Visibility == UE.ESlateVisibility.Hidden or self.Visibility == UE.ESlateVisibility.Collapsed or self.Visibility == UE.ESlateVisibility.HitTestInvisible then
    return
  end
  if 0 == action_type then
    _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.PCKeyPressCloseFriendPanelTeam)
    self.Btn_Slot:OnPress()
    self:OnSlotPressed()
  else
    self.Btn_Slot:OnRelease()
    self:OnSlotReleased()
  end
end

function UMG_Ability_Slot_Perception_C:IsPCMode()
  return UE.UGameplayStatics.GetGameInstance(self):IsPCMode()
end

return UMG_Ability_Slot_Perception_C
