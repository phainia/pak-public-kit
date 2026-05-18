local HeadIconModuleEvent = require("NewRoco.Modules.System.HeadIcon.HeadIconModuleEvent")
local ENUM_PLAYER_DATA_EVENT = require("Data.Global.PlayerDataEvent")
local HeadIconModule = NRCModuleBase:Extend("HeadIconModule")
local HEAD_ICON_SAVE_DATA = "HeadIconSaveData"

function HeadIconModule:OnConstruct()
  _G.NRCEventCenter:RegisterEvent("HeadIconModule", self, _G.NRCGlobalEvent.ON_LOGIN, self.OnLogin)
  _G.DataModelMgr.PlayerDataModel:AddEventListener(self, ENUM_PLAYER_DATA_EVENT.ON_CARD_INFO_CHANGED, self.OnCardInfoChanged)
  self.CallBackOwner = nil
  self.OnSuccessCallback = nil
  self.OnFailedCallback = nil
end

function HeadIconModule:OnDestruct()
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_LOGIN, self.OnLogin)
  _G.DataModelMgr.PlayerDataModel:RemoveEventListener(self, ENUM_PLAYER_DATA_EVENT.ON_CARD_INFO_CHANGED, self.OnCardInfoChanged)
end

function HeadIconModule:OnCardInfoChanged()
  self:Log("HeadIconModule:OnCardInfoChanged")
  if self.SaveData and self.SaveData:IsValid() then
    self:Internal_TryLoadHeadIcon()
  else
    self:LogWarning("SaveData is null or invalid in OnCardInfoChanged")
  end
end

local function OnAsyncLoadSaveGameSlotFinish(self, saveData, bResult)
  Log.Info("HeadIconModule:OnAsyncLoadSaveGameSlotFinish", bResult)
  if bResult then
    self.SaveData = saveData
    self.SaveData_Ref = UnLua.Ref(self.SaveData)
    self:OnLoadSaveDataSuccess()
  else
    Log.Warning("HeadIconModule:OnAsyncLoadSaveGameSlotFinish failed")
  end
  self:CleanupAsyncSaveGameHandle()
end

function HeadIconModule:OnActive()
  Log.Info("HeadIconModule:OnActive")
  self.PendingReqs = {}
  if UE.UAsyncSaveGameHandle then
    if not UEPath.HEADICON_SAVE_GAME or UEPath.HEADICON_SAVE_GAME == "" then
      Log.Error("HeadIconModule:OnActive HEADICON_SAVE_GAME path is invalid")
      return
    end
    if self.AsyncSaveGameHandle and self.AsyncSaveGameHandle:IsValid() then
      self.AsyncSaveGameHandle.Completed:Clear()
      UnLua.Unref(self.AsyncSaveGameHandle)
      self.AsyncSaveGameHandle = nil
    end
    if self.SaveData and self.SaveData:IsValid() then
      UnLua.Unref(self.SaveData)
      self.SaveData = nil
    end
    self.SaveData_Ref = nil
    self.AsyncSaveGameHandle = NewObject(UE.UAsyncSaveGameHandle, UE.UNRCPlatformGameInstance.GetInstance(), HEAD_ICON_SAVE_DATA)
    if not self.AsyncSaveGameHandle or not self.AsyncSaveGameHandle:IsValid() then
      Log.Error("HeadIconModule:OnActive Failed to create AsyncSaveGameHandle")
      return
    end
    self.AsyncSaveGameHandle_Ref = UnLua.Ref(self.AsyncSaveGameHandle)
    self.AsyncSaveGameHandle.Completed:Add(self.AsyncSaveGameHandle, function(_, saveData, bResult)
      OnAsyncLoadSaveGameSlotFinish(self, saveData, bResult)
    end)
    self.AsyncSaveGameHandle:AsyncLoadByRawClassPath(UEPath.HEADICON_SAVE_GAME, HEAD_ICON_SAVE_DATA)
  end
end

function HeadIconModule:CleanupAsyncSaveGameHandle()
  if self.AsyncSaveGameHandle and self.AsyncSaveGameHandle:IsValid() then
    self.AsyncSaveGameHandle.Completed:Clear()
    UnLua.Unref(self.AsyncSaveGameHandle)
    self.AsyncSaveGameHandle = nil
  end
  self.AsyncSaveGameHandle_Ref = nil
