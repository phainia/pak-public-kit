local LocalServer = {}

function LocalServer:Ctor()
end

function LocalServer:SetRSPTable(tbl)
  self.rspTable = tbl
end

function LocalServer:SendWithHandler(reqCmdID, reqMsg, caller, rspHandler, needModal, ignoreErrorTip)
  Log.Debug("LocalServer:SendWithHandler " .. _G.ProtoCMD:GetMessageName(reqCmdID))
  if self.rspTable and self.rspTable[reqCmdID] then
    local messages = self.rspTable[reqCmdID](reqMsg)
    local MessageData = {}
    MessageData.messages = messages
    MessageData.caller = caller
    MessageData.rspHandler = rspHandler
    if self.WaitMessageTable == nil then
      self.WaitMessageTable = {}
    end
    table.insert(self.WaitMessageTable, MessageData)
  else
    Log.Debug("request not found", _G.ProtoCMD:GetMessageName(reqCmdID))
  end
end

function LocalServer:Send(reqCmdID, reqMsg, reliable, needModal, ignoreErrorTip)
  self:SendWithHandler(reqCmdID, reqMsg, nil, nil, reliable, needModal, ignoreErrorTip)
end

function LocalServer:OnTick(deltaTime)
  if not self.WaitMessageTable then
    return
  end
  for _, MessageData in ipairs(self.WaitMessageTable) do
    local messages = MessageData.messages or {}
    local caller = MessageData.caller
    local rspHandler = MessageData.rspHandler
    for index, messageItem in ipairs(messages) do
      local rspCmdID, message = messageItem[1], messageItem[2]
      if 1 == index and rspHandler then
        tcall(caller, rspHandler, message)
      end
      if self.protocolEventDic[rspCmdID] then
        for i, v in ipairs(self.protocolEventDic[rspCmdID]) do
          if v.handler then
            tcall(v.target, v.handler, message)
          end
        end
      end
    end
  end
  self.WaitMessageTable = nil
end

function LocalServer:Connect(serverName, typeid, zoneid, ip, port)
  _G.DelayManager:DelayFrames(0.1, function()
    _G.ZoneServer.ZoneServerGCloud:OnConnected(1, UE4.ENetConnectEvent.ConnectResult, 0, 0, 1)
  end)
end

return LocalServer
