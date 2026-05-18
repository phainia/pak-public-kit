local JsonUtils = require("Common.JsonUtils")
local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local pb = require("pb")
local Base = DebugTabBase
local DebugTabNetwork = Base:Extend("DebugTabNetwork")

function DebugTabNetwork:Ctor()
  Base.Ctor(self)
end

function DebugTabNetwork:SetupTabs()
  self:Add("\229\188\128\229\144\175HttpDNS(\229\143\130\230\149\1761)", self.EnableHttpDNS, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\229\188\128\229\133\179SpaceAct\230\151\165\229\191\151", self.ToggleSpaceActLog, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\229\188\128\229\133\179\232\183\179\232\191\135\231\154\132\231\189\145\231\187\156\230\182\136\230\129\175\230\151\165\229\191\151", self.ToggleSkipNetLog, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\137\147\229\188\128\229\164\154\231\186\191\231\168\139DecodePb", self.EnableDecodePbMultiThread, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\229\133\179\233\151\173\229\164\154\231\186\191\231\168\139DecodePb", self.DisableDecodePbMultiThread, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\137\147\229\188\128Clb", self.EnableClb, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\229\133\179\233\151\173Clb", self.DisableClb, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\137\147\229\188\128\231\167\187\229\138\168\229\140\133\230\151\165\229\191\151", self.EnableMoveLog, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\229\133\179\233\151\173\231\167\187\229\138\168\229\140\133\230\151\165\229\191\151", self.DisableMoveLog, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\137\147\229\141\176\231\167\187\229\138\168\229\140\133\229\187\182\232\191\159", self.PrintMoveLag, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\181\139\232\175\149Server\229\191\131\232\183\179\232\182\133\230\151\182", self.TestServerHeartBeatTimeOut, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\229\133\179\233\151\173Server\229\191\131\232\183\179\230\163\128\230\159\165", self.CloseServerHeartBeatCheck, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\137\147\229\188\128Server\229\191\131\232\183\179\230\163\128\230\159\165", self.OpenServerHeartBeatCheck, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\137\147\229\188\128WaitingUI", self.TestOpenWaitingUI, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\229\133\179\233\151\173WaitingUI", self.TestCloseWaitingUI, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\181\139\232\175\149\233\135\141\229\144\175NetLuaState", self.TestReloadLuaState, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\229\188\128\229\133\179\233\171\152\233\162\145\229\140\133\230\163\128\230\181\139", self.ToggleHighFreq, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\181\139\232\175\149MD5", self.TestMd5, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\181\139\232\175\149MagicSequence", self.TestMagicSequence, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
end

function DebugTabNetwork:ChangeToLocalServer()
  if _G.ZoneServer.isLocalServer then
    return
  end
  _G.ZoneServer.isLocalServer = true
  local zoneServer = _G.ZoneServer
  local localServer = require("Common.LocalServer.LocalServer")
  _G.ZoneServer.SendWithHandler = localServer.SendWithHandler
  _G.ZoneServer.Send = localServer.Send
  _G.ZoneServer.OnTick = localServer.OnTick
  _G.ZoneServer.SetRSPTable = localServer.SetRSPTable
  _G.UpdateManager:Register(_G.ZoneServer)
end

function DebugTabNetwork:PauseNetwork(name, panel)
  _G.ZoneServer:Pause()
end

function DebugTabNetwork:ResumeNetwork(name, panel)
  _G.ZoneServer:Resume()
end

function DebugTabNetwork:DisConnect(name, panel)
  _G.ZoneServer:DisConnect()
  if panel then
    panel:DoClose()
  end
end

function DebugTabNetwork:ReConnect(name, panel)
  _G.ZoneServer:ReConnect()
end

function DebugTabNetwork:UseLocalGeneraServer(name, panel)
  self:ChangeToLocalServer()
  _G.ZoneServer:SetRSPTable(require("Common.LocalServer.LocalGeneralRSPTable"))
  if _G.DataModelMgr.PlayerDataModel.loginData == nil then
    local LoginModule = _G.NRCModuleManager:GetModule("LoginModule")
    if LoginModule then
      local function LoginRspFunc(_caller, rsp)
        local Func_LoginModule = _G.NRCModuleManager:GetModule("LoginModule")
        
        if Func_LoginModule then
          Func_LoginModule:OnLoginRsp(rsp)
          NRCModeManager:DeactiveMode("LoginMode")
        end
      end
      
      local loginReq = ProtoMessage:newZoneLoginReq()
      loginReq.openid = _G.GameSetting.LastLogin
      loginReq.plat_info.plat_id = 0
      loginReq.plat_info.cli_login_channel = 0
      loginReq.plat_info.world_id = 0
      _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_LOGIN_REQ, loginReq, self, LoginRspFunc, true)
    end
  else
    NRCModeManager:DeactiveMode("LoginMode")
  end
