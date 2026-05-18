local JsonUtils = require("Common.JsonUtils")
local LoginData = NRCData:Extend("LoginData")

function LoginData:Ctor()
  NRCData.Ctor(self)
  self:SetGEMState()
  self.openId = 0
  self.AccountInfo = {}
  self.tpns_token = ""
  local LoginEnum = require("NewRoco.Modes.LoginMode.LoginEnum")
  self.Conditions = {}
  for _, Condition in ipairs(LoginEnum.Conditions) do
    self.Conditions[Condition] = false
  end
  self.LauncherOverrideTDirUrlKey = nil
  self.CacheTDirUrlKey = nil
  self.curRegisterGender = ProtoEnum.ESexValue.SEX_NOT_SHOW
  self.bNeedDelayRotation = false
  local CachedConditions = JsonUtils.LoadSaved("LoginConditions", {})
  self.Conditions[LoginEnum.Conditions.SkipVideos] = CachedConditions[LoginEnum.Conditions.SkipVideos]
  self.Conditions[LoginEnum.Conditions.FirstTimeInstall] = CachedConditions[LoginEnum.Conditions.FirstTimeInstall]
  self.Conditions[LoginEnum.Conditions.AgreementsAccepted] = CachedConditions[LoginEnum.Conditions.AgreementsAccepted]
  self.Conditions[LoginEnum.Conditions.PermissionsAccepted] = CachedConditions[LoginEnum.Conditions.PermissionsAccepted]
  self.Conditions[LoginEnum.Conditions.LoginChannel] = CachedConditions[LoginEnum.Conditions.LoginChannel]
  self.Conditions[LoginEnum.Conditions.DevicePermitted] = true
  self.Conditions[LoginEnum.Conditions.IsOnIOS] = UE4.UNRCStatics.IsRunningOnIOS()
  self.Conditions[LoginEnum.Conditions.IsOnOpenHarmony] = UE4.UNRCStatics.IsRunningOnOpenHarmony()
  self.Conditions[LoginEnum.Conditions.IsFullPackage] = _G.AppMain.IsFullPackage()
  if not self.Conditions[LoginEnum.Conditions.IsFullPackage] then
    self.Conditions[LoginEnum.Conditions.IsFullPackage] = _G.AppMain.IsLocalSavedHasBasePaks()
  end
  self.Conditions[LoginEnum.Conditions.IfDownloadBasePaksWithoutLogin] = _G.AppMain.GetIfDownloadBasePaksWithoutLogin()
  if not UE4.UNRCStatics.IsRunningOnIOS() and not UE4.UNRCStatics.IsRunningOnAndroid() and not UE4.UNRCStatics.IsRunningOnOpenHarmony() then
    self.Conditions[LoginEnum.Conditions.LoginResCode] = -1
    if _G.AppMain:GetFormalPipeline() and RocoEnv.IS_SHIPPING then
      self.Conditions[LoginEnum.Conditions.UseWeGame] = true
    elseif nil ~= _G.App.launchParams.UseWeGame then
      self.Conditions[LoginEnum.Conditions.UseWeGame] = _G.App.launchParams.UseWeGame == "true"
    elseif nil ~= CachedConditions[LoginEnum.Conditions.UseWeGame] then
      self.Conditions[LoginEnum.Conditions.UseWeGame] = CachedConditions[LoginEnum.Conditions.UseWeGame]
    else
      self.Conditions[LoginEnum.Conditions.UseWeGame] = _G.App.launchParams.UseWeGame == "true"
    end
    if RocoEnv.PLATFORM_WINDOWS then
      local WeGameManager = UE4.UNRCPlatformGameInstance.GetInstance():GetSDKManager().WeGameManager
      self.Conditions[LoginEnum.Conditions.WeGameInitialized] = not self.Conditions[LoginEnum.Conditions.UseWeGame] or WeGameManager:CheckIfInitialized()
    end
    if nil ~= CachedConditions[LoginEnum.Conditions.IsOnPc] then
      self.Conditions[LoginEnum.Conditions.IsOnPc] = CachedConditions[LoginEnum.Conditions.IsOnPc]
    else
      self.Conditions[LoginEnum.Conditions.IsOnPc] = true
    end
  else
    self.Conditions[LoginEnum.Conditions.SkipMSDK] = "true" == _G.App.launchParams.SkipMSDK
  end
  if CachedConditions[LoginEnum.Conditions.EnableServerChoose] then
    self.Conditions[LoginEnum.Conditions.EnableServerChoose] = CachedConditions[LoginEnum.Conditions.EnableServerChoose]
  else
    self.Conditions[LoginEnum.Conditions.EnableServerChoose] = RocoEnv.IS_EDITOR
  end
  if RocoEnv.PLATFORM_WINDOWS then
    Log.Debug("PC skip update")
    self.Conditions[LoginEnum.Conditions.SkipUpdate] = true
    self.Conditions[LoginEnum.Conditions.WeGameBranchType] = ""
    self.Conditions[LoginEnum.Conditions.WeGameBranchType] = ""
  end
  self.Conditions[LoginEnum.Conditions.CheckBackFromBigWorld] = _G.AppMain:IsBackToLogin()
  Log.PrintScreenMsg("LoginData: active bIsOnPc: %s", tostring(self.Conditions[LoginEnum.Conditions.IsOnPc]))
  if RocoEnv.PLATFORM_WINDOWS then
    Log.PrintScreenMsg("LoginData: active UseWeGame: %s", tostring(self.Conditions[LoginEnum.Conditions.UseWeGame]))
  else
    Log.PrintScreenMsg("LoginData: active SkipMSDK: %s", tostring(self.Conditions[LoginEnum.Conditions.SkipMSDK]))
  end
  self.serverList = JsonUtils.LoadDefaultServerList({})
  self:SetServer(self.serverList and (self.serverList[1] or {}) or {})
  local InfoList = string.split(RocoEnv.DEVICE_INFO, "|")
  Log.PrintScreenMsg("DeviceInfo %s", RocoEnv.DEVICE_INFO)
  self:SetEnterWorldWithoutDownloadRes(false)
  self:SetGEMState()
