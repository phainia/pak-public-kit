require("UnLuaEx")
local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local AbilityErrorCode = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityErrorCode")
local AbilityEvent = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityEvent")
local AbilityID = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityID")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local StatusUtils = require("NewRoco.Modules.Core.Scene.Component.Status.StatusUtils")
local Base = require("NewRoco.Modules.System.MainUI.Res.Ability.UMG_Ability_Slot_C")
local AbilityHelperManager = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityHelperManager")
local UMG_Ability_Slot_Untransform_C = Base:Extend("UMG_Ability_Slot_Untransform_C")

function UMG_Ability_Slot_Untransform_C:OnConstruct()
  Base.OnConstruct(self)
  self._iconPath = "PaperSprite'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/MainUI/Frames/btn_Untransform1_png.btn_Untransform1_png'"
  self.BP_UIIcon:SetPath(self._iconPath)
  self._isVisible = false
  self.slotIndex = 1
  self.slotSubIndex = 3
end

function UMG_Ability_Slot_Untransform_C:OnDestruct()
  Base.OnDestruct(self)
end

function UMG_Ability_Slot_Untransform_C:RefreshUI()
  local IsVisible = self._isVisible
  if _G.NRCModuleManager:DoCmd(FunctionBanModuleCmd.CheckUIFunctionHide, Enum.FunctionEntrance.FE_UNTRANSFORM) then
    IsVisible = false
  end
  self:SetVisible(IsVisible)
end

function UMG_Ability_Slot_Untransform_C:OnSlotPressed(bind)
  local caster = self.localPlayer
  if not caster.inputComponent:GetInputEnable() then
    return
  end
  local buff = caster.buffComponent:GetBuff("Transform_Buff")
  if not buff then
    Log.Error("\230\151\160\229\143\152\229\189\162buff")
    return
  end
  if not buff.MagicTransformConf then
    Log.Error("\230\151\160\229\143\152\229\189\162\233\133\141\231\189\174")
    return
  end
  if buff._isInStartPerform then
    Log.Debug("\230\173\163\229\156\168\232\161\168\230\188\148\228\184\173, \231\166\129\230\173\162\229\143\150\230\182\136\229\143\152\229\189\162")
    return
  end
  if buff.MagicTransformConf.is_pet and not caster.viewObj.BP_RideComponent.RidePet then
    Log.Debug("\229\188\130\230\173\165\229\138\160\232\189\189\228\184\173, \231\166\129\230\173\162\229\143\150\230\182\136\229\143\152\229\189\162")
    return
  end
  self:PlayAnimation(self.press)
  if buff.MagicTransformConf.use_confirm_panel then
    local Context = DialogContext()
    Context:SetTitle(LuaText.TIPS):SetContent(LuaText.cancel_transform):SetMode(DialogContext.Mode.OK_CANCEL):SetButtonText(LuaText.YES, LuaText.NO):SetCallback(self, self.OnSelectOK):SetCloseOnCancel(true)
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
  else
    self:OnSelectOK(true)
  end
end

function UMG_Ability_Slot_Untransform_C:OnSelectOK(result)
  if result then
    local req = _G.ProtoMessage:newZoneSceneCancelPlayerTransformReq()
    req.cancel_reason = ProtoEnum.PlayerTransformCancelReason.PTCR_STATUS_BAN
    _G.ZoneServer:Send(ProtoCMD.ZoneSvrCmd.ZONE_SCENE_CANCEL_PLAYER_TRANSFORM_REQ, req, true, true)
  end
end

function UMG_Ability_Slot_Untransform_C:OnPlayerStatusChanged(...)
  self._isVisible = self.localPlayer.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_TRANSFORM)
  self:RefreshUI()
end

function UMG_Ability_Slot_Untransform_C:OnPCKey()
  if self.Visibility == UE.ESlateVisibility.Hidden or self.Visibility == UE.ESlateVisibility.Collapsed or self.Visibility == UE.ESlateVisibility.HitTestInvisible then
    return
  end
  if _G.FriendModuleCmd then
    _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.PCKeyPressCloseFriendPanelTeam)
  end
  self:OnSlotPressed()
end

function UMG_Ability_Slot_Untransform_C:IsPCMode()
  return UE.UGameplayStatics.GetGameInstance(self):IsPCMode()
end

return UMG_Ability_Slot_Untransform_C
