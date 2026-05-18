local BattlePlayAnimBaseAction = require("NewRoco.Modules.Core.Battle.Fsm.Actions.Base.BattlePlayAnimBaseAction")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local Base = BattlePlayAnimBaseAction
local BattleGetPosIn1VNAction = Base:Extend("BattleGetPosIn1VNAction")
FsmUtils.MergeMembers(Base, BattleGetPosIn1VNAction, {})
BattleGetPosIn1VNAction.SearchIndex = {
  11,
  12,
  21,
  22
}
BattleGetPosIn1VNAction.SearchConfig = {
  [11] = {
    InsideA = 1050,
    InsideB = 700,
    OutSideA = 1150,
    OutSideB = 800,
    StartAngle = 70,
    EndAngle = 95,
    StartAngleThree = 55,
    EndAngleThree = 75
  },
  [12] = {
    InsideA = 1050,
    InsideB = 700,
    OutSideA = 1150,
    OutSideB = 800,
    StartAngle = 45,
    EndAngle = 65,
    StartAngleThree = 35,
    EndAngleThree = 50
  },
  [21] = {
    InsideA = 950,
    InsideB = 600,
    OutSideA = 1050,
    OutSideB = 700,
    StartAngle = 20,
    EndAngle = 40,
    StartAngleThree = -10,
    EndAngleThree = 5
  },
  [22] = {
    InsideA = 950,
    InsideB = 600,
    OutSideA = 1050,
    OutSideB = 700,
    StartAngle = -10,
    EndAngle = 15,
    StartAngleThree = -30,
    EndAngleThree = -15
  }
}

function BattleGetPosIn1VNAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleGetPosIn1VNAction:OnEnter()
  if BattleUtils.IsCrowdBattle() then
    if _G.BattleManager.battleRuntimeData.enemyPetNumber > 2 then
      self.WaitFrame = 0
      self.IsGenerate = false
      self.NeedReCompute = true
      self.CanCheckStart = true
      self.CurrentIndex = 1
    else
      self:Finish()
    end
  else
    self:Finish()
  end
end

function BattleGetPosIn1VNAction:CheckCanStart()
  if not self.CanCheckStart then
    return
  end
  if not BattleResourceManager:GetCacheAssetDirect(BattleConst.BP_BattleEQSRunner_C) then
    return
  end
  if not BattleResourceManager:GetCacheAssetDirect(BattleConst.BattleSearchElliptic) then
    return
  end
  self.CanCheckStart = false
  self:StartSearch()
end

function BattleGetPosIn1VNAction:OnTick(DeltaTime)
  self:CheckCanStart()
end

function BattleGetPosIn1VNAction:DelayComplete()
  self.NeedReCompute = false
  self:GenerateFinish()
end

function BattleGetPosIn1VNAction:GenerateFinish()
  if not self.IsGenerate then
    self.IsGenerate = true
    self:SafeDelayFrames("d_CheckNavMeshLoad", 1, self.CheckNavMeshLoad, self)
  end
end

function BattleGetPosIn1VNAction:CheckNavMeshLoad()
  if not UE.UNRCStatics.IsNavMeshReady() then
    self.WaitFrame = self.WaitFrame + 1
    if self.WaitFrame < 3 then
      self:SafeDelayFrames("d_CheckNavMeshLoad", 1, self.CheckNavMeshLoad, self)
      return
    end
  end
  self:SafeDelayFrames("d_StartSearch", 1, self.StartSearch, self)
end

function BattleGetPosIn1VNAction:ChangeLocalPlayerPos()
  local localPlayer = _G.NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  _G.BattleManager.WorldPlayerInitPos = localPlayer.viewObj:Abs_K2_GetActorLocation()
  self.BattleCenter = _G.BattleManager.vBattleField:GetBattleFieldCenter()
  localPlayer.viewObj:SetActorTickEnabled(false)
  localPlayer:SetActorLocation(self.BattleCenter)
end

