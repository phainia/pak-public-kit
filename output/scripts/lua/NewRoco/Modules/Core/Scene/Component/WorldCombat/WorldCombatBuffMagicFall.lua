local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local WorldCombatBuffBase = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatBuffBase")
local Base = WorldCombatBuffBase
local WorldCombatBuffMagicFall = Base:Extend("WorldCombatBuffMagicFall")

function WorldCombatBuffMagicFall:OnAdd()
  local Npc = self:GetBuffOwner()
  if Npc then
    Npc:SendEvent(NPCModuleEvent.BE_HIT_BY_STAR)
  end
end

return WorldCombatBuffMagicFall
