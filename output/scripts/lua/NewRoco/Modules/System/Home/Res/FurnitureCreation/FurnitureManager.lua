local FurnitureCreationEditor = require("NewRoco/Modules/System/Home/Res/FurnitureCreation/FurnitureCreationEditor")
local CreationFurnitureManager = Class("CreationCreationFurnitureManager")
local EnmFurnitureControlState = {
  Default = 0,
  Disable = -1,
  Idle = 1,
  Up = 2,
  Down = 3
}

function CreationFurnitureManager:Ctor(Panel)
  self.FurnitureCreationPanel = Panel
  self.FurnitureCreationEditor = FurnitureCreationEditor(Panel)
  self.World = UE4Helper.GetCurrentWorld()
  self.FurnitureBasingBoxView = nil
  self.BasingSocketName = nil
  self.FurnitureView = nil
  self.FurnitureRotatorByControl = UE.FRotator()
  self.FurnitureControlState = EnmFurnitureControlState.Default
  self.FurnitureViewBPClass = nil
  self.FurnitureViewBPClassRef = nil
  self.FurnitureRootView = nil
  self.LoadingFurnitureRequest = nil
  self.SequencePlayers = {}
  self.Sequences = {}
  self.SequenceRefs = {}
  self.LoadingSequencesRequests = {}
  self.bNeedPauseIdle = false
end

function CreationFurnitureManager:Release()
  self:InternalClearViews()
  self:InternalClearSequences()
  self.FurnitureCreationPanel = nil
end

function CreationFurnitureManager:InternalClearViews()
  self:InternalClearFurnitureView()
  self.FurnitureBasingBoxView = nil
  if self.FurnitureRootView and UE.UObject.IsValid(self.FurnitureRootView) then
    self.FurnitureRootView:K2_DestroyActor()
  end
  self.FurnitureRootView = nil
  if self.FurnitureManualRootView and UE.UObject.IsValid(self.FurnitureManualRootView) then
    self.FurnitureManualRootView:K2_DestroyActor()
  end
  self.FurnitureManualRootView = nil
end

function CreationFurnitureManager:InternalClearFurnitureView()
  if self.LoadingFurnitureRequest then
    NRCResourceManager:UnLoadRes(self.LoadingFurnitureRequest)
    self.LoadingFurnitureRequest = nil
  end
  if self.FurnitureView and UE.UObject.IsValid(self.FurnitureView) then
    for k, v in pairs(self.SequencePlayers) do
      if UE.UObject.IsValid(v) then
        v:RemoveBindingByTag("Furniture", self.FurnitureView)
      end
    end
    self.FurnitureView:K2_DestroyActor()
  end
  self.FurnitureView = nil
  self.FurnitureConf = nil
  self.FurnitureBPClassPath = nil
  self.FurnitureViewBPClass = nil
  self.FurnitureCreationEditor:ForceHide()
end

function CreationFurnitureManager:InternalClearSequences()
  for k, v in pairs(self.LoadingSequencesRequests) do
    NRCResourceManager:UnLoadRes(v)
  end
  self.LoadingSequencesRequests = nil
  for k, v in pairs(self.SequencePlayers) do
    v:K2_DestroyActor()
  end
  self.SequencePlayers = nil
  self.SequenceRefs = nil
  self.Sequences = nil
end

function CreationFurnitureManager:InitBasingBox(Box, SocketName)
  self.FurnitureBasingBoxView = Box
  self.BasingSocketName = SocketName
  self:PreloadSequencePlayer(HomeIndoorSandbox.Enum.Create_Idle_Sequence, self.ConditionPlayFurnitureIdleSequence)
  self:PreloadSequencePlayer(HomeIndoorSandbox.Enum.Create_Up_Sequence)
  self:PreloadSequencePlayer(HomeIndoorSandbox.Enum.Create_Down_Sequence)
end