function BattleGetPosIn1VNAction:StartSearch()
  Log.Debug("BattleGetPosIn1VNAction:StartSearch")
  if self.CurrentIndex <= #self.SearchIndex then
    local Config = self.SearchConfig[self.SearchIndex[self.CurrentIndex]]
    if BattleUtils.Is1VN() then
      local querySuccess, queryId, runner = BattleAIManager:SearchEllipticPosWithCallBack(_G.BattleManager.vBattleField.battleFieldActor, self, self.OnEllipticSearchCompleteCallback, Config.InsideA, Config.InsideB, Config.OutSideA, Config.OutSideB, Config.StartAngle, Config.EndAngle)
      if not querySuccess then
        self:OnEllipticSearchCompleteCallback()
      else
        self.CurrentQueryId = queryId
        self.Runner = runner
        self:SafeDelaySeconds("d_CheckSearchComplete", 3, self.CheckSearchComplete, self)
      end
    else
      local querySuccess, queryId, runner = BattleAIManager:SearchEllipticPosWithCallBack(_G.BattleManager.vBattleField.battleFieldActor, self, self.OnEllipticSearchCompleteCallback, Config.InsideA, Config.InsideB, Config.OutSideA, Config.OutSideB, Config.StartAngleThree, Config.EndAngleThree)
      if not querySuccess then
        self:OnEllipticSearchCompleteCallback()
      else
        self.CurrentQueryId = queryId
        self.Runner = runner
        self:SafeDelaySeconds("d_CheckSearchComplete", 3, self.CheckSearchComplete, self)
      end
    end
  else
    self:Finish()
  end
end

function BattleGetPosIn1VNAction:CheckSearchComplete()
  Log.Debug("BattleGetPosIn1VNAction:CheckSearchComplete")
  if not self.CurrentQueryId or self.CurrentQueryId <= 0 or not self.Runner then
    Log.Debug("BattleGetPosIn1VNAction:CheckSearchComplete return")
    return
  end
  local runner = self.Runner
  local queryId = self.CurrentQueryId
  self:ClearCheckSearchComplete()
  if runner and UE4.UObject.IsValid(runner) and not runner:AbortQuery(queryId) then
    Log.Debug("BattleGetPosIn1VNAction:CheckSearchComplete handled")
    self:OnEllipticSearchCompleteCallback()
    return
  end
  self:OnEllipticSearchCompleteCallback()
  Log.Debug("BattleGetPosIn1VNAction:CheckSearchComplete unhandled!!!")
end

function BattleGetPosIn1VNAction:ClearCheckSearchComplete()
  self.CurrentQueryId = nil
  self:SafeCancelDelayById("d_CheckSearchComplete")
end

function BattleGetPosIn1VNAction:OnEllipticSearchCompleteCallback(QueryResult)
  if not self.active then
    Log.Debug("BattleGetPosIn1VNAction:OnEllipticSearchCompleteCallback return-1")
    return
  end
  if not BattleManager:IsInBattle(true) then
    Log.Debug("BattleGetPosIn1VNAction:OnEllipticSearchCompleteCallback return-2")
    return
  end
  if QueryResult and QueryResult.QueryID == self.CurrentQueryId then
    Log.Debug("BattleGetPosIn1VNAction:OnEllipticSearchCompleteCallback cancel delay")
    self:ClearCheckSearchComplete()
  end
  local configIndex = self.SearchIndex[self.CurrentIndex]
  _G.BattleManager.vBattleField.ReplacePetPos[configIndex] = {}
  local resultNumber = QueryResult and QueryResult.AbsoluteResultLocations:Length() or 0
  if resultNumber <= 0 then
    if self.NeedReCompute then
      self.NeedReCompute = false
      self:SafeDelaySeconds("d_CheckNavMeshLoad", 1, self.CheckNavMeshLoad, self)
      Log.Debug("BattleGetPosIn1VNAction:OnEllipticSearchCompleteCallback return-3")
      return
    end
    Log.Error("zgx 1VN\230\159\165\232\175\162\231\187\147\230\158\156\229\164\177\232\180\165\239\188\129\239\188\129\239\188\129  \228\189\191\231\148\168\233\187\152\232\174\164\230\149\176\230\141\174 ", self.CurrentIndex)
    local startPos = _G.BattleManager.vBattleField:GetBattleFieldCenter()
    local configPos = _G.BattleManager.vBattleField:GetCheerPetPosByIndex(self.CurrentIndex) or startPos
    local final = BattleUtils.GetNavInvalidPos(configPos, startPos)
    table.insert(_G.BattleManager.vBattleField.ReplacePetPos[configIndex], final)
  else
    for i = 1, resultNumber do
      local point = QueryResult.AbsoluteResultLocations:Get(i)
      table.insert(_G.BattleManager.vBattleField.ReplacePetPos[configIndex], point)
    end
  end
  self.CurrentIndex = self.CurrentIndex + 1
  self:StartSearch()
  Log.Debug("BattleGetPosIn1VNAction:OnEllipticSearchCompleteCallback completed!")
end

return BattleGetPosIn1VNAction
