local LockWeatherReason = require("NewRoco.Modules.System.EnvSystem.LockWeatherReason")
local MagicActionModelBase = require("NewRoco.Modules.Core.NPC.Actions.MagicActions.MagicActionBase")
local Base = MagicActionModelBase
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local NRCResourceManagerEnum = require("Core.Service.ResourceManager.NRCResourceManagerEnum")
local MagicActionCleanNightmare = Base:Extend("MagicActionCleanNightmare")
local NightmareCleanPath = "/Game/ArtRes/Effects/G6Skill/SceneEffect/G6_Scene_NightMare_Cleaning.G6_Scene_NightMare_Cleaning"

function MagicActionCleanNightmare:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
  self.isPlaying = false
end

function MagicActionCleanNightmare:OnExecute()
  self:ExecuteWithModel()
end

function MagicActionCleanNightmare:ExecuteWithModel()
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local npc = self:GetOwnerNPC()
  local npcView = self:GetOwnerNPCView()
  if not npc then
    return
  end
  if not player then
    return
  end
  if not npcView then
    Log.Debug("MagicActionCleanNightmare:ExecuteWithModel npcView is not ready or destroyed")
    return
  end
  local SkillComponent = npcView.RocoSkill
  self.Skill = RocoSkillProxy.Create(NightmareCleanPath, SkillComponent, NRCResourceManagerEnum.Priority.IMMEDIATELY)
  self.Skill:SetCaster(npcView)
  self.Skill:SetTargets({npcView})
  self.Skill:RegisterEventCallback("Interrupt", self, self.OnSkillInterrupt)
  self.Skill:RegisterEventCallback("End", self, self.OnSkillComplete)
  self.Skill:RegisterEventCallback("OutWeatherChange", self, self.OnChangeNightmareWeather)
  self.Skill:RegisterEventCallback("CloseFx", self, self.OnCloseFX)
  self.Skill:RegisterEventCallback("OpenLoopFXJH", self, self.OnOpenLoopFXJH)
  self.DoAction = true
  self.Skill:PlaySkill(self, self.OnSkillCallBack)
  npc:SetSignificant(false, UE.ESignificanceValue.Highest)
  npc:SetNotDestroyFlag(true)
  if player.inputComponent then
    player.inputComponent:SetInputEnable(self, false, "ActionNightmare")
  end
  _G.NRCModeManager:GetCurMode():DisablePanelByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
  _G.NRCModuleManager:DoCmd(_G.MiniGameModuleCmd.SetPlayNightmareCleanAction, true)
  _G.NRCEventCenter:RegisterEvent("MagicActionCleanNightmare", self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReConnect)
  self.isPlaying = true
end

function MagicActionCleanNightmare:OnChangeNightmareWeather()
  _G.NRCModuleManager:DoCmd(_G.EnvSystemModuleCmd.LockWeather, Enum.WeatherType.WT_NONE, LockWeatherReason.MiniGameNightmare)
end

function MagicActionCleanNightmare:OnSkillInterrupt()
  Log.Error("MagicActionCleanNightmare:OnSkillInterrupt skill is interrupting!")
  self:OnSkillComplete()
end

function MagicActionCleanNightmare:OnReConnect()
  Log.Error("MagicActionCleanNightmare:OnReConnect need to reset skill!")
  self:OnSkillComplete()
end

function MagicActionCleanNightmare:OnSkillCallBack(skillProxy, result)
  if result ~= UE4.ESkillStartResult.Success then
    Log.Error("MagicActionCleanNightmare:OnSkillCallBack failed to play skill!", result, skillProxy)
    self:SkillFailed()
  end
end

function MagicActionCleanNightmare:SkillFailed()
  Log.Error("MagicActionCleanNightmare:SkillFailed failed to play skill!")
  self:OnSkillComplete()
end

function MagicActionCleanNightmare:OnSkillComplete()
  if not self.isPlaying then
    return
  end
  self.isPlaying = false
  local MiniGameModule = _G.NRCModuleManager:GetModule("MiniGameModule")
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local npc = self:GetOwnerNPC()
  if player and player.inputComponent then
    player.inputComponent:SetInputEnable(self, true, "ActionNightmare")
  end
  if npc then
    npc:SetNotDestroyFlag(false)
  end
  if self.Skill then
    self.Skill:UnregisterEventCallback("End", self, self.OnSkillComplete)
    self.Skill:UnregisterEventCallback("OutWeatherChange", self, self.OnChangeNightmareWeather)
    self.Skill:UnregisterEventCallback("CloseFx", self, self.OnCloseFX)
    self.Skill:UnregisterEventCallback("OpenLoopFXJH", self, self.OnOpenLoopFXJH)
    self.Skill:UnregisterEventCallback("Interrupt", self, self.OnSkillInterrupt)
    self.Skill:ReleaseRequest()
    self.Skill = nil
  end
  _G.NRCModeManager:GetCurMode():RevertPanelEnableStateByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
  self:Finish()
  self.DoAction = false
  local bSuccessFinish = _G.NRCModuleManager:DoCmd(_G.MiniGameModuleCmd.NeedFinishGameByCleanAction)
  if bSuccessFinish then
    MiniGameModule:OnGameFinished()
  end
  _G.NRCModuleManager:DoCmd(_G.MiniGameModuleCmd.SetPlayNightmareCleanAction, false)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReConnect)
end

function MagicActionCleanNightmare:OnCloseFX()
  local npcView = self:GetOwnerNPCView()
  if npcView then
    npcView:OnCloseFX()
  end
end

function MagicActionCleanNightmare:OnOpenLoopFXJH()
  local npcView = self:GetOwnerNPCView()
  if npcView then
    npcView:OpenLoopFXJH()
  end
end

return MagicActionCleanNightmare
