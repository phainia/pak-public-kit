require("UnLuaEx")
local Delegate = require("Utils.Delegate")
local BP_BattleEQSRunner_C = _G.NRCClass("BP_BattleEQSRunner_C")
local FailedResult = UE.FNRCQueryResult()

function BP_BattleEQSRunner_C:Initialize(Initializer)
  self.CompleteDelegate = {}
  self.QueryID = -1
end

function BP_BattleEQSRunner_C:StartQuery(Mode, Query, Querier, Owner, Callback)
  if Query then
    self.Query = Query
  end
  if self.Query then
    self.QueryID = self:RunQuery(Mode, Querier)
    if -1 == self.QueryID then
      if Callback then
        Callback(Owner, FailedResult)
      end
    else
      local Del = Delegate()
      Del:Add(Owner, Callback)
      self.CompleteDelegate[self.QueryID] = Del
    end
    return self.QueryID
  else
    self.QueryID = -1
    if Callback then
      Callback(Owner, FailedResult)
    end
    return -1
  end
end

function BP_BattleEQSRunner_C:QueryComplete(Result)
  local Del = self.CompleteDelegate[Result.QueryID]
  if Del then
    Del:Invoke(Result)
    Del:Clear()
    self.CompleteDelegate[Result.QueryID] = nil
    self:Release()
  end
end

return BP_BattleEQSRunner_C
