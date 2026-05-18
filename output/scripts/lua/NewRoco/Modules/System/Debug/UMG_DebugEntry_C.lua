local DebugModuleEvent = reload("NewRoco.Modules.System.Debug.DebugModuleEvent")
local OnlineModuleEvent = reload("NewRoco.Modules.Core.Online.OnlineModuleEvent")
local DeviceUtils = reload("NewRoco.Modules.Core.App.DeviceUtils")
local DeviceEvent = reload("NewRoco.Modules.Core.App.DeviceEvent")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local JsonUtils = require("Common.JsonUtils")
local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local UMG_DebugEntry_C = _G.NRCPanelBase:Extend("UMG_DebugEntry_C")

local function GetDeviceInfoStr()
  local map = {
    [0] = "\228\189\142",
    [1] = "\228\184\173",
    [2] = "\233\171\152",
    [3] = "\230\158\129\233\171\152",
    [4] = "\232\135\170\229\174\154\228\185\137"
  }
  local level = UE4.UNRCQualityLibrary.GetImageQuality()
  local userLevel = map[level]
  local deviceInfo
  if userLevel then
    deviceInfo = string.format("DeviceLevel:%d(%s)", UE4.UNRCQualityLibrary.GetImageQuality_InternalValue(), userLevel)
  else
    deviceInfo = string.format("DeviceLevel:%d(error)", UE4.UNRCQualityLibrary.GetImageQuality_InternalValue())
  end
  if 3 == level then
    deviceInfo = string.format("<span size=\"15\" color=\"#98FB98\">%s</>", deviceInfo)
  elseif 2 == level then
    deviceInfo = string.format("<span size=\"15\" color=\"#7FFF00\">%s</>", deviceInfo)
  elseif 1 == level then
    deviceInfo = string.format("<span size=\"15\" color=\"#FFDEAD\">%s</>", deviceInfo)
  elseif 0 == level then
    deviceInfo = string.format("<span size=\"15\" color=\"#FF0000\">%s</>", deviceInfo)
  end
  return deviceInfo
end

function UMG_DebugEntry_C:OnConstruct()
  self.frameCount = 0
  self.SkipFrame = 5
  self.IsOnClick = false
  self.IsTextOnActive = true
  self.isshowloction = false
  self.isShowTimeAndWeather = false
  self.ShowNPCData = false
  self.IsNpcInfo = false
  self.PrintCurInfo = 0
  self.local_time = 0
  self.local_time_last = 0
  self.OtherPlayerState = {}
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.ServerBuildTime = ""
  self.ServerCurrentTime = ""
  self.ServerBusInfo = ""
  self.ClientVersionInfo = ""
  self.PlayerInfo = ""
  self.DeviceInfo = GetDeviceInfoStr()
  self.LocalGameTime = ""
  self.LocalWeather = ""
  self.ServerSceneInfo = ""
  if self.Segmentation then
    self.Segmentation:SetText("")
  end
  if self.Temperature then
    self.Temperature:SetText("")
  end
  if self.module.ServerInfoNotify then
    self:MakeServerInfo(self.module.ServerInfoNotify)
  end
  if RocoEnv.IS_EDITOR then
    local Branch, Success = nil, false
    if UE.UNRCStatics.GetSvnBranch then
      Branch, Success = UE.UNRCStatics.GetSvnBranch(UE.UBlueprintPathsLibrary.ProjectDir())
    end
    local str = string.format("\229\174\162\230\136\183\231\171\175\229\136\134\230\148\175:%s\n", Success and Branch or "\230\156\170\231\159\165")
    str = string.format("%s%s", str, self:GetSvnInfoAtPath("Project", UE.UBlueprintPathsLibrary.ProjectDir()))
    str = string.format("%s%s", str, self:GetSvnInfoAtPath("Engine", UE.UBlueprintPathsLibrary.EngineDir()))
    str = string.format("%s%s", str, self:GetSvnInfoAtPath("ArtRes", UE.UBlueprintPathsLibrary.Combine({
      UE.UBlueprintPathsLibrary.ProjectContentDir(),
      "ArtRes"
    })))
    str = string.format("%s%s", str, self:GetSvnInfoAtPath("Script", UE.UBlueprintPathsLibrary.Combine({
      UE.UBlueprintPathsLibrary.ProjectContentDir(),
      "Script"
    }), ""))
    self.ClientVersionInfo = str
    Log.Debug("ClientVersionInfo:", self.ClientVersionInfo)
  else
    local AppMain = _G.AppMain
    local curPlatform
    if RocoEnv.PLATFORM == "PLATFORM_ANDROID" then
      curPlatform = "Android"
    elseif RocoEnv.PLATFORM == "PLATFORM_OPENHARMONY" then
      curPlatform = "OpenHarmony:"
    elseif RocoEnv.PLATFORM == "PLATFORM_WINDOWS" then
      curPlatform = "PC"
    else
      curPlatform = "IOS"
    end
    local Branch = AppMain.ProjectBranch
    if string.StartsWith(Branch, "branches/") then
      Branch = Branch:sub(10)
    end
    self.ClientVersionInfo = string.format("%s(%s):%s\n\229\174\162\230\136\183\231\171\175\230\158\132\229\187\186\239\188\154%s(%s)\n", curPlatform, AppMain.ProjectBranch, AppMain:GetAppVersion(), tostring(AppMain:GetResRevision()), AppMain:GetBuildStartTime() or "no_time")
  end
  if RocoEnv.PLATFORM_IOS then
    UE4.UNRCQualityLibrary.ReSetFrameQuality()
  end
  self:AddButtonListener(self.OpenButton, self.TogglePanel)
  self:AddButtonListener(self.ControlTextButton, self.ControlText)
  self:RegisterEvent(self, DebugModuleEvent.OpenOrCloseDebugPanel, self.OnOpenOrCloseDebugPanel)
  self:RegisterEvent(self, DebugModuleEvent.ShowPlayerLoction, self.IsShowloction)
  self:RegisterEvent(self, DebugModuleEvent.ShowTimeAndWeather, self.ShowTimeAndWeather)
  self:RegisterEvent(self, DebugModuleEvent.ShowVisiblePoolInfo, self.ShowVisiblePoolInfo)
  self:RegisterEvent(self, DebugModuleEvent.ShowOrHideDungeonStageInfoText, self.ShowOrHideDungeonStageInfoText)
  self:RegisterEvent(self, DebugModuleEvent.ShowDungeonStageInfo, self.ShowDungeonStageInfo)
  self:RegisterEvent(self, DebugModuleEvent.SetTemperature, self.OnSetTemperature)
  self:RegisterEvent(self, DebugModuleEvent.ShowTemperature, self.OnShowTemperature)
  self:RegisterEvent(self, DebugModuleEvent.ShowNpcInfo, self.IsShowNpcInfo)
  self:RegisterEvent(self, DebugModuleEvent.CloseControlText, self.ControlTextData)
  self:RegisterEvent(self, DebugModuleEvent.SetUiAlpha, self.ChangBG)
  self:RegisterEvent(self, DebugModuleEvent.ToggleNPCStat, self.ToggleNPCData)
  self:RegisterEvent(self, DebugModuleEvent.TopHud_ShowZoneTip, self.OnShowZoneTips)
  _G.NRCEventCenter:RegisterEvent("UMG_DebugEntry_C", self, SceneEvent.OnEnterSceneFinishNtyAck, self.OnEnterSceneFinishNtyAckCallBack)
  _G.ZoneServer:AddProtocolListener(self, ProtoCMD.ZoneSvrGmCmd.ZONE_GM_GET_DUNGEON_CUR_STAGE_RSP, self.OnZoneGmGetDungeonCurStageRsp)
  DeviceUtils.EventDispatcher:AddEventListener(self, DeviceEvent.OnQualityChange, self.OnQualityChange)
  self:UpdateTimeText()