end

function HeadIconModule:OnDeactive()
  Log.Info("HeadIconModule:OnDeactive")
  self:CallOnLoadHeadIconAsyncFailedCallback()
  for sessionId, reqAsync in pairs(self.PendingReqs) do
    _G.NRCResourceManager:UnLoadRes(reqAsync)
  end
  self.PendingReqs = {}
  self:CleanupAsyncSaveGameHandle()
  if self.SaveData and self.SaveData:IsValid() then
    UnLua.Unref(self.SaveData)
    self.SaveData = nil
  end
  self.SaveData_Ref = nil
  self.CallBackOwner = nil
  self.OnFailedCallback = nil
  self.OnSuccessCallback = nil
end

function HeadIconModule:TryGetExternalSavedHeadIconFilePath(caller, onSuccessCallback, onFailedCallback)
  self.CallBackOwner = caller
  self.OnSuccessCallback = onSuccessCallback
  self.OnFailedCallback = onFailedCallback
  if self.SaveData and self.SaveData:IsValid() then
    self:Internal_TryLoadHeadIcon()
  else
    self:LogWarning("SaveData is null or invalid in TryGetExternalSavedHeadIconFilePath")
    self:CleanupAsyncSaveGameHandle()
    self.SaveData = UE4.UGameplayStatics.LoadGameFromSlot(HEAD_ICON_SAVE_DATA, 0)
    if self.SaveData and self.SaveData:IsValid() then
      self:Internal_TryLoadHeadIcon()
    else
      self:LogError("HeadIconModule:TryGetExternalSavedHeadIconFilePath Failed due to invalid SaveData")
      self:CallOnLoadHeadIconAsyncFailedCallback()
    end
  end
end

function HeadIconModule:OnLoadSaveDataSuccess()
  local isLogin = _G.NRCModuleManager:DoCmd(_G.OnlineModuleCmd.GetLoginState)
  self:Log("HeadIconModule:OnLoadSaveDataSuccess isLogin ", isLogin)
end

function HeadIconModule:OnLogin()
  self:Log("HeadIconModule:OnLogin")
end

function HeadIconModule:CallOnLoadHeadIconAsyncSuccessCallback()
  self:Log("HeadIconModule:CallOnLoadHeadIconAsyncSuccessCallback")
  local PlayerInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerInfo().brief_info
  if not PlayerInfo then
    self:LogError("HeadIconModule:CallOnLoadHeadIconAsyncFailedCallback Failed due to invalid PlayerInfo")
    return
  end
  local headIconPath = self:GetHeadIconPath()
  _G.NRCEventCenter:DispatchEvent(HeadIconModuleEvent.LoadHeadIconSuccess, PlayerInfo.openid, headIconPath)
  local onSuccessCallback = self.OnSuccessCallback
  local callbackOwner = self.CallBackOwner
  self.OnSuccessCallback = nil
  self.CallBackOwner = nil
  if onSuccessCallback then
    if callbackOwner then
      onSuccessCallback(callbackOwner, PlayerInfo.openid, headIconPath)
    else
      onSuccessCallback(PlayerInfo.openid, headIconPath)
    end
  end
end

function HeadIconModule:CallOnLoadHeadIconAsyncFailedCallback()
  self:Log("HeadIconModule:CallOnLoadHeadIconAsyncFailedCallback")
  local PlayerInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerInfo().brief_info
  if not PlayerInfo then
    self:LogError("HeadIconModule:CallOnLoadHeadIconAsyncFailedCallback Failed due to invalid PlayerInfo")
    return
  end
  _G.NRCEventCenter:DispatchEvent(HeadIconModuleEvent.LoadHeadIconFailed, PlayerInfo.openid)
  local onFailedCallback = self.OnFailedCallback
  local callbackOwner = self.CallBackOwner
  if onFailedCallback and callbackOwner then
    onFailedCallback(callbackOwner, PlayerInfo.openid)
  end
end

