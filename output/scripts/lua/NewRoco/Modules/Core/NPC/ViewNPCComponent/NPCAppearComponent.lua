local Class = _G.MakeSimpleClass
local NPCAppearComponent = Class("NPCAppearComponent")

function NPCAppearComponent:Ctor(owner)
  self.startPos = owner:Abs_K2_GetActorLocation()
end

function NPCAppearComponent:Appear(npc)
  npc:Abs_K2_SetActorLocation_WithoutHit(self.startPos)
end

return NPCAppearComponent
