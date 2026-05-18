local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local OnlineState = require("Core.Service.NetManager.OnlineState")
local GCloudConnEnum = require("Core.Service.NetManager.GCloudConnEnum")
local Class = _G.MakeSimpleClass
local ReconnectState = {
  None = 0,
  Phase1_Insensitive = 1,
  Phase2_Enduring = 2,
  Phase3_Finish = 3,
  Phase3_Failed = 4,
  Max = 5
}
local MAX_LIGHT_RECONNECT_TIME = 25000
local ReConnectIntervals = {
  0.5,
  1,
  2,
  3,
  3,
  3,
  5,
  5,
  5,
  5,
  5,
  5,
  5,
  5,
  5,
  5,
  5
}
local RECONNECT_PHASE1_TIME_OUT = 5000
local ReconnectRecord = Class("ReconnectRecord")
ReconnectRecord:SetMemberCount(4)

function ReconnectRecord:PreCtor()
  self.PreOnlineState = 0
  self.DisOnlineState = 0
  self.bKickOutNeedReconnect = false
  self.bRetryRunOut = false
end

local ZoneServerGCloud = Class()

function ZoneServerGCloud:Ctor()
  self.bReconnecting = false
  self.bIgnoreDisconnectDialogue = false
  self.bReconnectAfterDisconnect = false
  self.bPingTimeOut = false
  self.lastTimeOfDateRecv = 0
  self.CurReConnectTimes = 0
  self.StartReconnectTimeMS = 0
  self.CurReconnectState = ReconnectState.Phase1_Insensitive
  self.CurReconnectRecord = nil
  self.MaxReConnectTimes = 15
  self.MaxReConnectDuration = 45000
end

function ZoneServerGCloud:Init()
  Log.Debug("ZoneServerGCloud:Init()")
  _G.NRCNetworkManager:AddConnectEventListener(_G.ZoneServer.connectID, "ZoneServerGCloud", self, self.OnConnected)
  _G.NRCNetworkManager:AddDisconnectEventListener(_G.ZoneServer.connectID, "ZoneServerGCloud", self, self.OnDisconnectProc)
  _G.NRCNetworkManager:AddStateChangeEventListener(_G.ZoneServer.connectID, "ZoneServerGCloud", self, self.OnStateChangedProc)
  _G.NRCNetworkManager:AddPingTimeOutListener(_G.ZoneServer.connectID, "ZoneServerGCloud", self, self.OnPingTimeOut)
  _G.NRCNetworkManager:AddPingUpdateListener(_G.ZoneServer.connectID, "ZoneServerGCloud", self, self.OnPingUpdate)
  _G.NRCNetworkManager:AddServerTimeUpdateListener(_G.ZoneServer.connectID, "ZoneServerGCloud", self, self.OnServerTimeUpdate)
  _G.NRCEventCenter:RegisterEvent("ZoneServerGCloud", self, _G.NRCGlobalEvent.OnOnlineStateChanged, self.OnOnlineStateChanged)
  self.MaxReConnectTimes = _G.DataConfigManager:GetGlobalConfigNumByKeyType("MaxReConnectTimes", _G.DataConfigManager.ConfigTableId.GLOBAL_CONFIG, 15)
  self.MaxReConnectDuration = _G.DataConfigManager:GetGlobalConfigNumByKeyType("MaxReConnectDuration", _G.DataConfigManager.ConfigTableId.GLOBAL_CONFIG, 45000)
  Log.Debug("[ZoneServer] MaxReConnectTimes=", self.MaxReConnectTimes, "MaxReConnectDuration=", self.MaxReConnectDuration)
end

function ZoneServerGCloud:OnShutdown()
  Log.Debug("ZoneServerGCloud:OnShutdown")
  _G.NRCNetworkManager:RemoveConnectEventListener(_G.ZoneServer.connectID, "ZoneServerGCloud")
  _G.NRCNetworkManager:RemoveDisconnectEventListener(_G.ZoneServer.connectID, "ZoneServerGCloud")
  _G.NRCNetworkManager:RemoveStateChangeEventListener(_G.ZoneServer.connectID, "ZoneServerGCloud")
  _G.NRCNetworkManager:RemovePingTimeOutListener(_G.ZoneServer.connectID, "ZoneServerGCloud")
  _G.NRCNetworkManager:RemovePingUpdateListener(_G.ZoneServer.connectID, "ZoneServerGCloud")
  _G.NRCNetworkManager:RemoveServerTimeUpdateListener(_G.ZoneServer.connectID, "ZoneServerGCloud")
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCEventCenter.OnOnlineStateChanged, self.OnOnlineStateChanged)
end

