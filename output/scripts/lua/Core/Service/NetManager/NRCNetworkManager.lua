local NRCNetworkManager = _G.Singleton:Extend("NRCNetworkManager")

function NRCNetworkManager:Ctor()
  local GameInstance = UE4.UNRCPlatformGameInstance.GetInstance()
  if not GameInstance and RocoEnv.IS_EDITOR then
    return
  end
  self.bind = GameInstance:GetLuaNetworkManager()
end

function NRCNetworkManager:CreateConnector(connectID, connectType)
  self.bind:CreateConnector(connectID, connectType)
end

function NRCNetworkManager:DestroyConnector(connectID)
  self.bind:DestroyConnector(connectID)
end

function NRCNetworkManager:SetUserAccountInfo(connectID, openId, accessToken)
  self.bind:SetUserAccountInfo(connectID, openId, accessToken)
end

function NRCNetworkManager:SetAppId(connectID, appId)
  self.bind:SetAppId(connectID, appId)
end

function NRCNetworkManager:ConnectToZone(connectID, typeId, ZoneId, serverId, ipOrDomain, port, keyMakingMethod, encryptMethod, authType, authChannel, clbIpStrArr)
  self.bind:ConnectToZone(connectID, typeId, ZoneId, serverId, ipOrDomain, port, keyMakingMethod, encryptMethod, authType, authChannel, clbIpStrArr)
end

function NRCNetworkManager:DisConnect(connectID)
  self.bind:DisConnect(connectID)
end

function NRCNetworkManager:GetConnectState(connectID)
  return self.bind:GetConnectState(connectID)
end

function NRCNetworkManager:ReConnect(connectID)
  _G.NRCSDKManager:PerfBeginMark("ReConnect")
  _G.NRCSDKManager:PerfBeginExclude("ReConnect")
  self.bind:ReConnect(connectID)
  _G.NRCSDKManager:PerfEndExclude("ReConnect")
  _G.NRCSDKManager:PerfEndMark("ReConnect")
end

function NRCNetworkManager:GetIP(connectID)
  return self.bind:GetIP(connectID)
end

function NRCNetworkManager:GetPort(connectID)
  return self.bind:GetPort(connectID)
end

function NRCNetworkManager:AddConnectEventListener(connectID, key, caller, callback)
  self.bind:AddConnectEventListener(connectID, key, {
    self.bind,
    SimpleDelegateFactory:CreateCallback(self, function(self, cID, event, state, errorCode, extend, extend1, extend2, ip, serverID)
      callback(caller, cID, event, state, errorCode, extend, extend1, extend2, ip, serverID)
    end)
  })
end

function NRCNetworkManager:RemoveConnectEventListener(connectID, key)
  self.bind:RemoveConnectEventListener(connectID, key)
end

function NRCNetworkManager:AddDisconnectEventListener(connectID, key, caller, callback)
  self.bind:AddDisconnectEventListener(connectID, key, {
    self.bind,
    SimpleDelegateFactory:CreateCallback(self, function(self, cID, event, state, errorCode, extend, extend1, extend2, ip, serverID)
      callback(caller, cID, event, state, errorCode, extend, extend1, extend2, ip, serverID)
    end)
  })
end

function NRCNetworkManager:RemoveDisconnectEventListener(connectID, key)
  self.bind:RemoveDisconnectEventListener(connectID, key)
end

function NRCNetworkManager:AddStateChangeEventListener(connectID, key, caller, callback)
  self.bind:AddStateChangeEventListener(connectID, key, {
    self.bind,
    SimpleDelegateFactory:CreateCallback(self, function(self, cID, event, state, errorCode, extend, extend2, extend3, ip, serverID)
      callback(caller, cID, event, state, errorCode, extend, extend2, extend3, ip, serverID)
    end)
  })
end

function NRCNetworkManager:RemoveStateChangeEventListener(connectID, key)
  self.bind:RemoveStateChangeEventListener(connectID, key)
end

function NRCNetworkManager:AddPingTimeOutListener(connectID, key, caller, callback)
  self.bind:AddPingTimeOutListener(connectID, key, {
    self.bind,
    _G.SimpleDelegateFactory:CreateCallback(self, function(self, connectID)
      callback(caller, connectID)
    end)
  })
end

function NRCNetworkManager:RemovePingTimeOutListener(connectID, key)
  self.bind:RemovePingTimeOutListener(connectID, key)
end

function NRCNetworkManager:AddPingUpdateListener(connectID, key, caller, callback)
  self.bind:AddPingUpdateListener(connectID, key, {
    self.bind,
    _G.SimpleDelegateFactory:CreateCallback(self, function(self, connectID, NewPingInMs)
      callback(caller, connectID, NewPingInMs)
    end)
  })
end

function NRCNetworkManager:RemovePingUpdateListener(connectID, key)
  self.bind:RemovePingUpdateListener(connectID, key)
end