end

function UMG_DebugEntry_C:GetSvnInfoAtPath(Name, Path, Sep)
  local revision, time, success = UE.UNRCStatics.ShowRevisionAndTime(Path)
  if not success then
    return ""
  end
  if 0 == revision then
    return ""
  end
  Sep = Sep or "\n"
  return string.format([[
%s:%d
%s%s]], Name, revision, time, Sep)
end

function UMG_DebugEntry_C:OnGetSvrInfoRsp(rsp)
  if rsp.svr_info and rsp.svr_info[3] then
    self.hasCtorSvrBuildTime = true
    self.ServerBuildTime = string.format("\230\156\141\229\138\161\229\153\168\230\158\132\229\187\186\230\151\182\233\151\180(%s):\n%s", rsp.svr_info[1], rsp.svr_info[3])
    self:UpdateTimeText()
  end
end

function UMG_DebugEntry_C:OnDestruct()
  self:UnRegisterEvent(self, DebugModuleEvent.SetUiAlpha, self.ChangBG)
  DeviceUtils.EventDispatcher:RemoveEventListener(self, DeviceEvent.OnQualityChange, self.OnQualityChange)
  if not RocoEnv.IS_SHIPPING then
    _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_LOGIN, self.UpdateServerInfo)
    self:UnRegisterEvent(self, DebugModuleEvent.UpdateSvrTime, self.UpdateSvrTime)
  end
  _G.NRCEventCenter:UnRegisterEvent(self, SceneEvent.OnEnterSceneFinishNtyAck, self.OnEnterSceneFinishNtyAckCallBack)
end

function UMG_DebugEntry_C:OnQualityChange()
  Log.Debug("UMG_DebugEntry_C:OnQualityChange")
  self.DeviceInfo = GetDeviceInfoStr()
  self:UpdateTimeText()
end

function UMG_DebugEntry_C:UpdateSvrTime(svr_time)
  self:UpdateSvrTime_Impl(svr_time, true)
end