function ZoneServerGCloud:OnTick(deltaTime)
  if self.bReconnecting and self.StartReconnectTimeMS > 0 and self.CurReconnectState == ReconnectState.Phase1_Insensitive then
    local CurOSTime = os.msTime()
    local ElapsedTime = CurOSTime - self.StartReconnectTimeMS
    Log.Debug("[ZoneServer] ReconnectState check, ElapsedTime:", ElapsedTime, "CurReconnectState:", self.CurReconnectState)
    if ElapsedTime > RECONNECT_PHASE1_TIME_OUT then
      self.CurReconnectState = ReconnectState.Phase2_Enduring
      _G.NRCEventCenter:DispatchEvent(_G.NRCGlobalEvent.ON_RECONNECT_ENDURING)
      Log.Debug("[ZoneServer] ReconnectState: Phase1_Insensitive -> Phase2_Enduring")
    end
  end
end

function ZoneServerGCloud:ShouldShowReconnectingUI()
  return self.bReconnecting
end

function ZoneServerGCloud:EnterWaitForReconnect()
  if not self.CurReconnectRecord then
    _G.ZoneServer:SetDisOnlineState()
    self.CurReconnectRecord = ReconnectRecord()
    self.CurReconnectRecord.PreOnlineState = _G.ZoneServer:GetOnlineState()
    self.CurReconnectRecord.DisOnlineState = _G.ZoneServer:GetDisOnlineState()
    local bKickOutNeedReconnect = _G.ZoneServer.ZoneServerKickOut:IsKickOutNeedReconnect()
    self.CurReconnectRecord.bKickOutNeedReconnect = bKickOutNeedReconnect
    _G.ZoneServer:SetOnlineState(OnlineState.Logouted)
    Log.Debug("[ZoneServer] EnterWaitForReconnect, PreOnlineState:", OnlineState.ToString(self.CurReconnectRecord.PreOnlineState), "DisOnlineState:", OnlineState.ToString(self.CurReconnectRecord.DisOnlineState))
  end
end

