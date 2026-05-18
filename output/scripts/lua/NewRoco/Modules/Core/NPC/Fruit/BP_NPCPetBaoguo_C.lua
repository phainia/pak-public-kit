local BP_NPCFruit_C = require("NewRoco.Modules.Core.NPC.Fruit.BP_NPCFruit_C")
local Base = BP_NPCFruit_C
local BP_NPCPetBaoguo_C = Base:Extend("BP_NPCPetBaoguo_C")

function BP_NPCPetBaoguo_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
end

function BP_NPCPetBaoguo_C:GetHalfHeight()
  return 0
end

return BP_NPCPetBaoguo_C
