local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local Base = NPCActionBase
local NPCActionSwitchAudioState = Base:Extend("NPCActionSwitchAudioState")

function NPCActionSwitchAudioState:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionSwitchAudioState:Execute()
  _G.NRCAudioManager:BatchSetState(self.Config.action_param1)
  _G.NRCAudioManager:BatchSetState(self.Config.action_param2)
  _G.NRCAudioManager:BatchSetState(self.Config.action_param3)
  self:Finish()
end

return NPCActionSwitchAudioState
