local DialogueConst = require("NewRoco.Modules.System.Dialogue.DialogueConst")
local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local CameraUtils = require("NewRoco.Modules.System.Camera.CameraUtils")
local DialogueUtils = require("NewRoco.Modules.System.Dialogue.DialogueUtils")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Base = DebugTabBase
local DebugTabDialogue = Base:Extend("DebugTabDialogue")

function DebugTabDialogue:Ctor()
  Base.Ctor(self)
end

function DebugTabDialogue:SetupTabs()
  self:Add("\230\159\165\231\156\139\229\175\185\232\175\157\233\133\141\231\189\174", self.ShowDialogueConf, self)
  self:Add("\230\183\187\229\138\160\228\184\139\228\184\128\228\184\170\232\167\134\233\162\145", self.AddVideo, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "AddVideo")
end

function DebugTabDialogue:ShowDialogueConf(Name, Panel, Input)
  local ID = Input
  ID = ID or self:GetInputNumber()
  if not ID then
    Log.Error("\230\178\161\230\156\137\232\190\147\229\133\165\229\144\136\233\128\130\231\154\132ID")
    self:ShowTips("\230\178\161\230\156\137\232\190\147\229\133\165\229\144\136\233\128\130\231\154\132ID")
    return
  end
  local Conf = _G.DataConfigManager:GetDialogueConf(ID)
  self:Inspect(Conf or "\230\178\161\230\156\137\230\149\176\230\141\174!!!", string.format("\229\175\185\232\175\157\230\149\176\230\141\174%d", ID))
end

function DebugTabDialogue:PauseVideo()
  local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
  NRCEventCenter:DispatchEvent(DialogueModuleEvent.PauseVideo)
end

function DebugTabDialogue:ResumeVideo()
  local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
  NRCEventCenter:DispatchEvent(DialogueModuleEvent.ResumeVideo)
end

function DebugTabDialogue:HaltVideo()
  local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
  NRCEventCenter:DispatchEvent(DialogueModuleEvent.HaltVideo)
end

function DebugTabDialogue:SwitchCameraDebug()
  CameraUtils.Debug = not CameraUtils.Debug
end

function DebugTabDialogue:SwitchStoryDebugTab()
  Log.Error("Not implemented...")
end

function DebugTabDialogue:SwitchSkipDialogue(Name, Panel)
  DialogueUtils.SkipDialogue = true
  _G.UserSettingManager:SetDialogueAutoPlay(false)
  NRCModuleManager:DoCmd(DialogueModuleCmd.ShowStoryDebugCenter, true)
end

function DebugTabDialogue:SwitchFastDialogue()
  DialogueUtils.SkipTyping = true
  _G.UserSettingManager:SetDialogueAutoPlay(false)
  if DialogueUtils.SkipTyping then
    NRCModuleManager:DoCmd(DialogueModuleCmd.ShowStoryDebugCenter, true)
  end
end

function DebugTabDialogue:ToggleHideDialogueBlack()
  DialogueUtils.ToggleHideDialogueBlack()
end

function DebugTabDialogue:OverrideDoubleUpZoffset(name, panel, id)
  if panel then
    local value = panel.InputBox:GetText()
    DialogueConst.DoubleUpCameraZoffset = tonumber(value)
    Log.Error(DialogueConst.DoubleUpCameraZoffset)
  elseif id then
    local value = id
    DialogueConst.DoubleUpCameraZoffset = tonumber(value)
    Log.Error(DialogueConst.DoubleUpCameraZoffset)
  end
end

function DebugTabDialogue:OverrideFOV(name, panel, id)
  if panel then
    local value = panel.InputBox:GetText()
    DialogueConst.FOV = tonumber(value)
    Log.Error(DialogueConst.FOV)
  elseif id then
    local value = id
    DialogueConst.FOV = tonumber(value)
    Log.Error(DialogueConst.FOV)
  end
end

function DebugTabDialogue:ShowDebugLines()
  DialogueConst.DrawDebugLines = true
end

