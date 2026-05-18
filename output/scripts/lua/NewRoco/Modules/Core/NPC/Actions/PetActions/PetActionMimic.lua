local PetStatusComponent = require("NewRoco.Modules.Core.Scene.Component.Status.PetStatusComponent")
local BubbleComponent = require("NewRoco.Modules.Core.Scene.Component.Bubble.BubbleComponent")
local PetStatusType = require("NewRoco.Modules.Core.Scene.Component.Status.PetStatusType")
local PetActionBase = require("NewRoco.Modules.Core.NPC.Actions.PetActionBase")
local Base = PetActionBase
local PetActionMimic = Base:Extend("PetActionMimic")

function PetActionMimic:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function PetActionMimic:OnExecute()
  local Comp = self.Runner:EnsureComponent(BubbleComponent)
  Comp:Play(nil, Enum.EmotionType.EMT_QUANQUAN, self, self.PreSubmit)
end

function PetActionMimic:PreSubmit(Success)
  self:Finish(true)
end

function PetActionMimic:ContinueWhenSuccess()
  return true
end

return PetActionMimic
