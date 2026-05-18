local MagicReplayUtils = require("NewRoco.Modules.System.MagicReplay.MagicReplayUtils")
local MagicReplayModuleEnum = require("NewRoco.Modules.System.MagicReplay.MagicReplayModuleEnum")
local MagicReplayModuleEvent = require("NewRoco.Modules.System.MagicReplay.MagicReplayModuleEvent")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
require("UnLuaEx")
local PetHUDComponent = require("NewRoco.Modules.Core.Scene.Component.HUD.PetHUDComponent")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local BP_NPCVideoForTrace_C = Base:Extend("BP_NPCVideoForTrace_C")

function BP_NPCVideoForTrace_C:Init()
  Base.Init(self)
  self.range_warning_conf = _G.DataConfigManager:GetGlobalConfig("mark_video_rec_alarm_range")
  self.range_error_conf = _G.DataConfigManager:GetGlobalConfig("mark_video_rec_range")
end

function BP_NPCVideoForTrace_C:Recycle()
  self:DeactivateMagicReplayCheck()
  Base.Recycle(self)
end

function BP_NPCVideoForTrace_C:SetPosition(InitPosition, SelectPosition)
  self.InitialPosition = InitPosition
  self.SelectPosition = SelectPosition
end

function BP_NPCVideoForTrace_C:SetTopMessageVisible()
  local npc = self.sceneCharacter
  if npc then
    local hudClass = _G.NRCBigWorldPreloader:Get("PET_HUD")
    if not hudClass then
      Log.Error("BP_NPCVideoForTrace_C:SetTopMessageVisible _G.NRCBigWorldPreloader:Get(PET_HUD) First Failed")
      hudClass = _G.NRCBigWorldPreloader:Get("PET_HUD")
      if not hudClass then
        Log.Error("BP_NPCVideoForTrace_C:SetTopMessageVisible _G.NRCBigWorldPreloader:Get(PET_HUD) Second Failed")
        return
      end
      return
    end
    local hud = UE4.UWidgetBlueprintLibrary.Create(self, hudClass)
    if not hud then
      Log.Error("BP_NPCVideoForTrace_C:SetTopMessageVisible Create hud First Failed")
      hud = UE4.UWidgetBlueprintLibrary.Create(self, hudClass)
      if not hud then
        Log.Error("BP_NPCVideoForTrace_C:SetTopMessageVisible Create hud Second Failed")
        return
      end
    end
    self.HeadWidget:SetWidget(hud)
    hud:SetParentHUD(self.HeadWidget)
    self.hudComp = npc:EnsureComponent(PetHUDComponent)
    if self.hudComp then
      self.hudComp:OnSetViewObj()
      self.hudComp:ForceUpdate()
    end
  end
end

function BP_NPCVideoForTrace_C:OnDistanceOptimize(distance, viewDotValue, bulkyVisible, distanceRatio)
end

function BP_NPCVideoForTrace_C:ActivateMagicReplayCheck()
  Log.Debug("BP_NPCVideoForTrace_C:ActivateMagicReplayCheck", self.isActivateRangeCheck)
  if not self.isActivateRangeCheck then
    self.isActivateRangeCheck = true
    self.lastWarningState = false
    UpdateManager:Register(self)
  end
end

function BP_NPCVideoForTrace_C:DeactivateMagicReplayCheck()
  Log.Debug("BP_NPCVideoForTrace_C:DeactivateMagicReplayCheck", self.isActivateRangeCheck)
  if self.isActivateRangeCheck then
    self.isActivateRangeCheck = false
    UpdateManager:UnRegister(self)
  end
end

function BP_NPCVideoForTrace_C:OnTick(deltaTime)
  self:CheckMagicReplayRange()
end

function BP_NPCVideoForTrace_C:CheckMagicReplayRange()
  local player = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local pos = player:GetActorLocation()
  local npcPos = self:Abs_K2_GetActorLocation()
  if MagicReplayUtils.IsOpActivated(MagicReplayModuleEnum.ModuleOpType.Replay) then
    if not self.lastWarningState and self:IsOutOfCheckRange(pos, npcPos, self.range_warning_conf) then
      self.lastWarningState = true
      local msg = _G.LuaText.mark_video_watch_quit_alarm
      _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, msg)
    elseif self.lastWarningState and not self:IsOutOfCheckRange(pos, npcPos, self.range_warning_conf) then
      self.lastWarningState = false
    end
  end
  if self:IsOutOfCheckRange(pos, npcPos, self.range_error_conf) then
    self:DeactivateMagicReplayCheck()
    _G.NRCModeManager:DoCmd(_G.MagicReplayModuleCmd.LeaveMagicReplayArea)
  end
