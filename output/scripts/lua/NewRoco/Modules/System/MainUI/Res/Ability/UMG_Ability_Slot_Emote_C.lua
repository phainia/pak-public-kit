require("UnLuaEx")
local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local AbilityErrorCode = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityErrorCode")
local AbilityEvent = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityEvent")
local AbilityID = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityID")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local StatusUtils = require("NewRoco.Modules.Core.Scene.Component.Status.StatusUtils")
local Base = require("NewRoco.Modules.System.MainUI.Res.Ability.UMG_Ability_Slot_C")
local AbilityHelperManager = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityHelperManager")
local UMG_Ability_Slot_Emote_C = Base:Extend("UMG_Ability_Slot_Emote_C")

function UMG_Ability_Slot_Emote_C:OnConstruct()
  Base.OnConstruct(self)
  self._iconPath = "PaperSprite'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/MainUI/Frames/btn_Emote1_png.btn_Emote1_png'"
  self.BP_UIIcon:SetPath(self._iconPath)
  self._isVisible = false
  self:RefreshUI()
end

function UMG_Ability_Slot_Emote_C:OnDestruct()
  Base.OnDestruct(self)
end

function UMG_Ability_Slot_Emote_C:RefreshUI()
  local IsVisible = self._isVisible
  if _G.NRCModuleManager:DoCmd(FunctionBanModuleCmd.CheckUIFunctionHide, Enum.FunctionEntrance.FE_EMOTE) then
    IsVisible = false
  elseif self:IsPCMode() then
    if self.FoundationPCKey then
      self.FoundationPCKey:SetLeftClickMode()
      self.FoundationPCKey:SetKeyVisibility(true)
    end
  else
    self.Text_PCKey:SetKeyVisibility(false)
  end
  self:SetVisible(IsVisible)
end

function UMG_Ability_Slot_Emote_C:OnSlotPressed(bind)
  local caster = self.localPlayer
  if not caster.inputComponent:GetInputEnable() then
    return
  end
  self:PlayAnimation(self.press)
  local buff = self.localPlayer.buffComponent:GetBuff("Transform_Buff")
  buff:Emote()
end

function UMG_Ability_Slot_Emote_C:OnPlayerStatusChanged(...)
  local buff = self.localPlayer.buffComponent:GetBuff("Transform_Buff")
  local hasStatus = self.localPlayer.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_TRANSFORM)
  if hasStatus and buff and buff.MagicTransformConf.is_pet then
    self._isVisible = true
  else
    self._isVisible = false
  end
  self:RefreshUI()
end

function UMG_Ability_Slot_Emote_C:OnPCKey()
  if self.Visibility == UE.ESlateVisibility.Hidden or self.Visibility == UE.ESlateVisibility.Collapsed or self.Visibility == UE.ESlateVisibility.HitTestInvisible then
    return
  end
  if _G.FriendModuleCmd then
    _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.PCKeyPressCloseFriendPanelTeam)
  end
  self:OnSlotPressed()
end

function UMG_Ability_Slot_Emote_C:PCSet()
  if self.FoundationPCKey then
    self.FoundationPCKey:SetText("Z")
    self.FoundationPCKey:SetKeyVisibility(true)
  end
end

function UMG_Ability_Slot_Emote_C:IsPCMode()
  return UE.UGameplayStatics.GetGameInstance(self):IsPCMode()
end

return UMG_Ability_Slot_Emote_C
