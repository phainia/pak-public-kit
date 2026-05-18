local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local JsonUtils = require("Common.JsonUtils")
local MainUIModuleCmd = require("NewRoco.Modules.System.MainUI.MainUIModuleCmd")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local LoginModuleEvent = reload("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local mcw = require("Debug.MemoryCheckWrapper")
local Base = DebugTabBase
local DebugTabCommon = Base:Extend("DebugTabCommon")

function DebugTabCommon:Ctor()
  Base.Ctor(self)
  self.bHideAllHUD = true
end

function DebugTabCommon:SetupTabs()
  self:Add("\230\136\152\230\150\151\228\184\173\233\154\144\232\151\143\231\148\187\233\157\162\228\191\161\230\129\175", self.ShowOrHideScreenInfoInBattle, self, nil, "\231\190\142\230\156\175\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\137\147\229\188\128\228\187\187\229\138\161\228\191\161\229\176\129", self.OpenTaskMailPanel, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\232\180\180\229\155\190\229\144\136\229\185\182\229\136\134\233\131\168\228\187\182\229\177\149\231\164\186", self.ShowAvatarTextureParameter, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\229\188\128\229\144\175\229\143\172\229\155\158\230\180\187\229\138\168", self.OpenRecallActivity, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\229\133\179\233\151\173IOS\232\175\132\229\136\134", self.CloseIOSRating, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "CloseIOSRating")
  self:Add("\230\137\147\229\188\128IOS\232\175\132\229\136\134", self.OpenIOSRating, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "OpenIOSRating")
  self:Add("AI\233\159\179\233\162\145BASE64\232\167\163\231\160\129\230\146\173\230\148\190", self.SaveBASE64File, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "AI\233\159\179\233\162\145BASE64\232\167\163\231\160\129\230\146\173\230\148\190", nil, "")
  self:Add("\229\129\156\230\173\162AI\233\159\179\233\162\145\230\146\173\230\148\190", self.OnStopLocalVoice, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\229\129\156\230\173\162AI\233\159\179\233\162\145\230\146\173\230\148\190", nil, "")
  self:Add("\230\181\139\232\175\149\230\181\139\232\175\149", self.OnTestFilterParagraphID, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\230\181\139\232\175\149\230\181\139\232\175\149", nil, "")
end

function DebugTabCommon:CloseIOSRating(name, panel)
  _G.NRCModuleManager:DoCmd(_G.IOSRatingModuleCmd.GMCloseIOSRating)
end

function DebugTabCommon:OpenIOSRating(name, panel)
  _G.NRCModuleManager:DoCmd(_G.IOSRatingModuleCmd.GMOpenIOSRating)
end

function DebugTabCommon:OnTestFilterParagraphID(name, panel)
  _G.NRCModuleManager:DoCmd(_G.TaskModuleCmd.FilterParagraphIDListInCurrTask, {
    60022,
    60023,
    60024,
    60025,
    5001
  })
end

function DebugTabCommon:OnPlayLocalVoice(name, panel)
  local dir = UE4.UBlueprintPathsLibrary.ProjectSavedDir()
  local fileName = "1111"
  if panel and panel.InputBox:GetText() ~= "" then
    fileName = panel.InputBox:GetText()
  end
  _G.GVoiceManager:PlayRecordedFile(dir .. fileName .. ".opus")
end

function DebugTabCommon:OnStopLocalVoice(name, panel)
  _G.GVoiceManager:StopPlayRecordedFile()
end

function DebugTabCommon:SaveBASE64File(name, panel)
  local byteArray = "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"
  local decoData = {}
  decoData = UE4.UNRCStatics.DecodeBase64(byteArray, decoData)
  local fileName = "testGvoice"
  if panel and panel.InputBox:GetText() ~= "" then
    fileName = panel.InputBox:GetText()
  end
  local filePath = UE4.UBlueprintPathsLibrary.ProjectSavedDir() .. fileName .. ".opus"
  UE4.UNRCStatics.SaveByteArrayToFile(decoData, filePath)
  _G.GVoiceManager:PlayRecordedFile(filePath)
  _G.DelayManager:DelaySeconds(2, function()
    local level = _G.GVoiceManager:GetSpeakerLevel()
    Log.Debug("DebugTabCommon:OnPlayRecordedFile", level)
  end)
end

function DebugTabCommon:IOSRating(name, panel)
  if panel then
    local Text = panel.InputBox:GetText()
    local id = tonumber(Text)
    _G.NRCModuleManager:DoCmd(_G.IOSRatingModuleCmd.GMIOSRating, id)
  end
end

function DebugTabCommon:ChangeTaskIconHeight(name, panel, id)
  if panel then
    local Text = panel.InputBox:GetText()
    if Text then
      Log.Error("set to ", Text)
      _G.GlobalConfig.TaskIconHeightOverride = tonumber(Text)
    else
      _G.GlobalConfig.TaskIconHeightOverride = nil
    end
  elseif id then
    _G.GlobalConfig.TaskIconHeightOverride = id
  end
end

function DebugTabCommon:DebugLogCampfirePFF()
  if NRCModuleManager:GetModule("CampingModule") then
    _G.NRCModuleManager:DoCmd(_G.CampingModuleCmd.DebugLogCampfirePFF)
  end
end

function DebugTabCommon:CloseCrashSight()
  NRCSDKManager:CloseCrashSight()
end

function DebugTabCommon:TestLuaError()
end

function DebugTabCommon:TestFatalCrash()
  Log.Fatal("Test Crash")
end

function DebugTabCommon:DumpStoryFlags(name, panel)
  Log.Error("Story flags info: ", table.tostring(_G.DataModelMgr.PlayerDataModel.playerInfo.story_flag_info))
end

function DebugTabCommon:QuickLogin(name, panel)
  Log.Warning("\229\176\157\232\175\149\229\191\171\233\128\159\230\179\168\229\134\140")
  if self.DelayId then
    Log.Warning("\229\176\157\232\175\149\229\191\171\233\128\159\230\179\168\229\134\140 \239\188\154 \232\175\183\229\139\191\233\135\141\229\164\141\231\130\185\229\135\187")
    return
  end
  if OnlineModuleCmd and OnlineModuleCmd.Logout then
    NRCModuleManager:DoCmd(OnlineModuleCmd.Logout)
  end
  local namegen = require("NewRoco.Modules.System.Debug.Res.RandomName.namegen2")
  local data = NRCModuleManager:GetModule("LoginModule").data
  local username = data:GetOpenID()
  local final = ""
  local GenderPicker = math.random(0, 1)
  local letters = namegen:generate(GenderPicker)
  local numbers = "1"
  if username then
    letters = string.match(username, "%a+")
    numbers = string.match(username, "%d+")
    if nil == numbers then
      numbers = "1"
    end
  end
  local NumNum = numbers:len()
  local LetNum = letters:len()
  if NumNum + LetNum > 30 then
    if LetNum > 20 then
      letters = letters:sub(1, 20)
    end
    if NumNum > 10 then
      numbers = numbers:sub(1, 10)
    end
  end
  local IntNum = toNumber(numbers)
  IntNum = IntNum + 1
  if IntNum >= 1.0E10 then
    Log.Error("\229\144\141\229\173\151\229\186\143\229\143\183\232\191\135\229\164\167")
    IntNum = 1
  end
  numbers = tostring(IntNum)
  final = letters .. numbers
  self.Final = final
  Log.Warning("final name :", final)
  NRCModuleManager:DoCmd(OnlineModuleCmd.SetUserAccountInfo, final, "53535353535")
  NRCModuleManager:DoCmd(OnlineModuleCmd.ConnectAndLogin, data.selectedServer.key, 0, 0, data.selectedServer.ip, data.selectedServer.port, final)
  self.DelayId = _G.DelayManager:DelaySeconds(1, self.Luck, self, name, panel)
end

function DebugTabCommon:ChangeLevelStreamingMode(Name, Panel, id)
  if Panel then
    local Text = Panel.InputBox:GetText()
    local ModeIndex = tonumber(Text)
    UE4.UNRCStatics.ChangeLevelStreamingMode(ModeIndex)
  elseif id then
    UE4.UNRCStatics.ChangeLevelStreamingMode(id)
  end
end

function DebugTabCommon:ChangeRebaseOriginState(Name, Panel)
  UE4.UNRCStatics.ChangeRebaseOriginState()
end

function DebugTabCommon:ChangeRebaseOriginDistance(Name, Panel, id)
  if Panel then
    local value = Panel.InputBox:GetText()
    value = value and tonumber(value) or 0
    UE4.UNRCStatics.ChangeRebaseOriginDistance(value)
  elseif id then
    UE4.UNRCStatics.ChangeRebaseOriginDistance(id)
  end
end

function DebugTabCommon:DelayedTruth()
  if NRCModuleManager:GetModule("CinematicModule") then
    NRCModuleManager:GetModule("CinematicModule").Skip = true
  else
    _G.DelayManager:DelaySeconds(0.1, self.DelayedTruth, self)
  end
end

function DebugTabCommon:QuickLoginCE(name, panel)
  _G.GlobalConfig.PrepareForCE = true
  GlobalConfig.SkipCG = true
  self:QuickLogin(name, panel)
end

function DebugTabCommon:QuickLoginSkip(name, panel)
  if self.DelayId then
    Log.Warning("\229\176\157\232\175\149\229\191\171\233\128\159\230\179\168\229\134\140 \239\188\154 \232\175\183\229\139\191\233\135\141\229\164\141\231\130\185\229\135\187")
    return
  end
  NRCModuleManager:DoCmd(OnlineModuleCmd.Logout)
  self:DelayedTruth()
  local namegen = require("NewRoco.Modules.System.Debug.Res.RandomName.namegen2")
  local LoginModule = NRCModuleManager:GetModule("LoginModule")
  if nil == LoginModule then
    return
  end
  local data = LoginModule.data
  local username = data:GetOpenID()
  local final = ""
  local GenderPicker = math.random(0, 1)
  local letters = namegen:generate(GenderPicker)
  local numbers = "1"
  if username then
    letters = string.match(username, "%a+")
    numbers = string.match(username, "%d+")
    if nil == numbers then
      numbers = "1"
    end
  end
  local NumNum = numbers:len()
  local LetNum = letters:len()
  if NumNum + LetNum > 30 then
    if LetNum > 20 then
      letters = letters:sub(1, 20)
    end
    if NumNum > 10 then
      numbers = numbers:sub(1, 10)
    end
  end
  local IntNum = toNumber(numbers)
  IntNum = IntNum + 1
  if IntNum >= 1.0E10 then
    Log.Error("\229\144\141\229\173\151\229\186\143\229\143\183\232\191\135\229\164\167")
    IntNum = 1
  end
  numbers = tostring(IntNum)
  final = letters .. numbers
  self.Final = final
  Log.Warning("\229\176\157\232\175\149\229\191\171\233\128\159\230\179\168\229\134\140", final)
  NRCModuleManager:DoCmd(OnlineModuleCmd.SetUserAccountInfo, final, "53535353535")
  NRCModuleManager:DoCmd(OnlineModuleCmd.ConnectAndLogin, data.selectedServer.key, 0, 0, data.selectedServer.ip, data.selectedServer.port, final)
  self.DelayId = _G.DelayManager:DelaySeconds(1, self.Luck, self, name, panel)
end

function DebugTabCommon:Luck(name, panel)
  local namegen = require("NewRoco.Modules.System.Debug.Res.RandomName.namegen2")
  GlobalConfig.EnableDeahTeleport = not GlobalConfig.EnableDeahTeleport
  Log.Debug("EnableDeathTeleport=", GlobalConfig.EnableDeahTeleport)
  local GenderPicker = math.random(0, 1)
  local nomen = namegen:generate(GenderPicker)
  local Gender
  if 1 == GenderPicker then
    Gender = ProtoEnum.ESexValue.SEX_MALE
  else
    Gender = ProtoEnum.ESexValue.SEX_FEMALE
  end
  local roleAttrReq = ProtoMessage:newZoneRoleAttrReq()
  roleAttrReq.image = Gender
  roleAttrReq.sex = Gender
  roleAttrReq.name = nomen
  _G.DataModelMgr.PlayerDataModel.playerInfo.brief_info.sex = Gender
  _G.DataModelMgr.PlayerDataModel.playerInfo.brief_info.name = nomen
  local AccountInfos = JsonUtils.LoadSaved("DebugTabAccounts", {})
  local username = self.Final
  if not AccountInfos[username] then
    AccountInfos[username] = 0
    JsonUtils.DumpSaved("DebugTabAccounts", AccountInfos)
  end
  Log.Warning("\229\191\171\233\128\159\230\179\168\229\134\140", "\232\174\190\231\189\174\230\128\167\229\136\171", Gender, "\232\174\190\231\189\174\229\144\141\231\167\176", nomen)
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_ROLE_ATTR_REQ, roleAttrReq, self, self.CheckRoleValid)
  if self.DelayId then
    self.DelayId = nil
    DelayManager:CancelDelayById(self.DelayId)
  end
end

function DebugTabCommon:CheckRoleValid(rsp)
  if rsp.ret_info.ret_code == ProtoEnum.MOBA_RET.ErrorCode.SUCCESS then
    NRCModuleManager:DoCmd(LoginModuleCmd.ReqEnter)
    if rsp.appearance_info then
      _G.DataModelMgr.PlayerDataModel:SetPlayerAppearanceInfo(rsp.appearance_info)
    end
  end
end

function DebugTabCommon:CompareSnapshot(name, panel, InputText)
  local inputText
  if panel then
    inputText = panel.InputBox:GetText()
  else
    inputText = InputText
  end
  if nil == inputText then
    inputText = ""
  end
  local params = {}
  for w in string.gmatch(inputText, "%d+") do
    table.insert(params, w)
  end
  if #params >= 2 then
    local filterParams = {}
    for w in string.gmatch(inputText, "[%a.]+") do
      table.insert(filterParams, w)
    end
    Log.Debug("Compare Index " .. params[1] .. " " .. params[2])
    local filterMode = true
    if #params > 2 and 0 == tonumber(params[3]) then
      filterMode = false
    end
    mcw:CompareSnapshot(tonumber(params[1]), tonumber(params[2]), filterMode, filterParams)
  end
end

function DebugTabCommon:checkcin(name, panel)
  local playerController = UE4.UGameplayStatics.GetPlayerController(UE4Helper.GetCurrentWorld(), 0)
  if playerController then
    if playerController.bBlockInput then
      Log.Error("Block You")
    else
      Log.Error("No Block You")
    end
  end
end

function DebugTabCommon:Setting(name, panel)
  Log.Debug("DebugTabCommon Setting")
  if not RocoEnv.IS_EDITOR then
    UE4.UNRCStatics.ExecConsoleCommand("r.ScreenPercentage 80")
    UE4.UNRCStatics.ExecConsoleCommand("t.MaxFPS 30")
    AppMain.SetEnableScreenSaver(false)
  end
end

function DebugTabCommon:ToggleMinimap()
  SceneUtils.debugCloseMinimap = not SceneUtils.debugCloseMinimap
end

function DebugTabCommon:DebugPlayerTeleportEffect()
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local skillObj = player.viewObj.RocoSkill:FindOrAddSkillObj(player.viewObj.TransEffect)
  if not skillObj then
    Log.Error("\231\142\169\229\174\182\228\188\160\233\128\129\231\137\185\230\149\136\232\181\132\230\186\144\232\174\190\231\189\174\229\164\177\232\180\165\239\188\140\232\175\183\230\163\128\230\159\165")
    return
  end
  skillObj:SetCaster(player.viewObj)
  Log.Debug("SceneLocalPlayer:CheckLandLoaded play teleport effect")
  player.viewObj.RocoSkill:PlaySkill(skillObj)
end

function DebugTabCommon:OpenPetAltarPanel()
  _G.NRCModuleManager:DoCmd(AltarModuleCmd.OpenPetAltarPanel)
end

function DebugTabCommon:OpenItemAltarPanel()
  _G.NRCModuleManager:DoCmd(AltarModuleCmd.OpenItemAltarPanel)
end

function DebugTabCommon:SwitchLevelStreamBlockingForTeleporting()
  _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.SWITCH_STREAM_BLOCK)
end

function DebugTabCommon:SwitchBlockTill()
  SceneUtils.debugClosePlayerBlockTill = not SceneUtils.debugClosePlayerBlockTill
end

function DebugTabCommon:SpawnVideoActors()
  _G.NRCModuleManager:DoCmd(_G.VideoModuleCmd.CreateAllTestActors)
end

function DebugTabCommon:StartVideoActors()
  _G.NRCModuleManager:DoCmd(_G.VideoModuleCmd.StartAllVideos)
end

function DebugTabCommon:StopVideoActors()
  _G.NRCModuleManager:DoCmd(_G.VideoModuleCmd.StopAllVideos)
end

function DebugTabCommon:PauseVideoActors()
  _G.NRCModuleManager:DoCmd(_G.VideoModuleCmd.PauseAllVideos)
end

function DebugTabCommon:ResumeVideoActors()
  _G.NRCModuleManager:DoCmd(_G.VideoModuleCmd.ResumeAllVideos)
end

function DebugTabCommon:DestroyVideoActors()
  _G.NRCModuleManager:DoCmd(_G.VideoModuleCmd.DeleteAllTestActors)
end

function DebugTabCommon:SkipCheckUIFunctionBan()
  _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.GmSkipCheckUIFunctionBan)
end

function DebugTabCommon:DebugCatchPetToggle()
  _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.DebugCatchPetToggle)
