local ViewNPCBase = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local Base = ViewNPCBase
local BP_MiniGame_Time_C = Base:Extend("BP_MiniGame_Time_C")

function BP_MiniGame_Time_C:Ctor()
  self.KillTable = {}
  for i = 1, 12 do
    self.KillTable[i] = false
  end
end

function BP_MiniGame_Time_C:StartClock()
  self.KillTable = {}
  for i = 1, 12 do
    self.KillTable[i] = false
  end
  self.Overridden.StartClock(self)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1334, "BP_MiniGame_Time_C:StartClock")
end

function BP_MiniGame_Time_C:KillAll()
  self.Overridden.KillAll(self)
end

function BP_MiniGame_Time_C:Kill(KillDex)
  if self.KillTable[KillDex] then
    return
  end
  self.KillTable[KillDex] = true
  self.Overridden.Kill(self, KillDex)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1336, "BP_MiniGame_Time_C:Kill")
end

return BP_MiniGame_Time_C
