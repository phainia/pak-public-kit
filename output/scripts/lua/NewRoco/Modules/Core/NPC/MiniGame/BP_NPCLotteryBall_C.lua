local ViewNPCBase = require("NewRoco.Modules.Core.NPC.ViewDropNPCBase")
local Base = ViewNPCBase
local BP_NPCLotteryBall_C = Base:Extend("BP_NPCLotteryBall_C")

function BP_NPCLotteryBall_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

function BP_NPCLotteryBall_C:Init()
  Base.Init(self)
end

return BP_NPCLotteryBall_C
