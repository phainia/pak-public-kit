local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionSetEnableBattle = Base:Extend("LuaActionSetEnableBattle")

function LuaActionSetEnableBattle:OnStart(AIController, ...)
  local args = {
    ...
  }
  local owner = AIController
  local enable = self.Enable:GetValue(owner)
  if true == enable then
    owner.Npc.InteractionComponent:TryEnableInteraction()
  else
    owner.Npc.InteractionComponent:TryDisableInteraction()
  end
  self:Finish(true)
end

return LuaActionSetEnableBattle
