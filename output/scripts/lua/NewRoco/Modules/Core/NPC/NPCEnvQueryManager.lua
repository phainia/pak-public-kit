local Class = _G.MakeSimpleClass
local NPCEnvQueryManager = Class("NPCEnvQueryManager")

function NPCEnvQueryManager:Ctor()
  self.Runners = {}
  self.Runners_Ref = {}
end

function NPCEnvQueryManager:Get(Name)
  local Runner = self.Runners[Name]
  if not self:CheckEQSRunner(Runner) then
    Runner = self:CreateEQSRunner(Name)
    if not Runner or not UE.UObject.IsValid(Runner) then
      Log.Error("can't create EQSRunner", Name)
      return
    end
    self.Runners[Name] = Runner
    self.Runners_Ref[Name] = UnLua.Ref(Runner)
  end
  return Runner
end

function NPCEnvQueryManager:CreateEQSRunner(Name)
  local World = _G.UE4Helper.GetCurrentWorld()
  local Runner = NewObject(_G.NRCBigWorldPreloader:Get("EQS_Runner"), World)
  if Runner then
    Runner.Query = _G.NRCBigWorldPreloader:Get(string.format("EQS_%s", Name))
  end
  return Runner
end

function NPCEnvQueryManager:CheckEQSRunner(Runner)
  if not Runner then
    return false
  end
  if not UE4.UObject.IsValid(Runner) then
    return false
  end
  local Outer = UE4.UObject.GetOuter(Runner)
  if not Outer then
    return false
  end
  if not UE4.UObject.IsValid(Outer) then
    return false
  end
  return true
end

function NPCEnvQueryManager:Run(Name, Mode, Query, Querier, CallbackOwner, Callback)
  local Runner = self:Get(Name)
  if not Runner then
    Log.Error("Can't find eqs with name", Name)
    return -1
  end
  return Runner:StartQuery(Mode, Query, Querier, CallbackOwner, Callback)
end

function NPCEnvQueryManager:RunWithRequest(Name, Mode, Request, CallbackOwner, Callback)
  local Runner = self:Get(Name)
  if not Runner then
    Log.Error("Can't find eqs with name", Name)
    return -1
  end
  return Runner:StartQueryWithRequest(Mode, Request, CallbackOwner, Callback)
end

function NPCEnvQueryManager:ReleaseAll()
  for _, Runner in pairs(self.Runners) do
    UE4.UObject.Release(Runner)
  end
  table.clear(self.Runners)
  table.clear(self.Runners_Ref)
end

return NPCEnvQueryManager
