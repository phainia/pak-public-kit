require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local BP_NPCPetItemBase_C = Base:Extend("BP_NPCPetItemBase_C")

function BP_NPCPetItemBase_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
  self.isfirstloadfinish = false
end

function BP_NPCPetItemBase_C:OnFrameLoad(distanceRatio)
  Base.OnFrameLoad(self, distanceRatio)
end

function BP_NPCPetItemBase_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

return BP_NPCPetItemBase_C