function UMG_DebugEntry_C:UpdateSvrTime_Impl(svr_time, bAdjustLocalTime)
  self.svr_time = svr_time
  if bAdjustLocalTime then
    self:AdjustSvrTimeLocally()
  end
  if self.svr_time then
    self.ServerCurrentTime = string.format("\230\156\141\229\138\161\229\153\168\230\151\182\233\151\180:%s", self.svr_time)
    if RocoEnv.IS_EDITOR then
      if bAdjustLocalTime then
        local SvrInfoReq = _G.ProtoMessage:newZoneGmGetSvrInfoReq()
        _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_GM_GET_SVR_INFO_REQ, SvrInfoReq, self, self.OnGetSvrInfoRsp, false, true)
      end
    else
      self:UpdateTimeText()
    end
  end
end

function UMG_DebugEntry_C:UpdateServerInfo()
  local OnlineModule = _G.NRCModuleManager:GetModule("OnlineModule")
  if not OnlineModule then
    return
  end
  local Data = OnlineModule.data
  if self.serverName and Data.serverName and self.serverName ~= Data.serverName then
    self.hasCtorSvrBuildTime = false
  end
  self.serverName = Data.serverName
  if not Data then
    return
  end
  local PlayerUin = 0
  if _G.DataModelMgr.PlayerDataModel and _G.DataModelMgr.PlayerDataModel:GetPlayerInfo() then
    PlayerUin = _G.DataModelMgr.PlayerDataModel:GetPlayerUin()
  end
  self.PlayerInfo = string.format([[
%s:%d
%s
PlayerUin:%d]], Data.serverName, Data.port, Data.userName, PlayerUin or 0)
  self:UpdateTimeText()
  if not RocoEnv.IS_SHIPPING and not self.hasCtorSvrBuildTime then
    local SvrInfoReq = _G.ProtoMessage:newZoneGmGetSvrInfoReq()
    _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_GM_GET_SVR_INFO_REQ, SvrInfoReq, self, self.OnGetSvrInfoRsp, false, true)
  end
end

function UMG_DebugEntry_C:OnOpenOrCloseDebugPanel()
  if not RocoEnv.IS_EDITOR then
    self.IsOnClick = false
    self.frameCount = 0
    self.OnClickNum = 0
    self.ControlTextButton:SetRenderOpacity(0.01)
  end
end

function UMG_DebugEntry_C:TogglePanel()
  _G.NRCSDKManager:PerfBeginMark("DebugPanel")
  _G.NRCSDKManager:PerfBeginExclude("DebugPanel")
  local checkNum = 1
  if RocoEnv.IS_SHIPPING and AppMain:GetFormalPipeline() then
    checkNum = 999999
  end
  if not RocoEnv.IS_EDITOR then
    self.IsOnClick = true
    self.OnClickNum = self.OnClickNum + 1
    if self.OnClickNum == checkNum then
      self.module:Open()
    end
  else
    self.module:Open()
  end
end

function UMG_DebugEntry_C:ControlText()
  self.IsTextOnActive = not self.IsTextOnActive
  self:UpdateTimeText()
end

function UMG_DebugEntry_C:ControlTextData()
  self.IsTextOnActive = not self.IsTextOnActive
  self:UpdateTimeText()
end

function UMG_DebugEntry_C:UpdateTimeText()
  if not self.IsTextOnActive then
    self.TimeText:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return
  end
  if RocoEnv.IS_SHIPPING then
    self.TimeText:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return
  end
  self.TimeText:SetText(string.format([[
%s
%s
%s
%s
%s
%s
%s
%s %s]], self.ServerBuildTime, self.ServerCurrentTime, self.ServerBusInfo, self.ServerSceneInfo, self.ClientVersionInfo, self.PlayerInfo, self.DeviceInfo, self.LocalGameTime, self.LocalWeather))
  self.TimeText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_DebugEntry_C:OnActive()
  if not RocoEnv.IS_EDITOR then
    self.OnClickNum = 0
    self.OpenButton:SetRenderOpacity(0.01)
  else
    self.OpenButton:SetRenderOpacity(0.01)
  end
  self.ControlTextButton:SetRenderOpacity(0.01)
  if RocoEnv.IS_SHIPPING and AppMain:GetFormalPipeline() then
    if 0 == table.len(AppMain.launchParams) then
      self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  else
    _G.NRCEventCenter:RegisterEvent(self.name, self, _G.NRCGlobalEvent.ON_LOGIN, self.UpdateServerInfo)
    self:RegisterEvent(self, DebugModuleEvent.UpdateSvrTime, self.UpdateSvrTime)
  end
end