function DebugTabDialogue:SwitchDialogueAnimation()
  DialogueConst.BlockDialogueAnimation = not DialogueConst.BlockDialogueAnimation
end

function DebugTabDialogue:CloseDebugLines()
  DialogueConst.DrawDebugLines = false
end

function DebugTabDialogue:ModifySpringLength(Name, Panel, InputText)
  local Input
  if Panel then
    Input = Panel.InputBox:GetText()
  else
    Input = InputText
  end
  local Splatted = string.Split(Input, ";")
  local SpringArmLengthBase = tonumber(Splatted[1] or "650") or 650
  local SpringArmLengthFactor = tonumber(Splatted[2] or "1")
  DialogueConst.SpringArmLengthBase = SpringArmLengthBase
  DialogueConst.SpringArmLengthFactor = SpringArmLengthFactor
  DialogueConst.ModifySpringArmLength = not DialogueConst.ModifySpringArmLength
end

function DebugTabDialogue:ModifySpringOffsetHeight(Name, Panel, InputText)
  local Input
  if Panel then
    Input = Panel.InputBox:GetText()
  else
    Input = InputText
  end
  local Splatted = string.Split(Input, ";")
  local SpringArmOffsetHeight = tonumber(Splatted[1] or "0") or 0
  DialogueConst.SpringArmOffsetHeight = SpringArmOffsetHeight
  DialogueConst.ModifySpringArmOffsetHeight = not DialogueConst.ModifySpringArmOffsetHeight
end

function DebugTabDialogue:ModifySpringArmOffset()
  DialogueConst.ModifySpringArmOffset = not DialogueConst.ModifySpringArmOffset
end

function DebugTabDialogue:ModifyOverShoulderCamera(Name, Panel, InputText)
  local Input
  if Panel then
    Input = Panel.InputBox:GetText()
  else
    Input = InputText
  end
  local Splatted = string.Split(Input, ";")
  local SpringArmLengthBase = tonumber(Splatted[1] or "500") or 500
  local SpringArmYawBase = tonumber(Splatted[2] or "10") or 10
  local SetTargetAsOffset = tonumber(Splatted[3] or "0") or 0
  DialogueConst.SpringArmLengthBase = SpringArmLengthBase
  DialogueConst.SpringArmYawBase = SpringArmYawBase
  if 1 == SetTargetAsOffset then
    DialogueConst.SetTargetAsOffset = true
  end
  DialogueConst.ModifyOverShoulder = not DialogueConst.ModifyOverShoulder
end

function DebugTabDialogue:AddTargetAsShoulderMain()
  DialogueConst.SetTargetAsShoulderMain = true
end

function DebugTabDialogue:DeleteTargetAsShoulderMain()
  DialogueConst.SetTargetAsShoulderMain = false
end

function DebugTabDialogue:ShowDialogueBlack(Name, Panel, id)
  if Panel then
    local Number = Panel:GetInputNumber(5011314)
    local Module = _G.NRCModuleManager:GetModule("DialogueModule")
    Module:OpenPanel("DialogueBlack", _G.DataConfigManager:GetDialogueConf(Number))
  elseif id then
    local Number = id
    local Module = _G.NRCModuleManager:GetModule("DialogueModule")
    Module:OpenPanel("DialogueBlack", _G.DataConfigManager:GetDialogueConf(Number))
  end
end

function DebugTabDialogue:CloseDialogueBlack(Name, Panel)
  local Module = _G.NRCModuleManager:GetModule("DialogueModule")
  Module:ClosePanel("DialogueBlack")
end

function DebugTabDialogue:ForceCloseDialogue(Name, Panel)
  local Module = _G.NRCModuleManager:GetModule("DialogueModule")
  Module:OnCloseDialogue()
  Module:CleanUpOptions()
end

