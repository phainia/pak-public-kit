require("UnLuaEx")
local BP_Thorns_Box_Lock_C = NRCClass()

function BP_Thorns_Box_Lock_C:PlayDestroyEffect(DestroyedByFire)
  Log.Error("BP_Thorns_Box_Lock_C:PlayDestroyEffect")
  local SkillClass
  if DestroyedByFire then
    SkillClass = UE4.UKismetSystemLibrary.LoadClassAsset_Blocking(self.BurnSkill)
  else
    SkillClass = UE4.UKismetSystemLibrary.LoadClassAsset_Blocking(self.CutSKill)
  end
  if not SkillClass then
    Log.Warning("BP_Thorns_Box_Lock_C:PlayDestroyEffect skill not found")
  end
  local Skill = self.RocoSkill:FindOrAddSkillObj(SkillClass)
  if not Skill then
    return
  end
  Skill:SetCaster(self)
  Skill:RegisterEventCallback("End", self, self.OnSkillComplete)
  self.RocoSkill:PlaySkill(Skill)
end

function BP_Thorns_Box_Lock_C:OnSkillComplete(Name, Skill)
  self:K2_DestroyActor()
end

return BP_Thorns_Box_Lock_C
