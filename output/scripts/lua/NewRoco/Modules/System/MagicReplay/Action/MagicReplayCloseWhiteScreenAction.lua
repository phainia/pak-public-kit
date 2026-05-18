local MagicReplayModuleEvent = require("NewRoco.Modules.System.MagicReplay.MagicReplayModuleEvent")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local MagicReplayUtils = require("NewRoco.Modules.System.MagicReplay.MagicReplayUtils")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local MagicReplayActionBase = require("NewRoco.Modules.System.MagicReplay.Action.MagicReplayActionBase")
local FunctionBanModuleCmd = require("NewRoco.Modules.System.FunctionBan.FunctionBanModuleCmd")
local CreatePlayerModuleCmd = require("NewRoco.Modules.System.CreatePlayerModule.CreatePlayerModuleCmd")
local Base = MagicReplayActionBase
local MagicReplayCloseWhiteScreenAction = Base:Extend("MagicReplayCloseWhiteScreenAction")
FsmUtils.MergeMembers(Base, MagicReplayCloseWhiteScreenAction, {})

function MagicReplayCloseWhiteScreenAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function MagicReplayCloseWhiteScreenAction:OnEnter()
  self:InjectProperties()
  _G.NRCEventCenter:DispatchEvent(NRCGlobalEvent.CLOSE_WHITE_SCREEN, true, self, self.Finish)
end

function MagicReplayCloseWhiteScreenAction:OnExit()
end

return MagicReplayCloseWhiteScreenAction
