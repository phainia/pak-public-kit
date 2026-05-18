local Base = require("NewRoco.Modules.Core.NPC.Actions.PetActions.PetTypeInteractActionBase")
local PetActionThrowLightBonfireConditioned = Base:Extend("PetActionThrowLightBonfireConditioned")

function PetActionThrowLightBonfireConditioned:OnExecute()
  self:DoPetTypeInteraction(self, self.PreSubmit)
end

function PetActionThrowLightBonfireConditioned:PreSubmit(Success)
  if not Success then
    return
  end
  self:Finish(true)
end

function PetActionThrowLightBonfireConditioned:OnSubmit(rsp)
  self:ConsumeOwnerActorTag()
  self:Finish(0 == rsp.ret_info.ret_code)
end

function PetActionThrowLightBonfireConditioned:ContinueNormalInteract()
  return false
end

function PetActionThrowLightBonfireConditioned:GetRangeType()
  return Enum.PetReleaseRange.PRR_FAN_FRONT
end

return PetActionThrowLightBonfireConditioned
