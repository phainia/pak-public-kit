local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local DungeonStatusComponent = require("NewRoco.Modules.Core.Scene.Component.Status.DungeonStatusComponent")
local LuaActionCheckPlayerDungeonStatus = Base:Extend("LuaActionCheckPlayerDungeonStatus")

function LuaActionCheckPlayerDungeonStatus:Ctor(LuaBTNodeBase)
  Base.Ctor(self, LuaBTNodeBase)
end

function LuaActionCheckPlayerDungeonStatus:OnStart(AIController, ...)
  local LocalPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local bHas
  local DungeonStatusComp = LocalPlayer:GetComponent(DungeonStatusComponent)
  if not DungeonStatusComp then
    bHas = false
  else
    bHas = DungeonStatusComp:CheckCurDungeonStatus(self.CheckStatus and self.CheckStatus:GetValue(AIController))
  end
  local CheckHas = self.bCheckHas and self.bCheckHas:GetValue(AIController)
  self:Finish(bHas == CheckHas)
end

return LuaActionCheckPlayerDungeonStatus
