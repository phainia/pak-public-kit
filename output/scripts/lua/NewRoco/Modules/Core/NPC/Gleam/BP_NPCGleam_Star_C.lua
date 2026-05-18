require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.Gleam.BP_NPCGleam_C")
local BP_NPCGleam_Star_C = Base:Extend("BP_NPCGleam_Star_C")

function BP_NPCGleam_Star_C:Show()
  if self.ActorEmitter then
    self.ActorEmitter:SetTargetForwardRotator(self.sceneCharacter:GetActorRotation())
  end
  Base.Show(self)
end

return BP_NPCGleam_Star_C
