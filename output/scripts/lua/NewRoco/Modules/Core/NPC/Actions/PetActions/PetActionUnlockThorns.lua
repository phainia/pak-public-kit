local PetActionBase = require("NewRoco.Modules.Core.NPC.Actions.PetActions.PetActionUnlock")
local Base = PetActionBase
local PetActionUnlockThorns = Base:Extend("PetActionUnlockThorns")

function PetActionUnlockThorns:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function PetActionUnlockThorns:GetThrowEffectType()
  return ProtoEnum.ThrowEffect.TRIG_PET_INTERACT
end

function PetActionUnlockThorns:OnExecute()
  Log.Error("\232\191\153\228\184\170\232\141\134\230\163\152\229\174\157\231\174\177\229\186\148\232\175\165\229\183\178\231\187\143\232\162\171\229\186\159\229\188\131\228\186\134\230\137\141\229\175\185\239\188\140\230\131\179\229\134\141\230\172\161\229\144\175\231\148\168\232\175\183\230\143\144\233\156\128\230\177\130\239\188\140\229\174\131\229\129\156\230\173\162\231\187\180\230\138\164\228\186\134")
  local Box = self:GetOwnerNPCView()
  if not Box then
    self:Finish(false)
    return
  end
  local BoxUnlockSkillType, BoxUnlockEcoType = Box:GetUnlockType()
  local PetBaseConf = _G.DataConfigManager:GetPetbaseConf(self.Runner.ThrowSession.petData.base_conf_id)
  if table.contains(PetBaseConf.unit_type, BoxUnlockSkillType) then
    Box.DestroyByFire = true
    self:UnlockSuccess(Box)
    return
  elseif table.contains(PetBaseConf.ecology_feature, BoxUnlockEcoType) then
    Box:UseNewUnlockSkill()
    Box.DestroyByFire = false
    self:UnlockSuccess(Box)
    return
  end
  self:Finish(false)
end

function PetActionUnlockThorns:UnlockSuccess(Box)
  Box.LockSmith = self.Runner
  Box.UnlockFinishDelegate:Add(self, self.OnUnlock, Box)
  self:Submit()
end

function PetActionUnlockThorns:OnUnlock(Box)
  self:Finish(true)
  Box.UnlockFinishDelegate:Remove(self, self.OnUnlock)
end

return PetActionUnlockThorns
