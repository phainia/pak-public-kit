require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local BP_NPCGleam_C = Base:Extend("BP_NPCGleam_C")

function BP_NPCGleam_C:OnShouldDestroy()
  self:SetActorHiddenInGame(true)
  if self.sceneCharacter then
    self.sceneCharacter.InteractionComponent:OnPlayerLeaveActionArea()
  end
end

return BP_NPCGleam_C
