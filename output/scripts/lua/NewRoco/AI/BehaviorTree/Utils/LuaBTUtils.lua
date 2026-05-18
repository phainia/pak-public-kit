local LuaBTUtils = NRCClass()
local DecoratorFolder = "NewRoco.AI.BehaviorTree.Decorators"
local ServiceFolder = "NewRoco.AI.BehaviorTree.Services"
local ActionFolder = "NewRoco.AI.BehaviorTree.Actions"
LuaBTUtils.SPT_PlayAnimation = require("NewRoco.AI.BehaviorTree.SimpleTask.SimpleTaskPlayAnimation")
LuaBTUtils.SPT_PauseOrResumeAnimation = require("NewRoco.AI.BehaviorTree.SimpleTask.SimpleTaskPauseOrResumeAnimation")
LuaBTUtils.SPT_NumericOp = require("NewRoco.AI.BehaviorTree.SimpleTask.SimpleTaskNumericOp")
LuaBTUtils.SPT_GetPawnBBValue = require("NewRoco.AI.BehaviorTree.SimpleTask.SimpleTaskGetPawnBBValue")

function LuaBTUtils.GetDecorator(DecoratorName)
  return DecoratorFolder .. DecoratorName
end

function LuaBTUtils.GetService(ServiceName)
  return ServiceFolder .. ServiceName
end

function LuaBTUtils.GetService(ActionName)
  return ActionFolder .. ActionName
end

function LuaBTUtils.LogDebug(...)
  if GlobalConfig.DebugLuaBTree then
    Log.Debug(...)
  end
end

return LuaBTUtils
