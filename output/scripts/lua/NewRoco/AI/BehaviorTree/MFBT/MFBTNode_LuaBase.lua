local MFBTNode_LuaBase = Class("MFBTNode_LuaBase")
local _strFormat = string.format
local NodeClassRegistry = {}

function MFBTNode_LuaBase:Init()
  if self._HasInit then
    return
  end
  self._HasInit = true
  if self.Action or self.ActionName == nil or self.ActionName == "" or self.ActionName == "None" then
  else
    local ActionClass
    if NodeClassRegistry[self.ActionName] then
      ActionClass = NodeClassRegistry[self.ActionName]
    else
      local scriptPath = _strFormat("%s.%s", self.LuaFileFolderPath, self.ActionName)
      ActionClass = require(scriptPath)
      if ActionClass then
        NodeClassRegistry[self.ActionName] = ActionClass
      end
    end
    if not ActionClass then
      Log.Error(_strFormat("[MFBT] Lua action: %s not found ", self.ActionName))
      return
    end
    self.Action = ActionClass(self)
    self:InitNodeParams()
  end
end

function MFBTNode_LuaBase:InitNodeParams()
  if not self.Action then
    return
  end
  if not self.MFBTLuaComponent then
    return
  end
  local nodeData = self.MFBTLuaComponent:GetNodeData(self.ParentTreeID, self.NodeExeID)
  for _i, LuaParamName in ipairs(nodeData.paramNames) do
    self.Action[LuaParamName] = nodeData[LuaParamName]
  end
end

function MFBTNode_LuaBase:MFBTNodeCallActionFunc(TargetAction, Func, ...)
  if Func then
    local ownerAIController = self.MFBTLuaComponent:GetOwnerController()
    return Func(TargetAction, ownerAIController, ...)
  else
    Log.Error(_strFormat("[MFBT] %s attempt to call a nil function!", self.Action.Name))
  end
end

function MFBTNode_LuaBase:Finish(success)
end

return MFBTNode_LuaBase