function ZoneServerGCloud:OnConnected(connectID, event, state, errorCode, extend, extend2, extend3, ip, serverid)
  Log.Debug("[ZoneServer][NetMsg] OnConnected", connectID, event, state, errorCode, extend, extend2, extend3, ip, serverid)
  _G.ZoneServer:CloseWaitingUI("ConnectToZone")
  if errorCode == GCloudConnEnum.ErrorCode.kSuccess then
  else
    local bSuggestReconnect = false
    if errorCode == GCloudConnEnum.ErrorCode.kErrorConnectFailed then
      Log.Error("[ZoneServer][NetMsg] OnConnected ConnectResult kErrorConnectFailed", errorCode, extend, extend2, extend3)
      bSuggestReconnect = true
    elseif errorCode == GCloudConnEnum.ErrorCode.kErrorNetworkException then
      Log.Error("[ZoneServer][NetMsg] OnConnected ConnectResult kErrorNetworkException", errorCode, extend, extend2, extend3)
      bSuggestReconnect = true
    elseif errorCode == GCloudConnEnum.ErrorCode.kErrorTimeout then
      Log.Error("[ZoneServer][NetMsg] OnConnected ConnectResult kErrorTimeout", errorCode, extend, extend2, extend3)
      bSuggestReconnect = true
    elseif errorCode == GCloudConnEnum.ErrorCode.kErrorPeerStopSession then
      Log.Error("[ZoneServer][NetMsg] OnConnected ConnectResult kErrorPeerStopSession", errorCode, extend, extend2, extend3)
      bSuggestReconnect = true
    elseif errorCode == GCloudConnEnum.ErrorCode.kErrorPeerCloseConnection then
      Log.Error("[ZoneServer][NetMsg] OnConnected ConnectResult kErrorPeerCloseConnection", errorCode, extend, extend2, extend3)
      bSuggestReconnect = true
    elseif errorCode == GCloudConnEnum.ErrorCode.kErrorSvrIsFull then
      Log.Error("[ZoneServer][NetMsg] OnConnected ConnectResult kErrorSvrIsFull", errorCode, extend, extend2, extend3)
      bSuggestReconnect = true
    elseif errorCode == GCloudConnEnum.ErrorCode.kErrorInvalidToken then
      Log.Error("[ZoneServer][NetMsg] OnConnected ConnectResult kErrorInvalidToken", errorCode, extend, extend2, extend3)
      bSuggestReconnect = false
    elseif errorCode == GCloudConnEnum.ErrorCode.kErrorTokenSvrError then
      Log.Error("[ZoneServer][NetMsg] OnConnected ConnectResult kErrorTokenSvrError", errorCode, extend, extend2, extend3)
      bSuggestReconnect = false
    elseif errorCode == GCloudConnEnum.ErrorCode.kErrorAuthFailed then
      Log.Error("[ZoneServer][NetMsg] OnConnected ConnectResult kErrorAuthFailed", errorCode, extend, extend2, extend3)
      bSuggestReconnect = false
      local title = LuaText.TIPS
      local content = string.format(LuaText.NET_CONNECT_FAIL, errorCode)
      local extInfo = string.format(",%d,%d,%d", extend, extend2, extend3)
      content = content .. extInfo
      if _G.RocoEnv.IS_EDITOR then
        content = string.format([[
%s
%s]], content, "Editor\228\184\139\228\184\147\231\148\168\230\143\144\231\164\186\239\188\154\232\175\183\231\130\185\229\135\187\232\191\153\233\135\140\229\143\130\232\128\131\227\128\139<a id=\"\229\184\184\232\167\129\233\148\153\232\175\175\230\140\135\229\188\149\">https://iwiki.woa.com/pages/viewpage.action?pageId=1614654096</>\227\128\138\231\154\1321.1.4")
      end
      local debugInfo = "OnConnected,Err:" .. errorCode .. extInfo .. ",Auth failed!"
      local Ctx = DialogContext()
      Ctx:SetTitle(title):SetContent(content):SetMode(DialogContext.Mode.OK):SetCallback(nil, function()
        _G.AppMain.BackToLogin()
      end):SetCloseOnCancel(true):SetButtonText(LuaText.BACK):SetDebugInfo(debugInfo)
      Log.Debug("[ZoneServer] OpenDialog Ctx", Ctx.content)
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenOnlyForNetworkDialog, Ctx)
      _G.NRCEventCenter:DispatchEvent(_G.NRCGlobalEvent.ON_CONNECTED, errorCode)
      return
    elseif errorCode == GCloudConnEnum.ErrorCode.kErrorGcpError then
      Log.Error("[ZoneServer][NetMsg] OnConnected ConnectResult kErrorGcpError", errorCode, extend, extend2, extend3)
      bSuggestReconnect = false
    else
      Log.Error("[ZoneServer][NetMsg] OnConnected ConnectResult UnKnown", errorCode, extend, extend2, extend3)
      bSuggestReconnect = true
    end
    local CurOnlineState = _G.ZoneServer:GetOnlineState()
    local PreOnlineState = _G.ZoneServer:GetPreOnlineState()
    local DisOnlineState = _G.ZoneServer:GetDisOnlineState()
    local bInKickOut = _G.ZoneServer.ZoneServerKickOut:IsInKickOut()
    local bKickOutNeedReconnect = _G.ZoneServer.ZoneServerKickOut:IsKickOutNeedReconnect()
    local bTriggerAutoReconnect = false
    if self.CurReconnectRecord then
      if bKickOutNeedReconnect then
        bTriggerAutoReconnect = true
      elseif bSuggestReconnect then
        bTriggerAutoReconnect = true
      end
    end
    Log.Debug("[ZoneServer] OnConnected [Reconnect] Info, bSuggestReconnect", bSuggestReconnect, "bReconnecting", self.bReconnecting, "ReconnectState", self.ReconnectState, "CurOnlineState", OnlineState.ToString(CurOnlineState), "PreOnlineState", OnlineState.ToString(PreOnlineState), "DisOnlineState", OnlineState.ToString(DisOnlineState), "bInKickOut", bInKickOut, "bKickOutNeedReconnect", bKickOutNeedReconnect, "bTriggerAutoReconnect", bTriggerAutoReconnect)
    
    local function OpenFailedDialog(debugInfo)
      local content = string.format(LuaText.NET_CONNECT_FAIL, errorCode)
      local extInfo = string.format(",%d,%d,%d", extend, extend2, extend3)
      content = content .. extInfo
      if _G.RocoEnv.IS_EDITOR then
        content = string.format([[
%s
%s]], content, "Editor\228\184\139\228\184\147\231\148\168\230\143\144\231\164\186\239\188\154\232\175\183\231\130\185\229\135\187\232\191\153\233\135\140\229\143\130\232\128\131\227\128\139<a id=\"\229\184\184\232\167\129\233\148\153\232\175\175\230\140\135\229\188\149\">https://iwiki.woa.com/pages/viewpage.action?pageId=1614654096</>\227\128\138\231\154\1321.1.4")
      end
      self:OpenDialog(LuaText.TIPS, content, LuaText.RETRY, LuaText.BACK, DialogContext.Mode.OK_CANCEL, self.OnDialogResult, "OnConnected,Err:" .. errorCode .. extInfo .. debugInfo)
    end
    
    local function AbortReconnect()
      if self.bReconnecting then
        self:ResetAutoReconnect()
      end
    end
    
    if bTriggerAutoReconnect then
      local bAutoReconnectRes = self:AutoReConnect()
      if not bAutoReconnectRes then
        OpenFailedDialog(" Retry run out!")
        AbortReconnect()
      else
        Log.Debug("[ZoneServer][Reconnect] OnConnected AutoReconnect starting...")
      end
    else
      OpenFailedDialog("")
      AbortReconnect()
    end
  end
  _G.NRCEventCenter:DispatchEvent(_G.NRCGlobalEvent.ON_CONNECTED, errorCode)
