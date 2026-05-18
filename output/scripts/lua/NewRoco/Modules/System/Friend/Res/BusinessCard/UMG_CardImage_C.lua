local FriendModuleEvent = require("NewRoco.Modules.System.Friend.FriendModuleEvent")
local FriendEnum = require("NewRoco.Modules.System.Friend.FriendEnum")
local UIUtils = require("NewRoco.Utils.UIUtils")
local UMG_CardImage_C = _G.NRCViewBase:Extend("UMG_CardImage_C")

function UMG_CardImage_C:OnConstruct()
  self.player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  self.gender = self.player.gender
  self.camera = nil
  self.camera1 = nil
  self.captureComponent = nil
  self.captureComponent1 = nil
  self.PlayerActor = nil
  self.CurrentName = nil
  self.CardAdminFriendType = nil
  self.PlayerCardBriefInfo = nil
  self.panelName = nil
  self:InitSceneCapture()
  self:OnAddEventListener()
end

function UMG_CardImage_C:SetCardAdminFriendType(_CardAdminFriendType)
  self.CardAdminFriendType = _CardAdminFriendType
end

function UMG_CardImage_C:SetPlayerCardBriefInfo(_PlayerCardBriefInfo)
  self.PlayerCardBriefInfo = _PlayerCardBriefInfo
end

function UMG_CardImage_C:SetCardEntranceType(_CardEntranceType)
  self.CardEntranceType = _CardEntranceType
end

function UMG_CardImage_C:SetGender(_gender)
  self.gender = _gender
end

function UMG_CardImage_C:OnDestruct()
  if self.captureComponent and not UIUtils.RemoveImageRTNoUse(self.captureComponent.TextureTarget, self) then
    UE4.UNRCStatics.ChangeTextureToCustomSize(self.captureComponent.TextureTarget, 1, 1)
  end
  self.player = nil
  self.camera = nil
  self.camera1 = nil
  self.captureComponent = nil
  self.captureComponent1 = nil
  if self.PlayerActor and self.PlayerActor:IsValid() then
    if self.PlayerActor.Mesh then
      self.PlayerActor.Mesh:Release()
    end
    self.previewWorld:DestroyActor(self.PlayerActor)
    self.PlayerActor:Release()
  end
  self.PlayerActor = nil
  self:OnRemoveEventListener()
end

function UMG_CardImage_C:SetPlayerAppearanceInfo(CardEntrance)
  local fashionIds = self.player:GetFashionIds()
  local salonIds = self.player:GetSalonIds()
  if CardEntrance ~= FriendEnum.CardEntrance.ImageEditorPanel then
    local CardBriefInfo
    if self.CardAdminFriendType == FriendEnum.AdminFriendType.Own then
      CardBriefInfo = _G.DataModelMgr.PlayerDataModel:GetCardBriefInfo()
    else
      CardBriefInfo = self.PlayerCardBriefInfo
    end
    fashionIds = CardBriefInfo.card_appearance_info and CardBriefInfo.card_appearance_info.fashion_wear_id
    salonIds = CardBriefInfo.card_appearance_info and CardBriefInfo.card_appearance_info.salon_item_data
    Log.Dump(CardBriefInfo, 6, "UMG_CardImage_C:SetPlayerAppearanceInfo")
  end
  _G.NRCModeManager:DoCmd(FriendModuleCmd.SetDefaultSuit, self.PlayerActor, self.gender, fashionIds, salonIds, CardEntrance, self.panelName)
end

function UMG_CardImage_C:SetScaleAndLocation(Scale, Location)
  if self.PlayerActor then
    self.PlayerActor:SetActorScale3D(Scale)
    self.PlayerActor:Abs_K2_SetActorLocation_WithoutHit(Location)
  end
end

function UMG_CardImage_C:IsHiddenInGame(_IsHidden)
  self.PlayerActor:SetActorHiddenInGame(_IsHidden)
end

function UMG_CardImage_C:OnActive()
end

function UMG_CardImage_C:OnDeactive()
end

function UMG_CardImage_C:OnAddEventListener()
  self:RegisterEvent(self, FriendModuleEvent.SwitchAvatarSuitComplete, self.OnSwitchAvatarSuitComplete)
end

function UMG_CardImage_C:OnRemoveEventListener()
  self:UnRegisterEvent(self, FriendModuleEvent.SwitchAvatarSuitComplete)
end

function UMG_CardImage_C:InitSceneCapture()
  self.camera = self.previewWorld:getActorByName("DefaultSceneCapture_zong")
  self.captureComponent = self.camera:GetComponentByClass(UE4.USceneCaptureComponent2D)
  self.previewWorld:SetCapturePostProcessing(self.captureComponent)
  UE4.UNRCStatics.ChangeTextureToMatchScreen(self.captureComponent.TextureTarget, UE4Helper.GetCurrentWorld(), 1)
  UIUtils.AddImageRTInUse(self.captureComponent.TextureTarget, self)
end