function HeadIconModule:Internal_TryLoadHeadIcon()
  self:Log("HeadIconModule:TryLoadHeadIcon")
  if not self.SaveData or not self.SaveData:IsValid() then
    self:Log("HeadIconModule:TryLoadHeadIcon Failed due to invalid SaveData")
    self:CallOnLoadHeadIconAsyncFailedCallback()
    return
  end
  if self:CheckHeadIconAlreadyExists() then
    self:Log("HeadIconModule:TryLoadHeadIcon HeadIcon Already Exists")
    self:CallOnLoadHeadIconAsyncSuccessCallback()
    return
  end
  local HeadIconFilePath = self:GetHeadIconPath()
  if UE4.UBlueprintPathsLibrary.FileExists(HeadIconFilePath) then
    UE4.UNRCStatics.DeleteToFile(HeadIconFilePath)
  end
  self:LoadHeadIconAsync()
end

function HeadIconModule:CheckHeadIconAlreadyExists()
  self:Log("HeadIconModule:CheckHeadIconAlreadyExists")
  if not self.SaveData or not self.SaveData:IsValid() then
    self:LogError("HeadIconModule:CheckHeadIconAlreadyExists Failed due to invalid SaveData")
    return false
  end
  local PlayerInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerInfo().brief_info
  if not PlayerInfo then
    self:LogError("PlayerInfo is null")
    return false
  end
  if not (PlayerInfo.openid and self.SaveData.OpenID) or PlayerInfo.openid ~= self.SaveData.OpenID then
    self:Log("HeadIconModule:CheckHeadIconAlreadyExists OpenID not match PlayerInfo.openid ", PlayerInfo.openid, " self.SaveData.OpenID ", self.SaveData.OpenID)
    return false
  end
  local CardInfo = PlayerInfo.additional_data.card_brief_info
  if not CardInfo then
    self:LogError("CardInfo is null")
    return false
  end
  local CardIconConf = _G.DataConfigManager:GetCardIconConf(CardInfo.card_icon_selected)
  if not CardIconConf then
    self:LogError("CardIconConf is nil for ", CardInfo.card_icon_selected)
    return false
  end
  local HeadIconFilePath = self:GetHeadIconPath()
  if HeadIconFilePath ~= self.SaveData.HeadIconFilePath then
    self:Log("HeadIconModule:CheckHeadIconAlreadyExists HeadIconFilePath not match", HeadIconFilePath, self.SaveData.HeadIconFilePath)
    return false
  end
  if not UE4.UBlueprintPathsLibrary.FileExists(HeadIconFilePath) then
    self:Log("HeadIconModule:CheckHeadIconAlreadyExists HeadIconFilePath not exists", HeadIconFilePath)
    return false
  end
  local localFileMD5 = UE.UNRCStatics.HashFileMD5(HeadIconFilePath)
  if localFileMD5 ~= self.SaveData.HeadIconMD5 then
    self:Log("HeadIconModule:CheckHeadIconAlreadyExists HeadIconMD5 not match", localFileMD5, self.SaveData.HeadIconMD5)
    return false
  end
  local currentUTCTS = UE.UNRCStatics.GetUTCTimestampMS()
  if self.SaveData.LastModifyTimestamp and 0 ~= self.SaveData.LastModifyTimestamp and currentUTCTS - self.SaveData.LastModifyTimestamp < 0 then
    self:Log("HeadIconModule:CheckHeadIconAlreadyExists invalid modified ts", currentUTCTS, self.SaveData.LastModifyTimestamp)
    return false
  end
  return true
end

