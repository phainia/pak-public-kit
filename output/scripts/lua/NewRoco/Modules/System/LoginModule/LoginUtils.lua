local Fsm = require("NewRoco.Modules.Core.Fsm.Fsm")
local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local LoginModuleEvent = require("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local CreatePlayerModuleCmd = require("NewRoco.Modules.System.CreatePlayerModule.CreatePlayerModuleCmd")
local LoginModuleCmd = require("NewRoco.Modules.System.LoginModule.LoginModuleCmd")
local JsonUtils = require("Common.JsonUtils")
local LoginUtils = {}
LoginUtils.Debug = false
LoginUtils.EnableServerChoose = false
LoginUtils.BlackSpeed = 10

function LoginUtils.CreateChildrenFsm(ParentFsm, ChildFsmName)
  local ChildFsm = Fsm(ChildFsmName)
  
  function ChildFsm.SendEventToParentFsm(...)
    ParentFsm:SendEvent(...)
  end
  
  ChildFsm.ParentFsm = ParentFsm
  _G.NRCModuleManager:DoCmd(LoginModuleCmd.TrackFsm, ChildFsm)
  return ChildFsm
end

function LoginUtils.CallAndRemoveCallback(this, CallerName, CallbackName, ...)
  CallerName = CallerName or "autoCaller"
  CallbackName = CallbackName or "autoCallback"
  local caller = this[CallerName]
  local callback = this[CallbackName]
  if not callback then
    if "autoCallback" ~= CallbackName then
      Log.Warning("Warning: " .. CallbackName .. " is nil")
    end
    return false
  end
  callback(caller, ...)
  this[CallbackName] = nil
  this[CallerName] = nil
  return true
end

function LoginUtils.RegisterCallback(this, Caller, Callback, CallerName, CallbackName)
  if not Caller or not Callback then
    Log.Warning("No valid Callback inputed, returning")
    return
  end
  CallerName = CallerName or "autoCaller"
  CallbackName = CallbackName or "autoCallback"
  if this[CallerName] or this[CallbackName] then
    Log.Error("Callback name conflict, this is not tolerated")
    return
  end
  this[CallerName] = Caller
  this[CallbackName] = Callback
end

function LoginUtils.DestroyActors()
  local ActorHolder = LoginUtils.GetUObjectHolder()
  if not ActorHolder then
    Log.Warning("actor holder destroyed")
    return
  end
  ActorHolder.RestoreCameraCurve = nil
  ActorHolder.RestoreCameraCurveRef = nil
  if nil ~= ActorHolder.Player1 then
    ActorHolder.Player1:DoDestroy()
    ActorHolder.Player1 = nil
  end
  if nil ~= ActorHolder.Player2 then
    ActorHolder.Player2:DoDestroy()
    ActorHolder.Player2 = nil
  end
  if nil ~= ActorHolder.LevelSequenceActor then
    ActorHolder.LevelSequenceActor:DoDestroy()
    ActorHolder.LevelSequenceActor = nil
  end
  if nil ~= ActorHolder.PlayerCenter then
    ActorHolder.PlayerCenter:Destroy()
    ActorHolder.PlayerCenter = nil
  end
  ActorHolder.Player1Ref = nil
  ActorHolder.Player2Ref = nil
  ActorHolder.LevelSequenceActorRef = nil
end

function LoginUtils.GetLoginController()
  return UE4.UGameplayStatics.GetPlayerController(UE4Helper.GetCurrentWorld(), 0)
end

function LoginUtils.NewCanvasInfo(Canvas, ShowAnimationName, HideAnimationName)
  return {
    Canvas = Canvas,
    ShowAnimationName = ShowAnimationName,
    HideAnimationName = HideAnimationName
  }
end

function LoginUtils.InitActors(Owner, Callback)
  local curLevelName = LevelHelper:GetLevelName()
  if "Login" ~= curLevelName then
    LoginUtils.InitActorsInCreatePlayerMode(Owner, Callback)
    return
  end
  local ActorHolder = LoginUtils.GetUObjectHolder()
  local zeroTransform = UE4.FTransform(UE4.FQuat(), UE4.FVector(0, 0, 99999))
  ActorHolder.RestoreCameraCurve = LoadObject(_G.UEPath.RESTORE_CAMERA_CURVE)
  ActorHolder.RestoreCameraCurveRef = UnLua.Ref(ActorHolder.RestoreCameraCurve)
  _G.NRCResourceManager:LoadResAsync(LoginUtils, UEPath.LOGIN_PLAYER_AVATAR_MALE, 0, 0, function(Caller, Request, Res)
    ActorHolder.Player1 = UE4Helper.GetCurrentWorld():Abs_SpawnActor(Res, zeroTransform, UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn)
    ActorHolder.Player1:SetDefaultSuit(1)
    ActorHolder.Player1Ref = UnLua.Ref(ActorHolder.Player1)
    LoginUtils.CheckLoadResFinished(Owner, Callback)
  end, LoginUtils.OnLoadFailed)
  _G.NRCResourceManager:LoadResAsync(LoginUtils, UEPath.LOGIN_PLAYER_AVATAR_FAMALE, 0, 0, function(Caller, Request, Res)
    ActorHolder.Player2 = UE4Helper.GetCurrentWorld():Abs_SpawnActor(Res, zeroTransform, UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn)
    ActorHolder.Player2:SetDefaultSuit(2)
    ActorHolder.Player2Ref = UnLua.Ref(ActorHolder.Player2)
    LoginUtils.CheckLoadResFinished(Owner, Callback)
  end, LoginUtils.OnLoadFailed)
  _G.NRCResourceManager:LoadResAsync(LoginUtils, UEPath.LOGIN_LEVELSEQUENCEACTOR, 0, 0, function(Caller, Request, Res)
    if ActorHolder.LevelSequenceActor then
      ActorHolder.LevelSequenceActor:Destroy()
    end
    ActorHolder.LevelSequenceActor = UE4Helper.GetCurrentWorld():Abs_SpawnActor(Res, UE4.FTransform(UE4.FQuat(), UE4.FVector(0, 0, 500)), UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn)
    ActorHolder.LevelSequenceActorRef = UnLua.Ref(ActorHolder.LevelSequenceActor)
    LoginUtils.CheckLoadResFinished(Owner, Callback)
  end, LoginUtils.OnLoadFailed)
end

function LoginUtils.InitActorsInCreatePlayerMode(Owner, Callback)
  local ActorHolder = LoginUtils.GetUObjectHolder()
  local zeroTransform = UE4.FTransform(UE4.FQuat(), UE4.FVector(0, 0, 99999))
  ActorHolder.RestoreCameraCurve = NRCModuleManager:DoCmd(CreatePlayerModuleCmd.GetAsset, _G.UEPath.RESTORE_CAMERA_CURVE)
  if ActorHolder.RestoreCameraCurve then
    ActorHolder.RestoreCameraCurveRef = UnLua.Ref(ActorHolder.RestoreCameraCurve)
  end
  local player1Res = NRCModuleManager:DoCmd(CreatePlayerModuleCmd.GetAsset, _G.UEPath.LOGIN_PLAYER_AVATAR_MALE)
  ActorHolder.Player1 = UE4Helper.GetCurrentWorld():Abs_SpawnActor(player1Res, zeroTransform, UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn)
  if ActorHolder.Player1 then
    ActorHolder.Player1:SetDefaultSuit(1)
    ActorHolder.Player1Ref = UnLua.Ref(ActorHolder.Player1)
    ActorHolder.player1StartRotation = UE4.FRotator(0, 180, 0)
  else
    Log.Error("\228\184\187\232\167\146\230\168\161\229\158\139\229\136\155\229\187\186\229\164\177\232\180\165\239\188\140\232\175\183\229\145\138\231\159\165jobhuang\230\152\175\230\128\142\228\185\136\229\135\186\231\142\176\231\154\132")
  end
  local player2Res = NRCModuleManager:DoCmd(CreatePlayerModuleCmd.GetAsset, _G.UEPath.LOGIN_PLAYER_AVATAR_FAMALE)
  ActorHolder.Player2 = UE4Helper.GetCurrentWorld():Abs_SpawnActor(player2Res, zeroTransform, UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn)
  if ActorHolder.Player2 then
    ActorHolder.Player2:SetDefaultSuit(2)
    ActorHolder.Player2Ref = UnLua.Ref(ActorHolder.Player2)
    ActorHolder.player2StartRotation = UE4.FRotator(0, 180, 0)
  else
    Log.Error("\228\184\187\232\167\146\230\168\161\229\158\139\229\136\155\229\187\186\229\164\177\232\180\165\239\188\140\232\175\183\229\145\138\231\159\165jobhuang\230\152\175\230\128\142\228\185\136\229\135\186\231\142\176\231\154\132")
  end
  local LevelSequenceActorRes = NRCModuleManager:DoCmd(CreatePlayerModuleCmd.GetAsset, _G.UEPath.LOGIN_LEVELSEQUENCEACTOR)
  if ActorHolder.LevelSequenceActor then
    ActorHolder.LevelSequenceActor:Destroy()
  end
  ActorHolder.LevelSequenceActor = UE4Helper.GetCurrentWorld():Abs_SpawnActor(LevelSequenceActorRes, UE4.FTransform(UE4.FQuat(), UE4.FVector(0, 0, 500)), UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn)
  ActorHolder.LevelSequenceActorRef = UnLua.Ref(ActorHolder.LevelSequenceActor)
  if Owner then
    Callback(Owner)
  else
    Callback()
  end
end

function LoginUtils.CheckLoadResFinished(Owner, Callback)
  local ActorHolder = LoginUtils.GetUObjectHolder()
  if not UE4.UObject.IsValid(ActorHolder.Player1) then
    return
  end
  if not UE4.UObject.IsValid(ActorHolder.Player2) then
    return
  end
  if not UE4.UObject.IsValid(ActorHolder.LevelSequenceActor) then
    return
  end
  if not Callback then
    return
  end
  if Owner then
    Callback(Owner)
  else
    Callback()
  end
end

function LoginUtils.OnLoadFailed(Caller, Request, Message)
  Log.Warning("amonsu:LoginUtils \233\162\132\229\138\160\232\189\189\232\181\132\230\186\144\229\164\177\232\180\165", Message)
  _G.NRCResourceManager:UnLoadRes(Request)
end

function LoginUtils.GetMainFsm()
  local CurLevelName = LevelHelper:GetLevelName()
  if "UpdateLevel" == CurLevelName then
    return _G.NRCModuleManager:DoCmd(UpdateUIModuleCmd.GetMainLoginFsm)
  elseif "Login" == CurLevelName or "Plot_A1_LearnMagic_New_Release" == CurLevelName then
    return _G.NRCModuleManager:DoCmd(LoginModuleCmd.GetMainLoginFsm)
  end
end

function LoginUtils.GetPropertyHolder()
  return NRCModuleManager:DoCmd(CreatePlayerModuleCmd.GetCreatePlayerFsm) or _G.NRCModuleManager:DoCmd(LoginModuleCmd.GetMainLoginFsm)
end

function LoginUtils.GetUObjectHolder()
  local CurLevelName = LevelHelper:GetLevelName()
  local LoginFsm
  if "Login" == CurLevelName then
    LoginFsm = _G.NRCModuleManager:DoCmd(LoginModuleCmd.GetMainLoginFsm)
  else
    LoginFsm = NRCModuleManager:DoCmd(CreatePlayerModuleCmd.GetCreatePlayerFsm)
  end
  if LoginFsm then
    return LoginFsm.NRCLoginFsm
  else
    return nil
  end
end

function LoginUtils.GetMSDKEnvironment()
  local EnvriomentType = "\230\181\139\232\175\149\231\142\175\229\162\131"
  local SDKUrl = "https://hktest.itop.qq.com/"
  if RocoEnv.IS_SHIPPING then
    EnvriomentType = "\230\173\163\229\188\143\231\142\175\229\162\131"
    SDKUrl = "https://itop.tencent-cloud.net"
  end
  return string.format("MSDK Url\228\184\186%s\239\188\140\233\137\180\229\174\154\228\184\186%s", SDKUrl, EnvriomentType)
end

function LoginUtils.SendEventToLoginFsm(InEvent)
  local LoginFsm = LoginUtils.GetMainFsm()
  if LoginFsm then
    LoginFsm:SendEvent(InEvent)
  end
end

function LoginUtils.GetSelectionEnterStateEvent()
  local PropertyHolder = LoginUtils.GetPropertyHolder()
  if PropertyHolder.bIsMale ~= nil then
    if PropertyHolder.bIsMale then
      return LoginModuleEvent.ContinueToRestoreSelectionMale
    else
      return LoginModuleEvent.ContinueToRestoreSelectionFemale
    end
  else
    return LoginModuleEvent.ContinueToPreselection
  end
end

function LoginUtils.GetGender()
  local PropertyHolder = LoginUtils.GetPropertyHolder()
  if PropertyHolder.bIsMale then
    return LoginModuleEvent.MaleCharacterSelected
  else
    return LoginModuleEvent.FemaleCharacterSelected
  end
end

function LoginUtils.InstantiateMSDKLoginObserver()
  local Instance = UE4.UNRCPlatformGameInstance.GetInstance()
  if not _G.GlobalConfig.bLoginObserverSet then
    _G.GlobalConfig.bLoginObserverSet = true
    local Observer = NewObject(UE.ULoginObserver, Instance, "LoginObserver", "Core.Service.GCloud.LoginObserver")
    Instance.LoginObserver = Observer
    UE.ULoginStatics.SetLoginObserver(Instance.LoginObserver)
  else
  end
end

function LoginUtils.InstantiateMSDKNoticeObserver()
  local Instance = UE4.UNRCPlatformGameInstance.GetInstance()
  if not _G.GlobalConfig.bNoticeObserverSet then
    _G.GlobalConfig.bNoticeObserverSet = true
    local Observer = NewObject(UE.UNoticeObserver, Instance, "NoticeObserver", "Core.Service.GCloud.NoticeObserver")
    Instance.NoticeObserver = Observer
    UE.UNoticeStatics.SetNoticeObserver(Observer)
  end
end

function LoginUtils.OnPIEEnd(Holder)
  local Instance = UE4.UNRCPlatformGameInstance.GetInstance()
  _G.NRCEventCenter:UnRegisterEvent(Holder, _G.NRCGlobalEvent.OnPrePIEEnded, LoginUtils.OnPIEEnd)
end

function LoginUtils.GetLoginObserver()
  local Instance = UE4.UNRCPlatformGameInstance.GetInstance()
  return Instance.LoginObserver
end

function LoginUtils.GetLoginData()
  local loginModule = _G.NRCModuleManager:GetModule("LoginModule")
  if loginModule then
    return loginModule:GetData("LoginData")
  else
    return nil
  end
end

function LoginUtils.ShowBanner(Module, InText)
  NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, InText)
