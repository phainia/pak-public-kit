local Base = require("NewRoco.Modules.Core.NPC.Alchemy.BP_NPCIronPan_C")
local MagicCreationUtils = require("NewRoco.Modules.System.MagicCreation.MagicCreationUtils")
local BP_IronPan_Artificial_C = Base:Extend("BP_IronPan_Artificial_C")

function BP_IronPan_Artificial_C:UpdateData(ServerData, bIsReconnect)
  if bIsReconnect and self.hasRecycled and self.sceneCharacter.updateEnable then
    MagicCreationUtils.UndoDeleteEffect(self.sceneCharacter)
    local mesh = self.NRCSkeletalMesh
    mesh:SetVisibility(true, true)
  end
end

return BP_IronPan_Artificial_C
