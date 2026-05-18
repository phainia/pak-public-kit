require("UnLuaEx")
local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local AbilityErrorCode = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityErrorCode")
local AbilityEvent = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityEvent")
local AbilityID = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityID")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local Base = require("NewRoco.Modules.System.MainUI.Res.Ability.UMG_Ability_Slot_C")
local AbilityHelperManager = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityHelperManager")
local FunctionBanModuleEvent = require("NewRoco.Modules.System.FunctionBan.FunctionBanModuleEvent")
local UMG_Ability_Main_Slot_C = Base:Extend("UMG_Ability_Main_Slot_C")
local CHECK_INTERVAL = 0.5

function UMG_Ability_Main_Slot_C:OnConstruct()
  Base.OnConstruct(self)
  self._isBlock = false
  self._lastIsVisible = true
  self._unVisibleStatus = {
    ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL,
    ProtoEnum.WorldPlayerStatusType.WPST_CLIMB
  }
  self._blockStatus = {
    ProtoEnum.WorldPlayerStatusType.WPST_SLIDING,
    ProtoEnum.WorldPlayerStatusType.WPST_FALLING,
    ProtoEnum.WorldPlayerStatusType.WPST_TRANSFORM,
    ProtoEnum.WorldPlayerStatusType.WPST_MANTLE
  }
  self._curCheckInterval = CHECK_INTERVAL
  UE4.FCycleCounter.Create("UMG_Ability_Main_Slot_C:OnPlayerStatusChanged")
  self.slotIndex = 3
  self.slotSubIndex = 1
  _G.NRCEventCenter:RegisterEvent("UMG_Ability_Main_Slot_C", self, FunctionBanModuleEvent.OnUIFuncVisibilityChange, self.UIBan)
  FunctionBanManager:AddFunctionStateListener(Enum.PlayerFunctionBanType.PFBT_MOVE, self, self.OnFunctionBan)
end

function UMG_Ability_Main_Slot_C:OnDestruct()
  if self.OnRefreshHandle then
    DelayManager:CancelDelayById(self.OnRefreshHandle)
    self.OnRefreshHandle = nil
  end
  Base.OnDestruct(self)
  _G.NRCEventCenter:UnRegisterEvent(self, FunctionBanModuleEvent.OnUIFuncVisibilityChange, self.UIBan)
  FunctionBanManager:RemoveFunctionStateListener(Enum.PlayerFunctionBanType.PFBT_MOVE, self, self.OnFunctionBan)
end

function UMG_Ability_Main_Slot_C:OnActive()
  self:ShowPetSwitch(false)
  if not self._activated then
    local caster = self.localPlayer
    if caster then
      caster.abilityComponent:AddEventListener(self, AbilityEvent.ON_BUFF_LOOP_BEGIN, self.OnLoopBegin)
      caster.abilityComponent:AddEventListener(self, AbilityEvent.ON_BUFF_LOOP_END, self.OnLoopEnd)
      caster.abilityComponent:AddEventListener(self, AbilityEvent.ON_ABILITY_CHANGED, self.RefreshView)
    end
    self._activated = true
  end
  local mainAbilityHelper = AbilityHelperManager.GetHelper(AbilityID.MAIN)
  self:BindAbility(mainAbilityHelper)
  self:OnPlayerStatusChanged()
end

function UMG_Ability_Main_Slot_C:OnDeactive()
  if self._activated then
    local caster = self.localPlayer
    if caster then
      caster.abilityComponent:RemoveEventListener(self, AbilityEvent.ON_BUFF_LOOP_BEGIN, self.OnLoopBegin)
      caster.abilityComponent:RemoveEventListener(self, AbilityEvent.ON_BUFF_LOOP_END, self.OnLoopEnd)
      caster.abilityComponent:RemoveEventListener(self, AbilityEvent.ON_ABILITY_CHANGED, self.RefreshView)
    end
    self._activated = false
  end
end

function UMG_Ability_Main_Slot_C:BindAbility(abilityHelper)
  Base.BindAbility(self, abilityHelper)
  local caster = self.localPlayer
  if self._abilityHelper then
    self._hasAbility = true
    if self._abilityHelper.GetHelper then
      self._curHelper = self._abilityHelper:GetHelper(caster)
    end
    self:RefreshView()
    _G.UpdateManager:Register(self)
  else
    self:UnbindAbility(abilityHelper)
  end
end

function UMG_Ability_Main_Slot_C:OnRefreshByUserReasonChanged()
  Base.OnRefreshByUserReasonChanged(self)
  self:RefreshView()
end

function UMG_Ability_Main_Slot_C:UpdateUi(isAbilityAim)
  self.isAbilityAim = isAbilityAim
  self._isVisible = not isAbilityAim
  if self._isVisible then
    self:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Ability_Main_Slot_C:UnbindAbility(abilityHelper)
  self._abilityHelper = nil
  self._hasAbility = false
  self:RefreshView()
  _G.UpdateManager:UnRegister(self)
end