function UMG_CardImage_C:ChaneTextureSize(X, Y)
  if self.captureComponent.TextureTarget then
    UE4.UNRCStatics.ChangeTextureToCustomSize(self.captureComponent.TextureTarget, X, Y)
  else
    Log.Error("UMG_CardImage_C.ChaneTextureSize: TextureTarget is nil")
  end
end

function UMG_CardImage_C:SetPlayerPath()
  if self.PlayerActor then
    self.previewWorld:DestroyActor(self.PlayerActor)
    self.PlayerActor = nil
  end
  if not self.module then
    Log.Error("module\230\178\161\230\156\137\230\137\190\229\136\176,\232\175\183\230\159\165\231\156\139\229\142\159\229\155\160")
    return
  end
  local CardLocalPlayer = self.module:GetRes("Blueprint'/Game/NewRoco/Modules/System/Friend/Raw/Player/BP_CardLocalPlayer.BP_CardLocalPlayer_C'", self.panelName)
  if not CardLocalPlayer then
    CardLocalPlayer = UE4.UClass.Load("Blueprint'/Game/NewRoco/Modules/System/Friend/Raw/Player/BP_CardLocalPlayer.BP_CardLocalPlayer_C'")
    if not CardLocalPlayer then
      Log.ErrorFormat("UMG_ChangeCard_C:SetPlayerPath \230\168\161\229\158\139\232\183\175\229\190\132\233\148\153\232\175\175")
      return
    end
  end
  local quat = UE4.FQuat.FromAxisAndAngle(UE4Helper.UpVector, 1.5)
  local Transfom = UE4.FTransform(quat, UE4.FVector(0, 0, 0), UE4.FVector(1, 1, 1))
  self.PlayerActor = self.previewWorld:SpawnActor(CardLocalPlayer, Transfom)
  self.captureComponent.showOnlyActors:Clear()
  local mesh = self.PlayerActor:GetComponentByClass(UE4.USkeletalMeshComponent)
  local AnimComponent = self.PlayerActor:GetComponentByClass(UE4.URocoAnimComponent)
  if 1 == self.gender then
    self:LoadResAsyncAnimClass(mesh, UEPath.ABP_CARD_PLAYER_MALE)
    self:LoadResAsyncAnimConfig(AnimComponent, UEPath.ANIM_CONFIG_MALE)
  elseif 2 == self.gender then
    self:LoadResAsyncAnimClass(mesh, UEPath.ABP_CARD_PLAYER_FEMALE)
    self:LoadResAsyncAnimConfig(AnimComponent, UEPath.ANIM_CONFIG_FEMALE)
  end
  _G.NRCAudioManager:SetListenerToSelf(self.PlayerActor)
  self:Log("UMG_CardImage_C:SetPlayerPath() Gender=", self.gender)
end

function UMG_CardImage_C:LoadResAsyncAnimClass(mesh, Path)
  local asset = self.module:GetRes(Path, self.panelName)
  asset = asset or UE4.UClass.Load(Path)
  mesh:SetAnimClass(asset)
end

function UMG_CardImage_C:LoadResAsyncAnimConfig(AnimComponent, Path)
  local asset = self.module:GetRes(Path, self.panelName)
  asset = asset or UE4.UClass.Load(Path)
  AnimComponent:SetAnimConfig(asset)
end

function UMG_CardImage_C:OnSwitchAvatarSuitComplete(CardEntrance)
  self:AddHeadWear()
  self:SetAnimInstance()
  self:SetShowOnlyActors(CardEntrance)
  if CardEntrance == FriendEnum.CardEntrance.MainPanel then
    self:PlayAnimaByTime()
  elseif CardEntrance == FriendEnum.CardEntrance.InformationEditorPanel then
    self:PlayAnimByNameInfo("Think")
  elseif CardEntrance == FriendEnum.CardEntrance.ImageEditorPanel then
    local DefaultPoseId = _G.NRCModuleManager:DoCmd(FriendModuleCmd.GetDefaultPoseId)
    local RoleplayBehaviorConf = _G.DataConfigManager:GetRoleplayBehaviorConf(DefaultPoseId)
    self:PlayAnimInfo(RoleplayBehaviorConf.card_pose_resource_path)
  elseif CardEntrance == FriendEnum.CardEntrance.Photograph then
    if _G.GlobalConfig.DebugOpenUI then
      return
    end
    local PhotographAppearanceInfo = _G.NRCModuleManager:DoCmd(FriendModuleCmd.GetPhotographAppearanceInfo)
    local PoseId = PhotographAppearanceInfo.pose_selected
    local PoseFrame = PhotographAppearanceInfo.pose_frame_id / 10000
    local RoleplayBehaviorConf = _G.DataConfigManager:GetRoleplayBehaviorConf(PoseId)
    local RocoAnimComponent = self.PlayerActor:GetComponentByClass(UE4.URocoAnimComponent)
    if RocoAnimComponent then
      Log.Debug(RoleplayBehaviorConf.card_pose_resource_path, PoseFrame, "UMG_CardImage_C:OnSwitchAvatarSuitComplete")
      RocoAnimComponent:PlayAnimByName(RoleplayBehaviorConf.card_pose_resource_path, 0, PoseFrame, 0, 0, -1, 0)
    end
  end
end

