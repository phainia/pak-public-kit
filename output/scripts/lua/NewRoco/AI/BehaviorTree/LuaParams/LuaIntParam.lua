local Base = require("NewRoco.AI.BehaviorTree.LuaParams.LuaParamBase")
local LuaParamType = require("NewRoco.AI.BehaviorTree.LuaParams.LuaParamType")
local LuaIntParam = Base:Extend("LuaIntParam")

function LuaIntParam:Ctor(enableMFBT)
  Base.Ctor(self, enableMFBT)
  self.type = LuaParamType.Int
end

function LuaIntParam:GetValue(AIController)
  if not self.useBlackboardKey then
    return self.value
  end
  if not AIController then
    return 0
  end
  if AIController.LocalGlobalConfig.BTreeUseLuaBlackboard then
    local Value = AIController.LuaBTBlackboard[self.key]
    if nil ~= Value then
      return Value
    else
      return 0
    end
  elseif self.isMFBTEnable then
    return AIController:GetMfbbInt(self.key)
  else
    return AIController.Blackboard:GetValueAsInt(self.key)
  end
end

function LuaIntParam:SetValue(AIController, Value)
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
      AIController:SetMfbbInt(self.key, Value)
    end
  elseif not AIController.LocalGlobalConfig.BTreeUseLuaBlackboard or AIController.LocalGlobalConfig.BTreeDebugCppBlackboard then
    AIController.Blackboard:SetValueAsInt(self.key, Value)
  end
end

function LuaIntParam:GetType()
  return LuaParamType.Int
end

return LuaIntParam
