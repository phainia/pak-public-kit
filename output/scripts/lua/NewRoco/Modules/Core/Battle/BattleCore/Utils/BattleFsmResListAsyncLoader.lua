local BattleFsmResListAsyncLoader = _G.NRCClass()

function BattleFsmResListAsyncLoader:Ctor(caller, resPathList, successCallback, failedCallback)
  self.caller = caller
  self.resPathList = resPathList
  self.resTotalCount = #self.resPathList
  self.resLoadedCount = 0
  self.loadedResList = {}
  self.successCallback = successCallback
  self.failedCallback = failedCallback
end

function BattleFsmResListAsyncLoader:Run()
  for i, resPath in ipairs(self.resPathList) do
    _G.BattleResourceManager:LoadResAsync(self, resPath, self.LoadResCallBack, self.LoadResCallBack)
  end
end

function BattleFsmResListAsyncLoader:LoadResCallBack(resource)
  if not resource then
    Log.Error("cannot preload assert", self.resLoadedCount + 1)
  elseif not resource.GetDefaultObject then
    Log.Error("loaded assert is not a uclass resource", resource)
  end
  self.resLoadedCount = self.resLoadedCount + 1
  table.insert(self.loadedResList, resource)
  Log.Info("loaded", self.resLoadedCount, resource)
  if self.resLoadedCount == self.resTotalCount then
    self.successCallback(self.caller, self.loadedResList)
    self.loadedResList = {}
  end
end

return BattleFsmResListAsyncLoader
