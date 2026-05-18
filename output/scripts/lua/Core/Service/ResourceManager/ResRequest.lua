local Class = _G.MakeSimpleClass
local ResRequest = Class("ResRequest")
ResRequest:SetMemberCount(10)

function ResRequest:PreCtor()
  self.sessionId = -1
  self.caller = nil
  self.assetPath = nil
  self.priority = -1
  self.cacheTime = -1
  self.loadSuccessCallback = nil
  self.loadFailedCallback = nil
  self.loadProgressCallback = nil
  self.unLoadCallback = nil
end

function ResRequest:Ctor()
end

function ResRequest:__Dctor()
  if not self:IsEmpty() then
    NRCResourceManager:UnLoadRes(self)
  end
end

function ResRequest:IsEmpty()
  if -1 ~= self.sessionId then
    return false
  end
  return true
end

function ResRequest:SetData(sessionId, caller, assetPath, priority, cacheTime, loadSuccessCallback, loadFailedCallback, loadProgressCallback, unLoadCallback)
  self.sessionId = sessionId
  self.caller = caller
  self.assetPath = assetPath
  self.priority = priority
  self.cacheTime = cacheTime
  self.loadSuccessCallback = loadSuccessCallback
  self.loadFailedCallback = loadFailedCallback
  self.loadProgressCallback = loadProgressCallback
  self.unLoadCallback = unLoadCallback
end

function ResRequest:Reset()
  self.sessionId = -1
  self.caller = nil
  self.priority = -1
  self.cacheTime = -1
  self.loadSuccessCallback = nil
  self.loadFailedCallback = nil
  self.loadProgressCallback = nil
  self.unLoadCallback = nil
end

return ResRequest