function UMG_DebugEntry_C:OnTick(deltaTime)
  if self.IsOnClick then
    self.frameCount = self.frameCount + deltaTime
    if self.frameCount >= self.SkipFrame then
      self.frameCount = 0
      self.OnClickNum = 0
      self.IsOnClick = false
    end
  end
  if self.isshowloction then
    local LocalPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    local Instance = UE.UNRCPlatformGameInstance.GetInstance()
    local EnvSys = Instance and Instance:GetWorldSubSystem()
    local WeatherSystemValue = EnvSys:GetWeatherStat()
    if LocalPlayer then
      local PlayRotation = LocalPlayer:GetActorRotation()
      local CameraRotation = LocalPlayer.viewObj:GetController():GetControlRotation()
      local NowHeroPos = LocalPlayer:GetActorLocation()
      if NowHeroPos then
        if not self.IsLeftPanel then
          self.Text_Coordinate:SetText(string.format("%.1f/%.1f/%.1f\nPlayRot\239\188\154%.1f\nCameRot\239\188\154%.1f\nWeather\239\188\154%d", NowHeroPos.X, NowHeroPos.Y, NowHeroPos.Z, PlayRotation.Yaw, CameraRotation.Yaw, WeatherSystemValue))
        else
          self.PrintCurInfo = self.PrintCurInfo + deltaTime
          if self.PrintCurInfo >= 10 then
            self.PrintCurInfo = 0
            local Date = os.date("*t", math.floor(_G.ZoneServer:GetServerTime() / 1000))
            local NowTime = string.format("%d:%d:%d:%d:%d", Date.year, Date.month, Date.day, Date.hour, Date.min)
            local CurInfo = {
              string.format("%s  Name=%s%s  X=%.2f Y=%.2f Z=%.2f", NowTime, _G.DataModelMgr.PlayerDataModel:GetPlayerName(), self.AllDetail, NowHeroPos.X, NowHeroPos.Y, NowHeroPos.Z)
            }
            local PreInfo = JsonUtils.LoadSaved("loc_records", {})
            if nil ~= PreInfo then
              table.insert(PreInfo, CurInfo)
              JsonUtils.DumpSaved("loc_records", PreInfo)
            else
              JsonUtils.DumpSaved("loc_records", CurInfo)
            end
          end
          self.Text_X:SetText(string.format("X=%.2f,", NowHeroPos.X))
          self.Text_Y:SetText(string.format("Y=%.2f,", NowHeroPos.Y))
          self.Text_Z:SetText(string.format("Z=%.2f", NowHeroPos.Z))
          local x = math.ceil((NowHeroPos.X - 4800) / 50400)
          local y = math.ceil((NowHeroPos.Y - 4800) / 50400)
          self.Segmentation:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
          self.Segmentation:SetText(string.format("X%d-Y%d", x, y))
          self.Text_Time:SetText(os.date("%Y-%m-%d %H:%M:%S"))
        end
      end
    end
  else
    self.Segmentation:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  local EnvSystemModule = _G.NRCModuleManager:GetModule("EnvSystemModule")
  if EnvSystemModule and EnvSystemModuleCmd then
    local time = _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.GetCurrentTime)
    if time and type(time) == "number" then
      local hour = math.floor(time / 3600)
      local min = math.floor((time - hour * 3600) / 60)
      if min < 10 then
        min = "0" .. min
      end
      if hour < 10 then
        hour = "0" .. hour
      end
      self.LocalGameTime = hour .. ":" .. min
    else
      self.LocalGameTime = ""
    end
  end
  if self.isShowTimeAndWeather then
    self.Text_TimeNew:SetText(self.LocalGameTime)
  end
  if self.IsNpcInfo then
    local npcs = _G.NRCModuleManager:DoCmd(NPCModuleCmd.GetTopKNPC, self)
    if npcs and #npcs > 0 then
      npcs = npcs[1]
      self.NRCSwitcher_0:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      local Player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
      local View = Player and Player.viewObj
      if not View then
        return
      end
      local PlayerLocation = Player.viewObj:Abs_K2_GetActorLocation()
      local NpcLocationInfo = npcs.serverData
      local NpcLocation = string.format([[
%d,%d
%u,%d]], npcs.config.id, NpcLocationInfo.npc_base.npc_content_cfg_id or 0, NpcLocationInfo.base.actor_id, NpcLocationInfo.base.actor_id)
      self.Name:SetText(string.format("%s:%s", npcs.serverData.base.name, NpcLocation))
      local LocationInfo = string.format("\229\189\147\229\137\141\228\186\186\231\137\169\228\189\141\231\189\174 %f,%f,%f", PlayerLocation.X, PlayerLocation.Y, PlayerLocation.Z)
      self.CurCharacterPosition:SetText(LocationInfo)
      local ControllerInfo = string.format("\230\152\175\229\144\166\232\162\171\230\156\172\229\156\176\231\142\169\229\174\182\230\142\167\229\136\182?%s", npcs:IsControlledByPlayer() and " \230\152\175 " or " \229\144\166 ")
      self.IsLocalPlayerControl:SetText(ControllerInfo)
      local NPCOwnerInfo = string.format("NPC Creator: %u", npcs:GetCreatorID())
      self.NpcCreator:SetText(NPCOwnerInfo)
      local WorldOwnerInfo = string.format("World Owner: %u", npcs:GetWorldOwnerID())
      self.WorldOwner:SetText(WorldOwnerInfo)
    elseif npcs and 0 == #npcs then
      self.NRCSwitcher_0:SetVisibility(UE4.ESlateVisibility.Hidden)
    end
  end
  self:TickSvrTimeLocally(deltaTime)
end

function UMG_DebugEntry_C:ToggleNPCData()
  self.ShowNPCData = not self.ShowNPCData
  if self.ShowNPCData then
    self.NPCText:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self:SetNPCData(self.CacheData)
  else
    self.NPCText:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