end

function ZoneServerGCloud:OnDisconnectProc(connectID, event, state, errorCode, extend, extend2, extend3, ip, serverid)
  Log.Debug("[ZoneServer][NetMsg] OnDisconnectProc", connectID, event, state, errorCode, extend, extend2, extend3, ip, serverid)
  Log.Debug("[ZoneServer][NetMsg] OnDisconnectProc bIgnoreDisconnectDialogue=", self.bIgnoreDisconnectDialogue, "bReconnectAfterDisconnect=", self.bReconnectAfterDisconnect)
  if self.bReconnecting then
    if 0 == errorCode and _G.ZoneServer.ZoneServerKickOut:IsKickOutNeedReconnect() then
      Log.Debug("[ZoneServer][NetMsg][Reconnect] \233\135\141\232\191\158\232\191\135\231\168\139\228\184\173\232\167\166\229\143\145\228\186\134KickOutType=3\239\188\140\228\184\141\230\137\147\230\150\173\233\135\141\232\191\158!")
    else
      self.bReconnecting = false
    end
  end
  _G.ZoneServer:ClearAllPause()
  self:EnterWaitForReconnect()
  _G.NRCEventCenter:DispatchEvent(_G.NRCGlobalEvent.ON_DISCONNECT, errorCode)
  if not self.bIgnoreDisconnectDialogue and not _G.ZoneServer.ZoneServerKickOut:IsInKickOut() then
    self:OpenDialog(LuaText.TIPS, LuaText.onlinemodule_8, LuaText.RETRY, LuaText.BACK, DialogContext.Mode.OK_CANCEL, self.OnDialogResult, "Event:" .. event .. ",Err:" .. errorCode, true)
  end
  self.bIgnoreDisconnectDialogue = false
  local CurOnlineState = _G.ZoneServer:GetOnlineState()
  local PreOnlineState = _G.ZoneServer:GetPreOnlineState()
  local DisOnlineState = _G.ZoneServer:GetDisOnlineState()
  local bInKickOut = _G.ZoneServer.ZoneServerKickOut:IsInKickOut()
  local bKickOutNeedReconnect = _G.ZoneServer.ZoneServerKickOut:IsKickOutNeedReconnect()
  local bTriggerAutoReconnect = false
  if self.CurReconnectRecord then
    if bKickOutNeedReconnect then
      bTriggerAutoReconnect = true
    elseif self.bPingTimeOut then
      bTriggerAutoReconnect = true
    elseif self.bReconnectAfterDisconnect then
      bTriggerAutoReconnect = true
      self.bReconnectAfterDisconnect = false
    end
  end
  Log.Debug("[ZoneServer] OnDisconnectProc [Reconnect] Info, bPingTimeOut", self.bPingTimeOut, "bReconnecting", self.bReconnecting, "ReconnectState", self.ReconnectState, "CurOnlineState", OnlineState.ToString(CurOnlineState), "PreOnlineState", OnlineState.ToString(PreOnlineState), "DisOnlineState", OnlineState.ToString(DisOnlineState), "bInKickOut", bInKickOut, "bKickOutNeedReconnect", bKickOutNeedReconnect, "bTriggerAutoReconnect", bTriggerAutoReconnect)
  if bTriggerAutoReconnect then
    local bAutoReconnectRes = self:AutoReConnect()
    if not bAutoReconnectRes then
      self:OpenDialog(LuaText.TIPS, LuaText.onlinemodule_8, LuaText.RETRY, LuaText.BACK, DialogContext.Mode.OK_CANCEL, self.OnDialogResult, "OnDisconnect, Err:" .. errorCode .. " Retry run out!", true)
    end
  end
  self.bPingTimeOut = false
