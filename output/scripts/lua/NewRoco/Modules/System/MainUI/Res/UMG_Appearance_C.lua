local UMG_Appearance_C = _G.NRCPanelBase:Extend("UMG_Appearance_C")

function UMG_Appearance_C:OnConstruct()
  self.player = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  self.cameraManager = self.player:GetUEController().playerCameraManager
  self.playerController = UE4.UGameplayStatics.GetPlayerController(self, 0)
  self.playerMesh = self.player.viewObj:GetComponentByClass(UE4.USkeletalMeshComponent)
  self.Particle:PlayAnimation(self.Particle.Loop, 0, 0)
  _G.NRCAudioManager:PlaySound2DAuto(1301, "UMG_Appearance_C:OnConstruct")
end

function UMG_Appearance_C:OnActive()
  self:OnAddEventListener()
  _G.NRCProfilerLog:NRCPanelOpenAnimation(true, self.panelName)
  self:PlayAnimation(self.In)
end

function UMG_Appearance_C:OnDeactive()
end

function UMG_Appearance_C:OnAddEventListener()
  self:AddButtonListener(self.Btn_Appearance, self.OnClickBtn_Appearance)
end

function UMG_Appearance_C:OnDestruct()
end

function UMG_Appearance_C:Tick(MyGeometry, InDeltaTime)
  if self.player and self.player.statusComponent and self.player.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_MAGIC) then
    self.RolePlay.Slot:SetPosition(UE4.FVector2D(921, 277))
  else
    self.RolePlay.Slot:SetPosition(self:GetPlayerHeadLocatorLocation())
  end
end

function UMG_Appearance_C:GetPlayerHeadLocatorLocation()
  local headLoation = self.playerMesh:Abs_GetSocketLocation("Root")
  local ScreenPos = UE4.FVector2D()
  local ViewportPos = UE4.FVector2D()
  local CameraRightVector = UE4.UKismetMathLibrary.GetRightVector(self.cameraManager:GetCameraRotation())
  local CameraUpVector = UE4.UKismetMathLibrary.GetUpVector(self.cameraManager:GetCameraRotation())
  local headPositon = headLoation - CameraRightVector * 120 + CameraUpVector * 200
  UE4.UGameplayStatics.Abs_ProjectWorldToScreen(self.playerController, headPositon, ScreenPos)
  UE4.USlateBlueprintLibrary.ScreenToViewport(_G.UE4Helper.GetCurrentWorld(), ScreenPos, ViewportPos)
  return ViewportPos
end

function UMG_Appearance_C:OnClickBtn_Appearance()
  self.UMG_Appearance_Loop_3.Select:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.UMG_Appearance_Loop_3.Star:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.UMG_Appearance_Loop_3:PlayAnimation(self.UMG_Appearance_Loop_3.Loop, 0, 0)
  self.UMG_Appearance_Loop:PlayAnimation(self.UMG_Appearance_Loop.Loop, 0, 0)
  self:PlayAnimation(self.Btn_Click)
  _G.NRCAudioManager:PlaySound2DAuto(1141, "UMG_Appearance_C:OnClickBtn_Appearance")
  local suitInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerFashionInfo()
  _G.NRCModuleManager:DoCmd(AppearanceModuleCmd.OpenSuitPopupPanel, suitInfo, true, true, false, true)
end

function UMG_Appearance_C:OnClickCloseBtn()
  self:PlayAnimation(self.Close)
end

function UMG_Appearance_C:OnAnimationFinished(anim)
  if anim == self.Close then
    self:DoClose()
  elseif anim == self.In then
    _G.NRCProfilerLog:NRCPanelOpenAnimation(false, self.panelName)
  end
end

return UMG_Appearance_C
