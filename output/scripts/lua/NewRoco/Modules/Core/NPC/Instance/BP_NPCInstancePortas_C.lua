require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.Instance.BP_NPCInstanceMechanismBase_C")
local BP_NPCInstancePortas_C = Base:Extend("BP_NPCInstancePortas_C")

function BP_NPCInstancePortas_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
end

function BP_NPCInstancePortas_C:UpdateState(bInit)
  Base.UpdateState(self, bInit)
end

return BP_NPCInstancePortas_C
