local HomeResMgr = Class("HomeResMgr")

function HomeResMgr:Ctor()
  self.ResourcesMap = {}
  self.ResourcesRefMap = {}
  self.RecycledPropsActors = {}
  self.LoadingRequests = {}
end

function HomeResMgr:OnExitHome()
  self.RecycledPropsActors = {}
  self.ResourcesMap = {}
  self.ResourcesRefMap = {}
  self.LoadingRequests = {}
end

function HomeResMgr:OnResourceLoad(AssetPath, Asset)
  if not HomeIndoorSandbox:InHomeIndoor() then
    return
  end
  if HomeIndoorSandbox:Ensure(Asset, "invalid resource", AssetPath) then
    self.ResourcesMap[AssetPath] = Asset
    self.ResourcesRefMap[AssetPath] = UnLua.Ref(Asset)
  end
end

function HomeResMgr:ReleaseResource(Request)
  if not HomeIndoorSandbox:Ensure(Request, "logical error") then
    return
  end
  local TestRequests = self.LoadingRequests[Request.assetPath]
  if TestRequests then
    TestRequests[Request] = nil
  end
  if Request.assetPath then
    self.ResourcesMap[Request.assetPath] = nil
    self.ResourcesRefMap[Request.assetPath] = nil
  end
  if -1 ~= Request.sessionId then
    NRCResourceManager:UnLoadRes(Request)
  end
end

function HomeResMgr:TryGetResource(AssetPath, bNeedCheckReload)
  local Ret = self.ResourcesMap[AssetPath]
  if Ret and (not UE.UObject.IsValid(Ret) or not self.ResourcesRefMap[AssetPath]) then
    Ret = nil
    self.ResourcesMap[AssetPath] = nil
    self.ResourcesRefMap[AssetPath] = nil
    local TestRequests = self.LoadingRequests[AssetPath]
    local bLoading = false
    if TestRequests then
      for Request, _ in pairs(TestRequests) do
        if NRCResourceManager:IsLoadingRes(Request) then
          bLoading = true
          break
        end
      end
    end
    if not bLoading and bNeedCheckReload then
      HomeIndoorSandbox:Ensure(false, "reload " .. AssetPath)
      Ret = UE.UObject.Load(AssetPath)
      self:OnResourceLoad(AssetPath, Ret)
    end
  end
  return Ret
end

function HomeResMgr:ReqResource(Callback, AssetPath, LowPriority)
  local RetAsset = self:TryGetResource(AssetPath)
  if RetAsset then
    Callback(RetAsset)
    return
  end
  local TestRequests = self.LoadingRequests[AssetPath]
  if not TestRequests then
    TestRequests = {}
    self.LoadingRequests[AssetPath] = TestRequests
  elseif next(TestRequests) then
    HomeIndoorSandbox:LogDebug("duplicate request resource", AssetPath)
  end
  local bLoading = true
  local TestRequest
  
  local function OnLoadSuccess(Caller, Request, Asset)
    bLoading = false
    if TestRequest then
      TestRequests[TestRequest] = nil
    end
    RetAsset = Asset
    self:OnResourceLoad(AssetPath, Asset)
    return Callback(RetAsset)
  end
  
  local function OnLoadFailed(Caller, Request, Msg)
    bLoading = false
    if TestRequest then
      TestRequests[TestRequest] = nil
    end
    return Callback(nil, Msg)
  end
  
  local function OnUnLoad()
    bLoading = false
    if TestRequest then
      TestRequests[TestRequest] = nil
    end
    HomeIndoorSandbox:LogWarn("cancel load resource", AssetPath)
  end
  
  TestRequest = NRCResourceManager:LoadResAsync(self, AssetPath, LowPriority and 128 or 255, -1, OnLoadSuccess, OnLoadFailed, nil, OnUnLoad)
  if bLoading and TestRequest then
    TestRequests[TestRequest] = true
  end
  return TestRequest
end

function HomeResMgr:ResolvePropsActor(PropsData)
  local PropsActor = self.RecycledPropsActors[PropsData.Id]
  if PropsActor then
    self.RecycledPropsActors[PropsData.Id] = nil
  end
  return PropsActor
end

function HomeResMgr:RecyclePropsActor(PropsData, PropsActor)
  self.RecycledPropsActors[PropsData.Id] = PropsActor
end

return HomeResMgr
