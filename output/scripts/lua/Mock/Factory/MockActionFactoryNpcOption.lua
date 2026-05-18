local MockActionFactoryBase = require("Mock.Factory.MockActionFactoryBase")
local Base = MockActionFactoryBase
local MockActionFactoryNpcOption = Base:Extend("MockActionFactoryGeneral")

function MockActionFactoryNpcOption:SetRegistry()
  self.registry = {}
end

function MockActionFactoryNpcOption:GetSearchKey(MessageId, Request)
  local optionId = Request.option_id
  local optionConf = _G.DataConfigManager:GetNpcOptionConf(optionId)
  if nil == optionConf then
    return -1
  end
  return optionConf.action.action_type
end

return MockActionFactoryNpcOption