end

function DebugTabCommon:ChangeMoveJoystick()
  _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.ChangeMoveJoystickMode)
end

function DebugTabCommon:PrintDeviceCode()
  _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, UE4.UKismetSystemLibrary.GetDeviceId())
end

function DebugTabCommon:SwitchClosePIELoading()
  SceneUtils.debugClosePIELoading = not SceneUtils.debugClosePIELoading
end

function DebugTabCommon:PlayerTeleport(name, panel, InputText1, InputText2)
  local action = {
    to_pt = {
      pos = {
        x = 431677.09375,
        y = 685770.25,
        z = 7516.114746
      },
      dir = {
        x = 0,
        y = 0,
        z = 0
      }
    }
  }
  local inputText, abbreinputText
  if panel then
    inputText = panel.InputBox:GetText()
    abbreinputText = panel.AbbreInputBox:GetText()
  else
    inputText = InputText1
    abbreinputText = InputText2
  end
  if nil == inputText and nil == abbreinputText then
    inputText = ""
  elseif "" ~= abbreinputText then
    inputText = abbreinputText
  end
  local params = {}
  for w in string.gmatch(inputText, "%S+") do
    table.insert(params, w)
  end
  if 3 == #params then
    action.to_pt.pos.x = tonumber(params[1])
    action.to_pt.pos.y = tonumber(params[2])
    action.to_pt.pos.z = tonumber(params[3])
  end
  local Player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  Player:OnPlayerTeleport(action.to_pt)
