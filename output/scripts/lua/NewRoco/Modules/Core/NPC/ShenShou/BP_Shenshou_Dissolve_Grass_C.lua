local ViewNPCBase = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local Base = ViewNPCBase
local BP_Shenshou_Dissolve_Grass_C = Base:Extend("BP_Shenshou_Dissolve_Grass_C")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")

function BP_Shenshou_Dissolve_Grass_C:ReceiveBeginPlay()
  self.Overridden.ReceiveBeginPlay(self)
  _G.NRCEventCenter:DispatchEvent(NPCModuleEvent.OnLegendaryGrassBeginPlay)
end

function BP_Shenshou_Dissolve_Grass_C:Ctor()
  Base.Ctor(self)
end

return BP_Shenshou_Dissolve_Grass_C
