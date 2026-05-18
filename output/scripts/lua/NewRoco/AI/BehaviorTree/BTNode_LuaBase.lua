local LuaParamBase = require("NewRoco.AI.BehaviorTree.LuaParams.LuaParamBase")
local LuaIntParam = require("NewRoco.AI.BehaviorTree.LuaParams.LuaIntParam")
local LuaFloatParam = require("NewRoco.AI.BehaviorTree.LuaParams.LuaFloatParam")
local LuaBoolParam = require("NewRoco.AI.BehaviorTree.LuaParams.LuaBoolParam")
local LuaStringParam = require("NewRoco.AI.BehaviorTree.LuaParams.LuaStringParam")
local LuaRotatorParam = require("NewRoco.AI.BehaviorTree.LuaParams.LuaRotatorParam")
local LuaVectorParam = require("NewRoco.AI.BehaviorTree.LuaParams.LuaVectorParam")
local LuaObjectParam = require("NewRoco.AI.BehaviorTree.LuaParams.LuaObjectParam")
local LuaEnumParam = require("NewRoco.AI.BehaviorTree.LuaParams.LuaEnumParam")
local BTNode_LuaBase = NRCClass()
local _globalConf = GlobalConfig
local _pcall = pcall
local _strFormat = string.format
local LocalUE4 = UE4

function BTNode_LuaBase:Init()
  if self._HasInit then
    return
  end
  self._HasInit = true
  self.ActionName = self.LuaFileParamData.LuaFileSelectPathStruct.LuaFilePath
  if self.Action or self.ActionName == nil or self.ActionName == "" or self.ActionName == "None" then
  else
    local scriptPath = self.LuaFileFolderPath .. "." .. self.ActionName
    local ActionClass = require(scriptPath)
    if not ActionClass then
      Log.Error(_strFormat("Lua action: %s not found ", self.ActionName))
      return
    end
    self.Action = ActionClass(self)
    self:InitNodeParams()
  end
end

function BTNode_LuaBase:Finish(...)
end

function BTNode_LuaBase:InitNodeParams()
  if not self.Action then
    return
  end
  local ParamInfos = self.LuaFileParamData.LuaParamInfos
  for i = 1, ParamInfos:Length() do
    local ParamInfo = ParamInfos:Get(i)
    local LuaParam = self:GeneratedNodeParams(self.LuaFileParamData, ParamInfo)
    if LuaParam then
      self.Action[ParamInfo.LuaParamName] = LuaParam
    end
  end
end

function BTNode_LuaBase:GeneratedNodeParams(FileData, ParamInfo)
  if not self.Action or not FileData then
    return
  end
  if not FileData.LuaBlackboard then
    Log.WarningFormat("GeneratedNodeParams FileData.LuaBlackboard is nil")
    return
  end
  if ParamInfo.IsArrayType then
    local LuaParamArray = {}
    local cppArray, UseBlackboard = self:GetLuaBlackboardCppArray(ParamInfo, FileData)
    if cppArray then
      for i = 1, cppArray:Length() do
        local itemLuaParam = self:GenerateSingleLuaParamEmpty(ParamInfo)
        if UseBlackboard then
          local selector = cppArray:Get(i)
          if selector then
            itemLuaParam.useBlackboardKey = true
            itemLuaParam.key = selector.SelectedKeyName
          end
        else
          self:UpdateLuaParamValue(itemLuaParam, FileData, cppArray:Get(i))
        end
        table.insert(LuaParamArray, itemLuaParam)
      end
    end
    return LuaParamArray
  else
    local LuaParam = self:GenerateSingleLuaParamEmpty(ParamInfo)
    self:UpdateLuaParamValue(LuaParam, FileData)
    return LuaParam
  end
end

function BTNode_LuaBase:GetLuaBlackboardCppArray(ParamInfo, FileData)
  local CppArray
  if not ParamInfo.IsArrayType then
    return
  end
  local UseBlackboard = false
  local UseBehaviorTreeBlackboardKey = FileData.LuaUseArrayBlackboardKeyMap:Find(ParamInfo.LuaParamName)
  if UseBehaviorTreeBlackboardKey then
    UseBlackboard = true
    CppArray = UseBehaviorTreeBlackboardKey.Array
  else
    if ParamInfo.LuaParamType == LocalUE4.EBTData_LuaParamTypeEnum.LuaIntParam then
      CppArray = FileData.LuaBlackboard:GetValueAsArrayInt(ParamInfo.LuaParamName)
    end
    if ParamInfo.LuaParamType == LocalUE4.EBTData_LuaParamTypeEnum.LuaFloatParam then
      CppArray = FileData.LuaBlackboard:GetValueAsArrayFloat(ParamInfo.LuaParamName)
    end
    if ParamInfo.LuaParamType == LocalUE4.EBTData_LuaParamTypeEnum.LuaBoolParam then
      CppArray = FileData.LuaBlackboard:GetValueAsArrayBool(ParamInfo.LuaParamName)
    end
    if ParamInfo.LuaParamType == LocalUE4.EBTData_LuaParamTypeEnum.LuaStringParam then
      CppArray = FileData.LuaBlackboard:GetValueAsArrayString(ParamInfo.LuaParamName)
    end
    if ParamInfo.LuaParamType == LocalUE4.EBTData_LuaParamTypeEnum.LuaVectorParam then
      CppArray = FileData.LuaBlackboard:GetValueAsArrayVector(ParamInfo.LuaParamName)
    end
    if ParamInfo.LuaParamType == LocalUE4.EBTData_LuaParamTypeEnum.LuaRotatorParam then
      CppArray = FileData.LuaBlackboard:GetValueAsArrayRotator(ParamInfo.LuaParamName)
    end
    if ParamInfo.LuaParamType == LocalUE4.EBTData_LuaParamTypeEnum.LuaObjectParam then
    end
    if ParamInfo.LuaParamType == LocalUE4.EBTData_LuaParamTypeEnum.LuaEnumParam then
      CppArray = FileData.LuaBlackboard:GetValueAsArrayInt(ParamInfo.LuaParamName)
    end
  end
  return CppArray, UseBlackboard
