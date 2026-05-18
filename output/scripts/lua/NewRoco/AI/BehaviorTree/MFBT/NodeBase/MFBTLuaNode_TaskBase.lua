local Base = require("NewRoco.AI.BehaviorTree.MFBT.MFBTNode_LuaBase")
local MFBTLuaNode_TaskBase = Base:Extend("MFBTLuaNode_TaskBase")

function MFBTLuaNode_TaskBase:Ctor(LuaBTNodeBase)
  self.LuaFileFolderPath = "NewRoco.AI.BehaviorTree.Actions"
  self.running = false
end

function MFBTLuaNode_TaskBase:OnTaskStart()
  self:Init()
  if self.Action then
    self.running = true
    self:MFBTNodeCallActionFunc(self.Action, self.Action.OnStart)
  end
end

function MFBTLuaNode_TaskBase:OnTaskTick(deltaTime)
  if self.Action then
    self:MFBTNodeCallActionFunc(self.Action, self.Action.OnUpdate, deltaTime)
  end
end

function MFBTLuaNode_TaskBase:OnTaskEnd(...)
  if self.Action then
    self:MFBTNodeCallActionFunc(self.Action, self.Action.OnInterrupt, ...)
  end
end

function MFBTLuaNode_TaskBase:Finish(success)
  if not self.running then
    return
  end
  local aiController = self.MFBTLuaComponent:GetOwnerController()
  if aiController then
    if nil == success then
      Log.ErrorFormat("[MFBT] MFBTLuaNode_TaskBase:Finish succ param is nil. treeId:%s ExeID:%s", self.ParentTreeID, self.NodeExeID)
    end
    if aiController and UE.UObject.IsValid(aiController) then
      aiController:DoBTTaskFinish(self.ParentTreeID, self.NodeExeID, success)
    end
  end
  self.running = false
end

return MFBTLuaNode_TaskBase
