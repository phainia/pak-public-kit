local Base = require("NewRoco.Modules.Core.NPC.Actions.MagicActions.MagicActionBase")
local MagicActionStarHitShrub = Base:Extend("MagicActionStarHitShrub")

function MagicActionStarHitShrub:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function MagicActionStarHitShrub:OnExecute()
  local NPCView = self:GetOwnerNPCView()
  NPCView:LetFruitDrop()
  self:Finish(true)
end

function MagicActionStarHitShrub:OnSubmit(rsp)
end

return MagicActionStarHitShrub
