local EQSQueryType = require("NewRoco.Modules.Core.NPC.EQSQueryType")
local ThrowUtils = require("NewRoco.Modules.Core.NPC.ThrowUtils")
local ResObjectBase = require("NewRoco.Utils.ResObjectBase")
local Base = ResObjectBase
local EQSResObject = Base:Extend("EQSResObject")

function EQSResObject.MakeSenseReleaseQuery(PetData)
  if not PetData then
    return nil
  end
  local Object = EQSResObject(EQSQueryType.SenseRelease, nil, PetData)
  return Object
end

function EQSResObject.MakeStandReleaseQuery(QueryType, PetData, ModelID, Querier, Inner, Outer)
  if not PetData then
    return nil
  end
  if not Querier then
    return nil
  end
  local Object = EQSResObject(QueryType, Querier, PetData, ModelID)
  Object.InnerRadius = Inner
  Object.OuterRadius = Outer
  return Object
end

function EQSResObject.MakeRawQuery(Runner, RunMode, Query, Querier)
  if not Runner then
    Log.Error("\232\175\183\230\143\144\228\190\155\228\184\128\228\184\170Runner")
    return
  end
  local Object = EQSResObject(EQSQueryType.Raw, Querier)
  Object.RunMode = RunMode or UE.EEnvQueryRunMode.SingleResult
  Object.Runner = Runner
  Object.Query = Query
  return Object
end

function EQSResObject.MakeBlessingQuery(Querier, playerId1, playerId2, petId)
  local Object = EQSResObject(EQSQueryType.PetBlessing, Querier, nil, {
    playerId1 = playerId1,
    playerId2 = playerId2,
    petId = petId
  })
  Object.RunMode = UE.EEnvQueryRunMode.SingleResult
  return Object
end

function EQSResObject:Ctor(QueryType, Querier, PetData, ModelID, Params)
  Base.Ctor(self)
  self.AbsoluteLocations = nil
  self.Locations = nil
  self.Rotations = nil
  self.InnerRadius = 300
  self.OuterRadius = 600
  self.QueryType = QueryType
  self.Querier = Querier
  self.PetData = PetData
  self.ModelID = ModelID
  self.RunMode = UE.EEnvQueryRunMode.SingleResult
  self.Runner = nil
  self.Query = nil
  self.Params = Params
end

function EQSResObject:DoLoad()
  local StandType
  if self.PetData then
    StandType = ThrowUtils:ToStandType(self.PetData)
  end
  local Querier = self.Querier
  if self.QueryType == EQSQueryType.SenseRelease then
    local Player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    Querier = Player and Player.viewObj
  end
  local QueryID = -1
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  if self.QueryType == EQSQueryType.SenseRelease then
    QueryID = NPCModule:FindSenseRelease(Querier, StandType, self, self.QueryResult)
  elseif self.QueryType == EQSQueryType.StandRelease then
    QueryID = NPCModule:FindStandRelease(Querier, StandType, self.InnerRadius, self.OuterRadius, self, self.QueryResult)
  elseif self.QueryType == EQSQueryType.FarRelease then
    QueryID = NPCModule:FindFarRelease(Querier, StandType, self.InnerRadius, self.OuterRadius, self, self.QueryResult)
  elseif self.QueryType == EQSQueryType.FanRelease then
    QueryID = NPCModule:FindFanFrontRelease(Querier, StandType, self.InnerRadius, self.OuterRadius, self, self.QueryResult)
  elseif self.QueryType == EQSQueryType.PetBlessing then
    StandType = 3
    QueryID = NPCModule:FindPetBlessingRelease(Querier, StandType, self.Params, self, self.QueryResult)
  elseif self.QueryType == EQSQueryType.Raw then
    QueryID = self.Runner:StartQuery(self.RunMode, self.Query, self.Querier, self, self.QueryResult)
  end
  if QueryID < 0 then
    self:FireCallback(false)
  end
end

function EQSResObject:QueryResult(Result)
  if not Result then
    self:FireCallback(false)
    return
  end
  if not Result.bFinished then
    return
  end
  if not Result.bSuccess then
    self:FireCallback(false)
    return
  end
  self.Result = Result
  self.AbsoluteLocations = self.Result.AbsoluteResultLocations:ToTable()
  if not self.AbsoluteLocations then
    Log.Error("what?! AbsoluteLocations is nil!")
  end
  self.Locations = self.Result.ResultLocations:ToTable()
  self.Rotations = self.Result.ResultRotations:ToTable()
  self:FireCallback(true)
end

function EQSResObject:DoGet()
  return self.Result
end

function EQSResObject:DoRelease()
  self.Result = nil
  self.Querier = nil
  self.PetData = nil
  self.AbsoluteLocations = nil
  self.Locations = nil
  self.Rotations = nil
end

return EQSResObject
