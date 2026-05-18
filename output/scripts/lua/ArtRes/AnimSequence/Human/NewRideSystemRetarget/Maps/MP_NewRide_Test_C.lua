require("UnLuaEx")
local MP_NewRide_Test_C = NRCClass()

function MP_NewRide_Test_C:PlayMountSkill(Rider, RidePet, IsMount, IsRun)
  Log.Debug("PlayMountSkill")
  local skillPath
  if IsMount then
    if IsRun then
      skillPath = "/Game/NewRoco/Modules/Core/Scene/Ability/Ride/BP_RunRideWolfSkill.BP_RunRideWolfSkill"
    else
      skillPath = "/Game/NewRoco/Modules/Core/Scene/Ability/Ride/BP_RideWolfSkill.BP_RideWolfSkill"
    end
  elseif IsRun then
    skillPath = "/Game/NewRoco/Modules/Core/Scene/Ability/Ride/BP_RideOffWolfSkill.BP_RideOffWolfSkill"
  else
    skillPath = "/Game/NewRoco/Modules/Core/Scene/Ability/Ride/BP_RunRideOffWolfSkill.BP_RunRideOffWolfSkill"
  end
  if not string.IsNilOrEmpty(skillPath) then
    self.skillClass = UE4.UNRCStatics.ResolveClass(skillPath)
    local characters = {
      [2] = RidePet
    }
    self:CastG6Ability(Rider, characters, {})
  end
end

function MP_NewRide_Test_C:CastG6Ability(Caster, Characters, Targets)
  if self.skillClass then
    local skillComponent = Caster.RocoSkill
    if not skillComponent then
      return
    end
    local skillObj = skillComponent:FindOrAddSkillObj(self.skillClass)
    self._skillObj = skillObj
    skillObj:SetCaster(Caster)
    skillObj:SetCharacters(Characters)
    skillObj:SetTargets(Targets)
    skillObj:RegisterRawCallback(self, self.OnSkillEvent)
    local result = skillComponent:PlaySkill(skillObj)
    return result == UE4.ESkillStartResult.Success
  end
  return false
end

function MP_NewRide_Test_C:OnSkillEvent(Event)
  self.Overridden.OnSkillEvent(self, Event)
end

return MP_NewRide_Test_C