function CreationFurnitureManager:PreloadSequencePlayer(AssetObjPath, Callback)
  if not AssetObjPath then
    return
  end
  
  local function OnSuc(_, Request, Asset)
    self.LoadingSequencesRequests[AssetObjPath] = nil
    if not Asset then
      self:ReportError("(Home)AssetLoadingFailed", "Sequence Asset==nil (%s)", AssetObjPath)
      return
    end
    if not UE.UObject.IsValid(Asset) then
      self:ReportError("(Home)AssetLoadingFailed", "Sequence Asset invalid (%s)", AssetObjPath)
      return
    end
    HomeIndoorSandbox:LogDebug("Sequence loaded", AssetObjPath, Asset)
    self.Sequences[AssetObjPath] = Asset
    self.SequenceRefs[AssetObjPath] = UnLua.Ref(Asset)
    if Callback then
      Callback(self)
    end
  end
  
  local function OnFailed(_, Request, Err)
    self.LoadingSequencesRequests[AssetObjPath] = nil
    self:ReportError("(Home)AssetLoadingFailed", "Cannot found(%s), Err(%s)", AssetObjPath, Err)
  end
  
  local Request = NRCResourceManager:LoadResAsync(self, AssetObjPath, 255, -1, OnSuc, OnFailed)
  self.LoadingSequencesRequests[AssetObjPath] = Request
end

function CreationFurnitureManager:ReportError(Tag, Fmt, ...)
  if not RocoEnv.IS_EDITOR then
    local Message = string.format(Fmt, ...)
    _G.NRCSDKManager:CrashSightReportExceptionWithReason(Tag, Message, debug.traceback())
  end
  HomeIndoorSandbox:Ensure(false, string.format(Tag .. "|" .. Fmt, ...))
end

