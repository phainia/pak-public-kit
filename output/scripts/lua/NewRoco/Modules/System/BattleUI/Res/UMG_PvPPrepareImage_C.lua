local UMG_PvPPrepareImage_C = _G.NRCPanelBase:Extend("UMG_PvPPrepareImage_C")

function UMG_PvPPrepareImage_C:OnActive()
end

function UMG_PvPPrepareImage_C:OnDeactive()
  self:ClearWorld()
end

function UMG_PvPPrepareImage_C:OnAddEventListener()
end

function UMG_PvPPrepareImage_C:OnConstruct()
end

function UMG_PvPPrepareImage_C:OnDestruct()
  if self.captureComponent then
    self.captureComponent.showOnlyActors:Clear()
  end
end

function UMG_PvPPrepareImage_C:SetTeam(player)
  self.teamModel = player
end

function UMG_PvPPrepareImage_C:SetEnemy(player)
  self.enemyModel = player
end

function UMG_PvPPrepareImage_C:SetTeamData(teamPlayer, enemyPlayer)
  if teamPlayer then
    self.teamModel = teamPlayer.model
    self.lastTeamTrans = self.teamModel:Abs_GetTransform()
  end
  if enemyPlayer then
    self.enemyModel = enemyPlayer.model
    self.lastEnemyTrans = self.enemyModel:Abs_GetTransform()
  end
  self:InitSlots()
  self:InitSceneCapture()
  self:UpdateSlotActors()
end

function UMG_PvPPrepareImage_C:InitSceneCapture()
  local enemyCamera = self.previewWorld:getActorByName("EnemyCamera")
  self.captureComponent = enemyCamera:GetComponentByClass(UE4.USceneCaptureComponent2D)
  UE4.UNRCStatics.ChangeTextureToMatchScreen(self.captureComponent.TextureTarget, UE4Helper.GetCurrentWorld(), 1)
  self.captureComponent.bCaptureEveryFrame = true
  self.captureComponent.bCaptureOnMovement = true
  local initPos = enemyCamera:K2_GetActorLocation()
  self.WorldCamera = enemyCamera
  self.CameraCloseNum = 0
  self.CameraInitPos = UE.FVector(initPos.X, initPos.Y, initPos.Z)
  self.previewImage:SetBrushFromMaterial(self.PvPMaterial, false)
end

function UMG_PvPPrepareImage_C:InitSlots()
  self.teamSlotActor = self.previewWorld:getActorByName("Slot_2")
  self.enemySlotActor = self.previewWorld:getActorByName("Slot_1")
end

function UMG_PvPPrepareImage_C:UpdateSlotActors()
  self:AddPetToScene(self.teamSlotActor, self.teamModel)
  self:AddPetToScene(self.enemySlotActor, self.enemyModel)
end

function UMG_PvPPrepareImage_C:AddPetToScene(slotActor, playerActor)
  if playerActor then
    playerActor.CharacterMovement:SetMovementMode(UE4.EMovementMode.MOVE_Custom, UE4.ERocoCustomMovementMode.MOVE_N)
    playerActor:SetIKEnable(false)
    local transform = slotActor:GetTransform()
    playerActor:Abs_K2_SetActorTransform_WithoutHit(transform)
    self.captureComponent.showOnlyActors:Add(playerActor)
  end
end

function UMG_PvPPrepareImage_C:AddPlayerAvatar(playerActor)
  if not playerActor then
    return
  end
  local AvatarComponent = playerActor:GetComponentByClass(UE4.UAvatarComponent)
  if AvatarComponent then
    local AActorS = AvatarComponent:GetDecorators()
    for i, Actor in ipairs(AActorS:ToTable()) do
      self.captureComponent.showOnlyActors:Add(Actor)
    end
  end
end

function UMG_PvPPrepareImage_C:RecoverActors()
  if self.teamModel and self.lastTeamTrans then
    self.teamModel:Abs_K2_SetActorTransform_WithoutHit(self.lastTeamTrans)
    self:RecoverPlayerActor(self.teamModel)
  end
  if self.enemyModel and self.lastEnemyTrans then
    self.enemyModel:Abs_K2_SetActorTransform_WithoutHit(self.lastEnemyTrans)
    self:RecoverPlayerActor(self.enemyModel)
  end
end

function UMG_PvPPrepareImage_C:RecoverPlayerActor(playerActor)
  if playerActor then
    playerActor:SetIKEnable(true)
  end
end

function UMG_PvPPrepareImage_C:CameraClose()
  if self.WorldCamera and self.CameraCloseNum <= 200 then
    self.CameraCloseNum = self.CameraCloseNum + 1
    self.CameraInitPos.X = self.CameraInitPos.X + 1
    self.WorldCamera:K2_SetActorLocation(self.CameraInitPos, false, nil, false)
    self:DelayFrames(2, self.CameraClose, self)
  end
end

function UMG_PvPPrepareImage_C:ClearWorld()
  if self.teamModel and self.teamModel.RocoSkill then
    SkillUtils.ClearSkillObj(self.teamModel.RocoSkill)
    self.teamModel:Release()
  end
  if self.enemyModel and self.enemyModel.RocoSkill then
    SkillUtils.ClearSkillObj(self.enemyModel.RocoSkill)
    self.enemyModel:Release()
  end
  self.enemyModel = nil
  self.teamModel = nil
  self.WorldCamera = nil
end

return UMG_PvPPrepareImage_C
