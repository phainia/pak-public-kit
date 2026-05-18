local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local a = require("Common.Coroutine.async")
local au = require("Common.Coroutine.async_util")
local Base = BattleActionBase
local FinalBattleOverPreloadResAction = Base:Extend("FinalBattleOverPreloadResAction")

function FinalBattleOverPreloadResAction:Ctor()
  Base.Ctor(self)
  self.preloadResList = {
    _G.BattleConst.FinalBattleOverSeq1
  }
  self:SetActionType(BattleActionBase.ActionType.ClientLoadResAction)
end

function FinalBattleOverPreloadResAction:OnEnter()
  NRCModeManager:DoCmd(BattleUIModuleCmd.HideMainWindow, false, false)
  NRCModeManager:DoCmd(BattleUIModuleCmd.CloseFinalBattleLifeBar)
  NRCModeManager:DoCmd(BattleUIModuleCmd.HideBattlePopupPanel)
  self.isBlackScreenOpen = false
  self.isSeqResLoaded = false
  self.preLoadAssetNumber = #self.preloadResList
  for i = 1, #self.preloadResList do
    _G.BattleResourceManager:LoadResAsync(self, self.preloadResList[i], self.PreloadAssetCallBack, self.PreloadAssetCallBack)
  end
  _G.BattleSkillManager:PreLoadSingleRes(BattleConst.EnemyDeadFinalBattleBlackScreen, true, self, self.OnLoadBlackScreenSkillComplete)
end

function FinalBattleOverPreloadResAction:PreloadAssetCallBack(Resource)
  if not Resource then
    Log.Error("cannot preload assert", #self.preloadResList - self.preLoadAssetNumber + 1)
  end
  if not Resource.GetDefaultObject then
    Log.Error("loaded assert is not a uclass resource", Resource)
  end
  Log.Info("preload", self.preLoadAssetNumber, Resource)
  self.preLoadAssetNumber = self.preLoadAssetNumber - 1
  if 0 == self.preLoadAssetNumber then
    self.isSeqResLoaded = true
    self:CheckFinish()
  end
end

function FinalBattleOverPreloadResAction:GetTimeoutValue()
  local timeoutValue = Base.GetTimeoutValue(self)
  timeoutValue = timeoutValue * 5
  return timeoutValue
end

local function PerformFinalBattleBlackScreen(self, blackScreenFadeInSkillClass)
  if not UE4.UObject.IsValid(blackScreenFadeInSkillClass) then
    return false, "BattlePetDiePlayer.PerformFinalBattleBlackScreen blackScreenFadeInSkillClass is not valid"
  end
  local blackScreenFadeInSkillClassRef = UnLua.Ref(blackScreenFadeInSkillClass)
  local beforeFadeInWaitTime = BattleConst.FinalBattleBossDieBeforeBlackScreenTimeSpan
  Log.Debug("BattlePetDiePlayer.PerformFinalBattleBlackScreen: \229\135\134\229\164\135\232\191\155\229\133\165\233\187\145\229\177\143")
  a.wait(au.DelaySeconds(beforeFadeInWaitTime))
  Log.Debug("BattlePetDiePlayer.PerformFinalBattleBlackScreen: \229\188\128\229\167\139\232\191\155\229\133\165\233\187\145\229\177\143")
  
  local function PlaySkillUntilFadeInAsync(callback)
    local skillComponent = _G.BattleManager.vBattleField.battleFieldActor.Skill
    if not skillComponent then
      Log.Error("BattlePetDiePlayer.PerformFinalBattleBlackScreen skillComponent is nil")
      callback()
      return
    end
    local skillObject = skillComponent:FindOrAddSkillObj(blackScreenFadeInSkillClass)
    skillObject.Blackboard:SetValueAsBool("End", true)
    skillObject:RegisterEventCallback("FadeIn", nil, callback)
    _G.BattleManager.battleRuntimeData.finalBattleInfo.bossDeadBlackScreenSkillObject = skillObject
    if UE4.UObject.IsValid(skillObject) then
      _G.BattleManager.battleRuntimeData.finalBattleInfo.bossDeadBlackScreenSkillObjectRef = UnLua.Ref(skillObject)
    else
      Log.Error("BattlePetDiePlayer.PerformFinalBattleBlackScreen skillObject is not valid")
      callback()
      return
    end
    skillComponent:PlaySkill(skillObject)
  end
  
  a.wait(a.wrap(PlaySkillUntilFadeInAsync)())
  blackScreenFadeInSkillClass = nil
  blackScreenFadeInSkillClassRef = nil
  Log.Debug("BattlePetDiePlayer.PerformFinalBattleBlackScreen: \232\191\155\229\133\165\233\187\145\229\177\143\229\174\140\230\136\144")
  local blackScreenWaitingTime = BattleConst.FinalBattleBossDieBlackScreenTimeSpan
  Log.Debug("BattlePetDiePlayer.PerformFinalBattleEnemyDie: \229\188\128\229\167\139\233\187\145\229\177\143\231\173\137\229\190\133")
  a.wait(au.DelaySeconds(blackScreenWaitingTime))
  Log.Debug("BattlePetDiePlayer.PerformFinalBattleEnemyDie: \233\187\145\229\177\143\231\173\137\229\190\133\229\174\140\230\136\144")
  au.WaitUntilTimeOut(au.WaitUntilCondition(function()
    return _G.BattleManager.battleRuntimeData.finalBattleInfo.isBossDead
  end), 30)
  _G.BattleManager.battleRuntimeData.finalBattleInfo.isBossDead = true
  return true
end

FinalBattleOverPreloadResAction.PerformFinalBattleBlackScreen = a.sync(PerformFinalBattleBlackScreen)

function FinalBattleOverPreloadResAction:OnLoadBlackScreenSkillComplete(isLoadSucceed, skillPath)
  local skillClass = _G.BattleSkillManager:GetLoadedClass(skillPath)
  self:PerformFinalBattleBlackScreen(skillClass)(function(ok, errorOrMessage)
    if not ok then
      Log.Error(errorOrMessage)
    end
    self.isBlackScreenOpen = true
    self:CheckFinish()
  end)
end

function FinalBattleOverPreloadResAction:CheckFinish()
  if self.isBlackScreenOpen and self.isSeqResLoaded then
    self:Finish()
  end
end

return FinalBattleOverPreloadResAction
