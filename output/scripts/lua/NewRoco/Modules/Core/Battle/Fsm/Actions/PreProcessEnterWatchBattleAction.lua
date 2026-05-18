local FsmAction = require("NewRoco.Modules.Core.Fsm.FsmAction")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local SystemSettingModuleEvent = require("NewRoco.Modules.System.SystemSetting.SystemSettingModuleEvent")
local a = require("Common.Coroutine.async")
local au = require("Common.Coroutine.async_util")
local Base = BattleActionBase
local PreProcessEnterWatchBattleAction = Base:Extend("PreProcessEnterWatchBattleAction")
FsmUtils.MergeMembers(Base, PreProcessEnterWatchBattleAction, {})

function PreProcessEnterWatchBattleAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self:SetActionType(BattleActionBase.ActionType.ClientSkipableAction)
end

function PreProcessEnterWatchBattleAction:OnEnter()
  local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
  if not BattleUtils.IsWatchingBattle() then
    Log.Debug("\229\189\147\229\137\141\228\184\141\230\152\175\229\165\189\229\143\139\232\167\130\230\136\152\230\168\161\229\188\143\239\188\140\229\183\178\232\183\179\232\191\135 Action")
    self:Finish()
    return
  end
  _G.NRCModuleManager:DoCmd(_G.SystemSettingModuleCmd.ReqQueryPlayerSettings)
  _G.NRCEventCenter:RegisterEvent("UMG_PVP_ValueNumber_C", self, SystemSettingModuleEvent.PlayerSettingUpdate, self.HandlePlayerSettingUpdate)
  self:LaunchAsyncTaskAndFinish()
end

function PreProcessEnterWatchBattleAction:OnFinish()
  _G.NRCEventCenter:UnRegisterEvent(self, SystemSettingModuleEvent.PlayerSettingUpdate, self.HandlePlayerSettingUpdate)
end

function PreProcessEnterWatchBattleAction:AsyncTask()
  au.WaitUntilTimeOut(PreProcessEnterWatchBattleAction.ReqQueryPlayerSettings(self), 3)
  self.playerSettingUpdateCallback = nil
end

local function ReqQueryPlayerSettings(self, callback)
  self.playerSettingUpdateCallback = callback
  _G.NRCModuleManager:DoCmd(_G.SystemSettingModuleCmd.ReqQueryPlayerSettings)
end

PreProcessEnterWatchBattleAction.ReqQueryPlayerSettings = a.wrap(ReqQueryPlayerSettings)

function PreProcessEnterWatchBattleAction:OnExit()
end

function PreProcessEnterWatchBattleAction:HandlePlayerSettingUpdate()
  if self.playerSettingUpdateCallback then
    self.playerSettingUpdateCallback()
  end
end

return PreProcessEnterWatchBattleAction