function NRCNetworkManager:AddServerTimeUpdateListener(connectID, key, caller, callback)
  self.bind:AddServerTimeUpdateListener(connectID, key, {
    self.bind,
    _G.SimpleDelegateFactory:CreateCallback(self, function(self, connectID, bTimeOut)
      callback(caller, connectID, bTimeOut)
    end)
  })
end

function NRCNetworkManager:RemoveServerTimeUpdateListener(connectID, key)
  self.bind:RemoveServerTimeUpdateListener(connectID, key)
end

function NRCNetworkManager:AddAllProtocolListener(connectID, key, caller, callback)
  self.bind:AddAllProtocolListener(connectID, key, {
    self.bind,
    SimpleDelegateFactory:CreateCallback(self, function(self, connectID, seqID, protocolID, bytes, msgSize, receiveTimeMS, bLocal)
      callback(caller, connectID, seqID, protocolID, bytes, msgSize, receiveTimeMS, bLocal)
    end)
  })
end

function NRCNetworkManager:RemoveAllProtocolListener(connectID, key)
  self.bind:RemoveAllProtocolListener(connectID, key)
end

function NRCNetworkManager:AddProtocolListener(connectID, pid, key, caller, callback)
  self.bind:AddProtocolListener(connectID, pid, key, {
    self.bind,
    SimpleDelegateFactory:CreateCallback(self, function(self, connectID, seqID, protocolID, bytes, msgSize, receiveTimeMS, bLocal)
      callback(caller, connectID, seqID, protocolID, bytes, msgSize, receiveTimeMS, bLocal)
    end)
  })
end

function NRCNetworkManager:RemoveProtocolListener(connectID, pid, key)
  self.bind:RemoveProtocolListener(connectID, pid, key)
end

function NRCNetworkManager:Send(connectID, reqCmdID, data, msgSize, bWaitingForResponse, bWithSeqId)
  if self.bind.Send ~= nil then
    return self.bind:Send(connectID, reqCmdID, data, msgSize, bWaitingForResponse, bWithSeqId)
  else
    Log.Error("self.bind.Send == nil")
    return 0
  end
end

function NRCNetworkManager:SendUrgent(connectID, reqCmdID, data, msgSize, bWaitingForResponse, bWithSeqId)
  if self.bind.SendUrgent ~= nil then
    return self.bind:SendUrgent(connectID, reqCmdID, data, msgSize, bWaitingForResponse, bWithSeqId)
  else
    Log.Error("self.bind.SendUrgent == nil")
    return 0
  end
end

function NRCNetworkManager:Pause(connectID)
  self.bind:Pause(connectID)
end

function NRCNetworkManager:Resume(connectID)
  self.bind:Resume(connectID)
end

function NRCNetworkManager:EnableGCloudLogInfo(enable)
  self.bind:EnableGCloudLogInfo(enable)
end

function NRCNetworkManager:SetTCPTaskLogVerbose(bVerbose)
  self.bind:SetTCPTaskLogVerbose(bVerbose)
end

function NRCNetworkManager:GetTConndRTT(connectID)
  return self.bind:GetTConndRTT(connectID)
end

function NRCNetworkManager:GetServerRTT(connectID)
  return self.bind:GetServerRTT(connectID)
end

function NRCNetworkManager:GetServerTime(connectID)
  return self.bind:GetServerTime(connectID)
end

function NRCNetworkManager:SetServerTimeOnlyForInit(connectID, initServerTime)
  self.bind:SetServerTimeOnlyForInit(connectID, initServerTime)
end

function NRCNetworkManager:LockUpstream(connectID, bLock)
  self.bind:LockUpstream(connectID, bLock)
end

function NRCNetworkManager:IsUpstreamLocked(connectID)
  return self.bind:IsUpstreamLocked(connectID)
end

function NRCNetworkManager:GetLastTimeOfDataRecv(connectID)
  return self.bind:GetLastTimeOfDataRecv(connectID)
end

function NRCNetworkManager:FlushRecvMessage(connectID)
  self.bind:FlushRecvMessage(connectID)
end

function NRCNetworkManager:FlushSendMessage(connectID)
  self.bind:FlushSendMessage(connectID)
end

function NRCNetworkManager:SetCmdIdNameMap(connectID, CmdId, CmdName)
  self.bind:SetCmdIdNameMap(connectID, CmdId, CmdName)
end

function NRCNetworkManager:SetValidServerId(connectID, validServerId)
  self.bind:SetValidServerId(connectID, validServerId)
end

function NRCNetworkManager:ClearValidServerIdAndTime(connectID)
  self.bind:ClearValidServerIdAndTime(connectID)
end

function NRCNetworkManager:ReloadNetworkLuaState(connectID)
  self.bind:ReloadLuaState(connectID)
end

function NRCNetworkManager:ReceiveLocalMsg(connectID, bytes, size)
  local pb = self.bind:GetPbBuffForLocal(_G.ZoneServer.connectID)
  if pb then
    pb:SetDataFromBinary(bytes, size)
    self.bind:ReceiveLocalMsg(connectID, pb)
  else
    Log.Error("NRCNetworkManager:ReceiveLocalMsg, pb for local is nil!")
  end
end

return NRCNetworkManager
