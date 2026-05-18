local MockActionFactoryGeneral = require("Mock.Factory.MockActionFactoryGeneral")
local MockManager = Class()

function MockManager:Ctor()
  self.actions = {}
  self.factory = MockActionFactoryGeneral()
  self.RequestCounter = 0
  _G.ZoneServer.MockCallback = {
    caller = self,
    callback = self.ShouldUseMock
  }
end

function MockManager:GetSequenceId(SeqID)
  return "m" .. SeqID
end

function MockManager:ShouldUseMock(MessageId, Request)
  if UE4.UMockUtils.IsMockActive() ~= true then
    return nil
  end
  local action = self.factory:Get(MessageId, Request)
  if nil == action then
    return nil
  end
  if action:ShouldDoMock() then
    local ReqId = self.RequestCounter
    self.actions[ReqId] = action
    _G.DelayManager:DelaySeconds(0.1, function()
      self:DoMock(ReqId)
    end)
    self.RequestCounter = self.RequestCounter + 1
    return self:GetSequenceId(ReqId)
  end
  action = nil
  return nil
end

function MockManager:DoMock(RequestId)
  local action = self.actions[RequestId]
  if action and action.DoMock then
    local rsp = action:DoMock()
    local rspMessageId = action:GetResponseMessageId()
    _G.ZoneServer:BroadcastProcotolEvent(self:GetSequenceId(RequestId), rspMessageId, rsp)
  end
end

return MockManager
