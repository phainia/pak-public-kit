local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local UMG_LocalUI_C = _G.NRCPanelBase:Extend("UMG_LocalUI_C")

function UMG_LocalUI_C:OnConstruct()
  self:SetChildViews(self.UMG_PlayerAbilities, self.UMG_PlayerControl)
  self.BG:SetRenderOpacity(0)
  self.BG:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.localplayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  self.levelName = LevelHelper:GetLevelName()
  if self.levelName == "CharCatch_Map" then
    self:InitPlayer()
  end
  self.UMG_Ability_Slot_Local:OnConstruct()
  self.UMG_PlayerControl:OnConstruct()
  self:RegisterEvent(self, MainUIModuleEvent.UI_SHOW_ABILITY_AIM_JOYSTICK, self.SetAbilityAimJoystickVisible)
  self:RegisterEvent(self, MainUIModuleEvent.UI_UPDATE_JOYSTICK_LOCK_MOVE, self.UpdateJoyStickLockMove)
  self:RegisterEvent(self, MainUIModuleEvent.UI_ShowFrontSight, self.ShowFrontSight)
  self:RegisterEvent(self, MainUIModuleEvent.UI_UpdateFrontSight, self.UpdateLockPetUI)
end

function UMG_LocalUI_C:OnDestruct()
end

function UMG_LocalUI_C:AddInputMappingContext()
  local MainDefaultIMC = UE.UNRCEnhancedInputHelper.GetInputMappingContext("IMC_LocalMainUI")
  _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.EnhancedInputHelperAddInputMappingContext, MainDefaultIMC, self.depth)
end

function UMG_LocalUI_C:RemoveInputMappingContext()
  local MainDefaultIMC = UE.UNRCEnhancedInputHelper.GetInputMappingContext("IMC_LocalMainUI")
  _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.EnhancedInputHelperRemoveInputMappingContext, MainDefaultIMC)
end

function UMG_LocalUI_C:SetAbilityAimJoystickVisible(visible, abilityID)
  self.UMG_PlayerControl:SetAimJoystickMode(MainUIModuleEnum.ShowAimJoystick.Ability, abilityID)
  self.UMG_PlayerControl:SetAimJoystickVisible(visible)
end

function UMG_LocalUI_C:ShowFrontSight(show, cancelType, isAbility)
  if isAbility then
    if show then
      self.UMG_LockPet:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      self.UMG_LockPet:OnShow(isAbility)
    else
      self.UMG_LockPet:OnCancel(1)
      self.UMG_LockPet:ClearActorCache()
    end
  end
end

function UMG_LocalUI_C:UpdateLockPetUI(isCollision)
  self.UMG_LockPet:UpdateUI(isCollision)
end

function UMG_LocalUI_C:UpdateJoyStickLockMove(visible)
  if visible then
    if self.UMG_PlayerControl.bLockMove then
      self.UMG_PlayerControl.bLockMove = false
    end
  else
    self.UMG_PlayerControl.UMG_Control_Joystick:OnInVisible()
    self.UMG_PlayerControl.bLockMove = true
  end
end

function UMG_LocalUI_C:OnActive()
  local localMode = NRCModeManager:GetCurMode()
  local playerModule = localMode:GetModule("PlayerModule")
  self.UMG_PlayerAbilities.module = playerModule
  self.UMG_PlayerAbilities:OnActive()
  self:SendLocalMainUIOpen()
end

function UMG_LocalUI_C:OnEnable()
  UE4Helper.SetDesiredShowCursor(false, "UMG_LocalUI_C")
end

function UMG_LocalUI_C:OnDisable()
  UE4Helper.ReleaseDesiredShowCursor("UMG_LocalUI_C")
end

function UMG_LocalUI_C:OnDeactive()
  self.UMG_PlayerAbilities:OnDeactive()
  self:SendLocalMainUIClose()
end

function UMG_LocalUI_C:InitPlayer()
  self.localplayer:SetActorLocation(UE4.FVector(0, 0, 0))
end

function UMG_LocalUI_C:CalcDistance(x, y)
  return x ^ 2 + y ^ 2
end

function UMG_LocalUI_C:OnTick(deltaTime)
end

function UMG_LocalUI_C:SendLocalMainUIClose()
  _G.NRCEventCenter:DispatchEvent(MainUIModuleEvent.LOCALMAINUICLOSE)
end

function UMG_LocalUI_C:SendLocalMainUIOpen()
  _G.NRCEventCenter:DispatchEvent(MainUIModuleEvent.LOCALMAINUIOPEN)
end

return UMG_LocalUI_C