end

function DebugTabCommon:StopPopErrorRet()
  _G.DonntPopErrorRetMessageBox = true
end

function DebugTabCommon:EnterZone(name, panel, id)
  if panel then
    local idRec = tonumber(panel.InputBox:GetText())
    idRec = idRec or 50001
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.Tips_ShowZoneTip, idRec, self.action)
  elseif id then
    local idRec = id
    idRec = idRec or 50001
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.Tips_ShowZoneTip, idRec, self.action)
  end
end

function DebugTabCommon:Test(name, panel)
end

function DebugTabCommon:ShowReadMe(name, panel)
  UE4.UKismetSystemLibrary.LaunchURL("https://iwiki.woa.com/pages/viewpage.action?pageId=827460344")
end

function DebugTabCommon:OpenLogPanel(name, panel)
  UE4.UNRCPlatformGameInstance.GetInstance():ShowLogGUI()
  if panel then
    panel:DoClose()
  end
end

function DebugTabCommon:ForceCrash(name, panel)
  UE4.UNRCStatics.ForceCrash()
end

function DebugTabCommon:ForceAssert(name, panel)
  UE4.UNRCStatics.ForceAssert()
end

function DebugTabCommon:ForceAsanCrash(name, panel)
  UE4.UNRCStatics.ForceAsanCrash()
