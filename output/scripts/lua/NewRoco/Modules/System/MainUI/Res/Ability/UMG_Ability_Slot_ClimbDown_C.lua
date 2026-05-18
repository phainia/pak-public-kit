require("UnLuaEx")
local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local AbilityErrorCode = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityErrorCode")
local AbilityEvent = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityEvent")
local AbilityID = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityID")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local StatusUtils = require("NewRoco.Modules.Core.Scene.Component.Status.StatusUtils")
local Base = require("NewRoco.Modules.System.MainUI.Res.Ability.UMG_Ability_Slot_C")
local AbilityHelperManager = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityHelperManager")
local FunctionBanModuleEvent = require("NewRoco.Modules.System.FunctionBan.FunctionBanModuleEvent")
local UMG_Ability_Slot_ClimbDown_C = Base:Extend("UMG_Ability_Slot_ClimbDown_C")

function UMG_Ability_Slot_ClimbDown_C:OnConstruct()
  Base.OnConstruct(self)
  self.slotIndex = 3
  self.slotSubIndex = 2
  _G.NRCEventCenter:RegisterEvent("UMG_Ability_Slot_ClimbUp_C", self, FunctionBanModuleEvent.OnUIFuncVisibilityChange, self.UIBan)
end

function UMG_Ability_Slot_ClimbDown_C:OnDestruct()
  Base.OnDestruct(self)
  _G.NRCEventCenter:UnRegisterEvent(self, FunctionBanModuleEvent.OnUIFuncVisibilityChange, self.UIBan)
end

function UMG_Ability_Slot_ClimbDown_C:OnActive()
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  self.localPlayer = localPlayer
  self:RefreshUI()
  self:OnPlayerStatusChanged()
end

function UMG_Ability_Slot_ClimbDown_C:OnDeactive()
end

function UMG_Ability_Slot_ClimbDown_C:SetPcText()
  if self:IsClimbDown() then
    self:OnCast(true)
  end
end

function UMG_Ability_Slot_ClimbDown_C:OnPlayerStatusChanged(status, value, opCode)
  self:RefreshView()
end

function UMG_Ability_Slot_ClimbDown_C:RefreshView()
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

function UMG_Ability_Slot_ClimbDown_C:InternalRefreshView()
  local caster = self.localPlayer
  if not caster then
    Log.Error("UMG_Ability_Slot_ClimbDown_C:InternalRefreshView caster is nil")
    return
  end
  local statusComponent = caster.statusComponent
  self._isVisible = false
  self.isBlock = false
  if statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_CLIMB) then
    local bBan = NRCModuleManager:DoCmd(FunctionBanModuleCmd.CheckUIFunctionHide, Enum.FunctionEntrance.FE_MAIN_ABILITY_SLOT)
    self._isVisible = not bBan
  else
    self._isVisible = false
  end
  self:SetVisible(self._isVisible)
end

function UMG_Ability_Slot_ClimbDown_C:RefreshUI()
  local IconPath = "PaperSprite'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/MainUI/Frames/btn_cancelclimb_png.btn_cancelclimb_png'"
  local PressPath = "PaperSprite'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/MainUI/Frames/btn_cancelclimb_xuanzhong_png.btn_cancelclimb_xuanzhong_png'"
  self.BP_UIIcon:SetPath(IconPath)
  self.Image_Bg:SetPath(PressPath)
end

function UMG_Ability_Slot_ClimbDown_C:UIBan(FuncId)
  if FuncId == Enum.FunctionEntrance.FE_MAIN_ABILITY_SLOT then
    self:RefreshView()
  end
end

function UMG_Ability_Slot_ClimbDown_C:OnCast(isPress)
  if not self.localPlayer then
    return
  end
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1017, "UMG_Ability_Slot_C:OnSlotPressed")
  if self:ClimbDown() then
    return
  end
  if self:IsClimbDown() then
    return
  end
  self.localPlayer.statusComponent:RemoveStatus(ProtoEnum.WorldPlayerStatusType.WPST_CLIMB)
  self:SetVisible(false)
end

function UMG_Ability_Slot_ClimbDown_C:ClimbDown()
  local movement = self.localPlayer.viewObj.CharacterMovement
  return movement:TryClimbingDown()
end

function UMG_Ability_Slot_ClimbDown_C:IsClimbDown()
  local movement = self.localPlayer.viewObj.CharacterMovement
  return movement:IsClimbingDown()
end

function UMG_Ability_Slot_ClimbDown_C:OnPCKey(isPress)
  if self.Visibility == UE.ESlateVisibility.Hidden or self.Visibility == UE.ESlateVisibility.Collapsed or self.Visibility == UE.ESlateVisibility.HitTestInvisible then
    return
  end
  if isPress then
    self:OnSlotPressed()
  else
    if _G.FriendModuleCmd then
      _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.PCKeyPressCloseFriendPanelTeam)
    end
    self:OnSlotClicked()
  end
end

function UMG_Ability_Slot_ClimbDown_C:OnAnimationFinished(anim)
  if self.out and anim == self.out then
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Ability_Slot_ClimbDown_C:IsPCMode()
  return UE.UGameplayStatics.GetGameInstance(self):IsPCMode()
end

return UMG_Ability_Slot_ClimbDown_C