function DebugTabDialogue:ShowTaskFetchText(Name, Panel, InputNumber)
  local Number
  if Panel then
    Number = Panel:GetInputNumber(124004)
  else
    Number = tonumber(InputNumber) or 124004
  end
  local Module = _G.NRCModuleManager:GetModule("DialogueModule")
  Module:OpenPanel("TaskFetchText", _G.DataConfigManager:GetDialogueConf(Number))
  _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.OpenOrClosePanel)
end

function DebugTabDialogue:CloseTaskFetchText(Name, Panel)
  local Module = _G.NRCModuleManager:GetModule("DialogueModule")
  Module:ClosePanel("TaskFetchText")
end

function DebugTabDialogue:ForceInteract(name, panel)
  local NPC = self:GetNearestNpc()
  if not NPC then
    return
  end
  local OptionID = NPC.config.option_id[1] or 0
  local OptionData = NPC.serverData.npc_interact.option_infos[1]
  if 0 == OptionID or not OptionData then
    return
  end
  local req = ProtoMessage:newZoneSceneNpcNextActReq()
  req.option_id = OptionID
  req.npc_id = NPC.serverData.base.actor_id
  req.first_act = true
  req.battle_radius = _G.BattleConst.Define.BattleFieldRange
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_SCENE_NPC_NEXT_ACT_REQ, req, self, self.OnForceInteractResult, true, false)
  if panel then
    panel:DoClose()
  end
end

function DebugTabDialogue:OnForceInteractResult(rsp)
  Log.Dump(rsp, 2, "Force Interact Result")
end

function DebugTabDialogue:ShowServerActions(name, panel)
  local DialogueModule = _G.NRCModuleManager:GetModule("DialogueModule")
  local fsm = DialogueModule.DialogueFsm
  local Payload = {
    Actions = DialogueModule.CachedActions,
    CurrentOption = fsm:GetProperty("CurrentOption"),
    CurrentDialogue = fsm:GetProperty("CurrentDialogue")
  }
  self:Inspect(Payload, "Actions")
end

local function string_split(inputStr, delimiter)
  local result = {}
  local from = 1
  local delim_from, delim_to = string.find(inputStr, delimiter, from)
  while delim_from do
    table.insert(result, string.sub(inputStr, from, delim_from - 1))
    from = delim_to + 1
    delim_from, delim_to = string.find(inputStr, delimiter, from)
  end
  table.insert(result, string.sub(inputStr, from))
  return result
end

function DebugTabDialogue:AddVideo(name, panel, InputStr)
  local inputStr
  if panel then
    inputStr = panel:GetInputString()
  else
    inputStr = InputStr
  end
  local movieName = ""
  local soundID = ""
  local subtitleTrackID = ""
  local audioState = "Story"
  local mp4_id = tonumber(inputStr)
  if mp4_id and mp4_id > 0 then
    local movie_conf = _G.DataConfigManager:GetMovieConf(mp4_id)
    if movie_conf then
      movieName = string.Substr(movie_conf.movie_path, string.len("Movies/") + 1, string.len(movie_conf.movie_path) - string.len(".mp4"))
      soundID = movie_conf.sound_id
      subtitleTrackID = movie_conf.subtitle_track_id
      audioState = movie_conf.audio_state
    else
      Log.Warning("Please input Movie Path, Maybe like xunyou_1080")
      return
    end
  elseif not string.StartsWith(inputStr, "http") then
    resultArr = string_split(inputStr, ":")
    if table.len(resultArr) > 0 then
      movieName = resultArr[1]
    end
    if table.len(resultArr) > 1 then
      soundID = tonumber(resultArr[2])
    end
    if table.len(resultArr) > 2 then
      subtitleTrackID = tonumber(resultArr[3])
    end
    if table.len(resultArr) > 3 then
      audioState = tostring(resultArr[4])
    end
  else
    movieName = inputStr
  end
  if not movieName then
    Log.Warning("Please input Movie Path, Maybe like xunyou_1080")
    return
  end
  UE.UNRCStatics.ExecConsoleCommand("log LogMediaAssets VeryVerbose", nil)
  UE.UNRCStatics.ExecConsoleCommand("log LogAndroidMedia VeryVerbose", nil)
  UE.UNRCStatics.ExecConsoleCommand("log LogAndroidMediaPlayerStreamer VeryVerbose", nil)
  UE.UNRCStatics.ExecConsoleCommand("log LogAndroidMediaFactory VeryVerbose", nil)
  local param = {}
  param.Conf = {}
  param.Conf.end_black = 1
  param.Conf.begin_black = 1
  param.Conf.begin_black_fade_in = 1
  if UE4.UBlueprintPathsLibrary.FileExists(movieName) then
    param.Conf.movie_path = movieName
  elseif not string.StartsWith(movieName, "Movies/") and not string.StartsWith(movieName, "http") then
    if not string.EndsWith(movieName, ".mp4") then
      param.Conf.movie_path = string.format("Movies/%s.mp4", movieName)
    else
      param.Conf.movie_path = string.format("Movies/%s", movieName)
    end
  elseif string.StartsWith(movieName, "Movies/") then
    if not string.EndsWith(movieName, ".mp4") then
      param.Conf.movie_path = string.format("%s.mp4", movieName)
    end
  elseif string.StartsWith(movieName, "http") then
    param.Conf.movie_path = movieName
    param.Conf.isUrl = true
  else
    param.Conf.movie_path = string.format("Movies/%s.mp4", movieName)
  end
  param.Conf.sound_id = soundID
  param.Conf.subtitle_track_id = subtitleTrackID
  param.Conf.audio_state = audioState
  _G.NRCModuleManager:DoCmd(_G.DialogueModuleCmd.DebugAddVideo, param)