end

function DebugTabNetwork:StartHook()
  local Recorder = _G.ProtoRecorder
  Recorder:AddCmd(ProtoCMD.ZoneSvrCmd.ZONE_LOGIN_RSP)
  Recorder:AddCmd(ProtoCMD.ZoneSvrCmd.ZONE_GET_BAG_RSP)
  Recorder:AddCmd(ProtoCMD.ZoneSvrCmd.ZONE_ENTER_SCENE_RSP)
  Recorder:AddCmd(ProtoCMD.ZoneSvrCmd.ZONE_SCENE_CLIENT_ENTER_SCENE_FINISH_NTY_ACK)
  Recorder:AddCmd(ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_LOAD_FINISH_RSP)
  Recorder:AddCmd(ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_CMD_PUSHBACK_RSP)
  Recorder:AddCmd(ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_SUPPLY_PET_RSP)
  Recorder:AddCmd(ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_ROUND_FLOW_FINISH_RSP)
  Recorder:AddCmd(ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_ENTER_NOTIFY)
  Recorder:AddCmd(ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_PRE_PLAY_NOTIFY)
  Recorder:AddCmd(ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_ROUND_START_NOTIFY)
  Recorder:AddCmd(ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_PERFORM_START_NOTIFY)
  Recorder:AddCmd(ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_FINISH_NOTIFY)
  Recorder:Start()
end

function DebugTabNetwork:StopHook()
  local Recorder = _G.ProtoRecorder
  Recorder:Stop()
end

function DebugTabNetwork:PrintServerTimeAndRTT()
  local serverTime = math.round(_G.ZoneServer:GetServerTime() / 1000)
  Log.Error("[\230\156\141\229\138\161\229\153\168\230\151\182\233\151\180]", os.date("%c", serverTime))
  local tconndRTT = _G.NRCNetworkManager:GetTConndRTT(_G.ZoneServer.connectID)
  local serverRTT = _G.NRCNetworkManager:GetServerRTT(_G.ZoneServer.connectID)
  Log.Error("[TconndRTT]=" .. tconndRTT .. "ms", "[ServerRTT]=" .. serverRTT .. "ms")
  local LastTimeOfDateRecv = _G.NRCNetworkManager:GetLastTimeOfDataRecv(_G.ZoneServer.connectID)
  local CurTime = UE.UNRCStatics.GetTimestampMS()
  local ElapsedTime = CurTime - LastTimeOfDateRecv
  Log.Error("[LastTimeOfDateRecv]=" .. LastTimeOfDateRecv .. " [CurTime]=" .. CurTime .. " [ElapsedTime]=", ElapsedTime)
end

function DebugTabNetwork:PrintIPAndPort()
  local ipStr = _G.NRCNetworkManager:GetIP(_G.ZoneServer.connectID)
  local port = _G.NRCNetworkManager:GetPort(_G.ZoneServer.connectID)
  Log.Error("\230\156\141\229\138\161\229\153\168IP\229\146\140Port:", string.format("%s:%d", ipStr, port))
  UE4.UNRCStatics.ClipboardCopy(ipStr)
end

function DebugTabNetwork:OpenGCloundInfoLog()
  _G.NRCNetworkManager:EnableGCloudLogInfo(true)
end

function DebugTabNetwork:CloseGCloundInfoLog()
  _G.NRCNetworkManager:EnableGCloudLogInfo(false)
end

