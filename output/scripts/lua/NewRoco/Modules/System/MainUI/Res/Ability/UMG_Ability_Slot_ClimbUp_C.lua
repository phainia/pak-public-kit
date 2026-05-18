require("UnLuaEx")
local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local AbilityErrorCode = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityErrorCode")
local AbilityEvent = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityEvent")
local AbilityID = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityID")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local Base = require("NewRoco.Modules.System.MainUI.Res.Ability.UMG_Ability_Slot_C")
local AbilityHelperManager = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityHelperManager")
local FunctionBanModuleEvent = require("NewRoco.Modules.System.FunctionBan.FunctionBanModuleEvent")
local UMG_Ability_Slot_ClimbUp_C = Base:Extend("UMG_Ability_Slot_ClimbUp_C")
local CHECK_INTERVAL = 0.5

function UMG_Ability_Slot_ClimbUp_C:OnConstruct()
  Base.OnConstruct(self)
  self.isBlock = false
  self._lastIsVisible = true
  self._curCheckInterval = CHECK_INTERVAL
  self.slotIndex = 2
  self.slotSubIndex = 2
  _G.NRCEventCenter:RegisterEvent("UMG_Ability_Slot_ClimbUp_C", self, FunctionBanModuleEvent.OnUIFuncVisibilityChange, self.UIBan)
end

function UMG_Ability_Slot_ClimbUp_C:OnDestruct()
  Base.OnDestruct(self)
  _G.NRCEventCenter:UnRegisterEvent(self, FunctionBanModuleEvent.OnUIFuncVisibilityChange, self.UIBan)
end

function UMG_Ability_Slot_ClimbUp_C:OnActive()
  self:ShowPetSwitch(false)
  local climbAbilityHelper = AbilityHelperManager.GetHelper(AbilityID.MAIN)
  self:BindAbility(climbAbilityHelper)
  self:OnPlayerStatusChanged()
  if self:IsPCMode() then
    self:SetRenderOpacity(1)
  end
end

function UMG_Ability_Slot_ClimbUp_C:OnDeactive()
  local caster = self.localPlayer
  if caster then
    caster.abilityComponent:RemoveEventListener(self, AbilityEvent.ON_BUFF_LOOP_BEGIN, self.OnLoopBegin)
    caster.abilityComponent:RemoveEventListener(self, AbilityEvent.ON_BUFF_LOOP_END, self.OnLoopEnd)
  end
end

function UMG_Ability_Slot_ClimbUp_C:BindAbility(abilityHelper)
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

function UMG_Ability_Slot_ClimbUp_C:OnPlayerStatusChanged(status, value, opCode)
  self:RefreshView()
end

function UMG_Ability_Slot_ClimbUp_C:RefreshView()
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

function UMG_Ability_Slot_ClimbUp_C:UIBan(FuncId)
  if FuncId == Enum.FunctionEntrance.FE_MAIN_ABILITY_SLOT then
    self:RefreshView()
  end
end

function UMG_Ability_Slot_ClimbUp_C:InternalRefreshView()
  local caster = self.localPlayer
  local statusComponent = caster and caster.statusComponent
  self._isVisible = false
  self.isBlock = false
  if statusComponent and statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_CLIMB) then
    local bBan = NRCModuleManager:DoCmd(FunctionBanModuleCmd.CheckUIFunctionHide, Enum.FunctionEntrance.FE_MAIN_ABILITY_SLOT)
    self._isVisible = not bBan
  else
    self._isVisible = false
  end
  local climbDashHelper = AbilityHelperManager.GetHelper(AbilityID.CLIMB_DASH)
  local enough = climbDashHelper:IsVitalityEnough(self.localPlayer)
  local block = false
  if not enough then
    block = true
  end
  local IconPath = self:GetIcon(block)
  local pressIcon = self:GetPressIcon()
  self.Image_Bg:SetPath(pressIcon)
  self.BP_UIIcon:SetPath(IconPath)
  self.BP_UIIcon:SetPath(IconPath)
  self:SetVisible(self._isVisible)
