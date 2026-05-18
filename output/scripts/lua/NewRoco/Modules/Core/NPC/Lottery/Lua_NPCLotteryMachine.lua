local Base = require("NewRoco.Modules.Core.NPC.Lottery.Lua_ChestLikeNPCBase")
local Lua_NPCLotteryMachine = Base:Extend("Lua_NPCLotteryMachine")

function Lua_NPCLotteryMachine:InitActStatus(optionInfo)
  Base.InitActStatus(self, optionInfo)
  local View = self.sceneCharacter.viewObj
  if View then
    View:UpdateLights(optionInfo)
    View:ApplyLightsSwitch()
    View:Reset()
  end
end

function Lua_NPCLotteryMachine:UpdateActStatus(optionInfo)
  Base.UpdateActStatus(self, optionInfo)
  local View = self.sceneCharacter.viewObj
  if View then
    View:UpdateLights(optionInfo)
  end
end

return Lua_NPCLotteryMachine