function CreationFurnitureManager:GetBlueprintClassPath(Conf)
  if Conf then
    local Path = Conf.model
    if not string.EndsWith(Path, "_C") then
      local t = string.Split(Path, "/")
      if t then
        local name = t[#t]
        if string.find(name, ".") then
          return Path .. "_C"
        end
        return string.format("%s.%s_C", Path, name)
      end
    else
      return Path
    end
  end
end

function CreationFurnitureManager:InternalParseScale()
  local Context = self.FurnitureCreationEditor:GetContext()
  local Cache = Context and Context.Scale
  return (Cache or self.FurnitureConf.Funiture_ui_percentage or 5000) / 10000 / 10
end

function CreationFurnitureManager:InternalParseOffset()
  local Context = self.FurnitureCreationEditor:GetContext()
  local Cache = Context and Context.LocationString
  local LocString = Cache or self.FurnitureConf.Funiture_ui_init_location
  if LocString and "" ~= LocString then
    local Fields = string.split(LocString, ";")
    if math.tointeger(Fields[1]) and math.tointeger(Fields[2]) and math.tointeger(Fields[3]) then
      return UE.FVector(math.tointeger(Fields[1]) / 100, math.tointeger(Fields[2]) / 100, math.tointeger(Fields[3]) / 100)
    else
      return FVectorZero
    end
  else
    return FVectorZero
  end
end

function CreationFurnitureManager:InternalParseRotation()
  local Context = self.FurnitureCreationEditor:GetContext()
  local Cache = Context and Context.RotationString
  local RotString = Cache or self.FurnitureConf.Funiture_ui_init_rotation
  if RotString and "" ~= RotString then
    local Fields = string.split(RotString, ";")
    if math.tointeger(Fields[1]) and math.tointeger(Fields[2]) and math.tointeger(Fields[3]) then
      local Roll = math.tointeger(Fields[1]) / 100
      local Pitch = math.tointeger(Fields[2]) / 100
      local Yaw = math.tointeger(Fields[3]) / 100
      return UE.FRotator(Pitch, Yaw, Roll)
    else
      return FRotatorZero
    end
  else
    return FRotatorZero
  end
end

function CreationFurnitureManager:ToggleFurnitureView(FurnitureConf)
  if self.FurnitureConf == FurnitureConf or self.FurnitureConf and FurnitureConf and self.FurnitureConf.id == FurnitureConf.id then
    return
  end
  self:InternalClearFurnitureView()
  self.FurnitureConf = FurnitureConf
  self.FurnitureCreationEditor:ResetDebuggingFurniture()
  if not FurnitureConf then
    return
  end
  local BPClassPath = self:GetBlueprintClassPath(FurnitureConf)
  self.FurnitureBPClassPath = BPClassPath
  self.LoadingFurnitureRequest = NRCResourceManager:LoadResAsync(self, BPClassPath, 255, -1, self.OnFurnitureBPClassLoaded, self.OnFurnitureBPClassFailed, FPartial(self.OnFurnitureBPClassFailed, self))
end

function CreationFurnitureManager:OnFurnitureBPClassLoaded(Request, Asset)
  self.LoadingFurnitureRequest = nil
  if not Asset then
    self:ReportError("(Home)AssetLoadingFailed", "Furniture Asset==nil (%s)", Request.assetPath)
    return
  end
  if not UE.UObject.IsValid(Asset) then
    self:ReportError("(Home)AssetLoadingFailed", "Furniture Asset invalid (%s)", Request.assetPath)
    return
  end
  if not Asset:IsChildOf(UE.ANRCHomePlacementActor) then
    self:ReportError("(Home)AssetLoadingFailed", "Asset(%s) is not furniture", Asset:GetFullName())
    return
  end
  if not self.FurnitureBasingBoxView then
    return
  end
  if not UE.UObject.IsValid(self.World) then
    return
  end
  HomeIndoorSandbox:LogDebug("Furniture class loaded", Asset.assetPath, Asset)
  self.FurnitureViewBPClass = Asset
  self.FurnitureViewBPClassRef = UnLua.Ref(Asset)
  local Scale = self:InternalParseScale()
  local Offset = self:InternalParseOffset()
  local Rotator = self:InternalParseRotation()
  local RootTransform = UE.FTransform()
  if not self.FurnitureManualRootView then
    self.FurnitureManualRootView = self.World:SpawnActor(UE.AActor, RootTransform, UE.ESpawnActorCollisionHandlingMethod.AlwaysSpawn)
    self.FurnitureManualRootView:AddComponentByClass(UE.USceneComponent, false, RootTransform, false)
    self.FurnitureManualRootView:K2_AttachToComponent(self.FurnitureBasingBoxView.SkeletalMesh, self.BasingSocketName, UE4.EAttachmentRule.KeepRelative, UE4.EAttachmentRule.KeepRelative, UE4.EAttachmentRule.KeepRelative, false)
  end
  self.FurnitureManualRootView:K2_SetActorRelativeTransform(RootTransform, false, nil, false)
  if not self.FurnitureRootView then
    self.FurnitureRootView = self.World:SpawnActor(UE.AActor, RootTransform, UE.ESpawnActorCollisionHandlingMethod.AlwaysSpawn)
    self.FurnitureRootView:AddComponentByClass(UE.USceneComponent, false, RootTransform, false)
    self.FurnitureRootView:K2_AttachToActor(self.FurnitureManualRootView, nil, UE4.EAttachmentRule.KeepRelative, UE4.EAttachmentRule.KeepRelative, UE4.EAttachmentRule.KeepRelative, false)
  end
  self.FurnitureRootView:K2_SetActorRelativeTransform(RootTransform, false, nil, false)
  self.FurnitureRootInitTransform = RootTransform
  self.FurnitureView = self.World:SpawnActor(Asset, UE.FTransform(), UE.ESpawnActorCollisionHandlingMethod.AlwaysSpawn)
  if not self.FurnitureView then
    self:ReportError("SpawnActor", "Cannot spawn furniture actor by class(%s)", Asset:GetFullName())
    return
  end
  self.FurnitureView:K2_AttachToActor(self.FurnitureRootView, nil, UE4.EAttachmentRule.KeepRelative, UE4.EAttachmentRule.KeepRelative, UE4.EAttachmentRule.KeepRelative, false)
  self.FurnitureInitTransform = UE.FTransform(Rotator:ToQuat(), Offset, UE.FVector(Scale, Scale, Scale))
  self.FurnitureView:K2_SetActorRelativeTransform(self.FurnitureInitTransform, false, nil, false)
  self.FurnitureCreationEditor:ConditionShow()
  self:ConditionPlayFurnitureIdleSequence()
end

function CreationFurnitureManager:OnFurnitureBPClassFailed(Request, Err)
  self.LoadingFurnitureRequest = nil
  self:ReportError("(Home)AssetLoadingFailed", "Furniture Class Loading Failed, Path=%s, Err=%s", Request.assetPath, Err)
end

function CreationFurnitureManager:ConditionPlayFurnitureSequence(Path, bForceLoadRequire, OnFinish)
  for k, v in pairs(self.SequencePlayers) do
    v:GetSequencePlayer():Stop()
  end
  local LevelSequence = self.Sequences[Path]
  if not LevelSequence and bForceLoadRequire then
    NRCResourceManager:UnLoadRes(self.LoadingSequencesRequests[Path])
    self.LoadingSequencesRequests[Path] = nil
    LevelSequence = UE.UObject.Load(Path)
    if LevelSequence and not LevelSequence:IsChildOf(UE.ULevelSequence) then
      LevelSequence = nil
      self:ReportError("(Home)AssetLoadingFailed", "Cannot create level sequence force. (%s)", Path)
    end
    self.Sequences[Path] = LevelSequence
    self.SequenceRefs[Path] = LevelSequence and UnLua.Ref(LevelSequence)
  end
  if not LevelSequence or not self.FurnitureView then
    return
  end
  if not UE.UObject.IsValid(self.World) then
    return
  end
  if not UE.UObject.IsValid(LevelSequence) then
    HomeIndoorSandbox:Ensure(false, "invalid sequence", Path)
    return
  end
  if not UE.UObject.IsValid(self.FurnitureView) then
    HomeIndoorSandbox:Ensure(false, "invalid furniture view", Path)
    return
  end
  local levelSequenceActor = self.SequencePlayers[Path]
  if not levelSequenceActor or not UE.UObject.IsValid(levelSequenceActor) then
    local Settings = UE4.FMovieSceneSequencePlaybackSettings()
    Settings.bPauseAtEnd = Path ~= HomeIndoorSandbox.Enum.Create_Idle_Sequence
    levelSequenceActor = UE4.ULevelSequencePlayer.CreateLevelSequencePlayer(self.World, LevelSequence, Settings, nil)
    self.SequencePlayers[Path] = levelSequenceActor
  end
  if not levelSequenceActor then
    HomeIndoorSandbox:Ensure(false, "invalid sequence actor")
    return
  end
  local sequencePlayer = levelSequenceActor:GetSequencePlayer()
  if not sequencePlayer then
    HomeIndoorSandbox:Ensure(false, "invalid sequence player")
    return
  end
  levelSequenceActor:ResetBindings()
  levelSequenceActor:AddBindingByTag("Furniture", self.FurnitureRootView)
  if OnFinish then
    sequencePlayer.OnFinished:Clear()
    sequencePlayer.OnFinished:Add(self.FurnitureCreationPanel, function()
      HomeIndoorSandbox:LogDebug("Sequence finished", Path)
      OnFinish()
    end)
  end
  if Path == HomeIndoorSandbox.Enum.Create_Idle_Sequence then
    if not self.bNeedPauseIdle then
      sequencePlayer:PlayLooping(-1)
    end
  else
    sequencePlayer:Play()
  end
  HomeIndoorSandbox:LogDebug("Sequence played", Path)
  return true
end

function CreationFurnitureManager:OnTouchStart()
  if not self.bNeedPauseIdle then
    self.bNeedPauseIdle = true
    local levelSequenceActor = self.SequencePlayers[HomeIndoorSandbox.Enum.Create_Idle_Sequence]
    if levelSequenceActor and UE.UObject.IsValid(levelSequenceActor) then
      local sequencePlayer = levelSequenceActor:GetSequencePlayer()
      sequencePlayer:Pause()
      Log.Debug("Pause")
    end
  end
end

function CreationFurnitureManager:RotateFurniture(DeltaYaw)
  if self.FurnitureManualRootView and UE.UObject.IsValid(self.FurnitureManualRootView) then
    self.FurnitureRotatorByControl.Yaw = DeltaYaw
    self.FurnitureManualRootView:K2_AddActorLocalRotation(self.FurnitureRotatorByControl, false, nil, false)
  end
end

function CreationFurnitureManager:OnTouchEnd()
  self:CancelRotateFurniture()
end

function CreationFurnitureManager:CancelRotateFurniture()
  Log.Debug("Cancel")
  if self.bNeedPauseIdle then
    self.bNeedPauseIdle = false
    if self.FurnitureControlState == EnmFurnitureControlState.Idle then
      local levelSequenceActor = self.SequencePlayers[HomeIndoorSandbox.Enum.Create_Idle_Sequence]
      if levelSequenceActor and UE.UObject.IsValid(levelSequenceActor) then
        local sequencePlayer = levelSequenceActor:GetSequencePlayer()
        sequencePlayer:PlayLooping(-1)
        Log.Debug("Play")
      end
    end
  end
end

function CreationFurnitureManager:OnFurnitureWorkStart()
  self.FurnitureControlState = EnmFurnitureControlState.Disable
  for k, v in pairs(self.SequencePlayers) do
    v:GetSequencePlayer():Stop()
  end
  if self.FurnitureView and UE.UObject.IsValid(self.FurnitureView) then
    self.FurnitureView:SetActorHiddenInGame(true)
    self.FurnitureView:K2_SetActorRelativeTransform(self.FurnitureInitTransform, false, nil, false)
    self.FurnitureRootView:K2_SetActorRelativeTransform(self.FurnitureRootInitTransform, false, nil, false)
    self.FurnitureManualRootView:K2_SetActorRelativeTransform(self.FurnitureRootInitTransform, false, nil, false)
  end
end

function CreationFurnitureManager:OnFurnitureWorkEnd()
  if self.FurnitureView and UE.UObject.IsValid(self.FurnitureView) then
    self.FurnitureView:SetActorHiddenInGame(false)
  end
  self:ConditionPlayFurnitureUpSequence()
end

function CreationFurnitureManager:OnFurnitureCreateFinishConfirm()
  self:ConditionPlayFurnitureDownSequence()
end

function CreationFurnitureManager:ConditionPlayFurnitureIdleSequence()
  if self.FurnitureControlState ~= EnmFurnitureControlState.Default and self.FurnitureControlState ~= EnmFurnitureControlState.Idle then
    return
  end
  if self:ConditionPlayFurnitureSequence(HomeIndoorSandbox.Enum.Create_Idle_Sequence) then
    self.FurnitureControlState = EnmFurnitureControlState.Idle
  end
end

function CreationFurnitureManager:ConditionPlayFurnitureUpSequence()
  if self.FurnitureControlState ~= EnmFurnitureControlState.Disable then
    return
  end
  self:ConditionPlayFurnitureSequence(HomeIndoorSandbox.Enum.Create_Up_Sequence, true)
  self.FurnitureControlState = EnmFurnitureControlState.Up
end

function CreationFurnitureManager:ConditionPlayFurnitureDownSequence()
  if self.FurnitureControlState ~= EnmFurnitureControlState.Up then
    return
  end
  self.FurnitureControlState = EnmFurnitureControlState.Down
  
  local function OnFinish()
    self.FurnitureControlState = EnmFurnitureControlState.Default
    self:ConditionPlayFurnitureIdleSequence()
  end
  
  self:ConditionPlayFurnitureSequence(HomeIndoorSandbox.Enum.Create_Down_Sequence, true, OnFinish)
end

return CreationFurnitureManager