end

function DebugTabDialogue:PlayVideo(name, panel, InputStr)
  local inputStr
  if panel then
    inputStr = panel:GetInputString()
  else
    inputStr = InputStr
  end
  local movieName = ""
  local soundID = ""
  local subtitleTrackID = ""
  local audioState = "Story"
  local mp4_id = tonumber(inputStr)
  if mp4_id and mp4_id > 0 then
    local movie_conf = _G.DataConfigManager:GetMovieConf(mp4_id)
    if movie_conf then
      if not string.StartsWith(movie_conf.movie_path, "http") then
        movieName = string.Substr(movie_conf.movie_path, string.len("Movies/") + 1, string.len(movie_conf.movie_path) - string.len(".mp4"))
      else
        movieName = movie_conf.movie_path
      end
      soundID = movie_conf.sound_id
      subtitleTrackID = movie_conf.subtitle_track_id
      audioState = movie_conf.audio_state
    else
      Log.Warning("Please input Movie Path, Maybe like xunyou_1080")
      return
    end
  elseif not string.StartsWith(inputStr, "http") then
    if UE4.UBlueprintPathsLibrary.FileExists(inputStr) then
      movieName = inputStr
    else
      resultArr = string_split(inputStr, ":")
      if table.len(resultArr) > 0 then
        movieName = resultArr[1]
      end
      if table.len(resultArr) > 1 then
        soundID = tonumber(resultArr[2])
      end
      if table.len(resultArr) > 2 then
        subtitleTrackID = tonumber(resultArr[3])
      end
      if table.len(resultArr) > 3 then
        audioState = tostring(resultArr[4])
      end
    end
  else
    movieName = inputStr
  end
  if not movieName then
    Log.Warning("Please input Movie Path, Maybe like xunyou_1080")
    return
  end
  UE.UNRCStatics.ExecConsoleCommand("log LogMediaAssets VeryVerbose", nil)
  UE.UNRCStatics.ExecConsoleCommand("log LogAndroidMedia VeryVerbose", nil)
  UE.UNRCStatics.ExecConsoleCommand("log LogAndroidMediaPlayerStreamer VeryVerbose", nil)
  UE.UNRCStatics.ExecConsoleCommand("log LogAndroidMediaFactory VeryVerbose", nil)
  local param = {}
  param.Conf = {}
  param.Conf.end_black = 1
  param.Conf.begin_black = 1
  param.Conf.begin_black_fade_in = 1
  if UE4.UBlueprintPathsLibrary.FileExists(movieName) then
    param.Conf.movie_path = movieName
  elseif not string.StartsWith(movieName, "Movies/") and not string.StartsWith(movieName, "http") then
    if not string.EndsWith(movieName, ".mp4") then
      param.Conf.movie_path = string.format("Movies/%s.mp4", movieName)
    else
      param.Conf.movie_path = string.format("Movies/%s", movieName)
    end
  elseif string.StartsWith(movieName, "Movies/") then
    if not string.EndsWith(movieName, ".mp4") then
      param.Conf.movie_path = string.format("%s.mp4", movieName)
    end
  elseif string.StartsWith(movieName, "http") then
    param.Conf.movie_path = movieName
    param.Conf.isUrl = true
  else
    param.Conf.movie_path = string.format("Movies/%s.mp4", movieName)
  end
  param.Conf.sound_id = soundID
  param.Conf.subtitle_track_id = subtitleTrackID
  param.Conf.audio_state = audioState
  _G.NRCModuleManager:DoCmd(_G.DialogueModuleCmd.PlayVideo, param)
  _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.OpenOrClosePanel)