end

function LoginData:SetIfDownloadBasePaksWithoutLogin(flag)
  local LoginEnum = require("NewRoco.Modes.LoginMode.LoginEnum")
  self.Conditions[LoginEnum.Conditions.IfDownloadBasePaksWithoutLogin] = flag
end

function LoginData:CreateAccountInfo()
  return {}
end

function LoginData:SetChannel(InChannel)
  self.loginChannel = InChannel
end

function LoginData:GetChannel()
  return self.loginChannel
end

function LoginData:SetRegChannelDis(regChannelDis)
  self.regChannelDis = regChannelDis
end

function LoginData:GetRegChannelDis()
  return self.regChannelDis
end

function LoginData:SetCliStartUpChannel(cli_startup_channel)
  self.cli_startup_channel = cli_startup_channel
end

function LoginData:GetCliStartUpChannel()
  return self.cli_startup_channel
end

function LoginData:SetPackageChannel(channel)
  self.packageChannel = channel
end

function LoginData:GetPackageChannel()
  return self.packageChannel
end

function LoginData:SetTpnsToken(tpns_token)
  Log.Info("LoginData:SetTpnsToken", tpns_token)
  self.tpns_token = tpns_token
end

function LoginData:GetTpnsToken()
  return self.tpns_token
end

function LoginData:SetExtraInfo(extra_login_info)
  if not self.extra_login_info then
    self.extra_login_info = {}
  end
  if extra_login_info then
    for k, v in pairs(extra_login_info) do
      self.extra_login_info[k] = v
    end
  end
end

function LoginData:GetExtraInfo()
  return self.extra_login_info
end

function LoginData:SetServer(InServer)
  self.selectedServer = InServer
end

function LoginData:GetServer()
  return self.selectedServer
end

function LoginData:GetServerByName(ServerName)
  if self.serverList then
    for _, Server in ipairs(self.serverList) do
      if Server.key == ServerName then
        return Server
      end
    end
  end
end

function LoginData:HasServer()
  return self.selectedServer and not self.selectedServer.invalid
end

function LoginData:SetDefaultServerChoiceIfPossible()
  if #self.serverList > 0 then
    self:SetServer(self.serverList[1])
    return true
  end
  return false
end

function LoginData:SetAccountInfo(InInfo)
  self.AccountInfo = InInfo
end

function LoginData:SetServerList(InServerList)
  if not self.serverList then
    self.serverList = {}
  end
  table.clear(self.serverList)
  for _, v in pairs(InServerList) do
    table.insert(self.serverList, v)
  end
end

function LoginData:GetAccountInfo()
  return self.AccountInfo
end

function LoginData:GetGroupList()
  local GroupList = {}
  if self.serverList then
    local GroupMap = {}
    for _, Server in ipairs(self.serverList) do
      if Server.group and Server.group ~= "" and not GroupMap[Server.group] then
        GroupMap[Server.group] = true
        local GroupData = {
          key = Server.group,
          isGroup = true
        }
        table.insert(GroupList, GroupData)
      end
    end
  end
  return GroupList
end

function LoginData:GetServerList(GroupName)
  local ServerList = {
    [1] = {
      key = "\230\151\160\230\149\136\230\156\141\229\138\161\229\153\168",
      invalid = true
    }
  }
  for _, Server in ipairs(self.serverList) do
    if not GroupName or Server.group == GroupName then
      table.insert(ServerList, Server)
    end
  end
  return ServerList
end

function LoginData:BuildOpenID(inputID)
  Log.Debug("BuildOpenID\239\188\154", inputID)
  local lastLoginID = GameSetting.LastLogin
  Log.Debug("lastLoginID:", lastLoginID)
  local openId = ""
  if lastLoginID and "" ~= lastLoginID then
    openId = lastLoginID
  end
  self.Log("GetOpenID:", lastLoginID, inputID, openId)
  if "" == openId then
    openId = UE4.UKismetSystemLibrary.GetPlatformUserName()
    Log.Debug("UKismetSystemLibrary GetOpenID:", openId)
    if "GenericUser" == openId then
      openId = "User" .. tostring(os.time())
    end
  end
  self.openId = openId
  UE4.UGPMStatics.SetOpenId(tostring(self.openId))
  return openId
