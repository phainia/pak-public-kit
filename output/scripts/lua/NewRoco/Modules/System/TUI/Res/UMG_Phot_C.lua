local UMG_Photo_C = _G.NRCPanelBase:Extend("UMG_Photo_C")

function UMG_Photo_C:OnConstruct()
  self.LevelSequence = nil
  self.loadResRequest = {}
  self:OnAddEventListener()
end

function UMG_Photo_C:OnDestruct()
end

function UMG_Photo_C:OnActive()
  local PetLevelSequence = self.previewWorld:getActorByName("PhotoSequence")
  local CameraActor = self.previewWorld:getActorByName("MainCamera")
  self.camera = self.previewWorld:getActorByName("DefaultSceneCapture")
  self.captureComponent = self.camera:GetComponentByClass(UE4.USceneCaptureComponent2D)
  self.MainCamera = CameraActor
  self.LevelSequence = PetLevelSequence
  self:BindingSequenceCamera()
  self:LoadPhotoSequence()
end

function UMG_Photo_C:OnDeactive()
  if self.loadResRequest then
    for key, request in pairs(self.loadResRequest) do
      NRCResourceManager:UnLoadRes(request)
      self.loadResRequest[key] = nil
    end
  end
end

function UMG_Photo_C:OnAddEventListener()
  self:AddButtonListener(self.CloseBtn, self.OnClickCloseBtn)
end

function UMG_Photo_C:BindingSequenceCamera()
  if self.LevelSequence and self.LevelSequence.SequencePlayer and self.LevelSequence.SequencePlayer.Sequence then
    local BindingCapture = self.LevelSequence:FindNamedBindings("SceneCapture")
    if BindingCapture:Length() > 0 then
      local BindingCaptureInfo = self.LevelSequence:FindNamedBindings("SceneCapture")
      if BindingCaptureInfo then
        self.LevelSequence:SetBindingByTag("SceneCapture", {
          self.camera
        }, false)
      end
    end
  else
    Log.Debug("\229\186\143\229\136\151\231\155\184\230\156\186\230\137\190\228\184\141\229\136\176")
  end
end

function UMG_Photo_C:LoadPhotoSequence()
  local requset = NRCResourceManager:LoadResAsync(self, "LevelSequence'/Game/ArtRes/UI/Photo/JQ05_SUM_01/JQ05_SUM_01.JQ05_SUM_01'", -1, 10, function(caller, resRequest, asset)
    self:PlayPhotoSequence(asset)
  end, nil, nil)
  table.insert(self.loadResRequest, requset)
end

function UMG_Photo_C:PlayPhotoSequence(asset)
  if self.LevelSequence and asset then
    self.LevelSequence:SetSequence(asset)
    self.LevelSequence.SequencePlayer:PlayLooping(999999)
    self.skeletalMesh = self.previewWorld:getActorByName("SKM_PC1_0")
    self.captureComponent.showOnlyActors:Add(self.skeletalMesh)
  end
end

function UMG_Photo_C:OnClickCloseBtn()
  self:DoClose()
end

return UMG_Photo_C
