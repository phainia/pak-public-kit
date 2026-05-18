local EnhancedInputMappingContext = Class("EnhancedInputMappingContext")
local CurMappingContextSeq = 0

local function GetContextSeq()
  CurMappingContextSeq = CurMappingContextSeq + 1
  return CurMappingContextSeq
end

function EnhancedInputMappingContext:Ctor(contextName)
  assert(contextName, "must set a valid contextName!")
  self.contextName = contextName
  self.sortNumber = GetContextSeq()
  self.bindActions = {}
  self.onlyForChangeKey = {}
  self.mappingContext = UE.UNRCEnhancedInputHelper.GetInputMappingContext(contextName)
  if not self.mappingContext then
    Log.ErrorFormat("can't find context: %s", contextName)
  end
end

function EnhancedInputMappingContext:__Dctor()
  if not self.disableAutoRelease then
    self:Release()
  end
end

function EnhancedInputMappingContext:DisableAutoRelease()
  self.disableAutoRelease = true
end

function EnhancedInputMappingContext:Release()
  for _actionName, _inputAction in pairs(self.bindActions) do
    if _inputAction and UE.UObject.IsValid(_inputAction) and not self.onlyForChangeKey[_actionName] then
      UE.UNRCEnhancedInputHelper.UnBindAction(_inputAction)
    end
  end
  self:DisableInputMappingContext()
  self.mappingContext = nil
  self.bindActions = {}
end

function EnhancedInputMappingContext:GetMappingContextName()
  return self.contextName
end

function EnhancedInputMappingContext:IsMappingContextEnable()
  local mappingContext = self.mappingContext
  if mappingContext and UE.UObject.IsValid(mappingContext) then
    return UE.UNRCEnhancedInputHelper.HasInputMappingContext(mappingContext)
  end
  return false
end

function EnhancedInputMappingContext:EnableInputMappingContext(_priority)
  local mappingContext = self.mappingContext
  if mappingContext and UE.UObject.IsValid(mappingContext) then
    self.sortNumber = GetContextSeq()
    _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.EnhancedInputHelperAddInputMappingContext, mappingContext, _priority)
    for _actionName, _ in pairs(self.bindActions) do
      local bindKey = _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.GetMappingKey, _actionName)
      if bindKey then
        self:ChangeKey(_actionName, bindKey)
      end
    end
  end
end

function EnhancedInputMappingContext:DisableInputMappingContext()
  local mappingContext = self.mappingContext
  if mappingContext and UE.UObject.IsValid(mappingContext) then
    _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.EnhancedInputHelperRemoveInputMappingContext, mappingContext)
  end
end

function EnhancedInputMappingContext:SetMappingContextActive(_active)
  local mappingContext = self.mappingContext
  if mappingContext and UE.UObject.IsValid(mappingContext) then
    return UE.UNRCEnhancedInputHelper.SetInputMappingContextActive(mappingContext, _active or false)
  end
end

function EnhancedInputMappingContext:BindAction(_actionName, _caller, _functionName, _triggerEvent)
  if not _actionName then
    return
  end
  local inputAction = UE.UNRCEnhancedInputHelper.GetInputAction(_actionName)
  if inputAction then
    self.bindActions[_actionName] = inputAction
    if _caller and _functionName then
      UE.UNRCEnhancedInputHelper.BindAction(inputAction, _triggerEvent or UE.ETriggerEvent.Triggered, _caller, _functionName)
    else
      self.onlyForChangeKey[_actionName] = true
    end
    local bindKey = _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.GetMappingKey, _actionName)
    if bindKey then
      self:ChangeKey(_actionName, bindKey)
    end
  else
    Log.ErrorFormat("BindAction: can not find action %s", _actionName)
  end
end

function EnhancedInputMappingContext:UnBindAction(_actionName)
  if not _actionName then
    return
  end
  local inputAction = UE.UNRCEnhancedInputHelper.GetInputAction(_actionName)
  if inputAction then
    self.bindActions[_actionName] = nil
    UE.UNRCEnhancedInputHelper.UnBindAction(inputAction)
  end
end

function EnhancedInputMappingContext:ChangeKey(_actionName, _newKey)
  if not _actionName or not _newKey then
    return
  end
  local mappingContext = self.mappingContext
  if not mappingContext or not UE.UObject.IsValid(mappingContext) then
    return
  end
  local inputAction = self.bindActions[_actionName]
  if inputAction and UE.UObject.IsValid(inputAction) then
    if not UE.EKeys[_newKey] then
      Log.ErrorFormat("EnhancedInputMappingContext:ChangeKey invalid key name = %s for _actionName = %s, please check DEFAULT_BUTTON_CONF table config", tostring(_newKey), tostring(_actionName))
    end
    mappingContext:ChangeMapKey(inputAction, UE.EKeys[_newKey])
  end
end

function EnhancedInputMappingContext:AddKey(_actionName, _newKey)
  if not _actionName or not _newKey then
    return
  end
  local mappingContext = self.mappingContext
  if not mappingContext or not UE.UObject.IsValid(mappingContext) then
    return
  end
  local inputAction = self.bindActions[_actionName]
  if inputAction and UE.UObject.IsValid(inputAction) then
    mappingContext:MapKey(inputAction, UE.EKeys[_newKey])
  end
end

function EnhancedInputMappingContext:RemoveKey(_actionName, _removeKey)
  if not _actionName or not _removeKey then
    return
  end
  local mappingContext = self.mappingContext
  if not mappingContext or not UE.UObject.IsValid(mappingContext) then
    return
  end
  local inputAction = self.bindActions[_actionName]
  if inputAction and UE.UObject.IsValid(inputAction) then
    mappingContext:UnmapKey(inputAction, UE.EKeys[_removeKey])
  end
end

function EnhancedInputMappingContext:ChangeKeys(_keyMappings)
  if not _keyMappings then
    return
  end
  for _actionName, _newKey in pairs(_keyMappings) do
    self:ChangeKey(_actionName, _newKey)
  end
end

function EnhancedInputMappingContext:GetDebugData()
  local debugData = {}
  debugData.sortNumber = self.sortNumber
  debugData.contextName = self.contextName
  debugData.bindActions = {}
  for _actionName, _ in pairs(self.bindActions) do
    debugData.bindActions[_actionName] = _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.GetMappingKey, _actionName) or "Not Find Key!"
  end
  return debugData
end

return EnhancedInputMappingContext
