local BubbleComponent = require("NewRoco.Modules.Core.Scene.Component.Bubble.BubbleComponent")
local BubbleType = require("NewRoco.Modules.Core.Scene.Component.Bubble.BubbleType")
local PetActionBase = require("NewRoco.Modules.Core.NPC.Actions.PetActionBase")
local Base = PetActionBase
local PetActionBubble = Base:Extend("PetActionBubble")

function PetActionBubble:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function PetActionBubble:OnExecute()
  local Owner = self:GetOwnerNPC()
  local Comp = Owner:EnsureComponent(BubbleComponent)
  Comp:Play(self.Runner, self:GetBubbleType())
  self:Finish(true)
end

function PetActionBase:GetBubbleType()
  local ActionType = self.Config.action_type
  if ActionType == Enum.ActionType.ACT_PET_NPC_LIKE then
    return BubbleType.Fond
  end
  if ActionType == Enum.ActionType.ACT_PET_NPC_TROUBLE then
    return BubbleType.Trouble
  end
  if ActionType == Enum.ActionType.ACT_PET_NPC_SURPRISE then
    return BubbleType.Surprise
  end
  return BubbleType.Fond
end

return PetActionBubble
