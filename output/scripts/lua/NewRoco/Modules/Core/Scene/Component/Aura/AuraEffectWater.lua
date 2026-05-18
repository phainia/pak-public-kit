local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local AuraEffectObject = require("NewRoco.Modules.Core.Scene.Component.Aura.AuraEffectObject")
local Base = AuraEffectObject
local AuraEffectWater = Base:Extend("AuraEffectWater")

function AuraEffectWater:Ctor(Owner, Index, Effect)
  Base.Ctor(self, Owner, Index, Effect)
end

function AuraEffectWater:OnViewReady(View)
  Base.OnViewReady(self, View)
end

function AuraEffectWater:SetWater()
  local EnvSystem = self:GetEnvSys()
  if EnvSystem then
    local Bound = self:MakeEnvBound(UE.EEnvElementType.WATER)
    Bound.AuraID = self.Owner.ID
    EnvSystem:AddBound(Bound)
  else
    Log.Error("Can't find an env system")
  end
end

function AuraEffectWater:RemoveWater()
  local EnvSystem = self:GetEnvSys()
  if EnvSystem then
    EnvSystem:RemoveBound(self.Owner.ID)
  else
    Log.Error("Can't find an env system")
  end
end

function AuraEffectWater:Destroy()
  self:RemoveWater()
  Base.Destroy(self)
end

function AuraEffectWater:OnRemoveOther(Victim, RemoveInfo)
  local HasFire = false
  local Effects = Victim.aura_effect
  for _, Effect in ipairs(Effects) do
    if Effect.aura_effect_type == Enum.AuraEffect.AE_FIRE_LIGHTING then
      HasFire = true
      break
    end
  end
  if not HasFire then
    return
  end
  local FireNPC = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, RemoveInfo.create_info.create_actor_id)
  local FireView = FireNPC and FireNPC.viewObj
  local Killer = self:GetBindNPC()
  local KillerView = Killer and Killer.viewObj
  if not FireView or not KillerView then
    Log.Error("\231\148\168\228\186\142\232\161\168\230\188\148\231\154\132NPC\228\184\141\232\182\179\229\143\150\230\182\136\232\161\168\230\188\148", FireView, KillerView)
    return
  end
  local SkillComp = KillerView.RocoSkill
  local Skill = RocoSkillProxy.Create("/Game/ArtRes/Effects/G6Skill/SceneEffect/G6_Tempreture_StopFire", SkillComp, PriorityEnum.Active_Aura_Water)
  if not Skill then
    return
  end
  SkillComp:StopCurrentSkill()
  Skill:SetCaster(KillerView)
  Skill:SetTargets({FireView})
  Skill:SetAdditions("Killer", KillerView)
  Skill:SetAdditions("Victim", FireView)
  Skill:RegisterEventCallback("Head", self, self.SetHeadLookAt)
  Skill:RegisterEventCallback("End", self, self.OnSkillEnd)
  Skill:RegisterEventCallback("PreEnd", self, self.OnSkillEnd)
  Skill:RegisterEventCallback("PreEndAnim", self, self.OnSkillEnd)
  Skill:PlaySkill()
end

function AuraEffectWater:OnSkillEnd(Name, Skill)
end

function AuraEffectWater:SetHeadLookAt(Name, Skill)
end

return AuraEffectWater
