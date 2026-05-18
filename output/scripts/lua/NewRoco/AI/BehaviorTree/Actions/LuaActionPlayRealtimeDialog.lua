local RealtimeDialogModuleCmd = require("NewRoco.Modules.System.RealtimeDialog.RealtimeDialogModuleCmd")
local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionPlayRealtimeDialog = Base:Extend("LuaActionPlayRealtimeDialog")

function LuaActionPlayRealtimeDialog:OnStart(owner)
  local DialogueId = self.DialogueId:GetValue(owner)
  local DialogueConf = _G.DataConfigManager:GetDialogueConf(DialogueId, true)
  if DialogueConf then
    _G.NRCModuleManager:DoCmd(RealtimeDialogModuleCmd.StartRealtimeDialogByNpc, owner.Npc, DialogueConf)
  end
  return self:Finish(true)
end

return LuaActionPlayRealtimeDialog
