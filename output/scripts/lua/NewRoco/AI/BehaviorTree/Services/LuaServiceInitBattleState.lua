local Base = require("NewRoco.AI.BehaviorTree.LuaServiceBase")
local LuaServiceInitBattleState = Base:Extend("LuaServiceInitBattleState")

function LuaServiceInitBattleState:OnStart(OwnerController, ...)
  local owner = OwnerController
  local nextState = self.Status:GetValue(owner)
  owner.Npc.AIComponent:SetBattleState(nextState)
end

function LuaServiceInitBattleState:OnEnd(OwnerController, ...)
  local owner = OwnerController
  local nextState = self.Status:GetValue(owner)
  owner.Npc.AIComponent:UnsetBattleState(nextState)
end

return LuaServiceInitBattleState