end

function ZoneServerGCloud:OnStateChangedProc(connectID, event, state, errorCode, extend, extend2, extend3, ip, serverid)
  Log.Debug("[ZoneServer][NetMsg] OnStateChangedProc", connectID, event, state, errorCode, extend, extend2, extend3, ip, serverid)
  if _G.ZoneServer:IsConnected() then
    Log.Error("[ZoneServer][NetMsg] OnStateChangedProc: IsConnected()=true.")
  end
  local bSuggestReconnect = false
  if state == GCloudConnEnum.State.kConnectorStateRunning then
    Log.Error("[ZoneServer][NetMsg] OnStateChangedProc kConnectorStateRunning")
  elseif state == GCloudConnEnum.State.kConnectorStateReconnecting then
    Log.Error("[ZoneServer][NetMsg] OnStateChangedProc kConnectorStateReconnecting")
  elseif state == GCloudConnEnum.State.kConnectorStateReconnected then
    Log.Error("[ZoneServer][NetMsg] OnStateChangedProc kConnectorStateReconnected")
  elseif state == GCloudConnEnum.State.kConnectorStateStayInQueue then
    Log.Error("[ZoneServer][NetMsg] OnStateChangedProc kConnectorStateStayInQueue")
  elseif state == GCloudConnEnum.State.kConnectorStateError then
    if errorCode == GCloudConnEnum.ErrorCode.kErrorNetworkException then
      Log.Error("[ZoneServer][NetMsg] OnStateChangedProc kErrorNetworkException", errorCode, extend, extend2, extend3)
      bSuggestReconnect = true
    elseif errorCode == GCloudConnEnum.ErrorCode.kErrorSendError then
      Log.Error("[ZoneServer][NetMsg] OnStateChangedProc kErrorSendError", errorCode, extend, extend2, extend3)
      bSuggestReconnect = true
    elseif errorCode == GCloudConnEnum.ErrorCode.kErrorOverflow then
      Log.Error("[ZoneServer][NetMsg] OnStateChangedProc kErrorOverflow", errorCode, extend, extend2, extend3)
      bSuggestReconnect = true
    elseif errorCode == GCloudConnEnum.ErrorCode.kErrorPeerCloseConnection then
      Log.Error("[ZoneServer][NetMsg] OnStateChangedProc kErrorPeerCloseConnection", errorCode, extend, extend2, extend3)
      bSuggestReconnect = true
    elseif errorCode == GCloudConnEnum.ErrorCode.kErrorPeerStopSession then
      Log.Error("[ZoneServer][NetMsg] OnStateChangedProc kErrorPeerStopSession", errorCode, extend, extend2, extend3)
      local bKickOutNeedReconnect = _G.ZoneServer.ZoneServerKickOut:IsKickOutNeedReconnect()
      if bKickOutNeedReconnect then
        bSuggestReconnect = true
      else
        bSuggestReconnect = false
      end
    else
      Log.Error("[ZoneServer][NetMsg] OnStateChangedProc UnKnown", errorCode, extend, extend2, extend3)
      bSuggestReconnect = true
    end
    _G.ZoneServer:ClearAllPause()
    self:EnterWaitForReconnect()
    _G.ZoneServer.seqEventArray = {}
    _G.NRCEventCenter:DispatchEvent(_G.NRCGlobalEvent.ON_DISCONNECT, errorCode)
  end
  local CurOnlineState = _G.ZoneServer:GetOnlineState()
  local PreOnlineState = _G.ZoneServer:GetPreOnlineState()
  local DisOnlineState = _G.ZoneServer:GetDisOnlineState()
  local bInKickOut = _G.ZoneServer.ZoneServerKickOut:IsInKickOut()
  local bKickOutNeedReconnect = _G.ZoneServer.ZoneServerKickOut:IsKickOutNeedReconnect()
  local bTriggerAutoReconnect = false
  if self.CurReconnectRecord then
    if bKickOutNeedReconnect then
      bTriggerAutoReconnect = true
    elseif bSuggestReconnect then
      bTriggerAutoReconnect = true
    end
  end
  Log.Debug("[ZoneServer] OnStateChangedProc [Reconnect] Info, bSuggestReconnect", bSuggestReconnect, "bReconnecting", self.bReconnecting, "ReconnectState", self.ReconnectState, "CurOnlineState", OnlineState.ToString(CurOnlineState), "PreOnlineState", OnlineState.ToString(PreOnlineState), "DisOnlineState", OnlineState.ToString(DisOnlineState), "bInKickOut", bInKickOut, "bKickOutNeedReconnect", bKickOutNeedReconnect, "bTriggerAutoReconnect", bTriggerAutoReconnect)
  
  local function AbortReconnect()
    if self.bReconnecting then
      self:ResetAutoReconnect()
    end
  end
  
  if bTriggerAutoReconnect then
    local bAutoReconnectRes = self:AutoReConnect()
    if not bAutoReconnectRes then
      self:OpenDialog(LuaText.TIPS, LuaText.onlinemodule_8, LuaText.RETRY, LuaText.BACK, DialogContext.Mode.OK_CANCEL, self.OnDialogResult, "OnStateChanged,Err:" .. errorCode .. " Retry run out!", true)
      AbortReconnect()
    else
      Log.Debug("[ZoneServer][Reconnect] OnStateChangedProc AutoReconnect starting...")
    end
  else
    local bNeedDialogue = not bInKickOut or bKickOutNeedReconnect
    Log.Debug("[ZoneServer] OnStateChangedProc bNeedDialogue", bNeedDialogue, "bInKickOut", bInKickOut, "bKickOutNeedReconnect", bKickOutNeedReconnect)
    if bNeedDialogue then
      local content = string.format(LuaText.NET_DISCONNECT, errorCode)
      self:OpenDialog(LuaText.TIPS, content, LuaText.RETRY, LuaText.BACK, DialogContext.Mode.OK_CANCEL, self.OnDialogResult, "OnStateChanged,Err:" .. errorCode, true)
    end
    AbortReconnect()
  end
  _G.NRCEventCenter:DispatchEvent(_G.NRCGlobalEvent.ON_STATECHANGED, state, errorCode)