function UMG_DebugEntry_C:SetNPCData(NumData)
  self.CacheData = NumData
  if not self.ShowNPCData then
    return
  end
  if not NumData then
    return
  end
  self.NPCText:SetText(string.format("X=%d,Y=%d,Z=%d\n\230\128\187\230\149\176:%d/%d\n\229\164\167\232\167\134\233\135\142NPC:%d\n\230\156\128\229\176\143\230\157\131\229\128\188:%d", NumData.pos.x, NumData.pos.y, NumData.pos.z, NumData.view_num, NumData.total_num, NumData.total_advance_npc_num, NumData.min_weight))
end

function UMG_DebugEntry_C:MakeServerInfo(notify)
  self.ServerBusInfo = string.format("\230\156\141\229\138\161\229\153\168\231\156\159\229\174\158\230\151\182\233\151\180:%s\n\230\156\141\229\138\161\229\153\168: zone:%s scene:%s btle:%s\n\229\173\152\230\161\163\230\151\182\233\151\180: player:%s avatar:%s\ncell:%s", os.date("%Y-%m-%d %H:%M:%S", math.floor((_G.ZoneServer:GetServerTime() - (notify.faketime_offset_in_millis or 0)) / 1000)), notify.zonesvr_buspp_inst_id, notify.scenesvr_buspp_inst_id, notify.battlesvr_buspp_inst_id, notify.zone_player_last_sync_time, notify.scene_last_update_timestamp_in_us, notify.cell_id)
end

function UMG_DebugEntry_C:SetServerInfo(notify)
  self:MakeServerInfo(notify)
  self:UpdateTimeText()
end

function UMG_DebugEntry_C:IsShowloction(_leftPanel)
  self.isshowloction = not self.isshowloction
  local PlayModule = _G.NRCModuleManager:GetModule("PlayerModule")
  if not _leftPanel then
    self.IsLeftPanel = false
    self.Text_Coordinate:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.NRCSwitcher_0:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if self.isshowloction and PlayModule then
      self.Text_Coordinate:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.isshowloction = true
    else
      self.isshowloction = false
      self.Segmentation:SetText("")
      self.Text_Coordinate:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  else
    self.IsLeftPanel = true
    self.NRCSwitcher_0:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.NRCSwitcher_0:SetActiveWidgetIndex(0)
    self.Text_Coordinate:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if self.isshowloction and PlayModule then
      local AppMain = _G.App
      local curDevice
      local deviceProfileName = string.match(UE4.UNRCQualityLibrary.GetDeviceDetail(), "DeviceMakeAndModel:(%w+)")
      if RocoEnv.PLATFORM == "PLATFORM_ANDROID" then
        curDevice = "Android:"
        self.DeviceName:SetText(deviceProfileName)
      elseif RocoEnv.PLATFORM == "PLATFORM_OPENHARMONY" then
        curDevice = "OpenHarmony:"
        self.DeviceName:SetText(deviceProfileName)
      elseif RocoEnv.PLATFORM == "PLATFORM_WINDOWS" and not RocoEnv.IS_EDITOR then
        curDevice = "PC"
      elseif RocoEnv.PLATFORM == "PLATFORM_WINDOWS" and RocoEnv.IS_EDITOR then
        curDevice = "Editor:"
        self.DeviceName:SetText(deviceProfileName)
      else
        curDevice = "IOS:"
        self.DeviceName:SetText(deviceProfileName)
      end
      self.label_app:SetText(curDevice)
      self.TxtAppVersion:SetText(AppMain:GetAppVersion())
      self.AllDetail = "  " .. curDevice .. " " .. AppMain:GetAppVersion()
      self.NRCSwitcher_0:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.NRCSwitcher_0:SetActiveWidgetIndex(0)
      self.isshowloction = true
      local OnlineModule = _G.NRCModuleManager:GetModule("OnlineModule")
      if OnlineModule and OnlineModule.data then
        self.Text_ServeName:SetText(OnlineModule.data.serverName)
      else
        Log.Debug("UMG_DebugEntry_C:IsShowloction OnlineModule is nil")
      end
    else
      self.isshowloction = false
      self.Segmentation:SetText("")
      self.NRCSwitcher_0:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_DebugEntry_C:ShowTimeAndWeather()
  if self.Panel_TimeAndWeather and self.Panel_TimeAndWeather:GetVisibility() == UE4.ESlateVisibility.Collapsed then
    self.isShowTimeAndWeather = true
    self.Panel_TimeAndWeather:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:RefreshWeather()
  elseif self.Panel_TimeAndWeather and self.Panel_TimeAndWeather:GetVisibility() == UE4.ESlateVisibility.SelfHitTestInvisible then
    self.isShowTimeAndWeather = false
    self.Panel_TimeAndWeather:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_DebugEntry_C:RefreshWeather(weather)
  if self.isShowTimeAndWeather then
    if weather and weather ~= Enum.WeatherType.WT_NONE and weather ~= Enum.WeatherType.WT_THUNDER then
      local weatherConf = _G.DataConfigManager:GetWeatherConf(weather)
      local weatherText = string.format("%s(%s)", table.getKeyName(Enum.WeatherType, weather), weatherConf.name)
      if self.Text_Weather then
        self.Text_Weather:SetText(weatherText)
      end
    else
      local Instance = UE.UNRCPlatformGameInstance.GetInstance()
      local EnvSys = Instance and Instance:GetWorldSubSystem()
      local WeatherSystemValue = EnvSys:GetWeatherStat()
      if WeatherSystemValue and WeatherSystemValue ~= Enum.WeatherType.WT_NONE and WeatherSystemValue ~= Enum.WeatherType.WT_THUNDER then
        local weatherConf = _G.DataConfigManager:GetWeatherConf(WeatherSystemValue)
        local weatherText = string.format("%s(%s)", table.getKeyName(Enum.WeatherType, WeatherSystemValue), weatherConf.name)
        if self.Text_Weather then
          self.Text_Weather:SetText(weatherText)
        end
      end
    end
  end
  if weather and weather ~= Enum.WeatherType.WT_NONE and weather ~= Enum.WeatherType.WT_THUNDER then
    local weatherConf = _G.DataConfigManager:GetWeatherConf(weather)
    if weatherConf then
      self.LocalWeather = string.format("%s(%s)", table.getKeyName(Enum.WeatherType, weather), weatherConf.name)
    else
      self.LocalWeather = ""
    end
  else
    local Instance = UE.UNRCPlatformGameInstance.GetInstance()
    local EnvSys = Instance and Instance:GetWorldSubSystem()
    local WeatherSystemValue = EnvSys:GetWeatherStat()
    if WeatherSystemValue and WeatherSystemValue ~= Enum.WeatherType.WT_NONE and WeatherSystemValue ~= Enum.WeatherType.WT_THUNDER then
      local weatherConf = _G.DataConfigManager:GetWeatherConf(WeatherSystemValue)
      if weatherConf then
        self.LocalWeather = string.format("%s(%s)", table.getKeyName(Enum.WeatherType, WeatherSystemValue), weatherConf.name)
      else
        self.LocalWeather = ""
      end
    end
  end
  self:UpdateTimeText()
