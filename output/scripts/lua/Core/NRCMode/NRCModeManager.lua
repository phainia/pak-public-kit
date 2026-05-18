local NRCModeManager = _G.Singleton:Extend("NRCModeManager")

function NRCModeManager:Ctor()
  Log.Debug("NRCModeManager ctor")
  Singleton.Ctor(self, self.name)
  self.modeClaDict = {}
  self.modeDict = {}
  self.curActivedMode = nil
  self.needActiveMode = false
  self.nextModeName = nil
  _G.UpdateManager:Register(self)
end

function NRCModeManager:Free()
  _G.UpdateManager:UnRegister(self)
end

function NRCModeManager:RegisterMode(modeName, modeClass)
  if not self.modeClaDict[modeName] then
    self.modeClaDict[modeName] = modeClass
  else
    Log.Error("\229\183\178\231\187\143\230\179\168\229\134\140\231\155\184\229\144\140Mode:", modeName)
  end
end

function NRCModeManager:GetMode(modeName)
  if self.modeDict[modeName] then
    return self.modeDict[modeName]
  else
  end
end

function NRCModeManager:ActiveMode(modeName)
  if self.modeClaDict[modeName] then
    Log.Trace("NRCModeManager ActiveMode:", modeName)
    if self.curActivedMode and self.curActivedMode.modeName == modeName then
      Log.Trace("Mode \229\183\178\230\191\128\230\180\187 :", modeName)
    else
      local mode = self:GetMode(modeName)
      if not mode then
        self.modeDict[modeName] = self.modeClaDict[modeName]()
        Log.Debug("NRCModeManager active s")
        mode = self:GetMode(modeName)
      end
      if self.curActivedMode then
        Log.Debug("mode Deactive:", self.curActivedMode.modeName)
        self.modeDict[self.curActivedMode.modeName] = nil
        self.curActivedMode:Deactive()
      end
      self.curActivedMode = mode
      mode.modeName = modeName
      mode:Construct()
      mode:Active()
      mode:BroadcastActiveModeEvent()
      Log.Debug("NRCModeManager ActiveMode Suc", modeName, self.curActivedMode)
    end
  else
    Log.Error("\232\175\183\229\133\136\230\179\168\229\134\140Mode:", modeName)
  end
end

function NRCModeManager:ActiveModeNextFrame(modeName)
  self.needActiveMode = true
  self.nextAciveModeName = modeName
  _G.UpdateManager:Register(self)
end

function NRCModeManager:DeactiveMode(modeName)
  local mode = self:GetMode(modeName)
  if mode then
    mode:Deactive()
  end
end

function NRCModeManager:DeactiveModeNextFrame(modeName)
end

function NRCModeManager:GetCurMode()
  if self.curActivedMode then
    return self.curActivedMode
  else
  end
end

function NRCModeManager:DoCmd(cmd, ...)
  return NRCModuleManager:DoCmd(cmd, ...)
end

function NRCModeManager:DoCmdAsync(asyncData, cmd, ...)
  return NRCModuleManager:DoCmdAsync(asyncData, cmd, ...)
end

function NRCModeManager:OnTick()
  if self.needActiveMode and self.nextAciveModeName ~= nil then
    self:ActiveMode(self.nextAciveModeName)
    self.nextAciveModeName = nil
    self.needActiveMode = false
    _G.UpdateManager:UnRegister(self)
  end
end

return NRCModeManager
