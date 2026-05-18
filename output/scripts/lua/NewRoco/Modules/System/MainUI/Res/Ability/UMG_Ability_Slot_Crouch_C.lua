require("UnLuaEx")
local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local EnhancedInputModuleEvent = require("NewRoco.Modules.Core.EnhancedInput.EnhancedInputModuleEvent")
local AbilityErrorCode = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityErrorCode")
local AbilityEvent = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityEvent")
local AbilityID = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityID")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local StatusUtils = require("NewRoco.Modules.Core.Scene.Component.Status.StatusUtils")
local Base = require("NewRoco.Modules.System.MainUI.Res.Ability.UMG_Ability_Slot_C")
local AbilityHelperManager = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityHelperManager")
local UMG_Ability_Slot_Crouch_C = Base:Extend("UMG_Ability_Slot_Crouch_C")

function UMG_Ability_Slot_Crouch_C:OnConstruct()
  Base.OnConstruct(self)
  NRCEventCenter:RegisterEvent("UMG_Ability_Slot_Crouch_C", self, SceneEvent.OnPlayerEnterGrass, self.OnPlayerEnterGrass)
  NRCEventCenter:RegisterEvent("UMG_Ability_Slot_Crouch_C", self, SceneEvent.OnPlayerExitGrass, self.OnPlayerExitGrass)
  self._comp = self.localPlayer.CrouchComponent
  self._inCrouch = false
  self.slotIndex = 1
  self.slotSubIndex = 2
  self._stat = false
  self:RefreshUI()
  if self:IsPCMode() then
    self.Image_Bg_di:SetPath("PaperSprite'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/MainUIStatic/Frames/btn_gongneng_png.btn_gongneng_png'")
  end
  FunctionBanManager:AddFunctionStateListener(Enum.PlayerFunctionBanType.PFBT_MOVE, self, self.OnFunctionBan)
end

function UMG_Ability_Slot_Crouch_C:OnDestruct()
  Base.OnDestruct(self)
  NRCEventCenter:UnRegisterEvent(self, SceneEvent.OnPlayerEnterGrass, self.OnPlayerEnterGrass)
  NRCEventCenter:UnRegisterEvent(self, SceneEvent.OnPlayerExitGrass, self.OnPlayerExitGrass)
  FunctionBanManager:RemoveFunctionStateListener(Enum.PlayerFunctionBanType.PFBT_MOVE, self, self.OnFunctionBan)
end

function UMG_Ability_Slot_Crouch_C:OnPlayerEnterGrass()
  self._comp = self.localPlayer.CrouchComponent
  self:RefreshUI()
end

function UMG_Ability_Slot_Crouch_C:OnPlayerExitGrass()
  self:RefreshUI()
end

function UMG_Ability_Slot_Crouch_C:OnFunctionBan()
  self:RefreshUI()
end

function UMG_Ability_Slot_Crouch_C:OnRefreshByUserReasonChanged()
  Base.OnRefreshByUserReasonChanged(self)
  self:RefreshUI()
end

function UMG_Ability_Slot_Crouch_C:RefreshUI()
  if self._comp and self._comp:IsInGrass() and (self.localPlayer.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_CROUCHING) or self.localPlayer.statusComponent:PreApplyStatus(ProtoEnum.WorldPlayerStatusType.WPST_CROUCHING)) and not self.localPlayer.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_AIMTHROWING) and not _G.NRCModuleManager:DoCmd(FunctionBanModuleCmd.GetFunctionState, Enum.PlayerFunctionBanType.PFBT_MOVE) and not _G.NRCModuleManager:DoCmd(FunctionBanModuleCmd.CheckUIFunctionHide, Enum.FunctionEntrance.FE_CROUCH) and not self:IsHiddenByUser() then
    local flag = false
    if self._comp:isInCrouch() then
      flag = true
    end
    if nil == flag or flag ~= self._stat or not self._isVisible then
      self._stat = flag
      if not self._isVisible then
        if nil ~= self.show then
          self:StopAllAnimations()
          if not flag then
            self:PlayAnimation(self.press_dark, 0, 1, UE.EUMGSequencePlayMode.Forward, 999, false)
          else
            self:PlayAnimation(self.press_shine, 0, 1, UE.EUMGSequencePlayMode.Forward, 999, false)
          end
          self:PlayAnimation(self.show)
        end
      elseif flag then
        self:StopAnimation(self.press_dark)
        self:PlayAnimation(self.press_shine)
      else
        self:StopAnimation(self.press_shine)
        self:PlayAnimation(self.press_dark)
      end
    end
    self._isVisible = true
  else
    self._isVisible = false
    self._stat = self._comp and self._comp:isInCrouch()
  end
  self:SetVisible(self._isVisible)
end

function UMG_Ability_Slot_Crouch_C:SetVisible(visible, focusChanges)
  if not _G.NRCModuleManager:GetModule("MainUIModule") then
    return
  end
  if visible then
    if self.out ~= nil and self:IsAnimationPlaying(self.out) then
      self:StopAnimation(self.out)
    end
    _G.NRCModuleManager:GetModule("MainUIModule"):DispatchEvent(MainUIModuleEvent.SlotVisibilityChange, true, self.slotIndex, self.slotSubIndex)
    if focusChanges then
      if self.FoundationPCKey then
        self.FoundationPCKey:SetKeyVisibility(true)
      end
      if self.ParentPanel then
        self.ParentPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
      self:SetVisibility(UE4.ESlateVisibility.Visible)
    elseif self.Visibility ~= UE4.ESlateVisibility.Visible then
      if self.FoundationPCKey then
        self.FoundationPCKey:SetKeyVisibility(true)
      end
      if self.ParentPanel then
        self.ParentPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
      self:SetVisibility(UE4.ESlateVisibility.Visible)
      self.CurSlotStatus = 0
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
      if self.FoundationPCKey then
        self.FoundationPCKey:SetKeyVisibility(false)
      end
      if self.ParentPanel then
        self.ParentPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
      self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self.CurSlotStatus = 4
  end
end

function UMG_Ability_Slot_Crouch_C:OnSlotPressed(bind)
  self:OnCastCrouch()
end

function UMG_Ability_Slot_Crouch_C:OnCastCrouch(isPress)
  if self._comp:isInCrouch() then
    self._comp:TryUnCrouch()
  else
    self._comp:TryCrouch()
  end
  self:RefreshUI()
end

function UMG_Ability_Slot_Crouch_C:OnPlayerStatusChanged(...)
  self:RefreshUI()
end

function UMG_Ability_Slot_Crouch_C:OnPCKey()
  if self.Visibility == UE.ESlateVisibility.Hidden or self.Visibility == UE.ESlateVisibility.Collapsed or self.Visibility == UE.ESlateVisibility.HitTestInvisible then
    return
  end
  if _G.FriendModuleCmd then
    _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.PCKeyPressCloseFriendPanelTeam)
  end
  self:OnSlotPressed()
end

function UMG_Ability_Slot_Crouch_C:IsPCMode()
  return UE.UGameplayStatics.GetGameInstance(self):IsPCMode()
end

return UMG_Ability_Slot_Crouch_C