end

function UMG_DebugEntry_C:ShowVisiblePoolInfo()
  if GlobalConfig.DebugVisiblePoolInfo then
    self.Panel_VisiblePoolInfo:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Text_VisiblePoolInfo:SetText("\231\173\137\229\190\133\232\191\155\229\133\165\229\136\183\230\150\176\228\186\146\232\167\129\229\140\186\228\191\161\230\129\175")
    self.Panel_VisiblePoolInfo:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_DebugEntry_C:RefreshVisiblePoolInfo(zone)
  table.clear(self.OtherPlayerState)
  self:GetEnterAndLeaveOtherPlayerInfo(zone)
  local refreshTime = os.date("%Y-%m-%d %H:%M:%S")
  local info
  info = string.format("\228\186\146\232\167\129\229\140\186\228\191\161\230\129\175\229\136\183\230\150\176\230\151\182\233\151\180 %s", refreshTime)
  self:DelaySeconds(0.3, function()
    if zone and zone.enter then
      info = string.format("%s\n%s \232\191\155\229\133\165 %s", info, zone.enter.entrant_name, self:FormatVisiblePool(zone.enter.pool))
      self.Text_VisiblePoolInfo:SetText(info)
    end
    if zone and zone.leave then
      info = string.format("%s\n%s \231\166\187\229\188\128 %s %s %s", info, zone.leave.leaver_name, self:FormatVisiblePool(zone.leave.pool), zone.leave.merge and string.format("\228\184\142\229\143\175\232\167\129\230\177\160%d\229\144\136\229\185\182", zone.leave.pool.pool_id) or "", zone.leave.recycle and "\229\143\175\232\167\129\230\177\160\232\162\171\233\148\128\230\175\129" or "")
      self.Text_VisiblePoolInfo:SetText(info)
    end
  end)
end

function UMG_DebugEntry_C:FormatVisiblePool(pool)
  local baseInfo = string.format("\n\229\143\175\232\167\129\229\140\186: %d\n \229\143\175\232\167\129\230\177\160: %d\n \230\177\160\229\134\133\231\142\169\229\174\182\239\188\154\n", pool.area_cfg_id, pool.pool_id)
  if pool.players then
    for _, v in pairs(pool.players) do
      local playerInfo = self:FormatVisiblePlayer(v)
      baseInfo = baseInfo .. playerInfo
    end
  end
  return baseInfo
end

function UMG_DebugEntry_C:FormatVisiblePlayer(player)
  local stateText = self:GetOtherPlayerState(player)
  local visiblePlayerText
  if stateText then
    visiblePlayerText = string.format("%s \229\164\132\228\186\142%s      %s\n", player.name, player.in_visible and LuaText.playermodule_7 or LuaText.playermodule_8, stateText)
  else
    visiblePlayerText = string.format(LuaText.playermodule_6, player.name, player.in_visible and LuaText.playermodule_7 or LuaText.playermodule_8)
  end
  return visiblePlayerText
end

function UMG_DebugEntry_C:GetEnterAndLeaveOtherPlayerInfo(zone)
  if zone and zone.enter and zone.enter.pool.players then
    for _, v in pairs(zone.enter.pool.players) do
      self:GetOtherPlayerInfo(v)
    end
  end
  if zone and zone.leave and zone.leave.pool.players then
    for _, v in pairs(zone.leave.pool.players) do
      self:GetOtherPlayerInfo(v)
    end
  end
