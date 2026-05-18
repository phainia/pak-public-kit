local FsmAction = require("NewRoco.Modules.Core.Fsm.FsmAction")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleFsmResListAsyncLoader = require("NewRoco.Modules.Core.Battle.BattleCore.Utils.BattleFsmResListAsyncLoader")
local BattleFsmSkillListAsyncLoader = require("NewRoco.Modules.Core.Battle.BattleCore.Utils.BattleFsmSkillListAsyncLoader")
local Base = BattleActionBase
local BattleClientBranchActionBase = Base:Extend("BattleClientBranchActionBase")
FsmUtils.MergeMembers(Base, BattleClientBranchActionBase, {})

function BattleClientBranchActionBase:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self:SetActionType(BattleActionBase.ActionType.ClientUnSkipableAction)
end

function BattleClientBranchActionBase:LoadResAsync(resPath, successCallback)
  local function localSuccessCallback(successCallbackCaller, resources)
    successCallback(self, resources[1])
  end
  
  self:BattleClientBranchActionBase({resPath}, localSuccessCallback)
end

function BattleClientBranchActionBase:LoadResListAsync(resPathList, successCallback)
  local function localSuccessCallback(successCallbackCaller, resources)
    successCallback(self, resources)
  end
  
  local function failedCallback(failedCallbackCaller)
  end
  
  local resLoader = BattleFsmResListAsyncLoader(self, resPathList, localSuccessCallback, failedCallback)
  resLoader:Run()
end

function BattleClientBranchActionBase:LoadSkillAsync(skillPath, loadCompletedCheckType, successCallback)
  local function localSuccessCallback(successCallbackCaller, resources)
    successCallback(self, resources[1])
  end
  
  self:LoadSkillListAsync({skillPath}, loadCompletedCheckType, localSuccessCallback)
end

function BattleClientBranchActionBase:LoadSkillListAsync(skillPathList, loadCompletedCheckType, successCallback)
  local function localSuccessCallback(successCallbackCaller, resources)
    successCallback(self, resources)
  end
  
  local function failedCallback(failedCallbackCaller)
  end
  
  local skillLoader = BattleFsmSkillListAsyncLoader(self, skillPathList, loadCompletedCheckType, false, localSuccessCallback, failedCallback)
  skillLoader:Run()
end

function BattleClientBranchActionBase:GetSkillClass(skillResPath)
  if _G.BattleSkillManager:IsResLoaded(skillResPath) then
    return _G.BattleSkillManager:GetLoadedClass(skillResPath)
  else
    Log.Error(string.format("BattleClientBranchActionBase:GetSkillClass skillResPath not loaded, skillResPath = %s", skillResPath))
    self:Finish()
  end
end

return BattleClientBranchActionBase