function DebugTabNetwork:OpenTCPTaskLog()
  _G.NRCNetworkManager:SetTCPTaskLogVerbose(true)
  _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "TCPTaskLog\229\183\178\231\187\143\230\137\147\229\188\128!")
end

function DebugTabNetwork:CloseTCPTaskLog()
  _G.NRCNetworkManager:SetTCPTaskLogVerbose(false)
  _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "TCPTaskLog\229\183\178\231\187\143\229\133\179\233\151\173!")
end

function DebugTabNetwork:KickOut()
  local inputStr = self:GetInputString()
  if string.IsNilOrEmpty(inputStr) then
    Log.Error("[DebugTabNetwork:KickOut] \232\175\183\232\190\147\229\133\165KickOutType\229\143\130\230\149\176!")
    return
  end
  local params = string.split(inputStr, " ")
  if nil == params or #params < 1 then
    Log.Error("[DebugTabNetwork:KickOut] \232\175\183\232\190\147\229\133\165\230\173\163\231\161\174\231\154\132KickOutType\229\143\130\230\149\176!")
    return
  end
  local kickOutType = tonumber(params[1])
  local kickOutSubType = 0
  if #params > 1 then
    kickOutSubType = tonumber(params[2])
  end
  local kickOutMsg = "Hello KickOut!"
  if #params > 2 then
    kickOutMsg = tostring(params[3])
  end
  _G.ZoneServer.ZoneServerKickOut:ReqGMKickout(kickOutType, kickOutSubType, kickOutMsg)
  Log.Debug("DebugTabNetwork:KickOut", self:GetInputString())
  self:ClosePanel()
end

function DebugTabNetwork:QueryServer(Name, Panel, id)
  if Panel then
    local ID = self.Panel:GetInputNumber(0)
    local Servers = JsonUtils.LoadDefaultServerList({})
    for _, Server in ipairs(Servers) do
      if Server.id == ID then
        self:Inspect(Server, "\230\156\141\229\138\161\229\153\168\228\191\161\230\129\175")
        break
      end
    end
  elseif id then
    local ID = id
    local Servers = JsonUtils.LoadDefaultServerList({})
    for _, Server in ipairs(Servers) do
      if Server.id == ID then
        self:Inspect(Server, "\230\156\141\229\138\161\229\153\168\228\191\161\230\129\175")
        break
      end
    end
  end
end

function DebugTabNetwork:EnableHttpDNS()
  local inputStr = self:GetInputString()
  if "1" == inputStr then
    UE4.UNRCStatics.ExecConsoleCommand("RocoNetwork.UseHttpDns true")
  else
    UE4.UNRCStatics.ExecConsoleCommand("RocoNetwork.UseHttpDns false")
  end
end

function DebugTabNetwork:EnableClb()
  UE4.UNRCStatics.ExecConsoleCommand("RocoNetwork.UseClb true")
end

function DebugTabNetwork:DisableClb()
  UE4.UNRCStatics.ExecConsoleCommand("RocoNetwork.UseClb false")
end

function DebugTabNetwork:EnableMoveLog()
  _G.GlobalConfig.bDebugMoveLog = true
end

function DebugTabNetwork:DisableMoveLog()
  _G.GlobalConfig.bDebugMoveLog = false
end

function DebugTabNetwork:PrintMoveLag()
  local avgLag, queueSize = _G.ZoneServer:GetDebugAvgClientMoveLag()
  Log.Error("ClientMoveLag", avgLag, "ms,", queueSize, "\228\184\170\231\167\187\229\138\168\229\140\133\231\154\132\229\185\179\229\157\135\229\187\182\232\191\159", "RTT=", _G.ZoneServer:GetTConndRTT(), "ms")
end

function DebugTabNetwork:EnableDecodePbMultiThread()
  UE4.UNRCStatics.ExecConsoleCommand("unlua.EnableDecodePbMultiThread true")
end

function DebugTabNetwork:DisableDecodePbMultiThread()
  UE4.UNRCStatics.ExecConsoleCommand("unlua.EnableDecodePbMultiThread false")
end

function DebugTabNetwork:EnableSpaceActLog()
  _G.ZoneServer.bDebugSpaceAct = true
