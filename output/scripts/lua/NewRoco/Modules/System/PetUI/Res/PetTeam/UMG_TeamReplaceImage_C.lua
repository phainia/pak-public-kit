local UMG_TeamReplaceImage_C = _G.NRCPanelBase:Extend("UMG_TeamReplaceImage_C")

function UMG_TeamReplaceImage_C:OnActive()
end

function UMG_TeamReplaceImage_C:OnDeactive()
end

function UMG_TeamReplaceImage_C:OnAddEventListener()
end

function UMG_TeamReplaceImage_C:OnTick()
end

function UMG_TeamReplaceImage_C:OnLogin()
end

function UMG_TeamReplaceImage_C:OnConstruct()
end

function UMG_TeamReplaceImage_C:OnDestruct()
  self:DestroyAllActors()
end

function UMG_TeamReplaceImage_C:OnAnimationFinished(anim)
end

function UMG_TeamReplaceImage_C:SetTeamData(Parent, teamType)
  self.Parent = Parent
  self.curTeamType = teamType
  self:InitSceneCapture()
  self:UpdateBgImg()
end

function UMG_TeamReplaceImage_C:InitSceneCapture()
  local MainCamera = self.previewWorld:getActorByName("MainCamera")
  self.captureComponent = MainCamera:GetComponentByClass(UE4.USceneCaptureComponent2D)
  self.cameraComponent = MainCamera:GetComponentByClass(UE4.UCameraComponent)
  self.previewWorld:SetCapturePostProcessing(self.captureComponent)
  UE4.UNRCStatics.ChangeTextureToMatchScene(self.captureComponent.TextureTarget)
  self.captureComponent.bCaptureEveryFrame = false
  self.captureComponent.bCaptureOnMovement = true
  local viewInfo = self.cameraComponent:GetCameraView(0)
  UE4.UNRCStatics.SetCaptureComponentCameraView(self.captureComponent, viewInfo)
end

function UMG_TeamReplaceImage_C:UpdateBgImg()
  local BPPath = "/Game/NewRoco/Modules/System/PetUI/Res/BackGroundBP/BP_UI_PetTeamBg_02.BP_UI_PetTeamBg_02_C"
  if self.curTeamType == Enum.PlayerTeamType.PTT_PVP_BATTLE_2 then
    BPPath = "/Game/NewRoco/Modules/System/PetUI/Res/BackGroundBP/BP_UI_PetTeamBg_03.BP_UI_PetTeamBg_03_C"
  elseif self.curTeamType == Enum.PlayerTeamType.PTT_PVP_BATTLE_3 then
    BPPath = "/Game/NewRoco/Modules/System/PetUI/Res/BackGroundBP/BP_UI_PetTeamBg.BP_UI_PetTeamBg_C"
  elseif self.curTeamType == Enum.PlayerTeamType.PTT_PVP_BATTLE_4 then
    BPPath = "/Game/NewRoco/Modules/System/PetUI/Res/BackGroundBP/BP_UI_PetTeamBg_PVP.BP_UI_PetTeamBg_PVP_C"
  end
  self:DeleteBGBP()
  self.bgRequest = _G.NRCResourceManager:LoadResAsync(self, BPPath, -1, -1, self.LoadBpOver)
end

function UMG_TeamReplaceImage_C:DestroyAllActors()
  self:DeleteBGBP()
end

function UMG_TeamReplaceImage_C:DeleteBGBP()
  if self.BGRef and UE.UObject.IsValid(self.BGRef) then
    UnLua.Unref(self.BGRef)
  end
  self.BGRef = nil
  if self.BGbp then
    self.previewWorld:DestroyActor(self.BGbp)
  end
  self.BGbp = nil
end

function UMG_TeamReplaceImage_C:LoadBpOver(resRequest, BgClass)
  local actor = self.previewWorld:SpawnActor(BgClass, UE.FTransform())
  self:AsyncLoadSceneOver()
  if not actor then
    Log.Error("zgx load bp of Bg faild")
  else
    self.BGbp = actor
    self.BGRef = UnLua.Ref(actor)
  end
end

function UMG_TeamReplaceImage_C:AsyncLoadSceneOver()
  if self.Parent then
    self.Parent:AsyncLoadSceneOver()
  end
end

return UMG_TeamReplaceImage_C
