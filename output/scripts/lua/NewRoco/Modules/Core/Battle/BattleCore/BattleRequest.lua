local Class = _G.MakeSimpleClass
local BattleRequest = Class("BattleRequest")
BattleRequest:SetMemberCount(16)

function BattleRequest:PreCtor()
  self.request = nil
  self.unloadType = _G.BattleResourceManager.UnloadType.END_GAME
  self.resType = _G.BattleResourceManager.ResourceType.OTHER
  self.cacheTime = -1
  self.failCallback = nil
  self.successCallback = nil
  self.caller = nil
  self.param = nil
  self.Lock = 0
  self.LockBattleRequest = nil
  if UE.UObject.IsValid(self.assert) then
    UnLua.Unref(self.assert)
  end
  self.assert = nil
  self.assetRef = nil
end

function BattleRequest:Ctor()
end

function BattleRequest:SetData(Request, UnloadType, resType, CacheTime, SuccessCallback, FailCallback, Caller)
  self.request = Request
  self.unloadType = UnloadType
  self.cacheTime = CacheTime
  self.successCallback = SuccessCallback
  self.failCallback = FailCallback
  self.caller = Caller
  self.resType = resType
end

function BattleRequest:SetSuccessParam(...)
  self.successParam = {
    ...
  }
end

function BattleRequest:SetActorParam(transform, param)
  if not self.param then
    self.param = {}
  end
  self.param.transform = transform
  self.param.param = param
end

function BattleRequest:SetWidgetParam(owningPlayer, containWidget)
  if not self.param then
    self.param = {}
  end
  self.param.own = owningPlayer
  self.param.containObj = containWidget
end

function BattleRequest:ResetData()
  self:PreCtor()
end

function BattleRequest:BurnTime(BurnTime)
  if self.cacheTime > 0 then
    self.cacheTime = self.cacheTime - BurnTime
    if self.cacheTime <= 0 then
      self:UnloadRequest()
    end
  end
end

function BattleRequest:UnloadRequest()
  if self.request and self.Lock <= 0 then
    self.assert = nil
    self.param = nil
    self.successParam = nil
    NRCResourceManager:UnLoadRes(self.request)
    self.request = nil
  end
end

return BattleRequest