end

function DebugTabNetwork:ToggleSpaceActLog()
  local bDebugSpaceAct = _G.ZoneServer.bDebugSpaceAct
  _G.ZoneServer.bDebugSpaceAct = not bDebugSpaceAct
  Log.Error("bDebugSpaceAct", _G.ZoneServer.bDebugSpaceAct)
end

function DebugTabNetwork:ToggleSkipNetLog()
  local bNotSkipProtocolLog = _G.ZoneServer.bNotSkipAnyProtocolLog
  _G.ZoneServer.bNotSkipAnyProtocolLog = not bNotSkipProtocolLog
  Log.Error("bNotSkipAnyProtocolLog", _G.ZoneServer.bNotSkipAnyProtocolLog)
end

function DebugTabNetwork:OpenServerHeartBeatCheck()
  UE4.UNRCStatics.ExecConsoleCommand("RocoNetwork.CheckHeartBeat true")
end

function DebugTabNetwork:CloseServerHeartBeatCheck()
  UE4.UNRCStatics.ExecConsoleCommand("RocoNetwork.CheckHeartBeat false")
end

function DebugTabNetwork:TestOpenWaitingUI()
  local delayTime = 0
  local inputStr = self:GetInputString()
  if inputStr and not string.IsNilOrEmpty(inputStr) then
    delayTime = tonumber(inputStr)
  end
  _G.ZoneServer:OpenWaitingUI("Test", "TestOpenWaitingUI", delayTime)
  self:ClosePanel()
end

function DebugTabNetwork:TestCloseWaitingUI()
  _G.ZoneServer:CloseWaitingUI("Test")
  self:ClosePanel()
end

function DebugTabNetwork:TestReloadLuaState()
  _G.NRCNetworkManager:ReloadNetworkLuaState(_G.ZoneServer.connectID)
  self:ClosePanel()
end

function DebugTabNetwork:ToggleHighFreq()
  _G.GlobalConfig.bDisableStatProtocolFreq = not _G.GlobalConfig.bDisableStatProtocolFreq
  self:ClosePanel()
  Log.Error("_G.GlobalConfig.bDisableStatProtocolFreq", _G.GlobalConfig.bDisableStatProtocolFreq)
end

function DebugTabNetwork:TestMd5()
  local base_info_1 = _G.ProtoMessage:newFeedVideoBaseInfo()
  base_info_1.fashion_id[1] = 10704701
  base_info_1.fashion_id[2] = 10700107
  base_info_1.pet_base_id[1] = 3002
  base_info_1.pet_base_id[2] = 3001
  base_info_1.chat_msg[1] = "abc"
  base_info_1.chat_msg[2] = "defsaa"
  base_info_1.player_pos.x = 455354
  base_info_1.player_pos.y = 602072
  base_info_1.player_pos.z = 9193
  base_info_1.version = 1
  local pbData1 = pb.encode(".Next.FeedVideoBaseInfo", base_info_1)
  
  local function BaseInfoToStr(baseInfo)
    local str = ""
    if baseInfo.fashion_id then
      for i, v in ipairs(baseInfo.fashion_id) do
        str = str .. v
        if i ~= #baseInfo.fashion_id then
          str = str .. ","
        end
      end
      str = str .. ";"
    end
    if baseInfo.pet_base_id then
      for i, v in ipairs(baseInfo.pet_base_id) do
        str = str .. v
        if i ~= #baseInfo.pet_base_id then
          str = str .. ","
        end
      end
      str = str .. ";"
    end
    if baseInfo.chat_msg then
      for i, v in ipairs(baseInfo.chat_msg) do
        str = str .. v
        if i ~= #baseInfo.chat_msg then
          str = str .. ","
        end
      end
      str = str .. ";"
    end
    if baseInfo.player_pos then
      str = str .. baseInfo.player_pos.x .. "," .. baseInfo.player_pos.y .. "," .. baseInfo.player_pos.z
      str = str .. ";"
    end
    if baseInfo.version then
      str = str .. baseInfo.version
      str = str .. ";"
    end
    return str
  end
  
  local baseInfoStr = BaseInfoToStr(base_info_1)
  local localMd5Str = UE.UNRCStatics.HashUTF8StringMD5(baseInfoStr)
  local localMd5StrOfPb = UE.UNRCStatics.HashUTF8StringMD5(pbData1)
  Log.Debug("baseInfoStr", baseInfoStr)
  Log.Debug("localMd5Str", localMd5Str)
  Log.Debug("localMd5OfPb", localMd5StrOfPb)
  local base_info_2 = _G.ProtoMessage:newFeedVideoBaseInfo()
  base_info_2.fashion_id[1] = 10704701
  base_info_2.fashion_id[2] = 10700107
  base_info_2.pet_base_id[1] = 3002
  base_info_2.pet_base_id[2] = 3001
  base_info_2.chat_msg[1] = "abc"
  base_info_2.chat_msg[2] = "defsaa"
  base_info_2.chat_msg[3] = "\228\189\160\229\165\189"
  base_info_2.player_pos.x = 455354
  base_info_2.player_pos.y = 602072
  base_info_2.player_pos.z = 9193
  base_info_2.version = 1
  local pbData2 = pb.encode(".Next.FeedVideoBaseInfo", base_info_2)
  local baseInfoStr2 = BaseInfoToStr(base_info_2)
  local localMd5Str2 = UE.UNRCStatics.HashUTF8StringMD5(baseInfoStr2)
  local localMd5StrOfPb2 = UE.UNRCStatics.HashUTF8StringMD5(pbData2)
  Log.Debug("baseInfoStr2", baseInfoStr2)
  Log.Debug("localMd5Str2", localMd5Str2)
  Log.Debug("localMd5StrOfPb2", localMd5StrOfPb2)