function UMG_Ability_Main_Slot_C:OnPlayerStatusChanged(status, value, opCode)
  local caster = self.localPlayer
  local statusComponent = caster.statusComponent
  UE4.FCycleCounter.Start("UMG_Ability_Main_Slot_C:OnPlayerStatusChanged")
  local newAbilityId
  if statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL) then
    self:RefreshView()
    UE4.FCycleCounter.Stop()
    return
  elseif statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_CLIMB) then
    self:RefreshView()
    UE4.FCycleCounter.Stop()
    return
  elseif statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_SWIMMING) then
    newAbilityId = AbilityID.MAIN
    if self:IsPCMode() then
      if self.FoundationPCKey then
        self.FoundationPCKey:SetRenderOpacity(1)
      end
      if self.ParentPanel then
        self.ParentPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
      self:SetRenderOpacity(1)
    end
  else
    if self:IsPCMode() then
      if self.FoundationPCKey then
        self.FoundationPCKey:SetRenderOpacity(0)
      end
      if self.ParentPanel then
        self.ParentPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
      self:SetRenderOpacity(0)
    end
    newAbilityId = AbilityID.MAIN
  end
  if not self._hasAbility or self._abilityHelper.config.id ~= newAbilityId then
    local helper = AbilityHelperManager.GetHelper(newAbilityId)
    if nil ~= helper then
      if self._abilityHelper then
        local previousAbility = caster.abilityComponent:GetAbility(self._abilityHelper.config.id)
        if previousAbility and previousAbility:IsCasting() then
          previousAbility:Interrupt()
        end
      end
      self._abilityHelper = helper
      self:BindAbility(self._abilityHelper)
    end
  end
  self:RefreshView()
  UE4.FCycleCounter.Stop()
end

function UMG_Ability_Main_Slot_C:InternalRefreshFlag()
  if not self._unVisibleStatus then
    return
  end
  local statusComponent = self.localPlayer.statusComponent
  self._isVisible = true
  for _, value in pairs(self._unVisibleStatus) do
    if statusComponent:HasStatus(value) then
      self._isVisible = false
      break
    end
  end
  self._isBlock = false
  for _, value in pairs(self._blockStatus) do
    if statusComponent:HasStatus(value) then
      self._isBlock = true
      break
    end
  end
  if self._abilityHelper and not self._isBlock and self._abilityHelper:IsBlock(self.localPlayer) then
    self._isBlock = true
  end
  local bBan = _G.NRCModuleManager:DoCmd(FunctionBanModuleCmd.GetFunctionState, Enum.PlayerFunctionBanType.PFBT_MOVE)
  if bBan then
    self._isVisible = false
  end
  if self:IsHiddenByUser() then
    self._isVisible = false
  end
  bBan = NRCModuleManager:DoCmd(FunctionBanModuleCmd.CheckUIFunctionHide, Enum.FunctionEntrance.FE_MAIN_ABILITY_SLOT)
  if bBan then
    self._isVisible = false
  end
end

function UMG_Ability_Main_Slot_C:RefreshView()
  if self.OnRefreshHandle then
    DelayManager:CancelDelayById(self.OnRefreshHandle)
    self.OnRefreshHandle = nil
  end
  self.OnRefreshHandle = DelayManager:DelayFrames(1, function()
    self.OnRefreshHandle = nil
    if not UE.UObject.IsValid(self) then
      return
    end
    self:InternalRefreshView()
  end)
end

function UMG_Ability_Main_Slot_C:OnFunctionBan()
  self:RefreshView()
end

function UMG_Ability_Main_Slot_C:UIBan(FuncId)
  if FuncId == Enum.FunctionEntrance.FE_MAIN_ABILITY_SLOT then
    self:RefreshView()
  end
end

function UMG_Ability_Main_Slot_C:InternalRefreshView()
  if not self._hasAbility then
    self._isVisible = false
    return
  end
  if self.isAbilityAim then
    self._isVisible = false
    return
  end
  self:InternalRefreshFlag()
  local IconPath = self:GetIcon()
  if nil ~= IconPath and "" ~= IconPath then
    self.BP_UIIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Image_Bg:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local pressIcon = self:GetPressIcon()
    if nil ~= pressIcon and "" ~= pressIcon then
      self.Image_Bg:SetPath(pressIcon)
    end
    self.BP_UIIcon:SetPath(IconPath)
    if IconPath ~= self.oldIconPath then
      self.oldIconPath = IconPath
    end
  else
  end
  if self._isVisible then
    self:SetVisible(true)
  else
    self:SetVisible(false)
  end
end

function UMG_Ability_Main_Slot_C:GetIcon()
  if self._abilityHelper then
    return self._abilityHelper:GetIcon(self.localPlayer, self._isBlock)
  end
  return nil
end

function UMG_Ability_Main_Slot_C:GetPressIcon()
  if self._abilityHelper then
    return self._abilityHelper:GetPressIcon(self.localPlayer)
  end
  return nil
end