end

function UMG_DebugEntry_C:GetOtherPlayerInfo(player)
  local req = _G.ProtoMessage:newZoneFriendSearchPlayerReq()
  req.uin = player.id
  return _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_FRIEND_SEARCH_PLAYER_REQ, req, self, self.OnFriendSearchPlayerRsp, false, true)
end

function UMG_DebugEntry_C:OnFriendSearchPlayerRsp(Rsp)
  if 0 == Rsp.ret_info.ret_code then
    table.insert(self.OtherPlayerState, {
      uin = Rsp.player_info.uin,
      isFriend = Rsp.is_friend,
      isBlackRole = Rsp.is_black_role
    })
  end
end

function UMG_DebugEntry_C:GetOtherPlayerState(player)
  local visitors = _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.GetOnlineVisitorList)
  for _, v in pairs(self.OtherPlayerState) do
    if _G.DataModelMgr.PlayerDataModel:IsVisitState() then
      local bIsVisitor = false
      for i = 1, #visitors do
        if visitors[i].uin == player.id then
          bIsVisitor = true
        end
      end
      if v.uin == player.id then
        if v.isFriend then
          if bIsVisitor then
            return "\229\165\189\229\143\139,\228\186\146\232\174\191"
          else
            return "\229\165\189\229\143\139"
          end
        elseif v.isBlackRole then
          return "\230\139\137\233\187\145"
        end
      end
    elseif v.uin == player.id then
      if v.isFriend then
        return "\229\165\189\229\143\139"
      elseif v.isBlackRole then
        return "\230\139\137\233\187\145"
      end
    end
  end
end

function UMG_DebugEntry_C:ShowOrHideDungeonStageInfoText(bShow)
  if bShow then
    self.Text_DungeonInfo:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if _G.DataModelMgr.PlayerDataModel.playerInfo.common_info.in_dungeon_id and _G.DataModelMgr.PlayerDataModel.playerInfo.common_info.in_dungeon_id[1] then
      local dungeonId = _G.DataModelMgr.PlayerDataModel.playerInfo.common_info.in_dungeon_id[1]
      local dungeonConf = _G.DataConfigManager:GetDungeonConf(dungeonId)
      local dungeonInfoText = string.format([[
'%s'
%s]], dungeonConf.name, "\230\156\170\230\159\165\232\175\162\229\136\176\229\137\175\230\156\172\233\152\182\230\174\181\239\188\140\233\152\182\230\174\181\228\184\1860")
      self.Text_DungeonInfo:SetText(dungeonInfoText)
    end
  else
    self.Text_DungeonInfo:SetText("")
    self.Text_DungeonInfo:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_DebugEntry_C:ShowDungeonStageInfo(cur_stage)
  if _G.GlobalConfig.bShouldShowRevivePointInfo then
    if cur_stage then
      local dungeonStageConf = _G.DataConfigManager:GetDungeonStage(cur_stage)
      local dungeonConf = _G.DataConfigManager:GetDungeonConf(dungeonStageConf.dungeon_id)
      local dungeonInfoText = string.format([[
'%s'
%s]], dungeonConf.name, dungeonStageConf.stage_name)
      self.Text_DungeonInfo:SetText(dungeonInfoText)
      self.Text_DungeonInfo:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      local revivePointId = dungeonStageConf.revive_point
      local teleportConf = _G.DataConfigManager:GetTeleportConf(revivePointId)
      local destId = teleportConf.teleport_dest[1].dest_id
      local areaConf = _G.DataConfigManager:GetAreaConf(destId)
      local revivePointPos = areaConf.pos[1].position_xyz
      local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
      local NPC = NPCModule:CreateLocalNPC(50183, {
        x = revivePointPos[1],
        y = revivePointPos[2],
        z = revivePointPos[3]
      }, 0)
      NPC.Name = teleportConf.editor_name
      NPC.AreaId = destId
      NPCModule:AddRevivePointNPC(NPC)
    end
  else
    self.Text_DungeonInfo:SetText("")
    self.Text_DungeonInfo:SetVisibility(UE4.ESlateVisibility.Collapsed)
    local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
    NPCModule:ClearRevivePointNPC()
  end
end

function UMG_DebugEntry_C:OnBodyTempChange(bt, diffTime, btFinal)
  self:OnSetTemperature(bt, diffTime, btFinal)
end

function UMG_DebugEntry_C:OnSetTemperature(bt, diffTime, btFinal)
  local LocalPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not LocalPlayer then
    return
  end
  local C = LocalPlayer.TemperatureComponent:GetTempC()
  self.Temperature:SetText(string.format("%.1f & %.1f", C, bt))
end

