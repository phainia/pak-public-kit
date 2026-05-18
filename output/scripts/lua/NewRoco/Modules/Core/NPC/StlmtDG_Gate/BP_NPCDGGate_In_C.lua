require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local CameraAdditiveParamStatus = require("NewRoco.Modules.Core.Character.WorldCamera.CameraAdditiveParamStatus")
local CameraAdditiveParamType = require("NewRoco.Modules.Core.Character.WorldCamera.CameraAdditiveParamType")
local BP_NPCDGGate_In_C = Base:Extend("BP_NPCDGGate_In_C")

function BP_NPCDGGate_In_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
  self.IsPlaying = false
  self.IsUnlock = false
end

function BP_NPCDGGate_In_C:OnLoadResource()
  Base.OnLoadResource(self)
  if not self.IsPlaying and self.IsUnlock then
    self:PlayIdleEndEffect()
  end
end

function BP_NPCDGGate_In_C:OnVisible()
  Base.OnVisible(self)
  if not self.IsPlaying and self.IsUnlock then
    self:PlayIdleEndEffect()
    if self.NRCSkeletalMesh then
      UE.UNRCCharacterUtils.ForceTickMesh(self.NRCSkeletalMesh)
    end
  end
end

function BP_NPCDGGate_In_C:PlayIdleStartEffect()
  Log.Debug("BP_NPCDGGate_In_C PlayIdleStartEffect!")
  self.NRCAnimation:PlayAnimByName("IdleClose", 1, 0, 0, 0, -1, 0)
end

function BP_NPCDGGate_In_C:PlayIdleEndEffect()
  Log.Debug("BP_NPCDGGate_In_C PlayIdleEndEffect!")
  self.NRCAnimation:PlayAnimByName("IdleStart", 1, 0, 0, 0, -1, 0)
end

function BP_NPCDGGate_In_C:SetPhysicsSettings()
  self.NRCSkeletalMesh.KinematicBonesUpdateType = 0
  self.NRCSkeletalMesh.bNRCAlwaysUpdateKinematicBonesToAnim = true
  self.NRCSkeletalMesh.bNRCUseFixedSkelBounds = false
end

function BP_NPCDGGate_In_C:GetPlayer()
  local Player = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  return Player
end

function BP_NPCDGGate_In_C:PlaySkill()
  Log.Debug("BP_NPCDGGate_In_C:PlaySkill: pass!")
  local Player = self:GetPlayer()
  if not Player then
    return
  end
  local SkillComp = Player.viewObj.RocoSkill
  self.Skill = RocoSkillProxy.Create("/Game/ArtRes/Effects/G6Skill/SceneEffect/G6_PF_StlmtDG_Gate_In", SkillComp, PriorityEnum.Active_Player_Action)
  self.Skill:SetCaster(self)
  self.Skill:SetPassive(true)
  self.Skill:RegisterEventCallback("End", self, self.OnSkillComplete)
  self.isPlaying = true
  self.Skill:PlaySkill(self, self.OnSkillCallBack)
end

function BP_NPCDGGate_In_C:OnSkillCallBack(skillProxy, result)
  if result ~= UE4.ESkillStartResult.Success then
    Log.Error("BP_NPCDGGate_In_C failed to play skill!", result, skillProxy)
    self:SkillFailed()
  else
    local Player = self:GetPlayer()
    Player:SendEvent(PlayerModuleEvent.ON_ADDITIVE_CAMERA_PARAM, CameraAdditiveParamType.DungeonGate)
  end
end

function BP_NPCDGGate_In_C:OnSkillComplete()
  if not self.isPlaying then
    return
  end
  self.isPlaying = false
  if self.Skill then
    self.Skill:UnregisterEventCallback("End", self, self.OnSkillComplete)
    self.Skill:ReleaseRequest()
    self.Skill = nil
  end
end

function BP_NPCDGGate_In_C:SkillFailed()
  self:OnSkillComplete()
end

function BP_NPCDGGate_In_C:OnReConnect()
  Log.Debug("BP_NPCDGGate_In_C:OnReConnect need to reset skill!")
  self:OnSkillComplete()
end

return BP_NPCDGGate_In_C
