local NRCModuleManager = _G.Singleton:Extend("NRCModuleManager")

function NRCModuleManager:Ctor()
  _G.Singleton.Ctor(self, self.name)
  Log.Debug("[NRCModuleManager] ctor")
  self.registedModuleList = {}
  self.moduleHeadDict = {}
  self.moduleDict = {}
  self.modulePathToName = {}
  self.moduleCmdDict = {}
  self.moduleHeadCmdDict = {}
  self.autoActiveModuleByCmd = true
  
  function HotFix.AutoHotFixFileInjectFunction(fileName)
  end
  
  _G.NRCEventCenter:RegisterEvent(self.name, self, _G.NRCGlobalEvent.Shutdown, self.OnShutdown)
end

function NRCModuleManager:Free()
  _G.Singleton.Free(self)
end

function NRCModuleManager:OnShutdown()
  for moduleName, module in pairs(self.moduleDict) do
    Log.Debug("OnShutdown:", moduleName)
    _G.tcall(module, module.OnShutdown)
  end
end

function NRCModuleManager:RegisterModuleHead(moduleName, headPath)
  if headPath then
    local headCla = require(headPath)
    local head = headCla(moduleName)
    self.moduleHeadDict[moduleName] = head
    return head
  else
    return nil
  end
end

function NRCModuleManager:RegisterModule(moduleName, moduleType, moduleHeadPath, modulePath)
  Log.Trace("[NRCModuleManager] RegisterModule:", moduleName, moduleHeadPath, modulePath)
  self.modulePathToName[modulePath] = moduleName
  local moduleData = {}
  moduleData.moduleName = moduleName
  moduleData.moduleType = moduleType
  moduleData.modulePath = modulePath
  moduleData.moduleHead = self:RegisterModuleHead(moduleName, moduleHeadPath)
  if moduleData.moduleHead then
    for k, v in pairs(moduleData.moduleHead.cmdDict) do
      self.moduleCmdDict[k] = moduleName
      self.moduleHeadCmdDict[k] = moduleName
    end
  end
  self.registedModuleList[moduleName] = moduleData
end

function NRCModuleManager:UnRegisterModule(moduleName)
  self.registedModuleList[moduleName] = nil
end

function NRCModuleManager:ActiveModule(moduleName, isReload)
  local loadFunc = HotFix.RequireFile
  if isReload then
    loadFunc = HotFix.ReloadFile
  end
  if not self:GetModule(moduleName) then
    local moduleData = self.registedModuleList[moduleName]
    if moduleData then
      Log.Debug("[NRCModuleManager] try require module:", moduleData.modulePath)
      moduleData.moduleClass = loadFunc(moduleData.modulePath)
      local t = moduleData.moduleClass
      Log.Debug("[NRCModuleManager] ActiveModule:type", type(moduleData.moduleClass))
      if type(moduleData.moduleClass) == "string" then
        Log.Error("[NRCModuleManager] \229\136\157\229\167\139\229\140\150Module\229\188\130\229\184\184\239\188\140Module\231\188\150\232\175\145\229\164\177\232\180\165\239\188\140\232\175\183\233\135\141\232\189\189Module\229\144\142\229\134\141\232\175\149:", moduleName)
        return
      end
      Log.Debug("[NRCModuleManager] try create module:", moduleName)
      local module = t()
      Log.Debug("[NRCModuleManager] try create module end:", moduleName)
      module:SetModuleData(moduleData)
      Log.Debug("[NRCModuleManager] module name:", module.moduleName)
      self:Add(moduleData.moduleName, module)
      module:Construct()
      module:ActiveModule(moduleData.moduleActiveArgs)
      module.fromOutSide = 0
    else
      Log.Error("[NRCModuleManager] \230\151\160\230\179\149\230\191\128\230\180\187\230\156\170\230\179\168\229\134\140Module:", moduleName)
    end
  end
end

function NRCModuleManager:DeactiveModule(moduleName)
  local module = self:GetModule(moduleName)
  if module and self:IsModuleDeactivable(moduleName) then
    Log.Debug("[NRCModuleManager] DeactiveModule succ:", moduleName)
    module:DeactiveModule()
    module:Destruct()
    self:Remove(moduleName)
    self.registedModuleList[moduleName] = nil
  else
    Log.Debug("[NRCModuleManager] DeactiveModule fail:", moduleName)
  end
end

function NRCModuleManager:ReloadModule(moduleName, keepData)
  local data = self:GetModule(moduleName):GetData()
  self:DeactiveModule(moduleName)
  self:ActiveModule(moduleName, true)
  if keepData then
    self:GetModule(moduleName):SetData(data)
  end