end

function DebugTabDialogue:DebugPlayVideo(name, panel, MovieName)
  local movieName
  if panel then
    movieName = panel:GetInputString()
  else
    movieName = MovieName
  end
  if not movieName then
    Log.Warning("Please input Movie Path")
    return
  end
  moviePath = string.format("Movies/%s.mp4", movieName)
  _G.NRCModuleManager:DoCmd(_G.UpdateUIModuleCmd.DebugPlayVideo, moviePath)
  _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.OpenOrClosePanel)
end

function DebugTabDialogue:StopPlayVideo(name, panel)
  _G.NRCModuleManager:DoCmd(_G.UpdateUIModuleCmd.StopPlayVideo)
end

function DebugTabDialogue:DebugPlayAudio(name, panel)
  _G.NRCAudioManager:PlaySound2DAuto(9031, "")
end

function DebugTabDialogue:StopPlayingVideo(name, panel)
  NRCModeManager:GetCurMode():DisablePanelByLayer(Enum.UILayerType.UI_LAYER_MAIN)
  local DialogueModule = _G.NRCModuleManager:GetModule("DialogueModule")
  local DialogueVideo = DialogueModule:GetPanel("DialogueVideo")
  if DialogueVideo then
    DialogueVideo:MovieDone()
  end
end

function DebugTabDialogue:LogDialogueFsm(Name, Panel)
  local Module = self:GetModule("DialogueModule")
  if _G.NRCModuleManager:DoCmd(_G.DialogueModuleCmd.HasDialogue) then
    Log.Error("\230\173\163\229\156\168\229\175\185\232\175\157\228\184\173")
  else
    Log.Error("\229\189\147\229\137\141\228\184\141\229\156\168\229\175\185\232\175\157\228\184\173\239\188\140\229\190\136\229\165\135\229\166\153")
  end
  Log.Error("Current Dialogue: ", table.tostring(Module.DialogueFsm:GetProperty("CurrentDialogue")))
  Log.Error("", table.tostring(Module.DialogueFsm:GetProperty("NextConfID")))
  local activeActions = Module.DialogueFsm.activeState.activeActions
  Log.Error("\229\189\147\229\137\141\230\137\128\229\177\158\231\154\132State\230\152\175", Module.DialogueFsm.activeState.name)
  for _, Action in ipairs(activeActions) do
    Log.Error("\230\173\163\229\156\168\230\146\173\230\148\190\231\154\132Action\230\152\175", Action.name)
  end
  local CurrentOption = Module.DialogueFsm:GetProperty("CurrentOption")
  local TargetNPC = Module.DialogueFsm:GetProperty("TargetNPC")
  for option, Actions in pairs(Module.CachedActions or {}) do
    Log.Error("\232\174\169\230\136\145\228\187\172\230\159\165\230\159\165\231\156\139CachedActions\231\154\132\230\131\133\229\134\181\229\144\167 ", option, table.tostring(Actions or {}))
  end
  if TargetNPC then
    Log.Error("Target NPC: ", table.tostring(TargetNPC.serverData or {}))
  end
  for id, option in pairs(TargetNPC.InteractionComponent._options or {}) do
    Log.Error("\232\186\171\228\184\138\231\154\132Option\230\156\137", id, option, table.tostring(option.optionInfo or {}))
    Log.Error("\232\191\153\228\184\170Option\231\154\132config\230\152\175", table.tostring(option.config or {}))
  end
  Log.Error("\229\175\185\232\175\157\228\184\173\231\154\132Option\230\152\175", CurrentOption, table.tostring(CurrentOption.optionInfo or {}))
  Log.Error("\232\191\153\228\184\170Option\231\154\132config\230\152\175", table.tostring(CurrentOption.config or {}))