end

function UMG_Ability_Slot_ClimbUp_C:GetIcon(isBlock)
  if isBlock then
    local climbDashIcon = "/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/MainUI/Frames/btn_ClimbingJump4_png.btn_ClimbingJump4_png"
    return climbDashIcon
  else
    local climbDashIcon = "/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/MainUI/Frames/btn_ClimbingJump1_png.btn_ClimbingJump1_png"
    return climbDashIcon
  end
end

function UMG_Ability_Slot_ClimbUp_C:GetPressIcon()
  local climbDashIcon = "/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/MainUI/Frames/btn_ClimbingJump2_png.btn_ClimbingJump2_png"
  return climbDashIcon
end

function UMG_Ability_Slot_ClimbUp_C:OnSlotPressed(bind)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(self.SoundID, "UMG_Ability_Slot_C:OnSlotPressed")
  local errorCode = self:OnCast(true)
  if errorCode == AbilityErrorCode.NO_ERROR and self.press then
    self:StopAnimation(self.press)
    self:PlayAnimation(self.press)
  end
end

function UMG_Ability_Slot_ClimbUp_C:OnSlotReleased(bind)
  if not self._hasAbility then
    return
  end
  self.localPlayer.abilityComponent:StopAbility(true, self._abilityHelper.config.id)
  self.localPlayer:SendEvent(PlayerModuleEvent.ON_MAIN_ABILITY_RELEASED)
end

function UMG_Ability_Slot_ClimbUp_C:OnCast(isPress)
  local climbDashHelper = AbilityHelperManager.GetHelper(AbilityID.CLIMB_DASH)
  local errorCode = climbDashHelper:CanCastAbility(self.localPlayer)
  if errorCode == AbilityErrorCode.NO_ERROR then
    self.localPlayer.statusComponent:ApplyStatus(ProtoEnum.WorldPlayerStatusType.WPST_CLIMB_DASH)
  else
  end
  return errorCode
end

function UMG_Ability_Slot_ClimbUp_C:OnLoopBegin(abilityID)
  if abilityID == self._abilityHelper.config.id then
    self.curLoopId = abilityID
    self:StartLongPressMode()
  end
end

function UMG_Ability_Slot_ClimbUp_C:OnLoopEnd(abilityID)
  if self.curLoopId == abilityID then
    self:StopLongPressMode()
    self.curLoopId = -1
  end
end

function UMG_Ability_Slot_ClimbUp_C:OnTick(InDeltaTime)
end

function UMG_Ability_Slot_ClimbUp_C:StartLongPressMode()
  self:StopAllAnimations()
  self:PlayAnimation(self.inAnim)
end

function UMG_Ability_Slot_ClimbUp_C:OnAnimationFinished(anim)
  if anim == self.inAnim and self.loopAnim and not self:IsAnimationPlaying(self.loopAnim) then
    self:PlayAnimation(self.loopAnim, 0.0, 9999)
  end
  Base.OnAnimationFinished(self, anim)
end

function UMG_Ability_Slot_ClimbUp_C:StopLongPressMode()
  self:StopAllAnimations()
  self:PlayAnimation(self.outAnim)
end

function UMG_Ability_Slot_ClimbUp_C:PlayLoopAnim()
  self:StopAllAnimations()
  self:PlayAnimation(self.loopAnim, 0.0, 9999)
end

function UMG_Ability_Slot_ClimbUp_C:OnPCKey(action_type)
  if self.Visibility == UE.ESlateVisibility.Hidden or self.Visibility == UE.ESlateVisibility.Collapsed or self.Visibility == UE.ESlateVisibility.HitTestInvisible then
    return
  end
  if not self.localPlayer then
    Log.Error("UMG_Ability_Slot_ClimbUp_C:OnPCKey Local player is nil")
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

function UMG_Ability_Slot_ClimbUp_C:IsPCMode()
  return UE.UGameplayStatics.GetGameInstance(self):IsPCMode()
end

return UMG_Ability_Slot_ClimbUp_C
