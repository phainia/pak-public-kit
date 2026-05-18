local ViewNPCBase = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local Base = ViewNPCBase
local BP_NPCTextSteleBase_C = Base:Extend("BP_NPCTextSteleBase")

function BP_NPCTextSteleBase_C:Initialize(Initializer)
  self.bIsUnlocking = false
  self.bIsEnabled = false
end

function BP_NPCTextSteleBase_C:ReceiveBeginPlay()
  Base.ReceiveBeginPlay(self)
end

function BP_NPCTextSteleBase_C:ReceiveEndPlay()
  Base.ReceiveEndPlay(self)
end

return BP_NPCTextSteleBase_C