end

function DebugTabDialogue:SwitchLookAtDebug()
  GlobalConfig.DrawDebugLookAt = not GlobalConfig.DrawDebugLookAt
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, GlobalConfig.DrawDebugLookAt and "\229\144\175\231\148\168\230\156\157\229\144\145\232\176\131\232\175\149" or "\229\133\179\233\151\173\230\156\157\229\144\145\232\176\131\232\175\149")
end

function DebugTabDialogue:StartTalk(Name, Panel)
  local Speaker = self:GetNearestNpc()
  local View = Speaker.viewObj
  local MeshComp = View and View.Mesh
  local AnimInstance = MeshComp and MeshComp:GetAnimInstance()
  if not AnimInstance then
    self:ShowTips("\230\151\160\230\179\149\230\137\190\229\136\176\232\167\146\232\137\178\232\186\171\228\184\138\231\154\132AnimInstance", View and UE.UObject.GetName(View) or "\230\178\161\230\156\137ViewObject")
    self:ClosePanel()
    return
  end
  if not AnimInstance:IsA(UE.UCharacterEmotionAnimInstance) then
    self:ShowTips("\232\191\153\228\184\170NPC\232\174\178\228\184\141\228\186\134\232\175\157")
    self:ClosePanel()
    return
  end
  local AudioDataName = self:GetInputString()
  if string.IsNilOrEmpty(AudioDataName) then
    AudioDataName = "JQ01_YIXI_CN_C001"
  end
  local AudioDataPath = string.format("/Game/ArtRes/BP/Lipsync/%s", AudioDataName)
  local AudioData = _G.NRCResourceManager:LoadUObjectForDebugOnly(AudioDataPath)
  if not AudioData then
    self:ShowTips("\232\175\183\231\161\174\228\191\157\232\191\153\228\184\170\232\175\173\233\159\179\232\181\132\228\186\167\229\173\152\229\156\168", AudioDataPath)
    self:ClosePanel()
    return
  end
  AnimInstance:PlayEmotion(AudioData, 0.1)
  _G.NRCAudioManager:PlaySound2DByEventNameAuto(AudioDataName)
  self:ShowTips(string.format("%s\232\166\129\229\188\128\229\167\139\232\174\178\232\175\157\228\186\134%s", UE.UObject.GetName(View), UE.UObject.GetName(AudioData)))
  self:ClosePanel()
end

function DebugTabDialogue:PlayDialogue(name, panel, id1, id2)
  local req = ProtoMessage:newZoneSceneGmReq()
  local inputText
  if panel then
    inputText = panel.InputBox:GetText()
  end
  local numbers = {}
  for number in inputText:gmatch("%d+") do
    table.insert(numbers, tonumber(number))
  end
  local ID1 = tonumber(id1)
  local ID2 = tonumber(id2)
  req.gm_type = _G.ProtoEnum.SceneGmType.SGT_TASK_DIALOGUE
  req.param1 = ID1 or numbers[1]
  req.param2 = ID2 or numbers[2]
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_REQ, req, self, self.GetRsp)
end

