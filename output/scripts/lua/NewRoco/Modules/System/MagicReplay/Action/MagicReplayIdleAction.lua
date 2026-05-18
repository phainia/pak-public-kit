local MagicReplayModuleEnum = require("NewRoco.Modules.System.MagicReplay.MagicReplayModuleEnum")
local MagicReplayModuleEvent = require("NewRoco.Modules.System.MagicReplay.MagicReplayModuleEvent")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local MagicReplayUtils = require("NewRoco.Modules.System.MagicReplay.MagicReplayUtils")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local MagicReplayActionBase = require("NewRoco.Modules.System.MagicReplay.Action.MagicReplayActionBase")
local FunctionBanModuleCmd = require("NewRoco.Modules.System.FunctionBan.FunctionBanModuleCmd")
local CreatePlayerModuleCmd = require("NewRoco.Modules.System.CreatePlayerModule.CreatePlayerModuleCmd")
local Base = MagicReplayActionBase
local MagicReplayIdleAction = Base:Extend("MagicReplayIdleAction")
FsmUtils.MergeMembers(Base, MagicReplayIdleAction, {
  {name = "CurrentOp", type = "var"}
})

function MagicReplayIdleAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function MagicReplayIdleAction:OnEnter()
  self:InjectProperties()
  self.fsm:SetProperty("CurrentOp", MagicReplayModuleEnum.ModuleOpType.Other)
  self.fsm:Pause()
end

function MagicReplayIdleAction:OnExit()
  self.fsm:Resume()
end

return MagicReplayIdleAction
