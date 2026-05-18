local PetActionBase = require("NewRoco.Modules.Core.NPC.Actions.PetActions.PetTypeInteractActionBase")
local Base = PetActionBase
local PetActionNaughtyChest = Base:Extend("PetActionNaughtyChest")

function PetActionNaughtyChest:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function PetActionNaughtyChest:OnExecute()
  self.interact_type = _G.Enum.SkillDamType.SDT_NONE
  for _, config in pairs(self.Config.interact_cond_group) do
    for _, Type in ipairs(config.interact_cond_param) do
      self.interact_type = Enum.SkillDamType[Type]
    end
  end
  Log.Error(table.tostring(self.Info), table.tostring(self.Config))
  local Box = self:GetOwnerNPCView()
  if not Box then
    self:Finish(false)
    return
  end
  self:DoPetTypeInteraction(self, self.PreSubmit)
end

function PetActionNaughtyChest:PreSubmit(Success)
  if not Success then
    return
  end
  local Box = self:GetOwnerNPCView()
  if not Box then
    self:Finish(false)
    return
  end
  Box.ActivatePet = self.Runner
  Box.interact_type = self.interact_type
end

function PetActionNaughtyChest:OnSubmit(rsp)
  Base.OnSubmit(self, rsp)
  if 0 == rsp.ret_info.ret_code then
    self:OnUnlock()
  end
end

function PetActionNaughtyChest:OnUnlock()
  self:Finish(true)
end

function PetActionNaughtyChest:GetRangeType()
  return Enum.PetReleaseRange.PRR_FAR_BIG
end

return PetActionNaughtyChest