end

function DebugTabNetwork:TestMagicSequence()
  local MagicSequence = require("NewRoco.Modules.System.MagicReplay.MagicSequence.MagicSequence")
  local TempMagicSeqPath = UE.UBlueprintPathsLibrary.Combine({
    UE4.UBlueprintPathsLibrary.ProjectPersistentDownloadDir(),
    "MagicSequence"
  })
  if not UE.UNRCStatics.DirectoryExists(TempMagicSeqPath) then
    UE.UNRCStatics.MakeDirectory(TempMagicSeqPath)
  end
  local SeqFileExt = ".seq"
  local FileName = "17865431_" .. UE.UNRCStatics.GetTimestampMS() .. SeqFileExt
  local RelativeFullName = TempMagicSeqPath .. "/" .. FileName
  Log.Debug("RelativeFullName", RelativeFullName)
  local FullFileName = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(RelativeFullName)
  Log.Debug("FullFileName", FullFileName)
  local CurWriteSeq = MagicSequence(FullFileName, "w")
  CurWriteSeq.major_ver = 1
  CurWriteSeq.minor_ver = 9
  CurWriteSeq.logic_ver = 8
  local base_info_1 = _G.ProtoMessage:newFeedVideoBaseInfo()
  base_info_1.fashion_id[1] = 10704701
  base_info_1.fashion_id[2] = 10700107
  base_info_1.pet_base_id[1] = 3002
  base_info_1.pet_base_id[2] = 3001
  base_info_1.chat_msg[1] = "abc"
  base_info_1.chat_msg[2] = "defsaa"
  base_info_1.player_pos.x = 455354
  base_info_1.player_pos.y = 602072
  base_info_1.player_pos.z = 9193
  base_info_1.version = 1
  CurWriteSeq.baseInfo = base_info_1
  CurWriteSeq:CreateFile()
  CurWriteSeq:WriteBaseInfo()
  CurWriteSeq:Close()
  local CurReadSeq = MagicSequence(FullFileName, "r")
  CurReadSeq:CreateFile()
  CurReadSeq:ReadBaseInfo()
  Log.Debug("CurReadSeq Version", CurReadSeq.major_ver, CurReadSeq.minor_ver, CurReadSeq.logic_ver)
  Log.Debug("CurReadSeq BaseInfo", CurReadSeq.baseInfo.fashion_id[1], CurReadSeq.baseInfo.fashion_id[2])
  CurReadSeq:Close()
end

return DebugTabNetwork
