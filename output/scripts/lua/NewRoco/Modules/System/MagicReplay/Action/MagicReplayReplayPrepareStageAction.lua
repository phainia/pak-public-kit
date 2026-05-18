local MagicReplayModuleEvent = require("NewRoco.Modules.System.MagicReplay.MagicReplayModuleEvent")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local MagicReplayUtils = require("NewRoco.Modules.System.MagicReplay.MagicReplayUtils")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local MagicReplayActionBase = require("NewRoco.Modules.System.MagicReplay.Action.MagicReplayActionBase")
local FunctionBanModuleCmd = require("NewRoco.Modules.System.FunctionBan.FunctionBanModuleCmd")
local CreatePlayerModuleCmd = require("NewRoco.Modules.System.CreatePlayerModule.CreatePlayerModuleCmd")
local Base = MagicReplayActionBase
local MagicReplayReplayPrepareStageAction = Base:Extend("MagicReplayReplayPrepareStageAction")
FsmUtils.MergeMembers(Base, MagicReplayReplayPrepareStageAction, {})

function MagicReplayReplayPrepareStageAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function MagicReplayReplayPrepareStageAction:OnEnter()
  self:InjectProperties()
  self:Finish()
end

function MagicReplayReplayPrepareStageAction:OnExit()
end

return MagicReplayReplayPrepareStageAction
