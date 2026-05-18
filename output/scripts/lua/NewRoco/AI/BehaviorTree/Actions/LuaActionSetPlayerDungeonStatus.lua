local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionSetPlayerDungeonStatus = Base:Extend("LuaActionSetPlayerDungeonStatus")

function LuaActionSetPlayerDungeonStatus:Ctor(LuaBTNodeBase)
  Base.Ctor(self, LuaBTNodeBase)
end

function LuaActionSetPlayerDungeonStatus:OnStart(AIController, ...)
  local bAdd = self.bAddStatus and self.bAddStatus:GetValue(AIController)
  local AddStatus = self.Status and self.Status:GetValue(AIController)
  _G.NRCModuleManager:DoCmd("InstanceModuleCmd.SetPlayerDungeonStatus", bAdd, AddStatus, AIController.Npc)
  self:Finish(true)
end

return LuaActionSetPlayerDungeonStatus
