local Class = _G.MakeSimpleClass
local JsonUtils = require("Common.JsonUtils")
local PerfCatCmd = require("Profiler.PerfCat.PerfCatCmd")
local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local DelayTaskQueue = require("Profiler.Utils.DelayTaskQueue")
local AutomationDefines = require("Profiler.PerfCat.Base.AutomationDefines")
local BaseAutomation = Class("BaseAutomation")

function BaseAutomation:Init(callback, config)
  self:SetupConfig(config)
  if self.automation_status and self.automation_status ~= AutomationDefines.AutomationStatus.NOT_STARTED then
    return
  end
  self.task_queue = DelayTaskQueue()
  self.automation_status = AutomationDefines.AutomationStatus.NOT_STARTED
  self.callback_on_finished = callback
  self.map_loaded_event = SceneEvent.BigWorldPrepared
  self.local_modules = {}
  self.is_started = false
  self.is_finished = false
end

function BaseAutomation:SetupConfig(config)
  if nil ~= config then
    self.config = config
  else
    self.config = self:LoadConfig()
  end
  if nil ~= self.config.image_quality then
    self:SetImageQuality(string.lower(self.config.image_quality))
  end
  if self.config.vfx_quality then
    self:SetEffectQuality(string.lower(self.config.vfx_quality))
  end
end

function BaseAutomation:RegisterAutomator(automator)
  if automator then
    self.automator = automator
  else
    self.automator = self
  end
end

function BaseAutomation:SetTickable(is_tickable)
  if is_tickable then
    self.automator = self
    self:StartAutomator()
  elseif self.automator then
    self.StopAutomator()
    self.automator = nil
  end
end

function BaseAutomation:InitializeAutomation()
end

function BaseAutomation:OnTick(DeltaTime)
end

function BaseAutomation:StartAutomator()
  if self.automator then
    _G.UpdateManager:Register(self.automator)
  end
end

function BaseAutomation:StopAutomator()
  if self.automator then
    _G.UpdateManager:UnRegister(self.automator)
  end
end

function BaseAutomation:ProcessTaskQueue()
  self.task_queue:ProcessTaskQueue()
end

function BaseAutomation:AddTask(DelayInSeconds, TaskFunction, ...)
  self.task_queue:Add(DelayInSeconds, self, TaskFunction, ...)
end

function BaseAutomation:SetEffectQuality(vfxQuality)
  if "high" == vfxQuality then
    UE4.USkillBlueprintLibrary.SetEffectsQuality(UE4.ESkillEffectsQuality.High)
  elseif "medium" == vfxQuality then
    UE4.USkillBlueprintLibrary.SetEffectsQuality(UE4.ESkillEffectsQuality.Medium)
  elseif "low" == vfxQuality then
    UE4.USkillBlueprintLibrary.SetEffectsQuality(UE4.ESkillEffectsQuality.Low)
  end
end

function BaseAutomation:SetImageQuality(imageQuality)
  if "epic" == imageQuality then
    UE4.UNRCQualityLibrary.SetImageQuality(UE4.ENRCImageQuality.Epic)
  elseif "high" == imageQuality then
    UE4.UNRCQualityLibrary.SetImageQuality(UE4.ENRCImageQuality.High)
  elseif "medium" == imageQuality then
    UE4.UNRCQualityLibrary.SetImageQuality(UE4.ENRCImageQuality.Medium)
  elseif "low" == imageQuality then
    UE4.UNRCQualityLibrary.SetImageQuality(UE4.ENRCImageQuality.Low)
  end
end

function BaseAutomation:LoadConfig()
  local load_config = JsonUtils.LoadSaved(self:GetConfigName() or "")
  if not load_config then
    Log.Error("Failed to load config file")
    load_config = self:LoadDefaultConfig()
    return load_config
  end
  return load_config
end

function BaseAutomation:LoadDefaultConfig()
  return {
    is_local_mode = true,
    vfx_quality = "high",
    overdraw_mode = false,
    hide_hud = true
  }
end

function BaseAutomation:GetConfigName()
  local mt = getmetatable(self)
  Log.ErrorFormat("[%s] GetConfigName is not implemented", mt.name or "BaseAutomation")
  return nil
end

function BaseAutomation:EnterTestWorld()
  if self.config.is_local_mode == nil or self.config.is_local_mode then
    NRCModeManager:ActiveMode("LocalMode")
    for _, mode in ipairs(self.local_modules) do
      if "FunctionBanModule" == mode then
      elseif "CollisionModule" == mode then
        NRCModuleManager:RegisterModule("CollisionModule", "Type_Core", "NewRoco.Modules.Core.Collision.CollisionModuleHead", "NewRoco.Modules.Core.Collision.CollisionModule")
        NRCModeManager:ActiveMode("CollisionModule")
      elseif "CinematicModule" == mode then
        NRCModuleManager:RegisterModule("CinematicModule", "Type_Core", "NewRoco.Modules.Core.Cinematic.CinematicModuleHead", "NewRoco.Modules.Core.Cinematic.CinematicModule")
        NRCModuleManager:ActiveModule("CinematicModule")
      elseif "LoadingUIModule" == mode then
        NRCModuleManager:RegisterModule("LoadingUIModule", "Donnt_Destroy", "NewRoco.Modules.System.LoadingUIModule.LoadingUIModuleHead", "NewRoco.Modules.System.LoadingUIModule.LoadingUIModule")
        NRCModuleManager:ActiveModule("LoadingUIModule")
      end
    end
  end
  if nil ~= self.config.world_path then
    LevelHelper:OpenLevel(self.config.world_path)
  else
    LevelHelper:OpenLevel(self:GetDefaultMapPath())
  end