function UMG_Ability_Main_Slot_C:OnSlotPressed(bind)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(self.SoundID, "UMG_Ability_Slot_C:OnSlotPressed")
  self:OnCast(true)
  if not self._isBlock and self.press then
    if self:IsPCMode() then
      self:PlayAnimation(self.press)
    else
      self:PlayAnimation(self.press)
    end
  end
end

function UMG_Ability_Main_Slot_C:OnSlotReleased(bind)
  if not self._hasAbility then
    return
  end
  self.localPlayer.abilityComponent:StopAbility(true, self._abilityHelper.config.id)
  self.localPlayer:SendEvent(PlayerModuleEvent.ON_MAIN_ABILITY_RELEASED)
end

function UMG_Ability_Main_Slot_C:OnCast(isPress)
  if not self._hasAbility or not isPress then
    return
  end
  local caster = self.localPlayer
  if not caster.inputComponent:GetInputEnable() then
    return
  end
  local errorCode = self._abilityHelper:CanCastAbility(caster)
  if errorCode == AbilityErrorCode.NO_ERROR then
    self._abilityHelper:HandleStatus(caster)
    self.localPlayer.viewObj.WalkRun = false
  end
  if errorCode == AbilityErrorCode.VITALITY_NOT_ENOUGH and MainUIModuleCmd then
    NRCModuleManager:DoCmd(MainUIModuleCmd.UI_OnDashAbilityVitalityDeficiency)
  end
  if errorCode ~= AbilityErrorCode.NO_ERROR then
    Log.Debug(AbilityErrorCode.ToString(errorCode))
  end
  return errorCode
end

function UMG_Ability_Main_Slot_C:OnLoopBegin(abilityID)
  if abilityID == self._abilityHelper.config.id then
    self.curLoopId = abilityID
    self:StartLongPressMode()
  end
end

function UMG_Ability_Main_Slot_C:OnLoopEnd(abilityID)
  if self.curLoopId == abilityID then
    self:StopLongPressMode()
    self.curLoopId = -1
  end
end

function UMG_Ability_Main_Slot_C:OnTick(InDeltaTime)
  self:RefreshAbility(InDeltaTime)
end

function UMG_Ability_Main_Slot_C:RefreshAbility(deltaTime)
  if self._hasAbility and self._abilityHelper.GetHelper and self.localPlayer then
    if not self._curCheckInterval then
      self._curCheckInterval = CHECK_INTERVAL
    end
    self._curCheckInterval = self._curCheckInterval - deltaTime
    if self._curCheckInterval < 0 then
      self._curCheckInterval = self._curCheckInterval + CHECK_INTERVAL
      local newHelper = self._abilityHelper:GetHelper(self.localPlayer)
      if newHelper and (not self._curHelper or self._curHelper.config.id ~= newHelper.config.id) then
        self._curHelper = newHelper
        self:RefreshView()
      end
    end
  end
end

function UMG_Ability_Main_Slot_C:StartLongPressMode()
  self:StopAnimation(self.inAnim)
  self:StopAnimation(self.outAnim)
  self:StopAnimation(self.loopAnim)
  self:StopAnimation(self.press)
  self:PlayAnimation(self.inAnim)
end

function UMG_Ability_Main_Slot_C:OnAnimationFinished(anim)
  if anim == self.inAnim and self.loopAnim and not self:IsAnimationPlaying(self.loopAnim) then
    self:PlayAnimation(self.loopAnim, 0.0, 9999)
  end
  Base.OnAnimationFinished(self, anim)
end

function UMG_Ability_Main_Slot_C:StopLongPressMode()
  self:StopAnimation(self.inAnim)
  self:StopAnimation(self.outAnim)
  self:StopAnimation(self.loopAnim)
  self:StopAnimation(self.press)
  self:PlayAnimation(self.outAnim)
end

function UMG_Ability_Main_Slot_C:PlayLoopAnim()
  self:StopAnimation(self.inAnim)
  self:StopAnimation(self.outAnim)
  self:StopAnimation(self.loopAnim)
  self:StopAnimation(self.press)
  self:PlayAnimation(self.loopAnim, 0.0, 9999)
end

function UMG_Ability_Main_Slot_C:OnPCKey(action_type)
  if self.Visibility == UE.ESlateVisibility.Hidden or self.Visibility == UE.ESlateVisibility.Collapsed or self.Visibility == UE.ESlateVisibility.HitTestInvisible then
    return
  end
  if not self.localPlayer then
    Log.Error("UMG_Ability_Main_Slot_C:OnPCKey Local player is nil")
    return
  end
  if 0 == action_type then
    if _G.FriendModuleCmd then
      _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.PCKeyPressCloseFriendPanelTeam)
    end
    self.Btn_Slot:OnPress()
    self:OnSlotPressed()
  else
    self.Btn_Slot:OnRelease()
    self:OnSlotReleased()
  end
end

function UMG_Ability_Main_Slot_C:IsPCMode()
  return UE.UGameplayStatics.GetGameInstance(self):IsPCMode()
end

return UMG_Ability_Main_Slot_C
