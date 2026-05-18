local RealtimeDialogModuleCmd = require("NewRoco.Modules.System.RealtimeDialog.RealtimeDialogModuleCmd")
local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionStopRealtimeDialog = Base:Extend("LuaActionStopRealtimeDialog")

function LuaActionStopRealtimeDialog:OnStart(owner)
  _G.NRCModuleManager:DoCmd(RealtimeDialogModuleCmd.StopRealtimeDialogByNpc, owner.Npc)
  return self:Finish(true)
end

return LuaActionStopRealtimeDialog