end

function DebugTabCommon:ReloadModule(name, panel, InputText)
  local moduleName
  if panel then
    moduleName = panel.InputBox:GetText()
  else
    moduleName = InputText
  end
  if "" == moduleName then
    moduleName = "DebugModule"
  end
  NRCModuleManager:ReloadModule(moduleName)
  if panel then
    _G.GameSetting.DebugPanelInputText = panel.InputBox:GetText()
  else
    _G.GameSetting.DebugPanelInputText = InputText
  end
  _G.GameSetting:Save()
end

function DebugTabCommon:ReloadFile()
  reload("Core.NRCUtils")
end

function DebugTabCommon:DoCmd(name, panel, InputText)
  local text
  if panel then
    text = panel.InputBox:GetText()
  else
    text = InputText
  end
  _G.NRCModuleManager:DoCmdWithArgs(text)
end

function DebugTabCommon:GoToBigWorld(name, panel, InputText)
  local value
  if panel then
    value = panel.InputBox:GetText()
  else
    value = InputText
  end
  local sceneID = value and tonumber(value) or 102
  local loginData = DataModelMgr.PlayerDataModel.loginData
  if not loginData then
    Log.Debug("Can't find any login data!")
    return
  end
  NRCModuleManager:DoCmd(LoginModuleCmd.ReqEnter)
end

function DebugTabCommon:ChangeTime(name, panel, InputText)
  local value
  if panel then
    value = panel.InputBox:GetText()
  else
    value = InputText
  end
  local time = value and tonumber(value) or 0
  NRCModuleManager:DoCmd(EnvSystemModuleCmd.GMChangeGameTime, time)
end

function DebugTabCommon:ChangeLoginDragRatio(name, panel, InputText)
  local value
  if panel then
    value = panel.InputBox:GetText()
  else
    value = InputText
  end
  local ratio = value and tonumber(value) or 0
  NRCEventCenter:DispatchEvent(LoginModuleEvent.ChangeLoginDragRatio, ratio)
end

function DebugTabCommon:ChangeLoginDragAcceleration(name, panel, InputText)
  local value
  if panel then
    value = panel.InputBox:GetText()
  else
    value = InputText
  end
  local acceleration = value and tonumber(value) or 0
  NRCEventCenter:DispatchEvent(LoginModuleEvent.ChangeLoginDragAcceleration, acceleration)
end

function DebugTabCommon:ChangeLoginReleaseRatio(name, panel, InputText)
  local value
  if panel then
    value = panel.InputBox:GetText()
  else
    value = InputText
  end
  local ratio = value and tonumber(value) or 0
  NRCEventCenter:DispatchEvent(LoginModuleEvent.ChangeLoginReleaseRatio, ratio)
end

function DebugTabCommon:ChangeLoginReleaseAcceleration(name, panel, InputText)
  local value
  if panel then
    value = panel.InputBox:GetText()
  else
    value = InputText
  end
  local acceleration = value and tonumber(value) or 0
  NRCEventCenter:DispatchEvent(LoginModuleEvent.ChangeLoginReleaseAcceleration, acceleration)
end

function DebugTabCommon:ChangeTimeScale(name, panel, InputText)
  local value
  if panel then
    value = panel.InputBox:GetText()
  else
    value = InputText
  end
  local scale = value and tonumber(value) or 0
  NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, scale)
end

function DebugTabCommon:LockNoon(name, panel)
  NRCModuleManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 0)
  NRCModuleManager:DoCmd(EnvSystemModuleCmd.GMChangeGameTime, 43200)
end

function DebugTabCommon:PrintTodTime(name, panel)
  NRCModuleManager:DoCmd(EnvSystemModuleCmd.PrintCurrentTime)
end

function DebugTabCommon:ToggleTime(name, panel)
  NRCModuleManager:DoCmd(EnvSystemModuleCmd.TogglePause)
end

function DebugTabCommon:QuickRegisterMan(name, panel, InputText)
  GlobalConfig.SkipCG = true
  GlobalConfig.SkipVideo = true
  local username
  if panel then
    username = panel.InputBox:GetText()
  else
    username = InputText
  end
  if string.IsNilOrEmpty(username) then
    _G.NRCModuleManager:GetModule("LoginModule"):GetData("LoginData"):BuildOpenID()
    username = _G.NRCModuleManager:GetModule("LoginModule"):GetData("LoginData"):GetOpenID()
  end
  local roleAttrReq = ProtoMessage:newZoneRoleAttrReq()
  roleAttrReq.image = ProtoEnum.ESexValue.SEX_MALE
  roleAttrReq.sex = ProtoEnum.ESexValue.SEX_MALE
  local MaxCount = _G.DataConfigManager:GetRoleGlobalConfig("max_name_char_num").num
  if "" == username then
    username = _G.NRCModuleManager:GetModule("LoginModule"):GetData("LoginData"):GetOpenID()
  else
    roleAttrReq.name = username
  end
  if MaxCount < #username then
    username = string.sub(username, 1, MaxCount)
  end
  roleAttrReq.name = username
  _G.DataModelMgr.PlayerDataModel.playerInfo.brief_info.sex = roleAttrReq.sex
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_ROLE_ATTR_REQ, roleAttrReq, self, self.CheckRoleValid)
  if panel then
    panel:DoClose()
  end
  NRCModuleManager:DoCmd(LoadingUIModuleCmd.CloseCreatePlayerLoadingUI, nil, true)
