local Base = require("NewRoco.AI.BehaviorTree.LuaParams.LuaParamBase")
local LuaParamType = require("NewRoco.AI.BehaviorTree.LuaParams.LuaParamType")
local LuaVectorParam = Base:Extend("LuaVectorParam")

function LuaVectorParam:Ctor(enableMFBT)
  Base.Ctor(self, enableMFBT)
  self.type = LuaParamType.Vector
end

function LuaVectorParam:GetValue(AIController)
  if not self.useBlackboardKey then
    return self.value
  end
  if not AIController then
    return UE4Helper.InvalidVector
  end
  if AIController.LocalGlobalConfig.BTreeUseLuaBlackboard then
    local Value = AIController.LuaBTBlackboard[self.key]
    if nil ~= Value then
      return Value
    else
      return UE4Helper.InvalidVector
    end
  elseif self.isMFBTEnable then
    return AIController:GetMfbbVector(self.key)
  else
    return AIController.Blackboard:GetValueAsVector(self.key)
  end
end

function LuaVectorParam:SetValue(AIController, Value)
  if not self.useBlackboardKey then
    local NpcName = "nil"
    if AIController and AIController.Npc then
      NpcName = AIController.Npc.config.name
    end
    Log.WarningFormat("LuaParam: Cant Set Value For Not BlackboardType, Name:%s, NpcName:%s", tostring(self.paramName), NpcName)
    return
  end
  if not AIController then
    return Log.Trace("LuaParam: Invalid ai controller")
  end
  if AIController.LocalGlobalConfig.BTreeUseLuaBlackboard then
    AIController.LuaBTBlackboard[self.key] = Value
  end
  if self.isMFBTEnable then
    if AIController.LocalGlobalConfig.MFBTUpdateBlackboardValueToCpp then
      AIController:SetMfbbVector(self.key, Value)
    end
  elseif not AIController.LocalGlobalConfig.BTreeUseLuaBlackboard or AIController.LocalGlobalConfig.BTreeDebugCppBlackboard then
    AIController.Blackboard:SetValueAsVector(self.key, Value)
  end
end

function LuaVectorParam:GetType()
  return LuaParamType.Vector
end

return LuaVectorParam