end

function LoginData:GetCondition(ConditionName)
  return self.Conditions[ConditionName]
end

function LoginData:SetCondition(ConditionName, Value)
  Log.Debug("LoginData:SetCondition", ConditionName, Value)
  self.Conditions[ConditionName] = Value
end

function LoginData:SetDownloadBaseResFlag(bDownloadBaseRes)
  self.bDownloadBaseRes = bDownloadBaseRes
end

function LoginData:GetDownloadBaseResFlag()
  return self.bDownloadBaseRes
end

function LoginData:SetDownloadingTaskId(TaskId)
  self.CurrentDownloadingPufferTaskId = TaskId
end

function LoginData:GetDownloadingTaskId()
  return self.CurrentDownloadingPufferTaskId
end

function LoginData:SetOpenID(inputID)
  Log.Debug("\229\134\153\229\133\165\230\150\176OpenID\239\188\154", inputID)
  self.openId = inputID
  UE4.UGPMStatics.SetOpenId(tostring(self.openId))
end

function LoginData:SetToken(token)
  Log.Debug("\229\134\153\229\133\165token\239\188\154", token)
  self.token = token
end

function LoginData:GetToken()
  return self.token or "53535353535"
end

function LoginData:SetUserName(userName)
  self.userName = userName
end

function LoginData:GetUserName()
  return self.userName
end

function LoginData:GetPayInfo()
  return self.payToken, self.pf, self.pfKey
end

function LoginData:GetOpenID()
  Log.Debug("getting openid", self.openId)
  if not self.openId then
    self:LogError("\229\191\133\233\161\187\229\133\136SetOpenID")
  end
  return self.openId
end

function LoginData:SetRegisterGender(gender)
  self.curRegisterGender = gender
end

function LoginData:GetRegisterGender()
  return self.curRegisterGender
end

function LoginData:SetNeedDelayRotation(bNeedDelayRotation)
  self.bNeedDelayRotation = bNeedDelayRotation
end

function LoginData:GetNeedDelayRotation()
  return self.bNeedDelayRotation
end

function LoginData:SetEnterWorldWithoutDownloadRes(bFlag)
  self.bEnterWorldWithoutDownloadRes = bFlag
end

function LoginData:GetEnterWorldWithoutDownloadRes()
  return self.bEnterWorldWithoutDownloadRes
end

function LoginData:SetGEMState()
  self.curGEMState = 0
  self.GEMState = {
    "AgreementsAccepted",
    "PlayMoreFunOpenUpVideo",
    "ResetProgressBar",
    "PSOInit",
    "ShowPlatformButtons",
    "StartMSDKVerification",
    "ShowLoginPanel",
    "ClickLoginButton",
    "HideLoginPanel",
    "PlayEndLoginVideo",
    "EnterCommonLoading",
    "EnterBigWorld"
  }
  self.GEMChildState = {}
  self.GEMChildState.ResetProgressBar = {
    "CheckAppUpdate",
    "BeginAppUpdate",
    "CloseAppState",
    "CheckResUpdate",
    "BeginResUpdate",
    "UpdateResSuccess",
    "UpdateEndState"
  }
  self.GEMChildState.PSOInit = {
    "OpenLoginLevel"
  }
  self.GEMChildState.StartMSDKVerification = {
    "RealNameCertification",
    "AntiAddiction",
    "MSDKGeneralLoginSuccessState"
  }
  self.GEMChildState.ShowLoginPanel = {
    "OpenAnnouncement"
  }
  self.GEMChildState.ClickLoginButton = {
    "KickOutNotify",
    "WhiteListLimit"
  }
  self.GEMChildState.HideLoginPanel = {
    "EnterSelection",
    "EnterName",
    "ClickNameButton"
  }
  self.GEMChildState.PlayEndLoginVideo = {
    "LoginVideoEnd",
    "EnterLoading",
    "EnterLoadingEnd",
    "PlayEnterSequence",
    "EnterSequenceEnd"
  }
  self.GEMChildState.EnterCommonLoading = {
    "CommonLoadingEnd"
  }
end

function LoginData:IsGEMParentState(StateName)
  for k, v in ipairs(self.GEMState) do
    if v == StateName then
      self.curGEMState = k
      return true, k
    end
  end
  return false, 0
end

function LoginData:GetGEMChildState(ParentStateId, StateName)
  local parentStateName = self.GEMState[ParentStateId]
  if self.GEMState[parentStateName] and #self.GEMState[parentStateName] > 0 then
    for k, v in ipairs(self.GEMChildState[parentStateName]) do
      if v == StateName then
        return k
      end
    end
  end
  return -1
end

return LoginData
