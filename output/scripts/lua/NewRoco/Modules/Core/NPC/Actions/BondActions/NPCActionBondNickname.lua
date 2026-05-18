local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local Base = NPCActionBase
local NPCActionBondNickname = Base:Extend("NPCActionBondNickname")

function NPCActionBondNickname:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionBondNickname:ExecuteWithModel()
  local owner = self:GetOwnerNPC()
  if owner.ThrowSession and owner.ThrowSession:HasPet() then
    local petData = owner.ThrowSession.petData
    _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OpenRechristenPanel, petData, {action = self})
  else
    local ownerView = self:GetOwnerNPC()
    if ownerView.ThrowSession and ownerView.ThrowSession:HasPet() then
      local petData = ownerView.ThrowSession.petData
      _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OpenRechristenPanel, petData, {action = self})
    else
      Log.Error("\232\162\171\230\145\184\229\164\180\231\154\132\231\178\190\231\129\181\231\171\159\231\132\182\230\178\161\230\156\137ThrowSession\239\188\159\232\191\153\229\190\136\228\184\141\229\144\136\231\144\134\239\188\129")
      self:Finish()
    end
  end
end

return NPCActionBondNickname
