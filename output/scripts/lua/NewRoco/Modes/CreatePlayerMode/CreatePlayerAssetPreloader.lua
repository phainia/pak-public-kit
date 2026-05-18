local CreatePlayerAssetPreloader = NRCClass("NRCBigWorldPreloader")

function CreatePlayerAssetPreloader:Ctor()
  self.PreloadAssetList = {}
  self.PreloadAssetList[UEPath.CREATEPLAYER_ENTER] = UEPath.CREATEPLAYER_ENTER
  self.PreloadAssetList[UEPath.LOGIN_ENTER] = UEPath.LOGIN_ENTER
  self.PreloadAssetList[UEPath.GENDER_CONFIRM_ENTER_FEMALE] = UEPath.GENDER_CONFIRM_ENTER_FEMALE
  self.PreloadAssetList[UEPath.GENDER_CONFIRM_IDLE_FEMALE] = UEPath.GENDER_CONFIRM_IDLE_FEMALE
  self.PreloadAssetList[UEPath.NAME_CONFIRM_ENTER_FEMALE] = UEPath.NAME_CONFIRM_ENTER_FEMALE
  self.PreloadAssetList[UEPath.NAME_CONFIRM_IDLE_FEMALE] = UEPath.NAME_CONFIRM_IDLE_FEMALE
  self.PreloadAssetList[UEPath.NAME_CONFIRM_END_FEMALE] = UEPath.NAME_CONFIRM_END_FEMALE
  self.PreloadAssetList[UEPath.GENDER_CONFIRM_ENTER_MALE] = UEPath.GENDER_CONFIRM_ENTER_MALE
  self.PreloadAssetList[UEPath.GENDER_CONFIRM_IDLE_MALE] = UEPath.GENDER_CONFIRM_IDLE_MALE
  self.PreloadAssetList[UEPath.NAME_CONFIRM_ENTER_MALE] = UEPath.NAME_CONFIRM_ENTER_MALE
  self.PreloadAssetList[UEPath.NAME_CONFIRM_IDLE_MALE] = UEPath.NAME_CONFIRM_IDLE_MALE
  self.PreloadAssetList[UEPath.NAME_CONFIRM_END_MALE] = UEPath.NAME_CONFIRM_END_MALE
  self.PreloadAssetList[UEPath.RESTORE_CAMERA_CURVE] = UEPath.RESTORE_CAMERA_CURVE
  self.PreloadAssetList[UEPath.LOGIN_PLAYER_AVATAR_MALE] = UEPath.LOGIN_PLAYER_AVATAR_MALE
  self.PreloadAssetList[UEPath.LOGIN_PLAYER_AVATAR_FAMALE] = UEPath.LOGIN_PLAYER_AVATAR_FAMALE
  self.PreloadAssetList[UEPath.LOGIN_LEVELSEQUENCEACTOR] = UEPath.LOGIN_LEVELSEQUENCEACTOR
  self.PreloadAssetList[UEPath.LOGIN_NPC_SPAWNER] = UEPath.LOGIN_NPC_SPAWNER
  if RocoEnv.IS_EDITOR then
    self.PreloadAssetList.DialogueStage = "/Game/Editor/Dialogue/BP_DialogueStageActor.BP_DialogueStageActor_C"
  end
  self.Requests = {}
  self.LoadedAssets = {}
  self.LoadedAssetsRef = {}
  self.CallbackOwner = nil
  self.Callback = nil
  self.StartTime = -1
end

function CreatePlayerAssetPreloader:Get(Key)
  local Asset = self.LoadedAssets[Key]
  if NRCEnv:IsLocalMode() and not Asset then
    Asset = UE.UObject.Load(Key)
    self.LoadedAssets[Key] = Asset
    self.LoadedAssetsRef[Key] = Asset and UnLua.Ref(Asset)
  end
  return Asset
end

function CreatePlayerAssetPreloader:StartPreload(CallbackOwner, Callback)
  if self.Callback or self.CallbackOwner then
    Log.Error("NRCBigWorldPreloader\229\156\168\232\181\132\230\186\144\229\133\168\233\131\168\229\138\160\232\189\189\229\174\140\230\136\144\229\137\141\229\143\136\233\135\141\229\164\141\229\143\145\232\181\183\228\186\134\229\138\160\232\189\189...")
    if Callback then
      if CallbackOwner then
        Callback(CallbackOwner)
      else
        Callback()
      end
    end
    return
  end
  self.CallbackOwner = CallbackOwner
  self.Callback = Callback
  self.StartTime = os.msTime()
  ::lbl_28::
  self.avatarSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(UE4Helper.GetCurrentWorld(), UE.UAvatarSubsystem)
  if self.avatarSystem then
    self.avatarSystem:PreLoadAvatarConfigAsync({
      self.avatarSystem,
      SimpleDelegateFactory:CreateCallback(self, function()
        self.OnLoadAvatarAssets(self)
      end)
    })
    goto lbl_58
    goto lbl_56
    goto lbl_28
  end
  ::lbl_56::
  self:OnLoadAvatarAssets()
  ::lbl_58::
end

function CreatePlayerAssetPreloader:OnLoadAvatarAssets()
  Log.Debug("CreatePlayerAssetPreloader:OnLoadAvatarAssets")
  for Name, Path in pairs(self.PreloadAssetList) do
    self.Requests[Name] = _G.NRCResourceManager:LoadResAsync(self, Path, 0, 0, self.OnLoadSuccess, self.OnLoadFailed)
  end
  self:CheckFinish()
end

function CreatePlayerAssetPreloader:OnLoadSuccess(Request, Res)
  local Path = Request.assetPath
  local Name = table.getKeyName(self.PreloadAssetList, Path)
  self.LoadedAssets[Name] = Res
  self.LoadedAssetsRef[Name] = Res and UnLua.Ref(Res)
  self:CheckFinish()
end

function CreatePlayerAssetPreloader:OnLoadFailed(Request, Message)
  Log.Warning("\233\162\132\229\138\160\232\189\189\232\181\132\230\186\144\229\164\177\232\180\165", Message)
  _G.NRCResourceManager:UnLoadRes(Request)
  self.Requests[Request.assetPath] = nil
  self:CheckFinish()
end

function CreatePlayerAssetPreloader:CheckFinish()
  local TotalCount = table.len(self.Requests)
  local CurrentCount = table.len(self.LoadedAssets)
  local Done = TotalCount <= CurrentCount
  local Diff = os.msTime() - self.StartTime
  if Done then
    Log.Debug("\233\162\132\229\138\160\232\189\189\229\133\168\229\177\128\232\181\132\230\186\144", TotalCount, "\232\128\151\230\151\182", Diff / 1000)
    self:FireCallback()
  else
    Log.Debug("\230\173\163\229\156\168\233\162\132\229\138\160\232\189\189\229\133\168\229\177\128\232\181\132\230\186\144", TotalCount, CurrentCount, Diff / 1000)
  end
end

function CreatePlayerAssetPreloader:FireCallback()
  local Owner = self.CallbackOwner
  local Callback = self.Callback
  self.CallbackOwner = nil
  self.Callback = nil
  if not Callback then
    return
  end
  if Owner then
    Callback(Owner)
  else
    Callback()
  end
end

return CreatePlayerAssetPreloader
