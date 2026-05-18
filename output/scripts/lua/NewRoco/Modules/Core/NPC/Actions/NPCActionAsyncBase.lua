local Base = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local a = require("Common.Coroutine.async")
local au = require("Common.Coroutine.async_util")
local NPCActionAsyncBase = Base:Extend("NPCActionAsyncBase")
local FailedType = {
  None = 0,
  LoadFailed = 1,
  NoRespond = 2,
  RespondFailed = 3,
  Timeout = 4,
  AsyncError = 5
}
NPCActionAsyncBase.FailedType = FailedType

function NPCActionAsyncBase:PreCtor()
  Base.PreCtor(self)
  self.StartPerformAsyncRunning = nil
  self.SubmitPromise = nil
  self.ResRequests = nil
  self.AsyncTaskContext = nil
end

function NPCActionAsyncBase:Destroy()
  self:ClearAsyncBinds()
  Base.Destroy(self)
end

function NPCActionAsyncBase:Execute(playerId, needSendReq)
  Base.Execute(self, playerId, needSendReq)
  self:BeforeStartPerform()
  self:StartPerformAsync()
end

function NPCActionAsyncBase:BeforeStartPerform()
end

function NPCActionAsyncBase:CheckOnSubmit(Rsp)
  Base.CheckOnSubmit(self, Rsp)
  if self.SubmitPromise then
    self.SubmitPromise.resolve(Rsp)
  end
end

function NPCActionAsyncBase:IsNotServerFailed(Reason)
  return Reason ~= FailedType.NoRespond and Reason ~= FailedType.RespondFailed
end

function NPCActionAsyncBase:GetPerformResourceList()
  return nil
end

function NPCActionAsyncBase:ClearAsyncBinds()
  if self.AsyncTaskContext then
    a.kill(self.AsyncTaskContext)
    self.AsyncTaskContext = nil
  end
  if self.ResRequests then
    for _, Req in ipairs(self.ResRequests) do
      _G.NRCResourceManager:UnLoadRes(Req)
    end
    self.ResRequests = nil
  end
  self.StartPerformAsyncRunning = false
  self.SubmitPromise = nil
end

function NPCActionAsyncBase:OnPerformReady(LoadedAssets, Rsp)
end

function NPCActionAsyncBase:FinishAsync(Reason, Msg)
  if Reason and Reason ~= FailedType.None then
    if Reason == FailedType.Timeout and self:HasSubmit() and not self.SubmitPromise.result() then
      Reason = FailedType.NoRespond
    end
    self:LogError("PreparePerformFailed", table.getKeyName(FailedType, Reason), Msg)
    self:OnPerformFailed(Reason)
  end
  self:ClearAsyncBinds()
end

function NPCActionAsyncBase:OnPerformFailed(Reason)
end

function NPCActionAsyncBase:MakeResourceLoadFuture(Path)
  if not Path or "" == Path then
    return function(cb)
      cb(true)
    end
  end
  local Req = _G.NRCResourceManager:LoadResAsync(self, Path, _G.PriorityEnum.Active_Player_Action, 0)
  if not self.ResRequests then
    self.ResRequests = _G.MakeWeakTable()
  end
  table.insert(self.ResRequests, Req)
  return au.ResRequestCallback(Req)
end

function NPCActionAsyncBase:StartPerformAsync()
  if self.StartPerformAsyncRunning then
    return
  end
  local ResList = self:GetPerformResourceList()
  local HasRes = ResList and next(ResList) ~= nil
  local HasSubmit = self:HasSubmit()
  if not HasRes and not HasSubmit then
    self:OnPerformReady(nil, nil)
    return
  end
  self.StartPerformAsyncRunning = true
  if HasSubmit then
    self.SubmitPromise = au.CreatePromise()
  end
  local Task = a.task(function()
    local Thunks = {}
    if HasRes then
      for Name, Path in pairs(ResList) do
        Thunks[Name] = self:MakeResourceLoadFuture(Path)
      end
    end
    if HasSubmit then
      Thunks.Submit = self.SubmitPromise.future
    end
    local Results = a.wait_all(Thunks, true)
    local LoadedAssets
    if HasRes then
      local Ok, Msg
      LoadedAssets, Ok, Msg = self:CollectLoadedAssets(Results, ResList)
      if not Ok then
        return FailedType.LoadFailed, Msg
      end
    end
    local Rsp
    if HasSubmit then
      local SubmitRet = Results.Submit
      if not SubmitRet then
        return FailedType.NoRespond
      end
      Rsp = SubmitRet[2]
      if not (SubmitRet[1] and Rsp and Rsp.ret_info) or 0 ~= Rsp.ret_info.ret_code then
        return FailedType.RespondFailed
      end
    end
    self:OnPerformReady(LoadedAssets, Rsp)
  end)
  self.AsyncTaskContext = au.LaunchWithTimeout(Task, 5, function(NoUncheckedError, ResultType, Msg)
    if NoUncheckedError then
      self:FinishAsync(ResultType or FailedType.None, Msg)
    else
      self:FinishAsync(FailedType.Timeout)
      self:LogError(ResultType)
    end
  end)
end

function NPCActionAsyncBase:HasSubmit()
  return not self.SkipSubmit and self.needSendReq
end

function NPCActionAsyncBase:CollectLoadedAssets(Results, ResList)
  if not ResList then
    return nil, false
  end
  local LoadedAssets = {}
  for Name, Path in pairs(ResList) do
    local LoadRet = Results[Name]
    if not LoadRet then
      return nil, false, Name
    end
    local Ok = LoadRet[1]
    local Asset = LoadRet[3]
    if not Ok then
      return nil, false, Path
    end
    LoadedAssets[Name] = Asset
  end
  return LoadedAssets, true
end

return NPCActionAsyncBase
