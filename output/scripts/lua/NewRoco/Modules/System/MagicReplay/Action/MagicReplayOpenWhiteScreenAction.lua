local MagicReplayModuleEvent = require("NewRoco.Modules.System.MagicReplay.MagicReplayModuleEvent")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local MagicReplayUtils = require("NewRoco.Modules.System.MagicReplay.MagicReplayUtils")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local MagicReplayActionBase = require("NewRoco.Modules.System.MagicReplay.Action.MagicReplayActionBase")
local FunctionBanModuleCmd = require("NewRoco.Modules.System.FunctionBan.FunctionBanModuleCmd")
local CreatePlayerModuleCmd = require("NewRoco.Modules.System.CreatePlayerModule.CreatePlayerModuleCmd")
local Base = MagicReplayActionBase
local MagicReplayOpenWhiteScreenAction = Base:Extend("MagicReplayOpenWhiteScreenAction")
FsmUtils.MergeMembers(Base, MagicReplayOpenWhiteScreenAction, {
  {
    name = "NeedWhiteScreen,",
    type = "boolean"
  }
})

function MagicReplayOpenWhiteScreenAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function MagicReplayOpenWhiteScreenAction:OnEnter()
  self:InjectProperties()
  self.NeedWhiteScreen = self:GetProperty("NeedWhiteScreen")
  if not self.NeedWhiteScreen then
    self:Finish()
  else
    _G.NRCEventCenter:DispatchEvent(_G.NRCGlobalEvent.OPEN_WHITE_SCREEN, true, self, self.Finish)
  end
end

function MagicReplayOpenWhiteScreenAction:OnExit()
end

return MagicReplayOpenWhiteScreenAction
