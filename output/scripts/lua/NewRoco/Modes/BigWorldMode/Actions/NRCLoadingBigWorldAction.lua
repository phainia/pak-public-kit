local NRCModeAction = require("Core.NRCMode.NRCModeAction")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local NRCLoadingBigWorldAction = NRCModeAction:Extend("NRCLoadingBigWorldAction")

function NRCLoadingBigWorldAction:Ctor(name, properties)
  NRCModeAction.Ctor(self, name, properties)
end

function NRCLoadingBigWorldAction:OnEnter()
  Log.Debug("NRCLoadingBigWorldAction:OnEnter")
  NRCModuleManager:DoCmd(LoadingUIModuleCmd.OpenLoadingUI, LuaText.Loading, 0.3)
  self.BigWorldDelayTimer = _G.TimerManager:CreateTimer(self, "BigWorldDelayTimer", 0.1, nil, self.OnTimerComplete, 9999)
end

function NRCLoadingBigWorldAction:OnTimerComplete()
  Log.Debug("NRCLoadingBigWorldAction:OnTimerComplete")
  self:DoCmdAsyncToFinish(SceneModuleCmd.EnterScene, self.OnLoadMapCallback)
  self:ActiveModule("PlayerModule")
  if not _G.CloseNotNecessaryModule then
    self:ActiveModule("InputModule")
    self:ActiveModule("EnvSystemModule")
    self:ActiveModule("AreaAndZoneModule")
    self:ActiveModule("MarkerModule")
    self:ActiveModule("WorldCombatModule")
    self:ActiveModule("NPCModule")
    self:ActiveModule("TaskModule")
    self:ActiveModule("TipsModule")
    self:ActiveModule("StoryFlagModule")
    self:ActiveModule("MissileModule")
    self:ActiveModule("CollisionModule")
    self:ActiveModule("AirWallModule")
    self:ActiveModule("DialogueModule")
    self:ActiveModule("RealtimeDialogModule")
    self:ActiveModule("HomeModule")
    self:ActiveModule("FarmModule")
    self:ActiveModule("IOSRatingModule")
    self:ActiveModule("GuidanceModule")
    self:ActiveModule("HeadIconModule")
  end
end

function NRCLoadingBigWorldAction:OnLoadMapCallback(isLoadSucc)
  Log.Debug("NRCLoadingBigWorldAction:OnLoadMapCallback", isLoadSucc)
  if _G.GlobalConfig.BigWorldModuleTest or _G.GlobalConfig.DisablePreLoadAsset then
    NRCModuleManager:DoCmd(LoadingUIModuleCmd.CloseLoadingUI, 0.5)
  end
  if isLoadSucc then
    NRCEventCenter:RegisterEvent("NRCLoadingBigWorldAction", self, SceneEvent.PlayerTeleportFinish, self.PlayerTeleportFinish)
  else
    Log.Error("NRCLoadingBigWorldAction:OnLoadMapCallback fail")
    NRCModeManager:ActiveMode("LoginMode")
    self:Finish()
  end
end

function NRCLoadingBigWorldAction:PlayerTeleportFinish()
  NRCEventCenter:UnRegisterEvent(self, SceneEvent.PlayerTeleportFinish, self.PlayerTeleportFinish)
  NRCModuleManager:DoCmd(LoadingUIModuleCmd.OpenLoadingUI, LuaText.Loading, 0.6)
  self:Finish()
end

function NRCLoadingBigWorldAction:DialogCallback(result)
  if result then
  else
    NRCModeManager:ActiveMode("LoginMode")
    self:Finish()
  end
end

function NRCLoadingBigWorldAction:OnExit()
end

return NRCLoadingBigWorldAction
