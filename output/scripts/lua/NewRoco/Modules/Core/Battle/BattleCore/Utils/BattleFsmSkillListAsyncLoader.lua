local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleFsmSkillListAsyncLoader = _G.NRCClass()
BattleFsmSkillListAsyncLoader.LoadCompletedCheckType = {
  OnSkillResLoaded = BattleEvent.OnSkillResLoaded,
  OnAllSkillResLoaded = BattleEvent.OnAllSkillResLoaded
}

function BattleFsmSkillListAsyncLoader:Ctor(caller, resPathList, loadCompletedCheckType, needResourcesInCallback, successCallback, failedCallback)
  self.caller = caller
  self.resPathList = resPathList
  self.totalResCount = #self.resPathList
  self.loadedResCount = 0
  self.loadedResList = {}
  self.successCallback = successCallback
  self.failedCallback = failedCallback
  self.loadCompletedCheckType = loadCompletedCheckType
  self.needResourcesInCallback = needResourcesInCallback
end

function BattleFsmSkillListAsyncLoader:Run()
  _G.BattleEventCenter:Bind(self, BattleEvent.OnSkillResLoaded, BattleEvent.OnAllSkillResLoaded)
  _G.BattleSkillManager:PreLoadRes(self.resPathList)
end

function BattleFsmSkillListAsyncLoader:OnBattleEvent(event, value)
  if self.loadCompletedCheckType == BattleFsmSkillListAsyncLoader.LoadCompletedCheckType.OnSkillResLoaded and event == BattleEvent.OnSkillResLoaded then
    Log.Debug("BattleSkillListAsyncLoader:OnBattleEvent:", event, value)
    for i, resPath in ipairs(self.resPathList) do
      if value == resPath then
        self.loadedResCount = self.loadedResCount + 1
      end
    end
    if self.loadedResCount == self.totalResCount then
      self:OnLoadSuccess()
    end
  end
  if self.loadCompletedCheckType == BattleFsmSkillListAsyncLoader.LoadCompletedCheckType.OnAllSkillResLoaded and event == BattleEvent.OnAllSkillResLoaded then
    self:OnLoadSuccess()
  end
end

function BattleFsmSkillListAsyncLoader:OnLoadSuccess()
  _G.BattleEventCenter:UnBind(self)
  if self.needResourcesInCallback then
    self.successCallback(self.caller)
  else
    self.successCallback(self.caller)
  end
end

return BattleFsmSkillListAsyncLoader