function UMG_CardImage_C:SetAnimInstance()
  if self.PlayerActor then
    local AnimComponent = self.PlayerActor:GetComponentByClass(UE4.URocoAnimComponent)
    if AnimComponent then
      AnimComponent:InitAnimInstance()
    end
  end
end

function UMG_CardImage_C:AddHeadWear()
  local AvatarComponent = self.PlayerActor:GetComponentByClass(UE4.UAvatarComponent)
  if AvatarComponent then
    local AActorS = AvatarComponent:GetDecorators()
    for i, Actor in ipairs(AActorS:ToTable()) do
      self.captureComponent.showOnlyActors:Add(Actor)
    end
  end
end

function UMG_CardImage_C:SetShowOnlyActors(CardEntrance)
  if self.PlayerActor and CardEntrance ~= FriendEnum.CardEntrance.Null then
    self:DelayFrames(2, function()
      Log.Debug("\229\187\182\230\151\182\228\184\164\229\184\167, showOnlyActors")
      self.captureComponent.showOnlyActors:Add(self.PlayerActor)
      self:DispatchEvent(FriendModuleEvent.ShowOnlyActorsSucceed, CardEntrance)
    end)
  end
end

function UMG_CardImage_C:SelectSuit(fashionIds, CardEntrance, salonIds)
  _G.NRCModeManager:DoCmd(FriendModuleCmd.SetDefaultSuit, self.PlayerActor, self.gender, fashionIds, salonIds, CardEntrance, self.panelName)
end

function UMG_CardImage_C:PlayAnimByNameInfo(AnimName)
  if self.PlayerActor then
    local RocoAnimComponent = self.PlayerActor:GetComponentByClass(UE4.URocoAnimComponent)
    if RocoAnimComponent then
      self.CurrentName = AnimName
      RocoAnimComponent:PlayAnimByName(AnimName, 0, 0, 0, 0, -1, 0)
    end
  end
end

function UMG_CardImage_C:PlayAnimInfo(AnimName)
  if self.PlayerActor then
    local RocoAnimComponent = self.PlayerActor:GetComponentByClass(UE4.URocoAnimComponent)
    if RocoAnimComponent then
      self.CurrentMontage = RocoAnimComponent:PrepareMontageByName(AnimName, "DefaultSlot", 0.0, 0.0, -1)
      self.CurrentName = AnimName
      RocoAnimComponent:PlayAnim(self.CurrentMontage, 1, 0, 0, 0, -1, 0)
    end
  end
end

function UMG_CardImage_C:PlayAnimaByTime()
  if self.PlayerActor and self.CardAdminFriendType then
    local CardBriefInfo
    if self.CardAdminFriendType == FriendEnum.AdminFriendType.Own then
      CardBriefInfo = _G.DataModelMgr.PlayerDataModel:GetCardBriefInfo()
    else
      CardBriefInfo = self.PlayerCardBriefInfo
    end
    local DefaultPoseId = _G.NRCModuleManager:DoCmd(FriendModuleCmd.GetDefaultPoseId)
    local PoseId = CardBriefInfo.card_appearance_info and CardBriefInfo.card_appearance_info.pose_selected or DefaultPoseId
    local PoseFrame = (CardBriefInfo.card_appearance_info and CardBriefInfo.card_appearance_info.pose_frame_id or 1000) / 10000
    local RoleplayBehaviorConf = _G.DataConfigManager:GetRoleplayBehaviorConf(PoseId)
    local RocoAnimComponent = self.PlayerActor:GetComponentByClass(UE4.URocoAnimComponent)
    if RocoAnimComponent then
      RocoAnimComponent:PlayAnimByName(RoleplayBehaviorConf.card_pose_resource_path, 0, PoseFrame, 0, 0, -1, 0)
    end
  end
end

function UMG_CardImage_C:GetAnimPosition()
  if self.PlayerActor and self.CurrentMontage then
    local RocoAnimComponent = self.PlayerActor:GetComponentByClass(UE4.URocoAnimComponent)
    if RocoAnimComponent then
      local AnimInstance = RocoAnimComponent:GetAnimInstance()
      local Position = string.format("%.4f", AnimInstance:Montage_GetPosition(self.CurrentMontage))
      Log.Debug(Position, "UMG_CardImage_C:GetAnimPosition")
      Position = math.floor(Position * 10000)
      Log.Debug(Position, "UMG_CardImage_C:GetAnimPosition")
      return Position
    end
  end
  return 0
end

function UMG_CardImage_C:GetAnimName()
  if self.CurrentName then
    return self.CurrentName
  end
end

function UMG_CardImage_C:OnPhotograph()
  if self.PlayerActor then
    local Position = self:GetAnimPosition()
    local RocoAnimComponent = self.PlayerActor:GetComponentByClass(UE4.URocoAnimComponent)
    if RocoAnimComponent then
      RocoAnimComponent:PlayAnimByName(self.CurrentName, 0, Position, 0, 0, -1, 0)
      Log.Debug(Position, self.CurrentName, "UMG_CardImage_C:OnPhotograph")
    end
  end
end

return UMG_CardImage_C
