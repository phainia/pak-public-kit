local ViewNPCBase = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local Base = ViewNPCBase
local BP_NPC_LBTrigger_C = Base:Extend("BP_NPC_LBTrigger_C")

function BP_NPC_LBTrigger_C:ReceiveBeginPlay()
  Base.ReceiveBeginPlay(self)
  local path = "Blueprint'/Game/NewRoco/Modules/Core/NPC/ShenShou/BP_0A_ShenShou_Transmit_HD.BP_0A_ShenShou_Transmit_HD_C'"
  self.Request = _G.NRCResourceManager:LoadResAsync(self, path, PriorityEnum.Active_World_Combat_Boss, 10)
end

function BP_NPC_LBTrigger_C:ReceiveEndPlay(Reason)
  if self.Request then
    _G.NRCResourceManager:UnLoadRes(self.Request)
    self.Request = nil
  end
  Base.ReceiveEndPlay(self, Reason)
end

return BP_NPC_LBTrigger_C