end

function ZoneServerGCloud:OnPingTimeOut(connectID)
  if self.bPingTimeOut then
    Log.Debug("[ZoneServer][NetMsg] already OnPingTimeOut!")
    return
  end
  Log.Debug("[ZoneServer][NetMsg] OnPingTimeOut!")
  self.bPingTimeOut = true
  _G.ZoneServer:DisConnect(true, false)
end

function ZoneServerGCloud:OnPingUpdate(connectID, NewPingInMs)
  _G.NRCEventCenter:DispatchEvent(_G.NRCGlobalEvent.OnPingUpdate, NewPingInMs)
end

function ZoneServerGCloud:OnServerTimeUpdate(connectID, bTimeOut)
  if bTimeOut then
    local CurOnlineState = _G.ZoneServer:GetOnlineState()
    if CurOnlineState == OnlineState.EnteredCell and not self.bReconnecting then
      Log.Debug("[ZoneServer][NetMsg] OnServerTimeUpdate TimeOut!")
      _G.ZoneServer:DisConnect(true, false)
      self:OpenDialog(LuaText.TIPS, LuaText.onlinemodule_8, LuaText.RETRY, LuaText.BACK, DialogContext.Mode.OK_CANCEL, self.OnDialogResult, "Server heart beat time out!")
    end
  else
    local ServerTimeStamp = math.round(_G.ZoneServer:GetServerTime() / 1000)
    Log.Debug("[ZoneServer][NetMsg] OnServerTimeUpdate", _G.ZoneServer:GetTConndRTT(), os.date("%c", ServerTimeStamp))
    _G.NRCEventCenter:DispatchEvent(_G.NRCGlobalEvent.OnServerTimeUpdate)
    local ServerTimeStr = os.date("%Y-%m-%d %H:%M %S", ServerTimeStamp)
    if not RocoEnv.IS_SHIPPING and _G.DebugModuleCmd then
      _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.SetSvrTime, ServerTimeStr)
    end
    if _G.UpdateUIModuleCmd then
      _G.NRCModuleManager:DoCmd(_G.UpdateUIModuleCmd.SetSvrTime, ServerTimeStr)
    end
  end
