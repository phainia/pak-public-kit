local LockWeatherReason = require("NewRoco.Modules.System.EnvSystem.LockWeatherReason")
local MagicActionModelBase = require("NewRoco.Modules.Core.NPC.Actions.MagicActions.MagicActionBase")
local Base = MagicActionModelBase
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local NRCResourceManagerEnum = require("Core.Service.ResourceManager.NRCResourceManagerEnum")
local MagicActionCleanNightmareBigWorld = Base:Extend("MagicActionCleanNightmareBigWorld")
local NightmareCleanPath = "/Game/ArtRes/Effects/G6Skill/SceneEffect/G6_Scene_NightMare_Cleaning.G6_Scene_NightMare_Cleaning"

function MagicActionCleanNightmareBigWorld:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
  self.isPlaying = false
end

function MagicActionCleanNightmareBigWorld:OnExecute()
  self:ExecuteWithModel()
end

function MagicActionCleanNightmareBigWorld:OnSubmit(rsp)
end

function MagicActionCleanNightmareBigWorld:ExecuteWithModel()
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
    Log.Debug("MagicActionCleanNightmareBigWorld:ExecuteWithModel npcView is not ready or destroyed")
    self:Finish(true)
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
    player.inputComponent:SetInputEnable(self, false)
  end
  _G.NRCModeManager:GetCurMode():DisablePanelByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
  _G.NRCEventCenter:RegisterEvent("MagicActionCleanNightmareBigWorld", self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReConnect)
  self.isPlaying = true
end

function MagicActionCleanNightmareBigWorld:OnChangeNightmareWeather()
  _G.NRCModuleManager:DoCmd(_G.EnvSystemModuleCmd.LockWeather, Enum.WeatherType.WT_NONE, LockWeatherReason.MiniGameNightmare)
end

function MagicActionCleanNightmareBigWorld:OnSkillInterrupt()
  Log.Error("MagicActionCleanNightmareBigWorld:OnSkillInterrupt skill is interrupting!")
  self:OnSkillComplete()
end

function MagicActionCleanNightmareBigWorld:OnReConnect()
  Log.Error("MagicActionCleanNightmareBigWorld:OnReConnect need to reset skill!")
  self:OnSkillComplete()
end

function MagicActionCleanNightmareBigWorld:OnSkillCallBack(skillProxy, result)
  if result ~= UE4.ESkillStartResult.Success then
    Log.Error("MagicActionCleanNightmareBigWorld:OnSkillCallBack failed to play skill!", result, skillProxy)
    self:SkillFailed()
  end
end

function MagicActionCleanNightmareBigWorld:SkillFailed()
  Log.Error("MagicActionCleanNightmareBigWorld:SkillFailed failed to play skill!")
  self:OnSkillComplete()
end

function MagicActionCleanNightmareBigWorld:OnSkillComplete()
  if not self.isPlaying then
    self:Finish(true)
    return
  end
  self.isPlaying = false
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local npc = self:GetOwnerNPC()
  if player and player.inputComponent then
    player.inputComponent:SetInputEnable(self, true)
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
  self:Finish(true)
  self.DoAction = false
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReConnect)
end

function MagicActionCleanNightmareBigWorld:OnCloseFX()
  local npcView = self:GetOwnerNPCView()
  if npcView then
    npcView:CloseFx()
  end
end

function MagicActionCleanNightmareBigWorld:OnOpenLoopFXJH()
  local npcView = self:GetOwnerNPCView()
  if npcView then
    npcView:OpenLoopFXJH()
  end
end

return MagicActionCleanNightmareBigWorld
