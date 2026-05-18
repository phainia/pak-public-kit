local Class = _G.MakeSimpleClass
local FrameLimitQueue = require("NewRoco.Modules.Core.NPC.FrameLimitQueue")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local NPCActorPool = Class("NPCActorPool")

function NPCActorPool:Ctor()
  self.asyncLoad = true
  self.pool = {}
  self.totalUse = {}
  self.waitNPCCaller = {}
  self.waitNPCUrl = {}
  self.waitNPCRequest = {}
  self.needToExtend = {}
  self.bNeedToExtend = {}
  self.needToBurn = {}
  self.customNeed = {}
  self.recycle_num = 1
  self.spawn_num = 1
  self.asyncExtending = false
  self.extendTimer = 0
  self.extendTime = 0.5
  self.burnTime = 0.5
  self.SpawnQueue = FrameLimitQueue("Spawn", self.spawn_num)
  self.RecycleQueue = FrameLimitQueue("Recycle", self.recycle_num)
end

function NPCActorPool:PrintInfo()
  Log.Debug("NPCActorPool:PrintInfo")
  local total = 0
  for url, pool in pairs(self.pool) do
    local num = pool and #pool or 0
    total = total + num
    Log.Debug(url, num)
  end
  Log.Warning("NPCActorPool:PrintInfo, Pool Total", total)
  Log.Debug("needToExtend", #self.needToExtend)
end

local function BoxPoolCacheEntry(inst)
  return inst and {
    inst,
    UnLua.Ref(inst)
  }
end

local function UnBoxPoolCacheEntry(cacheEntry)
  return cacheEntry and cacheEntry[1]
end

function NPCActorPool:ExtendImmediately()
  Log.Warning("ExtendImmediately\230\150\185\230\179\149\229\183\178\229\188\131\231\148\168\239\188\140\232\139\165\230\156\137\229\191\133\232\166\129\233\156\128\232\166\129\233\135\141\229\134\153")
end

function NPCActorPool:SetCustomNeedByModelConfId(id, num)
  local url = _G.DataConfigManager:GetModelConf(id).path
  self:SetCustomNeedByUrl(url, num)
end

function NPCActorPool:SetCustomNeedByUrl(url, num)
  self.customNeed[url] = num
  local curNum = self.pool[url] and #self.pool[url] or 0
  if num > curNum then
    table.insert(self.needToExtend, url)
    self.bNeedToExtend[url] = true
  end
end

function NPCActorPool:OnAsyncExtendLoad(resRequest, characterClass)
  self.asyncExtending = false
  local url = resRequest.assetPath
  if not self.pool[url] then
    self.pool[url] = {}
  end
  table.insert(self.pool[url], BoxPoolCacheEntry(self:CreateActorByClass(characterClass)))
end

function NPCActorPool:ExtendOnce()
  local last = #self.needToExtend
  if last > 0 then
    local url = self.needToExtend[last]
    local totalNum = self.totalUse[url]
    local poolNum = self.pool[url] and #self.pool[url] or 0
    local totalNeed = self.customNeed[url] or 6
    if poolNum < totalNum * 2 and poolNum < totalNeed and not self.asyncExtending then
      if self.asyncLoad then
        self.asyncExtending = true
        NRCResourceManager:LoadResAsync(self, url, -1, -1, self.OnAsyncExtendLoad, function(call, resRequest, errMsg)
          Log.Error("NPCActorPool:ExtendOnce: Class\229\138\160\232\189\189\229\164\177\232\180\165\239\188\140\232\175\183\230\163\128\230\159\165\232\181\132\230\186\144\233\133\141\231\189\174 ", resRequest.assetPath)
        end)
      else
        local characterClass
        if nil == characterClass then
          Log.Error("NPCActorPool:Get: Class\229\138\160\232\189\189\229\164\177\232\180\165\239\188\140\232\175\183\230\163\128\230\159\165\232\181\132\230\186\144\233\133\141\231\189\174 ", url)
          return
        end
        if not self.pool[url] then
          self.pool[url] = {}
        end
        table.insert(self.pool[url], BoxPoolCacheEntry(self:CreateActorByClass(characterClass)))
      end
    end
    if #self.pool[url] >= totalNum * 2 or totalNeed <= #self.pool[url] then
      table.remove(self.needToExtend, last)
      self.bNeedToExtend[url] = nil
    end
  end
end

local needRemoveCache = {}

function NPCActorPool:OnTick(deltaTime)
  self.extendTimer = self.extendTimer + deltaTime
  local First = self.RecycleQueue:FramedPop()
  if First then
    self:Recycle(First.url, First.viewObj)
    self.RecycleQueue:ReturnNode(First)
  else
    self:TryOnClassLoad()
  end
  if not SceneUtils.debugCloseNPCPoolExtend and self.extendTimer > (SceneUtils.debugPoolExtendTime or self.extendTime) then
    self.extendTimer = 0
    self:ExtendOnce()
  end
  if not SceneUtils.debugCloseNPCPoolBurn then
    local needRemove = needRemoveCache
    table.clear(needRemove)
    for url, timer in pairs(self.needToBurn) do
      if #self.pool[url] > 0 then
        self.needToBurn[url] = timer + deltaTime
        if self.needToBurn[url] > (SceneUtils.debugPoolBurnTime or self.burnTime) then
          local obj = UnBoxPoolCacheEntry(table.remove(self.pool[url], #self.pool[url]))
          if UE4.UObject.IsValid(obj) and obj.K2_DestroyActor then
            NRCResourceManager:UnLoadResByCaller(obj)
            obj:K2_DestroyActor()
          else
            Log.Error("\229\175\185\232\177\161\230\177\160\229\134\133\231\154\132\229\175\185\232\177\161\232\162\171\230\143\144\229\137\141\233\148\128\230\175\129", url)
          end
        end
      else
        table.insert(needRemove, url)
      end
    end
    for _, url in pairs(needRemove) do
      self.needToBurn[url] = nil
    end
  end
end

function NPCActorPool:ClearAll()
  local Node = self.RecycleQueue:Pop()
  while Node do
    self:Recycle(Node.url, Node.viewObj)
    self.RecycleQueue:ReturnNode(Node)
    Node = self.RecycleQueue:Pop()
  end
  self.SpawnQueue:ClearAll()
  for url, pool in pairs(self.pool) do
    for _, poolEntry in pairs(pool) do
      local obj = UnBoxPoolCacheEntry(poolEntry)
      NRCResourceManager:UnLoadResByCaller(obj)
      if UE.UObject.IsValid(obj) then
        obj:K2_DestroyActor()
      end
    end
    table.clear(pool)
  end
  self.pool = {}
  self.needToExtend = {}
  self.totalUse = {}
  self.bNeedToExtend = {}
  self.customNeed = {}
  self.needToBurn = {}
  self.waitNPCCaller = {}
  self.waitNPCUrl = {}
  self.waitNPCRequest = {}
  NRCResourceManager:UnLoadResByCaller(self)
end

function NPCActorPool:CreateActorByClass(class)
  local params = {}
  params.sceneCharacter = nil
  local quat = UE4.FQuat.FromAxisAndAngle(UE4Helper.UpVector, 0)
  local World = _G.UE4Helper.GetCurrentWorld()
  local fTransfom = UE4.FTransform(quat, UE4.FVector(-10000, -10000, -10000))
  local actor = World:Abs_SpawnActor(class, fTransfom, UE4.ESpawnActorCollisionHandlingMethod.AdjustIfPossibleButAlwaysSpawn, nil, nil, nil, params)
  if actor and actor.ForceHidden then
    actor:ForceHidden()
  end
  return actor
end

function NPCActorPool:PreOnClassLoad(Request, Klass)
  if nil == Klass then
    Log.Error("NPCActorPool:Get: Class\229\138\160\232\189\189\229\164\177\232\180\165\239\188\140\232\175\183\230\163\128\230\159\165\232\181\132\230\186\144\233\133\141\231\189\174 ", Request.assetPath)
    return nil
  end
  local Node = self.SpawnQueue:Push()
  Node.Request = Request
  Node.Klass = Klass
end

function NPCActorPool:TryOnClassLoad()
  local First = self.SpawnQueue:FramedPop()
  if not First then
    return
  end
  local Req = First.Request
  local Klass = First.Klass
  self.SpawnQueue:ReturnNode(First)
  self:OnClassLoad(Req, Klass)
end

function NPCActorPool:OnClassLoad(resRequest, characterClass)
  local url = self.waitNPCUrl[resRequest]
  if nil == url then
    return nil
  end
  if nil == characterClass then
    Log.Error("NPCActorPool:Get: Class\229\138\160\232\189\189\229\164\177\232\180\165\239\188\140\232\175\183\230\163\128\230\159\165\232\181\132\230\186\144\233\133\141\231\189\174 ", url)
    return nil
  end
  if self.bNeedToExtend then
    if not self.bNeedToExtend[url] then
      table.insert(self.needToExtend, url)
      self.bNeedToExtend[url] = true
    end
  else
    Log.Error("Exception: NPCActorPool:OnClassLoad bNeedToExtend is nil")
  end
  local viewObj = self:CreateActorByClass(characterClass)
  if nil == viewObj then
    Log.Error("Failed to create class ", tostring(characterClass))
  end
  local npc = self.waitNPCCaller[resRequest]
  npc:OnViewObjGetFromPool(viewObj)
  self.waitNPCUrl[resRequest] = nil
  self.waitNPCCaller[resRequest] = nil
  self.waitNPCRequest[npc] = nil
  NRCResourceManager:UnLoadRes(resRequest)
end

function NPCActorPool:StopWaitClass(caller)
  local resRequest = self.waitNPCRequest[caller]
  if resRequest then
    self.waitNPCUrl[resRequest] = nil
    self.waitNPCCaller[resRequest] = nil
    self.waitNPCRequest[caller] = nil
    NRCResourceManager:UnLoadRes(resRequest)
  end
end

function NPCActorPool:Get(url, caller, block, priority)
  if priority and priority >= 255 then
    Log.Error("NPCActorPool:Get NPC should never large or equal to 255", url)
  end
  if not self.pool[url] then
    self.pool[url] = {}
  end
  if not self.totalUse[url] then
    self.totalUse[url] = 0
  end
  self.totalUse[url] = self.totalUse[url] + 1
  local totalUse = self.totalUse[url]
  local urlPool = self.pool[url]
  local num = #urlPool
  if num > 0 and not SceneUtils.debugCloseNPCPool then
    local object = UnBoxPoolCacheEntry(table.remove(urlPool, num))
    if not UE4.UObject.IsValid(object) then
      Log.Error("\228\187\142\230\177\160\229\134\133\230\139\191\229\135\186\231\154\132\229\175\185\232\177\161\229\183\178\231\187\143\232\162\171\233\148\128\230\175\129\228\186\134", url)
      return nil
    end
    object:SetActorEnableCollision(true)
    caller:OnViewObjGetFromPool(object)
  elseif block or not self.asyncLoad then
    local characterClass = UE4.UClass.Load(url)
    if nil == characterClass then
      Log.Error("NPCActorPool:Get: Class\229\138\160\232\189\189\229\164\177\232\180\165\239\188\140\232\175\183\230\163\128\230\159\165\232\181\132\230\186\144\233\133\141\231\189\174 ", url)
      return nil
    end
    if not self.bNeedToExtend[url] then
      table.insert(self.needToExtend, url)
      self.bNeedToExtend[url] = true
    end
    local viewObj = self:CreateActorByClass(characterClass)
    if not viewObj then
      Log.Error("Class\229\138\160\232\189\189\230\136\144\229\138\159\228\189\134\229\136\155\229\187\186Actor\229\164\177\232\180\165 ", url)
    end
    caller:OnViewObjGetFromPool(viewObj)
  else
    local request = NRCResourceManager:LoadResAsync(self, url, priority or -1, -1, self.PreOnClassLoad, self.OnLoadFailed)
    self.waitNPCCaller[request] = caller
    self.waitNPCUrl[request] = url
    self.waitNPCRequest[caller] = request
  end
end

function NPCActorPool:OnLoadFailed(resRequest, errMsg)
  Log.Error("NPCActorPool:Get: Class\229\138\160\232\189\189\229\164\177\232\180\165\239\188\140\232\175\183\230\163\128\230\159\165\232\181\132\230\186\144\233\133\141\231\189\174 ", resRequest.assetPath, errMsg)
end

local TempSweepResult = UE.FHitResult()
local FarAwayPos = UE4.FVector(-1000, -1000, -1000)

function NPCActorPool:Recycle(url, viewObj)
  if not UE4.UObject.IsValid(viewObj) then
    Log.Error("\229\173\152\229\133\165\230\177\160\229\134\133\231\154\132\229\175\185\232\177\161\229\183\178\231\187\143\232\162\171\233\148\128\230\175\129", url)
    return
  end
  viewObj:Abs_K2_SetActorLocation(FarAwayPos, false, TempSweepResult, false)
  if viewObj.ForceHidden then
    viewObj:ForceHidden()
  end
  if viewObj.Recycle then
    viewObj:Recycle()
  end
  if string.IsNilOrEmpty(url) then
    NRCResourceManager:UnLoadResByCaller(viewObj)
    viewObj:K2_DestroyActor()
    return
  end
  if not self.pool[url] then
    self.pool[url] = {}
  end
  table.insert(self.pool[url], BoxPoolCacheEntry(viewObj))
  if not self.totalUse[url] then
    self.totalUse[url] = 1
  end
  self.totalUse[url] = self.totalUse[url] - 1
  if (SceneUtils.debugCloseNPCPool or self.totalUse[url] < #self.pool[url] / 3) and not self.needToBurn[url] then
    self.needToBurn[url] = 0
  end
  viewObj:SetActorHiddenInGame(true)
end

function NPCActorPool:PreRecycle(url, viewObj)
  if viewObj and UE.UObject.IsValid(viewObj) then
    local Node = self.RecycleQueue:Push()
    Node.url = url
    Node.viewObj = viewObj
    Node.viewObjRef = UnLua.Ref(viewObj)
    UE4.UNRCStatics.SetActorOwner(viewObj, nil)
    viewObj:SetActorHiddenInGame(true)
  end
end

return NPCActorPool
