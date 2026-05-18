local MagicReplayModuleEvent = require("NewRoco.Modules.System.MagicReplay.MagicReplayModuleEvent")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local MagicReplayUtils = require("NewRoco.Modules.System.MagicReplay.MagicReplayUtils")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local MagicReplayActionBase = require("NewRoco.Modules.System.MagicReplay.Action.MagicReplayActionBase")
local FunctionBanModuleCmd = require("NewRoco.Modules.System.FunctionBan.FunctionBanModuleCmd")
local CreatePlayerModuleCmd = require("NewRoco.Modules.System.CreatePlayerModule.CreatePlayerModuleCmd")
local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local Base = MagicReplayActionBase
local MagicReplayRecordProcessResultAction = Base:Extend("MagicReplayRecordProcessResultAction")
FsmUtils.MergeMembers(Base, MagicReplayRecordProcessResultAction, {
  {
    name = "NeedWhiteScreen",
    type = "boolean"
  }
})

function MagicReplayRecordProcessResultAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function MagicReplayRecordProcessResultAction:OnEnter()
  self:InjectProperties()
  self.fsm:SetProperty("NeedWhiteScreen", false)
  _G.NRCModeManager:DoCmd(_G.MagicReplayModuleCmd.OnEnterPreviewState)
end

function MagicReplayRecordProcessResultAction:OnExit()
end

return MagicReplayRecordProcessResultAction