end

function BaseAutomation:GetDefaultMapPath()
  return "/Game/ArtRes/Level/SkillPerform/TestWorld2"
end

function BaseAutomation:HideHUD()
  if self.config.hide_hud == nil or self.config.hide_hud then
    local DebugTabCommon = require("NewRoco.Modules.System.Debug.Tabs.DebugTabCommon")()
    pcall(function()
      if NRCEnv:IsLocalMode() then
        DebugTabCommon:HideHUD()
      else
        DebugTabCommon:HideAllHUD()
      end
    end)
  end
end

function BaseAutomation:StopPlayerSceneFx()
  if self.player and self.player.viewObj then
    Log.Info("Stop player BP_SceneFxComponent")
    self.player.viewObj.BP_SceneFxComponent:Stop()
  else
    Log.Error("Player is not found")
  end
end

function BaseAutomation:HidePlayer()
  Log.Info("Hide player")
  _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.HIDE_LOCAL_PLAYER, true)
end

function BaseAutomation:OnMapLoaded()
  NRCEventCenter:UnRegisterEvent(self, self.map_loaded_event, self.OnMapLoaded)
  self:HideHUD()
  if self.config.disable_screen_msg == nil or self.config.disable_screen_msg then
    PerfCatCmd.ExecCmdCurrentWorld("DisableAllScreenMessages")
  end
  if self.config.hide_env then
    local World = _G.UE4Helper.GetCurrentWorld()
    local foundActors = UE4.UGameplayStatics.GetAllActorsOfClassWithTag(World, UE4.AEnvSystemActor, "EnvActorCraneCamera")
    if foundActors:Length() > 0 then
      local envActor = foundActors:Get(1)
      envActor:SetActorHiddenInGame(true)
    end
  end
  if self.config.overdraw_mode then
    PerfCatCmd.SetViewMode("simpleoverdraw")
    PerfCatCmd.EnableShaderComplexityPostProcess()
  end
  self.player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if nil == self.config.hide_player or self.config.hide_player then
    self:HidePlayer()
  end
  self.is_started = true
  self.automation_status = AutomationDefines.AutomationStatus.STARTED
  self:OnAutomationBegin()
  self:StartAutomator()
end

function BaseAutomation:OnAutomationBegin()
  local mt = getmetatable(self)
  Log.ErrorFormat("[%s] OnAutomationBegin is not implemented", mt.name or "BaseAutomation")
end

function BaseAutomation:OnAutomationEnd()
  local mt = getmetatable(self)
  Log.ErrorFormat("[%s] OnAutomationEnd is not implemented", mt.name or "BaseAutomation")
end

function BaseAutomation:StartAutomation()
  PerfCatCmd.ExecCmdCurrentWorld("rhi.EnablePerfCustomCsvStat 1")
  PerfCatCmd.ExecCmdCurrentWorld("r.EnableNRCStats 1")
  if self.automation_status == AutomationDefines.AutomationStatus.NOT_STARTED then
    NRCEventCenter:RegisterEvent("BaseAutomation", self, self.map_loaded_event, self.OnMapLoaded)
    _G.NRCBigWorldPreloader:StartPreload(self, self.EnterTestWorld)
  elseif self.automation_status == AutomationDefines.AutomationStatus.FINISHED then
    self:OnMapLoaded()
  end
end

function BaseAutomation:StopAutomation()
  self:OnAutomationEnd()
  self:StopAutomator()
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.CloseInputBlocker, "BaseAutomation:OnAutomationEnd")
  if self.config.disable_screen_msg == nil or self.config.disable_screen_msg then
    PerfCatCmd.ExecCmdCurrentWorld("EnableAllScreenMessages")
  end
  if self.config.overdraw_mode then
    PerfCatCmd.SetViewMode("lit")
    PerfCatCmd.DisableShaderComplexityPostProcess()
  end
  if self.callback_on_finished then
    self.callback_on_finished()
  end
  self.is_finished = true
  self.automation_status = AutomationDefines.AutomationStatus.FINISHED
end

function BaseAutomation:StartAutomationWithSavedConfig(callback)
  self:Init(callback, nil)
  self:InitializeAutomation()
  self:StartAutomation()
end

function BaseAutomation:StartAutomationWithConfig(config, callback)
  self:Init(callback, config)
  self:InitializeAutomation()
  self:StartAutomation()
end

function BaseAutomation:IsPlaying()
  Log.Error("IsPlaying is not implemented")
  return false
end

function BaseAutomation:IsFinished()
  return self.is_finished
end

function BaseAutomation:IsStarted()
  return self.is_started
end

return BaseAutomation
