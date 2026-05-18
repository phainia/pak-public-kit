local Base = require("NewRoco.AI.BehaviorTree.LuaParams.LuaParamBase")
local LuaParamType = require("NewRoco.AI.BehaviorTree.LuaParams.LuaParamType")
local LuaBoolParam = Base:Extend("LuaBoolParam")

function LuaBoolParam:Ctor(enableMFBT)
  Base.Ctor(self, enableMFBT)
  self.type = LuaParamType.Bool
end

function LuaBoolParam:GetValue(AIController)
  if not self.useBlackboardKey then
    return self.value
  end
  if not AIController then
    return false
  end
  if AIController.LocalGlobalConfig.BTreeUseLuaBlackboard then
    local Value = AIController.LuaBTBlackboard[self.key]
    if nil ~= Value then
      return Value
    else
      return false
    end
  elseif self.isMFBTEnable then
    return AIController:GetMfbbBool(self.key)
  else
    return AIController.Blackboard:GetValueAsBool(self.key)
  end
end

function LuaBoolParam:SetValue(AIController, Value)
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
      AIController:SetMfbbBool(self.key, Value)
    end
  elseif not AIController.LocalGlobalConfig.BTreeUseLuaBlackboard or AIController.LocalGlobalConfig.BTreeDebugCppBlackboard then
    AIController.Blackboard:SetValueAsBool(self.key, Value)
  end
end

function LuaBoolParam:GetType()
  return LuaParamType.Bool
end

return LuaBoolParam
