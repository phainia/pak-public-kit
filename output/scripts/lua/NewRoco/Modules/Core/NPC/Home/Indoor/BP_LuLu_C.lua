local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local Base = require("NewRoco.Modules.Core.NPC.BP_NPCCharacter_C")
local MagicCreationUtils = require("NewRoco/Modules/System/MagicCreation/MagicCreationUtils")
local BP_LuLu_C = Base:Extend("BP_LuLu_C")

function BP_LuLu_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
  if not self.RocoSkill then
    self.RocoSkill = self:AddComponentByClass(UE4.URocoSkillComponent, false, UE4.FTransform(), false)
  end
  if not self.RocoFx then
    self.RocoFx = self:AddComponentByClass(UE4.URocoFXComponent, false, UE4.FTransform(), false)
  end
  self:Appear()
end

function BP_LuLu_C:Appear()
  local skillPath = MagicCreationUtils.GetSkillLoadPath(self.sceneCharacter.config.emerge_skill)
  Log.Info("BP_LuLu_C, play born skill:", skillPath)
  if "" ~= skillPath then
    self:PlaySkill(skillPath, self, nil, nil, self.OnAppear, true)
  end
end

function BP_LuLu_C:PlaySkill(skillPath, caster, target, eventRegister, onSkillEnd, isPassive)
  local rocoSkill = self.RocoSkill
  if self.RocoSkill == nil then
    Log.Error("PlayCommonPetInteractionSkill Error, Not Find RocoSkill")
    return false
  end
  local SkillProxy = RocoSkillProxy(skillPath, rocoSkill)
  if caster then
    SkillProxy:SetCaster(caster)
  end
  if target then
    SkillProxy:SetTargets({target})
  end
  if onSkillEnd then
    SkillProxy:RegisterEventCallback("End", self, onSkillEnd)
    SkillProxy:RegisterEventCallback("PreEnd", self, onSkillEnd)
    SkillProxy:RegisterEventCallback("PreEndAnim", self, onSkillEnd)
    SkillProxy:RegisterEventCallback("Interrupt", self, onSkillEnd)
    SkillProxy:RegisterEventCallback("OnBirdEstablished", self, self.OnBirdEstablished)
  end
  if eventRegister then
    eventRegister(SkillProxy)
  end
  SkillProxy:SetPassive(isPassive)
  SkillProxy:PlaySkill()
end

function BP_LuLu_C:OnAppear()
end

function BP_LuLu_C:OnBirdEstablished()
  self:RefreshRelativeCollision()
end

local CHILD_ARRAY = UE.TArray(UE.AActor)

function BP_LuLu_C:SetVisible(bVisible)
  Base.SetVisible(self, bVisible)
  self:GetAttachedActors(CHILD_ARRAY, true)
  for k, v in tpairs(CHILD_ARRAY) do
    v:SetActorHiddenInGame(not bVisible)
  end
end

function BP_LuLu_C:SetCollisionEnable(CollisionEnable)
  Base.SetCollisionEnable(self, CollisionEnable)
  self:RefreshRelativeCollision()
end

function BP_LuLu_C:RefreshRelativeCollision()
  self:GetAttachedActors(CHILD_ARRAY, true)
  for k, v in tpairs(CHILD_ARRAY) do
    v:SetActorEnableCollision(not v.bHidden)
  end
end

return BP_LuLu_C