end

function NRCModuleManager:PreloadModulePanel()
  for moduleName, module in pairs(self.moduleDict) do
    Log.Debug("NRCModuleManager PreloadModulePanel:", moduleName)
    module:PreLoadCachePanel()
  end
end

function NRCModuleManager:Add(moduleName, module)
  Log.Debug("[NRCModuleManager] try add module:", moduleName)
  self.moduleDict[moduleName] = module
end

function NRCModuleManager:Remove(moduleName)
  self.moduleDict[moduleName] = nil
end

function NRCModuleManager:GetModule(moduleName)
  return self.moduleDict[moduleName]
end

function NRCModuleManager:IsModuleActive(moduleName)
  local module = self:GetModule(moduleName)
  return module and module.isActive
end

function NRCModuleManager:IsModuleRegistered(moduleName)
  return self.registedModuleList[moduleName] ~= nil
end

function NRCModuleManager:GetModuleType(moduleName)
  return self.registedModuleList[moduleName].moduleType
end

function NRCModuleManager:RegisterModuleCmd(cmd, moduleName)
  if not self.moduleCmdDict[moduleName] then
    self.moduleCmdDict[moduleName] = {}
  end
  if not self.moduleCmdDict[cmd] then
    self.moduleCmdDict[cmd] = moduleName
  else
  end
end

function NRCModuleManager:UnRegisterModuleCmd(cmd, moduleName, isUnRegistHeadCmd)
  if isUnRegistHeadCmd and self.moduleHeadCmdDict[cmd] then
    return
  end
  if self.moduleCmdDict[cmd] then
    Log.Debug("[NRCModuleManager] UnRegisterModuleCmd:", moduleName, cmd)
    self.moduleCmdDict[cmd] = nil
  else
    Log.Debug("[NRCModuleManager] \232\175\183\229\139\191\233\135\141\229\164\141\231\167\187\233\153\164\231\155\184\229\144\140cmd:" .. cmd)
  end
end

function NRCModuleManager:DoCmd(cmd, ...)
  if self.moduleCmdDict[cmd] then
    local module = self:GetModule(self.moduleCmdDict[cmd])
    if not module then
      if RocoEnv.IS_EDITOR then
        Log.Error("module\228\184\141\229\173\152\229\156\168:", cmd)
      end
      return false
    end
    if module.isActive then
      if module.enableLog then
      end
      return module:DoCmdInternal(cmd, ...)
    elseif self.autoActiveModuleByCmd then
      self:ActiveModule(self.moduleCmdDict[cmd])
      local module = self:GetModule(self.moduleCmdDict[cmd])
      if module.enableLog then
      end
      return module:DoCmdInternal(cmd, ...)
    end
  else
    if not _G.GlobalConfig.DisableNPCModule then
      Log.WarningFormat("[NRCModuleManager]:DoCmd %s not found", cmd)
    end
    return false
  end
end

function NRCModuleManager:DoCmdAsync(asyncData, cmd, ...)
  if self.moduleCmdDict[cmd] then
    local module = self:GetModule(self.moduleCmdDict[cmd])
    if module and module.isActive then
      if module.enableLog then
      end
      return module:DoCmdAsync(asyncData, cmd, ...)
    elseif self.moduleHeadCmdDict[cmd] and self.autoActiveModuleByCmd then
      self:ActiveModule(self.moduleCmdDict[cmd])
      local module = self:GetModule(self.moduleCmdDict[cmd])
      if module.enableLog then
      end
      return module:DoCmdAsync(asyncData, cmd, ...)
    end
  end
end

function NRCModuleManager:DoCmdWithArgs(cmdWithArgs, ...)
  local cmd = cmdWithArgs
  local args
  if string.find(cmdWithArgs, ",") then
    local subStrings = {}
    for str in string.gmatch(cmdWithArgs, "[^,;]+") do
      local trimStr = str:match("^%s*(.-)%s*$")
      table.insert(subStrings, trimStr)
    end
    if #subStrings > 1 then
      cmd = subStrings[1]
      args = {}
      for i = 2, #subStrings do
        local argString = subStrings[i]
        if argString then
          local numberParam = tonumber(argString)
          if numberParam then
            table.insert(args, numberParam)
          else
            table.insert(args, argString)
          end
        end
      end
    end
  end
  if args then
    self:DoCmd(cmd, table.unpack(args), ...)
  else
    self:DoCmd(cmd, ...)
  end
end

function NRCModuleManager:IsModuleDeactivable(moduleName)
  return self:GetModuleType(moduleName) ~= NRCModuleTypeDef.Donnt_Destroy
end

return NRCModuleManager
