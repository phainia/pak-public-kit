local BP_DungeonWater_C = require("NewRoco.Modules.Core.NPC.Instance.BP_DungeonWater_C")
local Base = BP_DungeonWater_C
local BP_NPCWater_C = Base:Extend("BP_NPCWater")

function BP_NPCWater_C:Ctor()
  Base.Ctor(self)
end

function BP_NPCWater_C:Init()
  Base.Init(self)
  self.bSkipOverlapCheck = true
end

function BP_NPCWater_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
end

function BP_NPCWater_C:ReceiveEndPlay()
  Base.ReceiveEndPlay(self)
end

function BP_NPCWater_C:ReceiveBeginPlay()
  Base.ReceiveBeginPlay(self)
  self.bSkipOverlapCheck = true
end

return BP_NPCWater_C