end

function DebugTabCommon:QuickRegisterWoman(name, panel, InputText)
  GlobalConfig.SkipCG = true
  GlobalConfig.SkipVideo = true
  local username
  if panel then
    username = panel.InputBox:GetText()
  else
    username = InputText
  end
  if string.IsNilOrEmpty(username) then
    _G.NRCModuleManager:GetModule("LoginModule"):GetData("LoginData"):BuildOpenID()
    username = _G.NRCModuleManager:GetModule("LoginModule"):GetData("LoginData"):GetOpenID()
  end
  local roleAttrReq = ProtoMessage:newZoneRoleAttrReq()
  roleAttrReq.image = ProtoEnum.ESexValue.SEX_FEMALE
  roleAttrReq.sex = ProtoEnum.ESexValue.SEX_FEMALE
  local MaxCount = _G.DataConfigManager:GetRoleGlobalConfig("max_name_char_num").num
  if "" == username then
    username = _G.NRCModuleManager:GetModule("LoginModule"):GetData("LoginData"):GetOpenID()
  else
    roleAttrReq.name = username
  end
  if MaxCount < #username then
    username = string.sub(username, 1, MaxCount)
  end
  roleAttrReq.name = username
  _G.DataModelMgr.PlayerDataModel.playerInfo.brief_info.sex = roleAttrReq.sex
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_ROLE_ATTR_REQ, roleAttrReq, self, self.CheckRoleValid)
  if panel then
    panel:DoClose()
  end
  NRCModuleManager:DoCmd(LoadingUIModuleCmd.CloseCreatePlayerLoadingUI, nil, true)
end

function DebugTabCommon:CheckRoleValid(rsp)
  if rsp.ret_info.ret_code == ProtoEnum.MOBA_RET.ErrorCode.SUCCESS then
    _G.NRCModuleManager:GetModule("LoginModule"):ReqEnter()
    if rsp.appearance_info then
      _G.DataModelMgr.PlayerDataModel:SetPlayerAppearanceInfo(rsp.appearance_info)
    end
    UE4Helper.ReleaseDesiredShowCursor("CreatePlayerDefaultHideCursor")
  end
end

function DebugTabCommon:ReflectLuaObject(Name, Panel)
  local Text = self.Panel.InputBox:GetText()
  local func = load(string.format("return %s", Text))
  _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.ShowTable, func())
end

function DebugTabCommon:OpenTileLoadLog(Name, Panel)
  local Text = self.Panel.InputBox:GetText()
  UE4.UNRCStatics.OpenTileLoadLog()
end

function DebugTabCommon:CloseTileLoadLog(Name, Panel)
  local Text = self.Panel.InputBox:GetText()
  UE4.UNRCStatics.CloseTileLoadLog()
end

function DebugTabCommon:DebugAddRemoveLevel(Name, Panel)
  local Text = self.Panel.InputBox:GetText()
  UE4.UNRCStatics.DebugAddRemoveLevel()
end

function DebugTabCommon:FreezeWorldComposition(Name, Panel)
  local Text = self.Panel.InputBox:GetText()
  UE4.UNRCStatics.FreezeWorldComposition()
end

function DebugTabCommon:LoadEqualVisible(Name, Panel)
  local Text = self.Panel.InputBox:GetText()
  UE4.UNRCStatics.TileLoadEqualVisible()
end

function DebugTabCommon:UnLoadHLOD(Name, Panel)
  local Text = self.Panel.InputBox:GetText()
  UE4.UNRCStatics.UnLoadHLODTile()
end

function DebugTabCommon:Set1x1LoadRadius(Name, Panel)
  local value = self.Panel.InputBox:GetText()
  local radius = value and tonumber(value) or 0
  UE4.UNRCStatics.Set1x1LoadRadius(radius)
end

function DebugTabCommon:AnimationHighQuality(Name, Panel)
  UE4.UNRCStatics.AnimationHighQuality()
end

function DebugTabCommon:Expand1x1HLODTileRadius(Name, Panel)
  UE4.UNRCStatics.Expand1x1HLODTileRadius()
end