end

function BTNode_LuaBase:GenerateSingleLuaParamEmpty(ParamInfo)
  local LuaParam
  if ParamInfo.LuaParamType == LocalUE4.EBTData_LuaParamTypeEnum.LuaIntParam then
    LuaParam = LuaIntParam()
  end
  if ParamInfo.LuaParamType == LocalUE4.EBTData_LuaParamTypeEnum.LuaFloatParam then
    LuaParam = LuaFloatParam()
  end
  if ParamInfo.LuaParamType == LocalUE4.EBTData_LuaParamTypeEnum.LuaBoolParam then
    LuaParam = LuaBoolParam()
  end
  if ParamInfo.LuaParamType == LocalUE4.EBTData_LuaParamTypeEnum.LuaStringParam then
    LuaParam = LuaStringParam()
  end
  if ParamInfo.LuaParamType == LocalUE4.EBTData_LuaParamTypeEnum.LuaVectorParam then
    LuaParam = LuaVectorParam()
  end
  if ParamInfo.LuaParamType == LocalUE4.EBTData_LuaParamTypeEnum.LuaRotatorParam then
    LuaParam = LuaRotatorParam()
  end
  if ParamInfo.LuaParamType == LocalUE4.EBTData_LuaParamTypeEnum.LuaObjectParam then
    LuaParam = LuaObjectParam()
  end
  if ParamInfo.LuaParamType == LocalUE4.EBTData_LuaParamTypeEnum.LuaEnumParam then
    LuaParam = LuaEnumParam()
  end
  if nil == LuaParam then
    LuaParam = LuaParamBase()
  end
  LuaParam.type = ParamInfo.LuaParamType
  LuaParam.paramName = ParamInfo.LuaParamName
  return LuaParam
end

function BTNode_LuaBase:UpdateLuaParamValue(LuaParam, FileData, OverrideValue)
  if not LuaParam then
    return
  end
  if OverrideValue then
    LuaParam.value = OverrideValue
    return
  end
  if FileData then
    local UseBehaviorTreeBlackboardKey = FileData.LuaUseBlackboardKeyMap:Find(LuaParam.paramName)
    if UseBehaviorTreeBlackboardKey then
      LuaParam.useBlackboardKey = true
      LuaParam.key = UseBehaviorTreeBlackboardKey.SelectedKeyName
    else
      LuaParam.useBlackboardKey = false
      if LuaParam.type == LocalUE4.EBTData_LuaParamTypeEnum.LuaIntParam then
        LuaParam.value = FileData.LuaBlackboard:GetValueAsInt(LuaParam.paramName)
      end
      if LuaParam.type == LocalUE4.EBTData_LuaParamTypeEnum.LuaFloatParam then
        LuaParam.value = FileData.LuaBlackboard:GetValueAsFloat(LuaParam.paramName)
      end
      if LuaParam.type == LocalUE4.EBTData_LuaParamTypeEnum.LuaBoolParam then
        LuaParam.value = FileData.LuaBlackboard:GetValueAsBool(LuaParam.paramName)
      end
      if LuaParam.type == LocalUE4.EBTData_LuaParamTypeEnum.LuaStringParam then
        LuaParam.value = FileData.LuaBlackboard:GetValueAsString(LuaParam.paramName)
      end
      if LuaParam.type == LocalUE4.EBTData_LuaParamTypeEnum.LuaVectorParam then
        LuaParam.value = FileData.LuaBlackboard:GetValueAsVector(LuaParam.paramName)
      end
      if LuaParam.type == LocalUE4.EBTData_LuaParamTypeEnum.LuaRotatorParam then
        LuaParam.value = FileData.LuaBlackboard:GetValueAsRotator(LuaParam.paramName)
      end
      if LuaParam.type == LocalUE4.EBTData_LuaParamTypeEnum.LuaObjectParam then
      end
      if LuaParam.type == LocalUE4.EBTData_LuaParamTypeEnum.LuaEnumParam then
        LuaParam.value = FileData.LuaBlackboard:GetValueAsInt(LuaParam.paramName)
      end
    end
  end
end

function BTNode_LuaBase:CallActionFunc(TargetAction, Func, AIController, ...)
  if Func then
    return Func(TargetAction, AIController, ...)
  else
    Log.Error(_strFormat("%s attempt to call a nil function!", self.Action.Name))
  end
end

return BTNode_LuaBase