end

function ZoneServerGCloud:OpenDialog(title, content, btnOk, btnCancel, mode, callback, debugInfo, bDisconnect)
  Log.Debug("[ZoneServer] OpenDialog", title, content, btnOk, btnCancel, mode, callback, debugInfo)
  local Ctx = DialogContext()
  Ctx:SetTitle(title):SetContent(content):SetMode(mode):SetCallback(self, callback):SetCloseOnCancel(true):SetButtonText(btnOk, btnCancel):SetDebugInfo(debugInfo)
  Log.Debug("[ZoneServer] OpenDialog Ctx", Ctx.content)
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenOnlyForNetworkDialog, Ctx)
end

function ZoneServerGCloud:OnDialogResult(result)
  Log.Debug("[ZoneServer] OnDialogResult", result)
  if result then
    if self.CurReconnectRecord then
      self.CurReConnectTimes = 0
      self.CurReconnectState = ReconnectState.Phase2_Enduring
      self:AutoReConnect()
    else
      self:ReConnect()
      _G.GlobalConfig.SetFastLoadingWorldRendering = false
    end
  else
    Log.Debug(_G.NRCModeManager:GetCurMode().modeName)
    if _G.ZoneServer.bPause then
      _G.ZoneServer:Resume()
    end
    _G.AppMain.BackToLogin()
  end
end

function ZoneServerGCloud:IsReconnecting()
  return self.bReconnecting
end

function ZoneServerGCloud:SetMainUIReconnect(isReconnecting)
  local MainUIModule = _G.NRCModuleManager:GetModule("MainUIModule")
  if MainUIModule then
    local LobbyMainPanel = MainUIModule:GetPanel("LobbyMain")
    if LobbyMainPanel then
      LobbyMainPanel.UMG_MinimapTime:SetReconnect(isReconnecting, _G.ZoneServer:GetTConndRTT())
    end
  end
end

function ZoneServerGCloud:OnOnlineStateChanged(oldOnlineState, newOnlineState, disOnlineState)
  if newOnlineState == disOnlineState and self.bReconnecting then
    self.CurReconnectState = ReconnectState.Phase1_Insensitive
    local curTime = os.msTime()
    local deltaTime = curTime - self.lastTimeOfDateRecv
    if deltaTime < MAX_LIGHT_RECONNECT_TIME then
      Log.Debug("[ZoneServer][NpcAOI][PlayerAOI] ON_RECONNECT_FINISH, OK_TYPE=light, bLight=true, deltaTime =", deltaTime)
      _G.NRCEventCenter:DispatchEvent(_G.NRCGlobalEvent.ON_RECONNECT_FINISH, true)
    else
      Log.Debug("[ZoneServer][NpcAOI][PlayerAOI] ON_RECONNECT_FINISH, OK_TYPE=heavy, bLight=false, deltaTime =", deltaTime)
      _G.NRCEventCenter:DispatchEvent(_G.NRCGlobalEvent.ON_RECONNECT_FINISH, false)
    end
    self.bReconnecting = false
    self.StartReconnectTimeMS = 0
    self.CurReconnectRecord = nil
    self:ResetAutoReconnect()
    _G.GlobalConfig.SetFastLoadingWorldRendering = false
    self:SetMainUIReconnect(false)
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.NET_CONNECT_SUC)
  end
end

