local Base = require("NewRoco.AI.BehaviorTree.LuaServiceBase")
local LuaServicePerceivePlayer = Base:Extend("LuaServicePerceivePlayer")

function LuaServicePerceivePlayer:OnStart(Controller)
  local AIComp = Controller.Npc.AIComponent
  if AIComp then
    AIComp:PerceiveLocalPlayer(true)
  end
end

function LuaServicePerceivePlayer:OnEnd(Controller)
  local AIComp = Controller.Npc.AIComponent
  if AIComp then
    AIComp:PerceiveLocalPlayer(false)
  end
end

return LuaServicePerceivePlayer