function DebugTabCommon:OnlyLoadOneLand(Name, Panel)
  UE4.UNRCStatics.ExecConsoleCommand("WorldTileTool.SetLayer /Game/ArtRes/Level/Game/BigWorld/L_Bigworld_01_Release/L_Bigworld_01_Release 1x1 1 0 1")
  UE4.UNRCStatics.ExecConsoleCommand("WorldTileTool.SetLayer /Game/ArtRes/Level/Game/BigWorld/L_Bigworld_01_Release/L_Bigworld_01_Release 1x1_hlod 1 10 1")
  UE4.UNRCStatics.ExecConsoleCommand("WorldTileTool.SetLayer /Game/ArtRes/Level/Game/BigWorld/L_Bigworld_01_Release/L_Bigworld_01_Release 2x2_hlod 1 10 1")
  UE4.UNRCStatics.ExecConsoleCommand("WorldTileTool.SetLayer /Game/ArtRes/Level/Game/BigWorld/L_Bigworld_01_Release/L_Bigworld_01_Release 4x4_hlod 1 10 1")
  UE4.UNRCStatics.ExecConsoleCommand("WorldTileTool.SetLayer /Game/ArtRes/Level/Game/BigWorld/L_Bigworld_01_Release/L_Bigworld_01_Release 8x8_hlod 1 10 1")
  UE4.UNRCStatics.ExecConsoleCommand("WorldTileTool.SetLayer /Game/ArtRes/Level/Game/BigWorld/L_Bigworld_01_Release/L_Bigworld_01_Release Props 1 10 1")
  UE4.UNRCStatics.ExecConsoleCommand("WorldTileTool.SetLayer /Game/ArtRes/Level/Game/BigWorld/L_Bigworld_01_Release/L_Bigworld_01_Release Buildings 1 10 1")
  UE4.UNRCStatics.ExecConsoleCommand("WorldTileTool.SetLayer /Game/ArtRes/Level/Game/BigWorld/L_Bigworld_01_Release/L_Bigworld_01_Release EnvProp 1 10 1")
  UE4.UNRCStatics.ExecConsoleCommand("WorldTileTool.SetLayer /Game/ArtRes/Level/Game/BigWorld/L_Bigworld_01_Release/L_Bigworld_01_Release FoliageProp 1 10 1")
  UE4.UNRCStatics.ExecConsoleCommand("WorldTileTool.SetLayer /Game/ArtRes/Level/Game/BigWorld/L_Bigworld_01_Release/L_Bigworld_01_Release A2_POI_Buildings 1 10 1")
  UE4.UNRCStatics.ExecConsoleCommand("WorldTileTool.SetLayer /Game/ArtRes/Level/Game/BigWorld/L_Bigworld_01_Release/L_Bigworld_01_Release A2_POI_Props 1 10 1")
  UE4.UNRCStatics.ExecConsoleCommand("WorldTileTool.SetLayer /Game/ArtRes/Level/Game/BigWorld/L_Bigworld_01_Release/L_Bigworld_01_Release Cave 1 10 1")
  UE4.UNRCStatics.ExecConsoleCommand("WorldTileTool.SetLayer /Game/ArtRes/Level/Game/BigWorld/L_Bigworld_01_Release/L_Bigworld_01_Release Cave_Buildings 1 10 1")
  UE4.UNRCStatics.ExecConsoleCommand("WorldTileTool.SetLayer /Game/ArtRes/Level/Game/BigWorld/L_Bigworld_01_Release/L_Bigworld_01_Release POI 1 10 1")
  UE4.UNRCStatics.ExecConsoleCommand("WorldTileTool.SetLayer /Game/ArtRes/Level/Game/BigWorld/L_Bigworld_01_Release/L_Bigworld_01_Release Plot 1 10 1")
  UE4.UNRCStatics.ExecConsoleCommand("WorldTileTool.SetLayer /Game/ArtRes/Level/Game/BigWorld/L_Bigworld_01_Release/L_Bigworld_01_Release Uncategorized 1 10 1")
  UE4.UNRCStatics.ExecConsoleCommand("WorldTileTool.SetLayer /Game/ArtRes/Level/Game/BigWorld/L_Bigworld_01_Release/L_Bigworld_01_Release Global 1 10 1")
  UE4.UNRCStatics.ExecConsoleCommand("WorldTileTool.SetLayer /Game/ArtRes/Level/Game/BigWorld/L_Bigworld_01_Release/L_Bigworld_01_Release NoStream 1 10 1")
  UE4.UNRCStatics.ExecConsoleCommand("WorldTileTool.SetLayer /Game/ArtRes/Level/Game/BigWorld/L_Bigworld_01_Release/L_Bigworld_01_Release Landform 1 10 1")
  UE4.UNRCStatics.ExecConsoleCommand("WorldTileTool.SetLayer /Game/ArtRes/Level/Game/BigWorld/L_Bigworld_01_Release/L_Bigworld_01_Release TBSLayer_LandAndRock2 1 10 1")
end

function DebugTabCommon:EnableTBS(Name, Panel)
  UE4.UNRCStatics.EnableTBS()
end

local bHideAllHUD = false

function DebugTabCommon:HideAllHUD(Name, Panel)
  local CurrentMode = NRCModeManager:GetCurMode()
  if bHideAllHUD then
    CurrentMode:RevertPanelEnableStateByLayer(_G.Enum.UILayerType.UI_LAYER_DIALOGUE)
    CurrentMode:RevertPanelEnableStateByLayer(_G.Enum.UILayerType.UI_LAYER_TOP)
    CurrentMode:RevertPanelEnableStateByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
    bHideAllHUD = false
  else
    CurrentMode:DisablePanelByLayer(_G.Enum.UILayerType.UI_LAYER_TOP)
    CurrentMode:DisablePanelByLayer(_G.Enum.UILayerType.UI_LAYER_DIALOGUE)
    CurrentMode:DisablePanelByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
    bHideAllHUD = true
  end
end

function DebugTabCommon:HideHUD(Name, Panel)
  local module = NRCModuleManager:GetModule("DebugModule")
  local widget = module:GetPanel("DebugEntry")
  local mainUIModule = _G.NRCModuleManager:GetModule("MainUIModule")
  local updateUIModule = _G.NRCModuleManager:GetModule("UpdateUIModule")
  local Account = updateUIModule and updateUIModule:GetPanel("AccountInfo")
  local MainView = mainUIModule and mainUIModule:GetPanel("LobbyMain") or nil
  if bHideAllHUD then
    NRCModeManager:GetCurMode():RevertPanelEnableStateByLayer(_G.Enum.UILayerType.UI_LAYER_DIALOGUE)
    NRCModeManager:GetCurMode():RevertPanelEnableStateByLayer(_G.Enum.UILayerType.UI_LAYER_TOP)
    widget.OpenButton:SetRenderOpacity(0.01)
    widget.TimeText:SetRenderOpacity(1)
    if Account then
      Account.HorizontalBox_58:SetRenderOpacity(1)
      Account.Canvas_Info:SetRenderOpacity(1)
    end
    if MainView then
      for _, Widget in wpairs(MainView.VisibleContents) do
        Widget:SetVisibility(UE4.ESlateVisibility.Visible)
      end
    end
    local localMode = NRCModeManager:GetMode("LocalMode")
    if localMode then
      localMode.UIVisible = not localMode.UIVisible
      if localMode.UIVisible then
        mainUIModule:OnCmdOpenLobbyMainPanel()
      else
        mainUIModule:OnCmdCloseLobbyMainPanel()
      end
    end
    bHideAllHUD = false
  else
    NRCModeManager:GetCurMode():DisablePanelByLayer(_G.Enum.UILayerType.UI_LAYER_TOP)
    NRCModeManager:GetCurMode():DisablePanelByLayer(_G.Enum.UILayerType.UI_LAYER_DIALOGUE)
    widget.OpenButton:SetRenderOpacity(0)
    widget.TimeText:SetRenderOpacity(0)
    if Account then
      Account.HorizontalBox_58:SetRenderOpacity(0)
      Account.Canvas_Info:SetRenderOpacity(0)
    end
    if MainView then
      for _, Widget in wpairs(MainView.VisibleContents) do
        local WidgetName = Widget:GetName()
        if "Right" == WidgetName or "InThe" == WidgetName then
          Widget:SetVisibility(UE4.ESlateVisibility.Visible)
          for _, Sub in wpairs(Widget) do
            local SubName = Sub:GetName()
            if "UMG_PlayerAbilities" == SubName or "PlayerCtrl" == SubName then
              Sub:SetVisibility(UE4.ESlateVisibility.Visible)
            else
              Sub:SetVisibility(UE4.ESlateVisibility.Hidden)
            end
          end
        else
          Widget:SetVisibility(UE4.ESlateVisibility.Hidden)
        end
      end
    end
    local localMode = NRCModeManager:GetMode("LocalMode")
    if localMode then
      localMode.UIVisible = not localMode.UIVisible
      if localMode.UIVisible then
        mainUIModule:OnCmdOpenLobbyMainPanel()
      else
        mainUIModule:OnCmdCloseLobbyMainPanel()
      end
    end
    bHideAllHUD = true
  end
