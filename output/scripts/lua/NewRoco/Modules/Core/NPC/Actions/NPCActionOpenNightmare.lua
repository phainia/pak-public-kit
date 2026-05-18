local NPCActionModelBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local LockWeatherReason = require("NewRoco.Modules.System.EnvSystem.LockWeatherReason")
local Base = NPCActionModelBase
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local NRCResourceManagerEnum = require("Core.Service.ResourceManager.NRCResourceManagerEnum")
local NPCActionOpenNightmare = Base:Extend("NPCActionOpenNightmare")
local OpenNightmareStartPath = "/Game/ArtRes/Effects/G6Skill/SceneEffect/G6_Scene_NightMare_Start.G6_Scene_NightMare_Start"

function NPCActionOpenNightmare:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionOpenNightmare:ExecuteWithModel()
  local player = self:GetPlayer()
  if not player then
    return
  end
  if player.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_DEATH) then
    Log.Debug("NPCActionOpenNightmare:ExecuteWithModel player is dead")
    return
  end
  if self:IsLocalAction() then
    local SkillComponent = player.viewObj.RocoSkill
    self.Skill = RocoSkillProxy.Create(OpenNightmareStartPath, SkillComponent, NRCResourceManagerEnum.Priority.IMMEDIATELY)
  end
  _G.NRCModuleManager:DoCmd(_G.MiniGameModuleCmd.AddNPC, self.OwnerNpc:GetServerId())
  if self.Skill then
    self.Skill:SetCaster(player.viewObj)
    self.Skill:SetTargets({
      self:GetOwnerNPCView()
    })
    self.Skill:RegisterEventCallback("End", self, self.OnStartSkillComplete)
    self.Skill:RegisterEventCallback("OnPreEnd", self, self.OnPreEnd)
    self.Skill:RegisterEventCallback("OnWeatherChange", self, self.OnChangeNightmareWeather)
    self.Skill:RegisterEventCallback("OnSetPlayer", self, self.InitPlayer)
    self.Skill:RegisterEventCallback("OpenLoopFX", self, self.OnOpenLoopFX)
    self.Skill:RegisterEventCallback("OnPlaySecondAction", self, self.OnPlaySecondAction)
  else
    Log.Debug("NPCActionOpenNightmare:ExecuteWithModel: Add RocoSkill failed ")
  end
  _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.AddCondition, Enum.PlayerConditionType.PCT_OPTION)
  self.DoAction = true
  _G.NRCModuleManager:DoCmd(_G.MiniGameModuleCmd.SetPlayNightmareAction, true)
  self.Skill:PlaySkill(self, self.OnSkillCallBack)
  if player.inputComponent then
    player.inputComponent:SetInputEnable(self, false, "ActionNightmare")
  end
  if self:IsLocalAction() then
    _G.NRCModeManager:GetCurMode():DisablePanelByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
  end
end

function NPCActionOpenNightmare:OnChangeNightmareWeather()
  local WeatherType
  local MiniGameConfig = _G.DataConfigManager:GetMinigameConf(tonumber(self.Config.action_param1), true)
  if MiniGameConfig then
    if MiniGameConfig.effect_type == Enum.MiniGameType.MINIGAME_NIGHTMARE_SPACE then
      WeatherType = Enum.WeatherType.WT_NIGHTMARE
    elseif MiniGameConfig.effect_type == Enum.MiniGameType.MINIGAME_NIGHTMARE_SPACE_SP then
      WeatherType = Enum.WeatherType.WT_NIGHTMARE_SP
    end
  end
  if not WeatherType then
    return
  end
  _G.NRCModuleManager:DoCmd(_G.EnvSystemModuleCmd.LockWeather, WeatherType, LockWeatherReason.MiniGameNightmare)
end

function NPCActionOpenNightmare:OnPlaySecondAction()
  _G.NRCModuleManager:DoCmd(_G.MiniGameModuleCmd.SetOpenNightmareFinish, true)
end

