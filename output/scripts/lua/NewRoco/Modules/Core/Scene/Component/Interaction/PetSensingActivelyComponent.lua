local ActorComponent = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local Delegate = require("Utils.Delegate")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local PerceptionTriggerComponent = require("NewRoco.Modules.Core.Scene.Component.Collision.PerceptionTriggerComponent")
local Base = ActorComponent
local PetSensingActivelyComponent = Base:Extend("PetSensingActivelyComponent")

function PetSensingActivelyComponent:Ctor()
  Base.Ctor(self)
  self.startDelegate = Delegate()
  self.stopDelegate = Delegate()
  self.CurrentSkill = nil
  self.bStarted = false
end

function PetSensingActivelyComponent:PlayPerceptionSkill(ScenePet, CallbackOwner, CallbackFunc)
  if self.bStarted or self.CurrentSkill then
    Log.Debug("there's a skill running!!!")
    if CallbackFunc then
      CallbackFunc(CallbackOwner, false)
    end
    return
  end
  self.PetGid = ScenePet.gid
  if CallbackFunc then
    self.startDelegate:Add(CallbackOwner, CallbackFunc)
  end
  Log.Debug("Start Sensing...")
  local perceptionTriggerComponent = self.owner:EnsureComponent(PerceptionTriggerComponent)
  perceptionTriggerComponent:StartPerception(self.PetGid, ScenePet.config.id, "PetSensingActivelyComponent")
  self:StartSkill()
end

function PetSensingActivelyComponent:StartSkill()
  local Player = self:GetPlayer()
  local PlayerView = Player.viewObj
  local _, WearMedal = _G.DataModelMgr.PlayerDataModel:GetMedalListAndWearMedalByPetGid(self.PetGid)
  self.MedalType = nil
  if WearMedal then
    local medal_conf = _G.DataConfigManager:GetMedalConf(WearMedal.conf_id, true)
    if medal_conf then
      self.MedalType = medal_conf.fx_res
    end
  end
  local SkillComp = PlayerView.RocoSkill
  local Skill = RocoSkillProxy.Create("/Game/ArtRes/Effects/G6Skill/SceneEffect/Perception/G6_Scene_Perception_Open2", SkillComp, PriorityEnum.Active_Throw_Sense)
  if not Skill then
    self:StartSkillFinish(false)
    return
  end
  self.bStarted = true
  Skill:SetPassive(true)
  Skill:SetCaster(PlayerView)
  Skill:RegisterEventCallback("Interrupt", self, self.SkillInterrupt)
  Skill:RegisterEventCallback("PreStart", self, self.OnSkillPreStart)
  Skill:PlaySkill(self, self.OnSkillStarted)
end

function PetSensingActivelyComponent:OnSkillPreStart(Name, Skill)
  local Blackboard = Skill.Blackboard
  Blackboard:SetValueAsInt("Continue", -1)
  if self.MedalType then
    Blackboard:SetValueAsString(self.MedalType, self.MedalType)
  end
  self.CurrentSkill = Skill
end

function PetSensingActivelyComponent:OnSkillStarted(SkillProxy, Result)
  self:StartSkillFinish(Result == UE.ESkillStartResult.Success)
end

function PetSensingActivelyComponent:StartSkillFinish(Success)
  Log.Debug("Start Sensing...Done")
  self.startDelegate:Invoke(Success)
  self.startDelegate:Clear()
end

function PetSensingActivelyComponent:SkillInterrupt()
  Log.Debug("Sensing Skill Interrupt")
  self:StopPerceptionSkill()
end

function PetSensingActivelyComponent:StopPerceptionSkill(CallbackOwner, CallbackFunc)
  if CallbackFunc then
    self.stopDelegate:Add(CallbackOwner, CallbackFunc)
  end
  Log.Debug("Stop Sensing...")
  local Skill = self.CurrentSkill
  if not Skill then
    self:FireStopSkillFinish(false)
    return
  end
  Skill:RegisterEventCallback("Recycle", self, self.Recycle)
  Skill:RegisterEventCallback("End", self, self.RemovePet)
  Skill.Blackboard:SetValueAsInt("Continue", 0)
end

function PetSensingActivelyComponent:Recycle()
  local perceptionTriggerComponent = self.owner:EnsureComponent(PerceptionTriggerComponent)
  perceptionTriggerComponent:StopPerception()
end

function PetSensingActivelyComponent:FireStopSkillFinish(Success)
  Log.Debug("Stop Sensing...Done")
  if self.stopDelegate then
    self.stopDelegate:Invoke(Success)
    self.stopDelegate:Clear()
  end
  self.skillFinishTimerId = nil
end

function PetSensingActivelyComponent:RemovePet(Name, Skill)
  self.CurrentSkill = nil
  self.bStarted = false
  if self.skillFinishTimerId then
    _G.DelayManager:CancelDelayById(self.skillFinishTimerId)
    self.skillFinishTimerId = nil
  end
  self.skillFinishTimerId = _G.DelayManager:DelayFrames(1, self.FireStopSkillFinish, self, true)
end

function PetSensingActivelyComponent:GetPlayer()
  return self.owner
end

function PetSensingActivelyComponent:DeAttach()
  if self.skillFinishTimerId then
    _G.DelayManager:CancelDelayById(self.skillFinishTimerId)
    self.skillFinishTimerId = nil
  end
end

return PetSensingActivelyComponent
