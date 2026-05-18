local MockActionFactoryBase = require("Mock.Factory.MockActionFactoryBase")
local Base = MockActionFactoryBase
local MockActionFactoryGeneral = Base:Extend("MockActionFactoryGeneral")

function MockActionFactoryGeneral:SetRegistry()
  self.registry = {
    [_G.ProtoCMD.ZoneSvrCmd.ZONE_SCENE_NPC_NEXT_ACT_REQ] = require("Mock.Factory.MockActionFactoryNpcOption")
  }
end

function MockActionFactoryGeneral:GetSearchKey(MessageId, Request)
  return MessageId
end

return MockActionFactoryGeneral
