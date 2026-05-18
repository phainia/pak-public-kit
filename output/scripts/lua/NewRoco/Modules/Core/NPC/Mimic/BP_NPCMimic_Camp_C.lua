local BP_NPCMimicBase_C = require("NewRoco.Modules.Core.NPC.Mimic.BP_NPCMimicBase_C")
local Base = BP_NPCMimicBase_C
local BP_NPCMimic_Camp_C = Base:Extend("BP_NPCMimic_Camp_C")

function BP_NPCMimic_Camp_C:CanEnterThrowInter(Comp)
  return Comp == self.StaticMesh or Comp == self.StaticMesh1
end

return BP_NPCMimic_Camp_C
