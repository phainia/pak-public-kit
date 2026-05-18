local MockActionBase = Class("MockActionBase")

function MockActionBase:Ctor(MessageId, Request)
  self.MessageId = MessageId
  self.Request = Request
end

function MockActionBase:ShouldDoMock()
  return false
end

function MockActionBase:GetResponseMessageId()
  if self.MessageId then
    return self.MessageId + 1
  end
  return -1
end

function MockActionBase:DoMock()
  local rsp = {
    ret_info = _G.ProtoMessage:newRetInfo()
  }
  rsp.ret_info.ret_code = -1
  return rsp
end

return MockActionBase