end

function DebugTabCommon:EnableDebugInfo(Name, Panel)
  _G.EnableLogInfo = true
end

function DebugTabCommon:DisableDebugInfo(Name, Panel)
  _G.EnableLogInfo = false
end

function DebugTabCommon:EnableDebug(Name, Panel)
  Log.Debug("EnableDebug")
  Log.SetLogLevel(Log.LOG_LEVEL.ELogTrace)
  UE4.UNRCStatics.SetLogLevel(8)
  Log.Debug("EnableDebug 1")
  _G.DataConfigManager:ToggleFatalError(true)
end

function DebugTabCommon:DisableDebug(Name, Panel)
  Log.Debug("DisableDebug")
  Log.SetLogLevel(Log.LOG_LEVEL.ELogWarn)
  UE4.UNRCStatics.SetLogLevel(3)
  Log.Debug("DisableDebug 1")
  _G.DataConfigManager:ToggleFatalError(false)
end

function DebugTabCommon:SwitchWeatherState(name, panel, InputText)
  local value
  if panel then
    value = panel.InputBox:GetText()
  else
    value = InputText
  end
  local req = _G.ProtoMessage:newZoneSceneGmReq()
  req.gm_type = 3
  req.gm_op_type = 2
  req.uin = _G.DataModelMgr.PlayerDataModel:GetPlayerUin()
  req.param1 = value
  _G.ZoneServer:Send(_G.ProtoEnum.ZoneSvrGmCmd.ZONE_SCENE_GM_REQ, req)
end

function DebugTabCommon:ShowWeatherState(name, panel)
  local Instance = UE.UNRCPlatformGameInstance.GetInstance()
  local EnvSys = Instance and Instance:GetWorldSubSystem()
  local WeatherSystemValue = EnvSys:GetWeatherStat()
  local EnvModule = _G.NRCModuleManager:GetModule("EnvSystemModule")
  local LuaEnvValue = EnvModule and EnvModule.CurrentWeather or Enum.WeatherType.WT_NONE
  local AreaModule = _G.NRCModuleManager:GetModule("AreaAndZoneModule")
  local AreaEnvValue = AreaModule and AreaModule:GetZoneWeather() or Enum.WeatherType.WT_NONE
  self:Inspect({
    ["\229\144\142\229\143\176\228\184\139\229\143\145\231\154\132\229\164\169\230\176\148"] = table.getKeyName(Enum.WeatherType, AreaEnvValue),
    ["Lua\232\174\164\228\184\186\231\154\132\229\164\169\230\176\148"] = table.getKeyName(Enum.WeatherType, LuaEnvValue),
    ["\229\174\158\233\153\133\231\154\132\229\164\169\230\176\148"] = WeatherSystemValue,
    ["\229\189\147\229\137\141\231\154\132\229\140\186\229\159\159\229\136\151\232\161\168"] = AreaModule.zoneInfoArray:Items()
  }, "\229\164\169\230\176\148\231\179\187\231\187\159")
end

function DebugTabCommon:OpenLevel(name, panel, InputText)
  local value
  if panel then
    value = panel.InputBox:GetText()
  else
    value = InputText
  end
  Log.Debug(value)
  LevelHelper:OpenLevel(value)
end

function DebugTabCommon:ChangeRotationAutoSpeed(name, panel, id)
  if panel then
    local value = panel.InputBox:GetText()
    value = value and tonumber(value) or 0
    NRCEventCenter:DispatchEvent(LoginModuleEvent.GmChangeRotationAutoSpeed, value)
  elseif id then
    local value = id
    NRCEventCenter:DispatchEvent(LoginModuleEvent.GmChangeRotationAutoSpeed, value)
  end
end

function DebugTabCommon:ChangeRotationSensitive(name, panel, id)
  if panel then
    local value = panel.InputBox:GetText()
    value = value and tonumber(value) or 0
    NRCEventCenter:DispatchEvent(LoginModuleEvent.GmChangeRotationSensitive, value)
  elseif id then
    local value = id
    NRCEventCenter:DispatchEvent(LoginModuleEvent.GmChangeRotationSensitive, value)
  end
end

function DebugTabCommon:ChangeRotationFriction(name, panel, id)
  if panel then
    local value = panel.InputBox:GetText()
    value = value and tonumber(value) or 0
    NRCEventCenter:DispatchEvent(LoginModuleEvent.GmChangeRotationFriction, value)
  elseif id then
    local value = id
    NRCEventCenter:DispatchEvent(LoginModuleEvent.GmChangeRotationFriction, value)
  end
end

function DebugTabCommon:SetEnableWorldRendering(name, panel, id)
  if panel then
    local value = panel.InputBox:GetText()
    value = value and tonumber(value) or 0
    local render = true
    if 0 == value then
      render = false
    end
    UE4Helper.SetEnableWorldRendering(render)
  elseif id then
    local value = id
    local render = true
    if 0 == value then
      render = false
    end
    UE4Helper.SetEnableWorldRendering(render)
  end
end