function HeadIconModule:LoadHeadIconAsync()
  self:Log("HeadIconModule:LoadHeadIconAsync")
  if not self.SaveData or not self.SaveData:IsValid() then
    self:LogError("HeadIconModule:TryLoadHeadIcon Failed due to invalid SaveData")
    self:CallOnLoadHeadIconAsyncFailedCallback()
    return
  end
  local PlayerInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerInfo().brief_info
  local CardInfo = PlayerInfo.additional_data.card_brief_info
  if not CardInfo then
    self:LogError("CardInfo is null")
    self:CallOnLoadHeadIconAsyncFailedCallback()
    return
  end
  local CardIconConf = _G.DataConfigManager:GetCardIconConf(CardInfo.card_icon_selected)
  if not CardIconConf then
    self:LogError("CardIconConf is null")
    self:CallOnLoadHeadIconAsyncFailedCallback()
    return
  end
  local PlayerOpenID = PlayerInfo.openid
  if self.PendingReqs[PlayerOpenID] ~= nil then
    _G.NRCResourceManager:UnLoadRes(self.PendingReqs[PlayerOpenID])
    self.PendingReqs[PlayerOpenID] = nil
  end
  local AvatarPath = CardIconConf.icon_resource_path
  AvatarPath = string.format("%s%s.%s'", "Texture2D'/Game/NewRoco/Modules/System/Common/Icon/BigHeadIcon256/", AvatarPath, AvatarPath)
  self:Log("HeadIconModule:OnLogin AsyncLoad HeadIconPath : ", AvatarPath)
  local reqAsync = _G.NRCResourceManager:LoadResAsync(self, AvatarPath, PriorityEnum.UI_LoadRes_Default, -1, function(caller, resRequest, asset)
    self:Log("HeadIconModule:OnLoadHeadIconAsyncSuccess ", resRequest.assetPath)
    local HeadIconFilePath = caller:GetHeadIconPath()
    caller.PendingReqs[PlayerOpenID] = nil
    _G.NRCResourceManager:UnLoadRes(resRequest)
    if not UE.UPlatformImageLibrary.SaveTextureAsFile(UE4Helper.GetCurrentWorld(), asset, UE.FVector2D(asset:Blueprint_GetSizeX(), asset:Blueprint_GetSizeY()), UE.FVector2D(0, 0), UE.FVector2D(1.0, 1.0), HeadIconFilePath) then
      self:CallOnLoadHeadIconAsyncFailedCallback()
    else
      if UE4.UBlueprintPathsLibrary.FileExists(HeadIconFilePath) then
        self.SaveData.OpenID = PlayerOpenID
        self.SaveData.HeadIconFilePath = HeadIconFilePath
        self.SaveData.HeadIconMD5 = UE.UNRCStatics.HashFileMD5(HeadIconFilePath)
        UE4.UGameplayStatics.SaveGameToSlot(self.SaveData, HEAD_ICON_SAVE_DATA, 0)
      end
      self:CallOnLoadHeadIconAsyncSuccessCallback()
    end
  end, function(caller, resRequest, errMsg)
    self:Log("HeadIconModule:OnLoadHeadIconAsyncFailed ", resRequest.assetPath, errMsg)
    caller.PendingReqs[PlayerOpenID] = nil
    _G.NRCResourceManager:UnLoadRes(resRequest)
    self:CallOnLoadHeadIconAsyncFailedCallback()
  end)
  self.PendingReqs[PlayerOpenID] = reqAsync
end

function HeadIconModule:GetHeadIconPath()
  local PlayerInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerInfo().brief_info
  if not PlayerInfo then
    self:LogError("PlayerInfo is null")
    return
  end
  local CardInfo = PlayerInfo.additional_data.card_brief_info
  if not CardInfo then
    self:LogError("CardInfo is null")
    return
  end
  local CardIconConf = _G.DataConfigManager:GetCardIconConf(CardInfo.card_icon_selected)
  if not CardIconConf then
    self:LogError("CardIconConf is nil for ", CardInfo.card_icon_selected)
    return
  end
  local icon_resource_path = CardIconConf.icon_resource_path
  local headIconPersistentPath = UE.UBlueprintPathsLibrary.Combine({
    UE4.UBlueprintPathsLibrary.ProjectPersistentDownloadDir(),
    "HeadIcons"
  })
  local SaveDir = UE4.UBlueprintPathsLibrary.ProjectSavedDir()
  local ProjDir = UE4.UBlueprintPathsLibrary.ProjectDir()
  local ProjectUserDir = UE4.UBlueprintPathsLibrary.ProjectUserDir()
  local RootDir = UE4.UBlueprintPathsLibrary.RootDir()
  local RelativePath = string.format("%s/%s_%s.png", headIconPersistentPath, PlayerInfo.openid, icon_resource_path)
  local FullPath = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(RelativePath)
  self:Log("SaveDir ", SaveDir, " ProjDir ", ProjDir, " ProjectUserDir ", ProjectUserDir, " RootDir ", RootDir, "headIconPersistentPath ", headIconPersistentPath)
  self:Log("HeadIconModule:GetHeadIconPath RelativePath ", RelativePath, " FullPath ", FullPath)
  return FullPath
end

return HeadIconModule
