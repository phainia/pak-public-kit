local MockActionBase = require("Mock.Actions.MockActionBase")
local Base = MockActionBase
local MockActionNextActReq = Base:Extend("MockActionNextActReq")

function MockActionNextActReq:Ctor(MessageId, Request)
  Base.Ctor(self, MessageId, Request)
  self.OptionConf = _G.DataConfigManager:GetNpcOptionConf(self.Request.option_id)
end

return MockActionNextActReq