function DebugTabCommon:SetEnableTinyIO(name, panel)
  if _G.isEnableTinyIO == nil or _G.isEnableTinyIO == false then
    _G.isEnableTinyIO = true
    if panel then
      panel.InputBox:SetText("true")
    end
    Log.Warning("Opened TinyIO")
  else
    if panel then
      panel.InputBox:SetText("false")
    end
    _G.isEnableTinyIO = false
    Log.Warning("Closed TinyIO")
  end
end

function DebugTabCommon:DeleteFile()
  JsonUtils.DeleteFile("DebugTab")
  JsonUtils.DeleteFile("SearchTab")
  JsonUtils.DeleteFile("LockSet")
  _G.NRCModeManager:DoCmd(_G.DebugModuleCmd.DeleteFileCMD)
end

function DebugTabCommon:ParseParam(Name, Panel)
  local Map = UE.UNRCStatics.DecodeClipboardParams()
  Log.Dump(Map:ToTable(), "Show Param Table")
end

function DebugTabCommon:LuaWriteGMDataToConfig()
  NRCModuleManager:DoCmd(DebugModuleCmd.LuaWriteGMDataToConfig)
end

function DebugTabCommon:ShowOrHideAllScreenInfo()
  local updateUIModule = _G.NRCModuleManager:GetModule("UpdateUIModule")
  local debugModule = _G.NRCModuleManager:GetModule("DebugModule")
  local battleUIModule = _G.NRCModuleManager:GetModule("BattleUIModule")
  local battlePosition
  local Account = updateUIModule and updateUIModule:GetPanel("AccountInfo")
  local DebugEntry = debugModule:GetPanel("DebugEntry")
  if battleUIModule:HasPanel("BattleMain") then
    battlePosition = battleUIModule:GetPanel("BattleMain")
  end
  if battlePosition then
    if battlePosition:GetVisibility() ~= UE4.ESlateVisibility.SelfHitTestInvisible then
      battlePosition:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      if Account then
        Account.HorizontalBox_58:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        Account.Canvas_Info:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        DebugEntry.IsTextOnActive = true
        DebugEntry.TimeText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        DebugEntry.OpenButton:SetRenderOpacity(1)
        _G.GlobalConfig.CloseDebugPanel = true
      end
    else
      battlePosition:SetVisibility(UE4.ESlateVisibility.Collapsed)
      if Account then
        Account.HorizontalBox_58:SetVisibility(UE4.ESlateVisibility.Collapsed)
        Account.Canvas_Info:SetVisibility(UE4.ESlateVisibility.Collapsed)
        DebugEntry.IsTextOnActive = false
        DebugEntry.TimeText:SetVisibility(UE4.ESlateVisibility.Collapsed)
        DebugEntry.OpenButton:SetRenderOpacity(0)
        _G.GlobalConfig.CloseDebugPanel = true
      end
    end
  elseif Account then
    if Account.HorizontalBox_58:GetVisibility() ~= UE4.ESlateVisibility.SelfHitTestInvisible then
      Account.HorizontalBox_58:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      Account.Canvas_Info:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      DebugEntry.IsTextOnActive = true
      DebugEntry.TimeText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      DebugEntry.OpenButton:SetRenderOpacity(1)
      _G.GlobalConfig.CloseDebugPanel = true
    else
      Account.HorizontalBox_58:SetVisibility(UE4.ESlateVisibility.Collapsed)
      Account.Canvas_Info:SetVisibility(UE4.ESlateVisibility.Collapsed)
      DebugEntry.IsTextOnActive = false
      DebugEntry.TimeText:SetVisibility(UE4.ESlateVisibility.Collapsed)
      DebugEntry.OpenButton:SetRenderOpacity(0)
      _G.GlobalConfig.CloseDebugPanel = true
    end
  end
end

function DebugTabCommon:ShowOrHideScreenInfoInBattle()
  local updateUIModule = _G.NRCModuleManager:GetModule("UpdateUIModule")
  local debugModule = _G.NRCModuleManager:GetModule("DebugModule")
  local battleUIModule = _G.NRCModuleManager:GetModule("BattleUIModule")
  local battlePosition, battleProcess
  local Account = updateUIModule and updateUIModule:GetPanel("AccountInfo")
  local DebugEntry = debugModule:GetPanel("DebugEntry")
  if battleUIModule:HasPanel("BattleMain") then
    battlePosition = battleUIModule:GetPanel("BattleMain")
  end
  if battleUIModule:HasPanel("BattleProcess_Visible") then
    battleProcess = battleUIModule:GetPanel("BattleProcess_Visible")
  end
  if battlePosition then
    if battlePosition.BattlePosition:GetVisibility() ~= UE4.ESlateVisibility.SelfHitTestInvisible then
      battlePosition.BattlePosition:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      if battleProcess and battleProcess:GetVisibility() ~= UE4.ESlateVisibility.SelfHitTestInvisible then
        battleProcess:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
      if Account then
        Account.HorizontalBox_58:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        Account.Canvas_Info:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        DebugEntry.IsTextOnActive = true
        DebugEntry.TimeText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        _G.GlobalConfig.CloseDebugPanel = true
      end
    else
      battlePosition.BattlePosition:SetVisibility(UE4.ESlateVisibility.Collapsed)
      if battleProcess and battleProcess:GetVisibility() == UE4.ESlateVisibility.SelfHitTestInvisible then
        battleProcess:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
      if Account then
        Account.HorizontalBox_58:SetVisibility(UE4.ESlateVisibility.Collapsed)
        Account.Canvas_Info:SetVisibility(UE4.ESlateVisibility.Collapsed)
        DebugEntry.IsTextOnActive = false
        DebugEntry.TimeText:SetVisibility(UE4.ESlateVisibility.Collapsed)
        _G.GlobalConfig.CloseDebugPanel = true
      end
    end
  end
end

function DebugTabCommon:OpenTaskMailPanel()
  _G.NRCModuleManager:DoCmd(TaskModuleCmd.lookLetter, 10012)
end

function DebugTabCommon:ShowAvatarTextureParameter()
  UE4.UAvatarTextureDisplayPanelManager.ShowAvatarTextureParameter()
  self:ClosePanel()
end

function DebugTabCommon:OpenRecallActivity()
  local req = _G.ProtoMessage:newZoneGmOpenStageActivityReq()
  req.activity_id = 15
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_GM_OPEN_STAGE_ACTIVITY_REQ, req)
end

return DebugTabCommon
