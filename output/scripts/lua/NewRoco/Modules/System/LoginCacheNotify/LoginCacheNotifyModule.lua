local LoginCacheNotifyModule = NRCModuleBase:Extend("LoginCacheNotifyModule")

function LoginCacheNotifyModule:OnConstruct()
  self.ZoneServer = _G.ZoneServer
  DataModelMgr.LoginNotifyModel:Init()
end

function LoginCacheNotifyModule:OnActive()
  self:Log("OnActive")
  self:RegisterBattleNotify()
end

function LoginCacheNotifyModule:RegisterBattleNotify()
  self.ZoneServer:AddProtocolListener(self, ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_ENTER_NOTIFY, self.CacheBattleNotify)
end

function LoginCacheNotifyModule:UnRegisterBattleNotify()
  self.ZoneServer:RemoveProtocolListener(self, ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_ENTER_NOTIFY, self.CacheBattleNotify)
end

function LoginCacheNotifyModule:CacheBattleNotify(notify)
  if not self.isActive then
    self:LogError("is deactive")
    return
  end
  local notifyCmdId = ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_ENTER_NOTIFY
  self:CacheNotify("Battle", notifyCmdId, notify)
end

function LoginCacheNotifyModule:CacheNotify(tag, notifyCmdId, notify)
  self.Log("tag,notifyCmdId:", tag, notifyCmdId)
  DataModelMgr.LoginNotifyModel:WriteCache(tag, notifyCmdId, notify)
end

function LoginCacheNotifyModule:OnLogin(isRelogin)
  self:Log("OnLogin", isRelogin)
  DataModelMgr.LoginNotifyModel:ClearCache()
end

function LoginCacheNotifyModule:OnDeactive()
  self:Log("OnDeactive")
  self:UnRegisterBattleNotify()
  self:UnRegisterAllCmd()
end

function LoginCacheNotifyModule:OnDestruct()
end

return LoginCacheNotifyModule
