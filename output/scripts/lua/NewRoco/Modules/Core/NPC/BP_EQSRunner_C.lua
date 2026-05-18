require("UnLuaEx")
local Delegate = require("Utils.Delegate")
local BP_EQSRunner_C = _G.NRCClass("BP_EQSRunner_C")
local FailedResult = UE.FNRCQueryResult()

function BP_EQSRunner_C:Initialize(Initializer)
  self.CompleteDelegate = {}
end

function BP_EQSRunner_C:StartQuery(Mode, Query, Querier, Owner, Callback)
  if Query then
    self.Query = Query
  end
  if self.Query then
    local QueryID = self:RunQuery(Mode, Querier)
    if -1 == QueryID then
      if Callback then
        Callback(Owner, FailedResult)
      end
    else
      local Del = Delegate()
      Del:Add(Owner, Callback)
      self.CompleteDelegate[QueryID] = Del
    end
    return QueryID
  else
    if Callback then
      Callback(Owner, FailedResult)
    end
    return -1
  end
end

function BP_EQSRunner_C:QueryComplete(Result)
  local Del = self.CompleteDelegate[Result.QueryID]
  if Del then
    Del:Invoke(Result)
    Del:Clear()
    self.CompleteDelegate[Result.QueryID] = nil
  end
end

function BP_EQSRunner_C:MakeRequest(Query, Querier)
  return UE4.FEnvQueryRequest(Query or self.Query, Querier)
end

function BP_EQSRunner_C:StartQueryWithRequest(Mode, Request, Owner, Callback)
  local QueryID = self:RunQueryWithRequest(Mode, Request)
  if -1 == QueryID or nil == QueryID then
    if Callback then
      Callback(Owner, FailedResult)
    end
  else
    local Del = Delegate()
    Del:Add(Owner, Callback)
    self.CompleteDelegate[QueryID] = Del
  end
  return QueryID
end

function BP_EQSRunner_C:RemoveRequest(QueryID)
  self.CompleteDelegate[QueryID] = nil
end

return BP_EQSRunner_C
