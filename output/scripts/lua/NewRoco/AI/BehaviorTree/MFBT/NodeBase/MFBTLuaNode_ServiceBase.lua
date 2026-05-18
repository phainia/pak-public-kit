local Base = require("NewRoco.AI.BehaviorTree.MFBT.MFBTNode_LuaBase")
local MFBTLuaNode_ServiceBase = Base:Extend("MFBTLuaNode_ServiceBase")

function MFBTLuaNode_ServiceBase:Ctor(LuaBTNodeBase)
  self.Name = "LuaServiceBase"
  self.BTNodeBase = LuaBTNodeBase
  self.LuaFileFolderPath = "NewRoco.AI.BehaviorTree.Services"
end

function MFBTLuaNode_ServiceBase:OnServiceStart(...)
  self:Init()
  if self.Action then
    self:MFBTNodeCallActionFunc(self.Action, self.Action.OnStart, ...)
  end
end

function MFBTLuaNode_ServiceBase:OnServiceTick(deltaTime)
  if self.Action then
    self:MFBTNodeCallActionFunc(self.Action, self.Action.OnUpdateService, deltaTime)
  end
end

function MFBTLuaNode_ServiceBase:OnServiceEnd(...)
  if self.Action then
    self:MFBTNodeCallActionFunc(self.Action, self.Action.OnEnd, ...)
  end
end

return MFBTLuaNode_ServiceBase
