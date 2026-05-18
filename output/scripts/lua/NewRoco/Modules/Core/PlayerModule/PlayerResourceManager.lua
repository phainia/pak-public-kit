local Base = require("Common.Singleton.Singleton")
local PlayerResourceManager = Base:Extend()

function PlayerResourceManager:Ctor(name)
  self.name = name or "PlayerResourceManager"
  Base.Ctor(self, self.name)
  self.bind = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.URocoPlayerResourceManager)
  if not self.bind then
    return
  end
  self.sessionMapSuc = setmetatable({}, {__mode = "v"})
  self.sessionMapFail = setmetatable({}, {__mode = "v"})
  self.sessionMapCaller = setmetatable({}, {__mode = "v"})
  self.sessionMapSignle = setmetatable({}, {__mode = "v"})
  self.bind:BindCallBackFunction({
    self.bind,
    SimpleDelegateFactory:CreateCallback(self, function(caller, id, success, assets)
      self.OnLoadComplete(caller, id, success, assets)
    end)
  })
  _G.NRCEventCenter:RegisterEvent(self.name, self, _G.NRCGlobalEvent.OnPrePIEEnded, self.Uninit)
  _G.NRCEventCenter:RegisterEvent(self.name, self, _G.NRCGlobalEvent.Shutdown, self.OnShutdown)
end

function PlayerResourceManager:Free()
  Base.Free(self)
end

function PlayerResourceManager:Uninit()
  if not self.bind then
    return
  end
  self.bind:UnBindCallBackFunction()
end

function PlayerResourceManager:OnShutdown()
  self:Uninit()
end

function PlayerResourceManager:LoadResources(caller, paths, Priority, onSuc, onFail, setSession, cacheTime)
  if nil == cacheTime then
    cacheTime = -1
  end
  local sessionId = self.bind:CreateLoadResourcesSession(paths, Priority, cacheTime)
  if 0 == sessionId then
    Log.Error("PlayerResourceManager:\229\190\133\229\138\160\232\189\189\232\181\132\228\186\167\229\136\151\232\161\168\228\184\186\231\169\186")
    return -1
  end
  self.sessionMapCaller[sessionId] = caller
  self.sessionMapSuc[sessionId] = onSuc
  self.sessionMapFail[sessionId] = onFail
  if setSession and type(setSession) == "function" then
    setSession(sessionId)
  end
  self.bind:CommitSession(sessionId)
  return sessionId
end

function PlayerResourceManager:LoadResourceSingle(caller, paths, Priority, onSuc, onFail, cacheTime)
  local sessionId = self.bind:CreateLoadResourcesSession(paths, Priority, cacheTime)
  if 0 == sessionId then
    Log.Error("PlayerResourceManager:\229\190\133\229\138\160\232\189\189\232\181\132\228\186\167\229\136\151\232\161\168\228\184\186\231\169\186")
    return
  end
  self.sessionMapCaller[sessionId] = caller
  self.sessionMapSuc[sessionId] = onSuc
  self.sessionMapFail[sessionId] = onFail
  self.sessionMapSignle[sessionId] = true
  self.bind:CommitSession(sessionId)
end

function PlayerResourceManager:OnLoadComplete(sessionId, success, assets)
  if not self.sessionMapCaller[sessionId] then
    self.sessionMapSuc[sessionId] = nil
    self.sessionMapFail[sessionId] = nil
    self.sessionMapSignle[sessionId] = nil
    return
  end
  if self.sessionMapSignle[sessionId] then
    assets = assets[1]
  end
  if success then
    if self.sessionMapSuc[sessionId] then
      self.sessionMapSuc[sessionId](self.sessionMapCaller[sessionId], assets, sessionId)
    end
  elseif self.sessionMapFail[sessionId] then
    self.sessionMapFail[sessionId](self.sessionMapCaller[sessionId], assets, sessionId)
  end
  self.sessionMapCaller[sessionId] = nil
  self.sessionMapSuc[sessionId] = nil
  self.sessionMapFail[sessionId] = nil
  self.sessionMapSignle[sessionId] = nil
end

function PlayerResourceManager:GetStaticResource(path)
  return self.bind:GetStaticResource(path)
end

function PlayerResourceManager:LoadResources_PlayerLogic_List(caller, paths, isLocal, onSuc, onFail, setSession, cacheTime)
  local Priority = isLocal and PriorityEnum.Local_Player_Logic or PriorityEnum.Other_Player_Logic
  return self:LoadResources(caller, paths, Priority, onSuc, onFail, setSession, cacheTime)
end

function PlayerResourceManager:LoadResources_PlayerLogic(caller, path, isLocal, onSuc, onFail, setSession, cacheTime)
  local Priority = isLocal and PriorityEnum.Local_Player_Perform or PriorityEnum.Other_Player_Perform
  return self:LoadResourceSingle(caller, {path}, Priority, onSuc, onFail, setSession, cacheTime)
end

function PlayerResourceManager:LoadResources_PlayerPerform_List(caller, paths, isLocal, onSuc, onFail, setSession, cacheTime)
  local Priority = isLocal and PriorityEnum.Local_Player_Perform or PriorityEnum.Other_Player_Perform
  return self:LoadResources(caller, paths, Priority, onSuc, onFail, setSession, cacheTime)
end

function PlayerResourceManager:LoadResources_PlayerPerform(caller, path, isLocal, onSuc, onFail, setSession, cacheTime)
  local Priority = isLocal and PriorityEnum.Local_Player_Perform or PriorityEnum.Other_Player_Perform
  return self:LoadResourceSingle(caller, {path}, Priority, onSuc, onFail, setSession, cacheTime)
end

return PlayerResourceManager