function DebugTabDialogue:PlayDialogueTree(name, panel, id)
  local req = ProtoMessage:newZoneSceneGmReq()
  local num = tonumber(id)
  local IDNum
  if panel then
    IDNum = panel:GetInputNumber()
  else
    IDNum = num
  end
  req.gm_type = _G.ProtoEnum.SceneGmType.SGT_DIALOGUE
  req.param1 = IDNum
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_REQ, req, self, self.GetRsp)
end

function DebugTabDialogue:FinishDialogueAction()
  local req = ProtoMessage:newZoneSceneGmReq()
  req.gm_type = _G.ProtoEnum.SceneGmType.SGT_COMMIT_ACTION
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_REQ, req, self, self.GetRsp)
end

function DebugTabDialogue:GetRsp()
end

function DebugTabDialogue:StartContentOption(Name, Panel, ID1, ID2)
  local Params
  if Panel then
    local InputString = Panel:GetInputString()
    Params = string.split(InputString, ",")
    for i = 1, #Params do
      Params[i] = tonumber(Params[i])
    end
  else
    Params = {}
  end
  local ContentID = Params[1] or ID1
  local OptionID = Params[2] or ID2
  local ContentConf = _G.DataConfigManager:GetNpcRefreshContentConf(ContentID)
  if not ContentConf then
    self:ShowTips("\230\159\165\232\175\162\228\184\141\229\136\176\228\188\160\229\133\165\231\154\132ContentID")
    return
  end
  local AreaID = ContentConf.refresh_param
  local AreaConf = _G.DataConfigManager:GetAreaConf(AreaID)
  if not AreaConf then
    self:ShowTips("\230\159\165\232\175\162\228\184\141\229\136\176\228\188\160\229\133\165\231\154\132Area")
    return
  end
  if SceneUtils.GetSceneID() ~= AreaConf.scene_id then
    self:ShowTips("\229\156\186\230\153\175\228\184\141\229\144\140\239\188\140\230\151\160\230\179\149\232\183\179\232\189\172")
    return
  end
  if 0 == #AreaConf.pos then
    self:ShowTips("\230\159\165\230\137\190\228\184\141\229\136\176\229\136\183\230\150\176\231\130\185")
    return
  end
  local Pos = AreaConf.pos[1]
  self:SetPlayerLocation(Pos.position_xyz[1] + 100, Pos.position_xyz[2] + 100, Pos.position_xyz[3] + 780, true)
  _G.DelayManager:DelaySeconds(2, self.DialogueCreateNPC, self, ContentID, OptionID, Pos)
end

function DebugTabDialogue:DialogueCreateNPC(ContentID, OptionID, Pos)
  self.ContentID = ContentID
  self.OptionID = OptionID
  local Point = ProtoMessage:newPoint()
  Point.pos.x = math.round(Pos.position_xyz[1])
  Point.pos.y = math.round(Pos.position_xyz[2])
  Point.pos.z = math.round(Pos.position_xyz[3])
  Point.dir.z = math.round(Pos.rotation_xyz[1])
  Point.dir.x = math.round(Pos.rotation_xyz[2])
  Point.dir.y = math.round(Pos.rotation_xyz[3])
  local req = ProtoMessage:newZoneGmCreateNpcReq()
  req.content_cfg_id = ContentID
  req.npc_pos = Point
  req.only_test = true
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_CREATE_NPC_REQ, req, self, self.OnServerCreateDebugNPC)
end

function DebugTabDialogue:OnServerCreateDebugNPC(rsp)
  _G.DelayManager:DelaySeconds(2, self.PutOptionOnContent, self, self.ContentID, self.OptionID)
  self.ContentID = 0
  self.OptionID = 0
end

function DebugTabDialogue:PutOptionOnContent(ContentID, OptionID)
  local Req = ProtoMessage:newZoneSceneGmReq()
  Req.gm_type = 22
  Req.param1 = ContentID
  Req.param2 = OptionID
  _G.ZoneServer:Send(ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_REQ, Req)
end

return DebugTabDialogue