function UMG_DebugEntry_C:OnShowTemperature()
  if self.Temperature:GetVisibility() == UE4.ESlateVisibility.Collapsed then
    self.Temperature:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Temperature:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_DebugEntry_C:IsShowNpcInfo(_leftPanel)
  local LocalPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not LocalPlayer then
    return
  end
  self.IsNpcInfo = not self.IsNpcInfo
  if self.IsNpcInfo then
    self.NRCSwitcher_0:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.NRCSwitcher_0:SetActiveWidgetIndex(1)
    _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.RegisterTopKFinder, self, 1, self, self.AlwaysValid, self, self.AlwaysValid)
  else
    self.NRCSwitcher_0:SetVisibility(UE4.ESlateVisibility.Collapsed)
    _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.UnRegisterTopKFinder, self)
  end
end

function UMG_DebugEntry_C:AlwaysValid()
  return true
end

function UMG_DebugEntry_C:OnDeactive()
end

function UMG_DebugEntry_C:ChangBG()
  self.TimeText:SetVisibility(UE4.ESlateVisibility.Hidden)
end

function UMG_DebugEntry_C:OnShowZoneTips(_name)
  self.zoneTitle:SetText(_name)
end

function UMG_DebugEntry_C:OnZoneGmGetDungeonCurStageRsp(rsp)
  if 0 == rsp.ret_info.ret_code and rsp.cur_stage then
    self:ShowDungeonStageInfo(rsp.cur_stage)
  end
end

function UMG_DebugEntry_C:SetDebugText()
  self:UpdateTimeText()
end

function UMG_DebugEntry_C:SetPerfStutter(stutter)
  self.PerfStutter:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.PerfStutter:SetText(string.format("stutter: %.6f", stutter))
  if self.DelayHidePerfStutter then
    _G.DelayManager:CancelDelayById(self.DelayHidePerfStutter)
    self.DelayHidePerfStutter = nil
  end
  self.DelayHidePerfStutter = _G.DelayManager:DelaySeconds(10, self.HidePerfStutter, self)
end

function UMG_DebugEntry_C:HidePerfStutter()
  self.DelayHidePerfStutter = nil
  self.PerfStutter:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_DebugEntry_C:AdjustSvrTimeLocally()
  self.svr_time:gsub("(%d%d)$", function(s)
    local second = tonumber(s) or 0
    second = math.floor(second) % 60
    self.local_time = second
    self.local_time_last = second
  end)
end

function UMG_DebugEntry_C:TickSvrTimeLocally(deltaTime)
  if self.svr_time then
    local seconds = self.local_time + deltaTime
    self.local_time = seconds % 60
    local new_seconds = math.floor(self.local_time)
    if self.local_time_last ~= new_seconds then
      local base_second = self.local_time_last
      self.local_time_last = new_seconds
      if new_seconds < base_second then
        base_second = base_second - 60
      end
      local span_s = new_seconds - base_second
      local span_m = math.floor((new_seconds - base_second) / 60)
      local span_h = math.floor((new_seconds - base_second) / 3600)
      self.svr_time = self.svr_time:gsub("(%d%d):(%d%d) (%d%d)$", function(hh, mm, ss)
        local s = tonumber(ss) + span_s
        local carry_m = s >= 60 and math.ceil(s / 60) or 0
        local m = tonumber(mm) + span_m + carry_m
        local carry_h = m >= 60 and math.ceil(m / 60) or 0
        local h = tonumber(hh) + span_h + carry_h
        return string.format("%02d:%02d %02d", h % 24, m % 60, s % 60)
      end)
      self:UpdateSvrTime_Impl(self.svr_time, false)
    end
  end
end

function UMG_DebugEntry_C:OnEnterSceneFinishNtyAckCallBack(notify, isReconnecting, isEnteringCell)
  self:GetServerSceneAssetSvnVersion()
end

function UMG_DebugEntry_C:GetServerSceneAssetSvnVersion()
  local asset_type = 1
  local req = _G.ProtoMessage:newZoneGmQuerySceneAssetSvnVersionReq()
  req.asset_type = asset_type
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local PlayerLocation = player.viewObj:Abs_K2_GetActorLocation()
  req.pos.x = math.floor(PlayerLocation.X)
  req.pos.y = math.floor(PlayerLocation.Y)
  req.pos.z = math.floor(PlayerLocation.Z)
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_GM_QUERY_SCENE_ASSET_SVN_VERSION_REQ, req, self, self.GetServerSceneAssetSvnVersionRsp, false, true)
end

function UMG_DebugEntry_C:GetServerSceneAssetSvnVersionRsp(rsp)
  if 0 ~= rsp.ret_info.ret_code then
    return
  end
  local lines = {}
  for line in string.gmatch(rsp.svn_version, "[^\r\n]+") do
    table.insert(lines, line)
  end
  local targetIndex
  for i, line in ipairs(lines) do
    if line:match("^%s*asset_type") then
      targetIndex = i
      break
    end
  end
  local result = ""
  if targetIndex then
    for i = targetIndex + 1, #lines do
      result = result .. lines[i] .. "\n"
    end
  end
  local scene_name = string.match(rsp.svn_version, [[
scene name: %s*(.-)
=+]])
  self.ServerSceneInfo = string.format([[
%s%s
%s]], "\229\175\188\229\135\186\232\138\130\231\130\185:", scene_name, result)
end

return UMG_DebugEntry_C
