local PetActionUnlock = require("NewRoco.Modules.Core.NPC.Actions.PetActions.PetActionUnlock")
local Base = PetActionUnlock
local PetActionUnlockAddEnergy = Base:Extend("PetActionUnlockAddEnergy")

function PetActionUnlockAddEnergy:OnUnlock()
  local Stone = self:GetOwnerNPCView()
  if not Stone then
    return
  end
  Stone:SetDamageType(self.interact_type)
  Base.OnUnlock(self)
end

return PetActionUnlockAddEnergy
