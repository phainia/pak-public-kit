local PetActionBase = require("NewRoco.Modules.Core.NPC.Actions.PetActionBase")
local Base = PetActionBase
local BubbleComponent = require("NewRoco.Modules.Core.Scene.Component.Bubble.BubbleComponent")
local PetActionDigLightSpot = Base:Extend("PetActionDigLightSpot")

function PetActionDigLightSpot:OnExecute()
  local Runner = self.Runner
  local BubbleComp = Runner:EnsureComponent(BubbleComponent)
  BubbleComp:StopAll()
  BubbleComp:Play(self:GetOwnerNPC(), Enum.EmotionType.EMT_PET_JINGYA, self, self.Submit)
end

function PetActionDigLightSpot:GetRangeType()
  return Enum.PetReleaseRange.PRR_FAR
end

function PetActionDigLightSpot:ContinueNormalInteract()
  return false
end

function PetActionDigLightSpot:ContinueWhenSuccess()
  return false
end

return PetActionDigLightSpot
