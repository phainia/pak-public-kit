local Base = require("NewRoco.AI.BehaviorTree.LuaServiceBase")
local LuaServiceSetControlFlag = Base:Extend("LuaServiceSetControlFlag")

function LuaServiceSetControlFlag:OnStart(OwnerController, ...)
  local owner = OwnerController
  local flag = self.Flag:GetValue(owner)
  owner.Npc.AIComponent:SetControlFlags(flag)
end

function LuaServiceSetControlFlag:OnEnd(OwnerController, ...)
  local owner = OwnerController
  local flag = self.Flag:GetValue(owner)
  owner.Npc.AIComponent:UnsetControlFlags(flag)
end

return LuaServiceSetControlFlag