end

function LoginUtils.GetAgeHintText()
  local config = _G.DataConfigManager:GetGlobalConfig("age_notice")
  return config.str
end

function LoginUtils.ShowPopUpWindow(Module, InTitle, InText, ConfirmEvent, CancelEvent, ConfigName, SmallWindow)
  local Context = DialogContext()
  local PopWindowConfig
  if ConfigName then
    PopWindowConfig = _G.DataConfigManager:GetGlobalConfig(ConfigName)
  end
  Context:SetTitle(PopWindowConfig and PopWindowConfig.title or InTitle):SetContent(PopWindowConfig and PopWindowConfig.str or InText):SetMode(DialogContext.Mode.OK_CANCEL):SetCallback(Module, function(this, result)
    LoginUtils.OnDialogResult(result, ConfirmEvent, CancelEvent)
  end):SetCloseOnCancel(true):SetButtonText(PopWindowConfig and PopWindowConfig.button_right or LuaText.YES, PopWindowConfig and PopWindowConfig.button_left or LuaText.NO)
  NRCModuleManager:DoCmd(SmallWindow and TipsModuleCmd.Dialog_OpenDialog or TipsModuleCmd.Dialog_OpenLongDialog, Context)
end

function LoginUtils.PopConfirmWindow(Module, InTitle, InText, ConfirmEvent, ConfigName, SmallWindow)
  local Context = DialogContext()
  local PopWindowConfig
  if ConfigName then
    PopWindowConfig = _G.DataConfigManager:GetGlobalConfig(ConfigName)
  end
  Context:SetTitle(PopWindowConfig and PopWindowConfig.title or InTitle):SetContent(PopWindowConfig and PopWindowConfig.str or InText):SetMode(DialogContext.Mode.OK):SetCallback(Module, function(this, result)
    LoginUtils.OnDialogResult(result, ConfirmEvent, nil)
  end):SetButtonText(PopWindowConfig and PopWindowConfig.button_right or LuaText.YES)
  NRCModuleManager:DoCmd(SmallWindow and TipsModuleCmd.Dialog_OpenDialog or TipsModuleCmd.Dialog_OpenLongDialog, Context)
