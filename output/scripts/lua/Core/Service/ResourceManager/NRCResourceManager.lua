local NRCResourceManager = _G.Singleton:Extend("NRCResourceManager")
local ResRequest = reload("Core.Service.ResourceManager.ResRequest")

function NRCResourceManager:Ctor()
  if _G.NRCEditorEntranceEnable then
    return
  end
  local GameInstance = UE4.UNRCPlatformGameInstance.GetInstance()
  if not GameInstance and RocoEnv.IS_EDITOR then
    return
  end
  self.bind = GameInstance:GetLuaResourceManager()
  self.sessionMap = setmetatable({}, {__mode = "v"})
  self.requestMap = {}
  self:BindCallBackFunction(self, self.OnSuc, self.OnFail, self.OnProgress)
  _G.NRCEventCenter:RegisterEvent(self.name, self, _G.NRCGlobalEvent.OnPrePIEEnded, self.Uninit)
  _G.NRCEventCenter:RegisterEvent(self.name, self, _G.NRCGlobalEvent.Shutdown, self.OnShutdown)
end

function NRCResourceManager:Uninit()
  Log.Debug("NRCResourceManager:Uninit")
  local toRemoveList = {}
  for key, value in pairs(self.sessionMap) do
    table.insert(toRemoveList, value)
  end
  for i = 1, #toRemoveList do
    self:UnLoadRes(toRemoveList[i])
  end
  self.sessionMap = setmetatable({}, {__mode = "v"})
  self.requestMap = {}
end

function NRCResourceManager:OnShutdown()
  self.bind:UnBindCallBackFunction()
  self:Uninit()
end

function NRCResourceManager:BindCallBackFunction(caller, loadSuccessCallback, loadFailedCallback, loadProgressCallback)
  self.bind:BindCallBackFunction({
    self.bind,
    SimpleDelegateFactory:CreateCallback(caller, function(caller, id, path, asset)
      loadSuccessCallback(caller, id, path, asset)
    end)
  }, {
    self.bind,
    SimpleDelegateFactory:CreateCallback(caller, function(caller, id, path, errMsg)
      loadFailedCallback(caller, id, path, errMsg)
    end)
  }, {
    self.bind,
    SimpleDelegateFactory:CreateCallback(caller, function(caller, id, path, progress)
      loadProgressCallback(caller, id, path, progress)
    end)
  })
end

function NRCResourceManager:LoadResAsync(caller, assetPath, priority, cacheTime, loadSuccessCallback, loadFailedCallback, loadProgressCallback, unLoadCallback)
  if assetPath and string.find(assetPath, "//") then
    Log.ErrorFormat("Attempted to load a resource with name containing double slashes. AssetPath: %s", assetPath)
    return
  end
  local sessionId = self.bind:LoadAssetAsync(assetPath, priority, cacheTime)
  Log.Debug("NRCResourceManager:LoadResAsync", assetPath, priority)
  local resRequest
  if nil == resRequest then
    resRequest = ResRequest()
  end
  resRequest:SetData(sessionId, caller, assetPath, priority, cacheTime, loadSuccessCallback, loadFailedCallback, loadProgressCallback, unLoadCallback)
  Log.Debug("NRCResourceManager:LoadResAsync", resRequest.sessionId, resRequest.caller, resRequest.assetPath, resRequest.priority, resRequest.cacheTime, resRequest.loadSuccessCallback, resRequest.loadFailedCallback, resRequest.loadProgressCallback)
  self.sessionMap[sessionId] = resRequest
  self.requestMap[sessionId] = resRequest
  return resRequest
end

function NRCResourceManager:UnLoadRes(resRequest)
  if not resRequest then
    Log.Error("NRCResourceManager:UnLoadRes has not resRequest!!!")
    return
  end
  Log.Debug("NRCResourceManager:UnLoadRes", resRequest.sessionId, self.sessionMap[resRequest.sessionId])
  if resRequest and resRequest.unLoadCallback then
    resRequest.unLoadCallback(resRequest)
  end
  if -1 ~= resRequest.sessionId then
    self.sessionMap[resRequest.sessionId] = nil
    self.requestMap[resRequest.sessionId] = nil
    self.bind:UnloadAsset(resRequest.sessionId)
    resRequest:Reset()
  else
  end
end

function NRCResourceManager:UnLoadResByCaller(caller)
  Log.Debug("NRCResourceManager:UnLoadResByCaller", caller)
  local toRemoveList = {}
  for key, value in pairs(self.sessionMap) do
    if value.caller == caller then
      table.insert(toRemoveList, value)
    end
  end
  for i = 1, #toRemoveList do
    self:UnLoadRes(toRemoveList[i])
  end
end

function NRCResourceManager:IsLoadedRes(resRequest)
  self.bind:IsLoadedAsset(resRequest.sessionId)
end

function NRCResourceManager:IsLoadingRes(resRequest)
  self.bind:IsLoadingAsset(resRequest.sessionId)
end

function NRCResourceManager:TryGetLoadedRes(resRequest)
  return self.bind:TryGetLoadedAsset(resRequest.sessionId)
end

function NRCResourceManager:OnSuc(sessionId, path, asset)
  Log.Debug("NRCResourceManager:OnSuc", sessionId, path, asset)
  local resRequest = self.sessionMap[sessionId]
  if resRequest then
    if resRequest.loadSuccessCallback then
      resRequest.loadSuccessCallback(resRequest.caller, resRequest, asset)
    end
    resRequest.loadSuccessCallback = nil
    resRequest.loadFailedCallback = nil
    resRequest.loadProgressCallback = nil
    resRequest.unLoadCallback = nil
    self.requestMap[resRequest.sessionId] = nil
  end
end

function NRCResourceManager:OnFail(sessionId, path, errMsg)
  Log.Error("NRCResourceManager:OnFail", sessionId, path)
  local resRequest = self.sessionMap[sessionId]
  if resRequest then
    if resRequest.loadFailedCallback then
      resRequest.loadFailedCallback(resRequest.caller, resRequest, errMsg)
    end
    resRequest.loadSuccessCallback = nil
    resRequest.loadFailedCallback = nil
    resRequest.loadProgressCallback = nil
    resRequest.unLoadCallback = nil
    self.requestMap[resRequest.sessionId] = nil
  end
end

function NRCResourceManager:OnProgress(sessionId, path, progress)
  Log.Debug("NRCResourceManager:OnProgress", sessionId, path)
  local resRequest = self.sessionMap[sessionId]
  if resRequest and resRequest.loadProgressCallback then
    resRequest.loadProgressCallback(resRequest.caller, resRequest, progress)
  end
end

function NRCResourceManager:IsValidLoad()
  return self.bind and self.bind:IsValid()
end

function NRCResourceManager:LoadForDebugOnly(Path)
  return UE4.UClass.Load(Path)
end

function NRCResourceManager:LoadUObjectForDebugOnly(Path)
  return UE4.UObject.Load(Path)
end

return NRCResourceManager