end

function BP_NPCVideoForTrace_C:IsOutOfCheckRange(pos1, pos2, range_conf)
  local checkHeight = range_conf.numList[2] * 100
  if checkHeight < math.abs(pos1.Z - pos2.Z) then
    return true
  end
  local checkRadius = range_conf.numList[1] * 100
  if (pos1.X - pos2.X) ^ 2 + (pos1.Y - pos2.Y) ^ 2 > checkRadius ^ 2 then
    return true
  end
  return false
end

function BP_NPCVideoForTrace_C:IsRecTarget(npc_id)
  if not (self.sceneCharacter and self.sceneCharacter.serverData) or not self.sceneCharacter.serverData.base then
    return false
  end
  if self.sceneCharacter.serverData.base.actor_id == npc_id then
    return true
  end
  return false
end

function BP_NPCVideoForTrace_C:PlaySeqTargetEmergeEffect(targetView, isPlayer, isRidePet)
  local path
  if isPlayer then
    path = "/Game/ArtRes/Effects/G6Skill/SceneEffect/MovieMagic/G6_Scene_MovieMagic_Charactor"
  elseif isRidePet then
    path = "/Game/ArtRes/Effects/G6Skill/SceneEffect/MovieMagic/G6_Scene_MovieMagic_Ride"
  else
    path = "/Game/ArtRes/Effects/G6Skill/SceneEffect/MovieMagic/G6_Scene_MovieMagic_Pet"
  end
  if not self.RocoSkill then
    Log.Error("BP_NPCVideoForTrace_C:PlayReplayEffect self.RocoSkill is nil")
  end
  local skill
  if isPlayer then
    skill = RocoSkillProxy.Create(path, self.RocoSkill)
    skill:SetCaster(self)
    skill:SetTargets({targetView})
    skill:SetForcePlayPassive(true)
  else
    if isRidePet then
      skill = RocoSkillProxy.Create(path, self.RocoSkill)
    else
      skill = RocoSkillProxy.Create(path, targetView.RocoSkill)
    end
    skill:SetCaster(targetView)
    skill:SetTargets({self})
  end
  skill:SetPassive(true)
  skill:SetWithLoadAndPlay(true)
  skill:RegisterEventCallback("PreEnd", self, self.OnEmergeEffectSkillComplete)
  skill:RegisterEventCallback("End", self, self.OnEmergeEffectSkillComplete)
  skill:RegisterEventCallback("Interrupt", self, self.OnEmergeEffectSkillComplete)
  skill:RegisterEventCallback("ShowPlayer", self, self.OnEmergeEffectShowPlayer)
  skill:RegisterEventCallback("ShowPet", self, self.OnEmergeEffectShowPet)
  skill:PlaySkill(self, self.OnEmergeEffectSkillStart)
end

function BP_NPCVideoForTrace_C:OnEmergeEffectSkillStart(Skill, Result)
  Log.Debug("BP_NPCVideoForTrace_C:OnEmergeEffectSkillStart", Result)
  if Result ~= UE.ESkillStartResult.Success then
    self:OnEmergeEffectSkillComplete()
  end
end

function BP_NPCVideoForTrace_C:OnEmergeEffectSkillComplete()
end

function BP_NPCVideoForTrace_C:OnEmergeEffectShowPlayer(eventName, skill)
  if skill and skill.DynamicData and skill.DynamicData.Targets[1] and UE.UObject.IsValid(skill.DynamicData.Targets[1]) then
    skill.DynamicData.Targets[1]:SetHiddenMask(false, UE4.EPlayerForceHiddenType.MagicReplay)
  end
end

function BP_NPCVideoForTrace_C:OnEmergeEffectShowPet(eventName, skill)
  if skill and skill.DynamicData and skill.DynamicData.Caster and UE.UObject.IsValid(skill.DynamicData.Caster) then
    skill.DynamicData.Caster:SetHiddenMask(false, UE4.EPlayerForceHiddenType.MagicReplay)
  end
end

return BP_NPCVideoForTrace_C