end

function LoginUtils.OnDialogResult(result, ConfirmEvent, CancelEvent)
  if result then
    LoginUtils.SendEventToLoginFsm(ConfirmEvent)
  else
    LoginUtils.SendEventToLoginFsm(CancelEvent)
  end
end

function LoginUtils.GetPersistedUserName()
  local loginUserInfo = JsonUtils.LoadSaved("LoginUserInfo", {})
  Log.Debug("LoginUtils.GetPersistedUserName:", loginUserInfo.userName)
  return loginUserInfo.userName
end

function LoginUtils.ShowPufferGenericErrorDailog(ErrorCode, GiveUpCallback, RetryCallback)
  Log.Error("[LoginUtils:ShowPufferGenericErrorDailog] Puffer error: ", ErrorCode)
  if LoginUtils.bShowPufferFailedDialog then
    Log.Error("Show Puffer Init Failed Dialog Repeatly")
    return
  end
  LoginUtils.bShowPufferFailedDialog = true
  LoginUtils.SendEventToLoginFsm(LoginModuleEvent.UpdateError)
  local PufferErrorCodeDesc = require("Core.Service.GCloud.PufferErrorCodeDesc")
  _G.GEMPostManager:GEMPostStepEvent("UpdateResSuccess", PufferErrorCodeDesc:GetDesc(ErrorCode))
  local Context = DialogContext()
  Context:SetTitle(LuaText.updateuimodule_26):SetContent(PufferErrorCodeDesc:GetDesc(ErrorCode)):SetMode(DialogContext.Mode.OK_CANCEL):SetCallback(LoginUtils, function(this, result)
    LoginUtils.bShowPufferFailedDialog = false
    if result then
      GiveUpCallback()
    else
      RetryCallback()
    end
  end):SetButtonText(LuaText.umg_minigame_giveup_1, LuaText.RETRY)
  NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
end

return LoginUtils
