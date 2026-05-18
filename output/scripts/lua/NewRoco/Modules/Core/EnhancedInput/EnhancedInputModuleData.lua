local EnhancedInputModuleData = _G.NRCData:Extend("EnhancedInputModuleData")

function EnhancedInputModuleData:Ctor()
  NRCData.Ctor(self)
  self.configKeyMappings = {}
end

function EnhancedInputModuleData:InitData()
  local allConfData = _G.DataConfigManager:GetAllByName("DEFAULT_BUTTON_CONF")
  if not allConfData then
    return
  end
  local configKeyMappings = self.configKeyMappings
  for _, _conf in pairs(allConfData) do
    configKeyMappings[_conf.button_action] = _conf.default_button
  end
end

function EnhancedInputModuleData:GetMappingKey(_actionName)
  local userKeyMappings = self.userKeyMappings
  if userKeyMappings then
    local key = userKeyMappings[_actionName]
    if key then
      return key
    end
  end
  local configKeyMappings = self.configKeyMappings
  if configKeyMappings then
    return configKeyMappings[_actionName]
  end
end

function EnhancedInputModuleData:ApplyUserModifiedKeyMappings(_keyMappings)
  if not _keyMappings then
    return
  end
  if not self.userKeyMappings then
    self.userKeyMappings = _keyMappings
  else
    local userKeyMappings = self.userKeyMappings
    for actionName, key in pairs(_keyMappings) do
      userKeyMappings[actionName] = key
    end
  end
end

return EnhancedInputModuleData
