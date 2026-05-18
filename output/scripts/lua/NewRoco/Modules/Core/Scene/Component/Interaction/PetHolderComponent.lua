local ThrowSessionStatusEnum = require("NewRoco.Modules.Core.NPC.ThrowSessionStatusEnum")
local PetStatusType = require("NewRoco.Modules.Core.Scene.Component.Status.PetStatusType")
local PetStatusComponent = require("NewRoco.Modules.Core.Scene.Component.Status.PetStatusComponent")
local ActorComponent = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local Base = ActorComponent
local PetHolderComponent = Base:Extend("PetHolderComponent")

function PetHolderComponent:Attach(owner)
  Base.Attach(self, owner)
  self.PetIDs = {}
  self.IsRecyclingInteractPet = false
end

function PetHolderComponent:UpdateAction(Action)
  if not Action then
    return
  end
  if not Action.combine_interact_infos then
    self.owner:SendEvent(NPCModuleEvent.OnPetInteractPerform, 0)
    table.clear(self.PetIDs)
    return
  end
  table.clear(self.PetIDs)
  if Action.combine_interact_infos then
    for _, Info in ipairs(Action.combine_interact_infos) do
      table.insert(self.PetIDs, Info.pet_obj_id)
    end
  end
  for _, ID in ipairs(self.PetIDs) do
    local Pet = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, ID)
    if Pet then
      local Comp = Pet:EnsureComponent(PetStatusComponent)
      if Comp.Type ~= PetStatusType.Wait then
        Comp:SetStatus(PetStatusType.Wait)
      end
      Pet:FaceTo(self.owner)
      local Session = Pet and Pet.ThrowSession
      if Session then
        Session:SetStatus(ThrowSessionStatusEnum.PostInteract)
      end
    else
      Log.Debug("Pet Holder\230\137\190\228\184\141\229\136\176ID\228\184\186", ID, "\231\154\132\231\178\190\231\129\181")
    end
  end
  self.owner:SendEvent(NPCModuleEvent.OnPetInteractPerform, self:GetPetsWeightSum())
end

function PetHolderComponent:GetPets()
  if not self.PetIDs then
    return nil
  end
  if 0 == #self.PetIDs then
    return nil
  end
  local Pets = {}
  for _, ID in ipairs(self.PetIDs) do
    local Pet = _G.NRCModuleManager:DoCmd(NPCModuleCmd.GetNpcByServerID, ID)
    if Pet then
      table.insert(Pets, Pet)
    end
  end
  return Pets
end

function PetHolderComponent:GetPetsWeightSum()
  local weightSum = 0
  local pets = self:GetPets()
  if not pets then
    return 0
  end
  for _, pet in ipairs(pets) do
    weightSum = weightSum + pet.serverData.npc_base.weight
  end
  return weightSum
end

function PetHolderComponent:RecyclePets()
  for _, ID in ipairs(self.PetIDs) do
    local Pet = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, ID)
    if Pet then
      local Session = Pet and Pet.ThrowSession
      if Session then
        Session:Recycle()
      end
    end
  end
  table.clear(self.PetIDs)
end

function PetHolderComponent:OnRecyclePet(PetId)
  for _, ID in ipairs(self.PetIDs) do
    if PetId == ID then
      self.IsRecyclingInteractPet = true
      return
    end
  end
  self.IsRecyclingInteractPet = false
end

function PetHolderComponent:DeAttach()
  Base.DeAttach(self)
  table.clear(self.PetIDs)
end

function PetHolderComponent:Destroy()
  Base.Destroy(self)
  table.clear(self.PetIDs)
end

return PetHolderComponent