function NPCActionOpenNightmare:OnSkillCallBack(skillProxy, result)
  if result ~= UE4.ESkillStartResult.Success then
    Log.Error("NPCActionOpenNightmare:OnSkillCallBack failed to play skill!", result, skillProxy)
    self:SkillFailed()
  end
end

function NPCActionOpenNightmare:SkillFailed()
  Log.Error("NPCActionOpenNightmare:SkillFailed failed to play skill!")
  self:OnStartSkillComplete(true)
end

function NPCActionOpenNightmare:OnStartSkillComplete(bFailed)
  _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.RemoveCondition, Enum.PlayerConditionType.PCT_OPTION)
  local player = self:GetPlayer()
  if self.Skill then
    self.Skill:UnregisterEventCallback("End", self, self.OnStartSkillComplete)
    self.Skill:UnregisterEventCallback("OnPreEnd", self, self.OnPreEnd)
    self.Skill:UnregisterEventCallback("OpenLoopFX", self, self.OnChangeNightmareWeather)
    self.Skill:UnregisterEventCallback("OnSetPlayer", self, self.InitPlayer)
    self.Skill:UnregisterEventCallback("OpenLoopFX", self, self.OnOpenLoopFX)
    self.Skill:UnregisterEventCallback("OnPlaySecondAction", self, self.OnPlaySecondAction)
    self.Skill:ReleaseRequest()
    self.Skill = nil
  end
  self.DoAction = false
  local NightmareBP = self:GetOwnerNPCView()
  if not _G.NRCModuleManager:DoCmd(_G.MiniGameModuleCmd.IsInNightmare) then
    if player and player.inputComponent then
      player.inputComponent:SetInputEnable(self, true, "ActionNightmare")
    end
    _G.NRCModeManager:GetCurMode():RevertPanelEnableStateByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
    _G.NRCModuleManager:DoCmd(_G.EnvSystemModuleCmd.LockWeather, Enum.WeatherType.WT_NONE, LockWeatherReason.MiniGameNightmare)
    if NightmareBP and NightmareBP.CloseFx then
      NightmareBP:CloseFx()
    end
    _G.NRCModuleManager:DoCmd(_G.MiniGameModuleCmd.SetPlayNightmareAction, false)
  end
  if not bFailed and NightmareBP and NightmareBP.OpenFX then
    NightmareBP:OpenFX()
  end
end

function NPCActionOpenNightmare:OnPreEnd()
  self.DoAction = false
  self:Finish()
end

function NPCActionOpenNightmare:OnOpenLoopFX()
  local NightmareBP = self:GetOwnerNPCView()
  if NightmareBP and NightmareBP.OpenLoopFX then
    NightmareBP:OpenLoopFX()
  end
end

function NPCActionOpenNightmare:InitPlayer()
  local player = self:GetPlayer()
  if player then
    local StandLocation = self:GetOwnerNPCView():GetExplodeLocation()
    player:SetActorLocation(StandLocation)
    player:FaceTo(self:GetOwnerNPC())
  end
end

function NPCActionOpenNightmare:Destroy()
  local player = self:GetPlayer()
  if player then
    if self.DoAction and player.viewObj and UE.UObject.IsValid(player.viewObj) and self.Skill and UE4.UObject.IsValid(self.Skill) then
      self.Skill:UnregisterEventCallback("End", self, self.OnStartSkillComplete)
      self.Skill:UnregisterEventCallback("OnPreEnd", self, self.OnPreEnd)
      self.Skill:UnregisterEventCallback("OnWeatherChange", self, self.OnChangeNightmareWeather)
      self.Skill:UnregisterEventCallback("OnSetPlayer", self, self.InitPlayer)
      self.Skill:UnregisterEventCallback("OpenLoopFX", self, self.OnOpenLoopFX)
      self.Skill:UnregisterEventCallback("OnPlaySecondAction", self, self.OnPlaySecondAction)
      player.viewObj.RocoSkill:RemoveSkillObj(self.Skill)
      self:Finish()
    end
    self.DoAction = false
  end
  Base.Destroy(self)
end

return NPCActionOpenNightmare