function ZoneServerGCloud:ReConnect()
  self.DelayHandle = nil
  if self.bReconnecting and 0 == self.CurReConnectTimes then
    Log.Debug("[ZoneServer] ReConnect: Already in ReConnecting...")
    return
  end
  local preOnlineState = _G.ZoneServer:GetPreOnlineState()
  Log.Debug("[ZoneServer] ReConnect, OnlineStateInfo:", "CurOnlineState=", OnlineState.ToString(_G.ZoneServer:GetOnlineState()), "DisOnlineState=", OnlineState.ToString(_G.ZoneServer:GetDisOnlineState()), "PreOnlineState=", OnlineState.ToString(_G.ZoneServer:GetPreOnlineState()))
  local SceneModule = NRCModuleManager:GetModule("SceneModule")
  if SceneModule then
    Log.Debug("[ZoneServer] ReConnect, SceneModule mapInfo:", SceneModule.preMapId, SceneModule.mapID, SceneModule._isLoading)
  end
  if preOnlineState == OnlineState.SwitchingCell and (SceneModule.preMapId == SceneModule.mapID or SceneModule._isLoading) then
    _G.GlobalConfig.SetFastLoadingWorldRendering = false
  else
    _G.GlobalConfig.SetFastLoadingWorldRendering = true
  end
  _G.ZoneServer.seqEventArray = {}
  if _G.ZoneServer:IsConnected() then
    _G.ZoneServer:DisConnect(true, true)
  else
    _G.NRCNetworkManager:ReConnect(_G.ZoneServer.connectID)
    if self.CurReconnectRecord then
      if not self.bReconnecting then
        self.bReconnecting = true
        self.CurReconnectRecord.bRetryRunOut = false
        self.StartReconnectTimeMS = os.msTime()
        Log.Debug("[ZoneServer] ON_RECONNECT_START")
        self.lastTimeOfDateRecv = _G.NRCNetworkManager:GetLastTimeOfDataRecv(_G.ZoneServer.connectID)
        self:SetMainUIReconnect(true)
        _G.ZoneServer:OpenWaitingUI("Reconnecting", LuaText.NET_CONNECTING, 5)
        _G.NRCEventCenter:DispatchEvent(_G.NRCGlobalEvent.ON_RECONNECT_START)
      end
    else
      _G.ZoneServer:OpenWaitingUI("ConnectToZone", LuaText.NET_CONNECTING)
    end
  end
end

function ZoneServerGCloud:ResetAutoReconnect()
  self.bReconnecting = false
  if self.DelayHandle then
    _G.DelayManager:CancelDelayById(self.DelayHandle)
    self.DelayHandle = nil
  end
  self.CurReConnectTimes = 0
end

function ZoneServerGCloud:AutoReConnect()
  local ElapsedTime = 0
  if self.CurReConnectTimes > 0 then
    local CurOSTime = os.msTime()
    ElapsedTime = CurOSTime - self.StartReconnectTimeMS
  end
  Log.Debug("[ZoneServer] AutoReConnect, CurReConnectTimes=", self.CurReConnectTimes, "ElapsedTime=", ElapsedTime)
  if self.CurReConnectTimes < self.MaxReConnectTimes and ElapsedTime < self.MaxReConnectDuration then
    local DelayTime = 0
    if self.CurReConnectTimes < #ReConnectIntervals then
      DelayTime = ReConnectIntervals[self.CurReConnectTimes + 1]
      Log.Debug("[ZoneServer] AutoReConnect, DelayTime=", DelayTime)
    else
      DelayTime = ReConnectIntervals[#ReConnectIntervals]
      Log.Debug("[ZoneServer] AutoReConnect, DelayTime=", DelayTime)
    end
    if self.DelayHandle then
      _G.DelayManager:CancelDelayById(self.DelayHandle)
      self.DelayHandle = nil
    end
    self.CurReConnectTimes = self.CurReConnectTimes + 1
    if self.CurReConnectTimes > 1 then
      self.DelayHandle = _G.DelayManager:DelaySeconds(DelayTime, self.ReConnect, self)
    else
      local bKickOutNeedReconnect = _G.ZoneServer.ZoneServerKickOut:IsKickOutNeedReconnect()
      if bKickOutNeedReconnect then
        self.DelayHandle = _G.DelayManager:DelaySeconds(3, self.ReConnect, self)
      else
        self:ReConnect()
      end
    end
    return true
  else
    self.bReconnecting = false
    self.CurReconnectRecord.bRetryRunOut = true
    Log.Debug("[ZoneServer] AutoReConnect failed, ClearValidServerIdAndTime", self.CurReConnectTimes)
    _G.NRCNetworkManager:ClearValidServerIdAndTime(_G.ZoneServer.connectID)
    return false
  end
end

return ZoneServerGCloud
