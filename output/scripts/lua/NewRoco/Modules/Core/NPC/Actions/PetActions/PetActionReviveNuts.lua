local PetActionBase = require("NewRoco.Modules.Core.NPC.Actions.PetActionBase")
local Base = PetActionBase
local PetActionReviveNuts = Base:Extend("PetActionReviveNuts")

function PetActionReviveNuts:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function PetActionReviveNuts:OnExecute()
  self.interact_type = _G.Enum.SkillDamType.SDT_NONE
  for _, config in pairs(self.Config.interact_cond_group) do
    for _, Type in ipairs(config.interact_cond_param) do
      self.interact_type = Enum.SkillDamType[Type]
    end
  end
  local Nuts = self:GetOwnerNPCView()
  if not Nuts then
    self:Finish(false)
    return
  end
  self:PreSubmit()
end

function PetActionReviveNuts:PreSubmit()
  local Nuts = self:GetOwnerNPCView()
  if not Nuts then
    self:Finish(false)
    Log.Error("\232\175\161\229\188\130")
    return
  end
  Nuts.ActivatePet = self.Runner
  Nuts.interact_type = self.interact_type
  Nuts.ActivateFinishDelegate:Add(self, self.OnUnlock)
  self:Submit()
end

function PetActionReviveNuts:OnSubmit(rsp)
  self:ConsumeOwnerActorTag()
end

function PetActionReviveNuts:OnUnlock()
  self:Finish(true)
end

return PetActionReviveNuts
