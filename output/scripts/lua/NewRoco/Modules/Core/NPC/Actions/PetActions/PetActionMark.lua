local BubbleType = require("NewRoco.Modules.Core.Scene.Component.Bubble.BubbleType")
local BubbleComponent = require("NewRoco.Modules.Core.Scene.Component.Bubble.BubbleComponent")
local PetActionBase = require("NewRoco.Modules.Core.NPC.Actions.PetActionBase")
local Base = PetActionBase
local PetActionMark = Base:Extend("PetActionMark")

function PetActionMark:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function PetActionMark:OnExecute()
  local Owner = self:GetOwnerNPC()
  local Comp = Owner:EnsureComponent(BubbleComponent)
  Comp:Play(self.Runner, BubbleType.Special)
  self:Submit()
end

return PetActionMark
