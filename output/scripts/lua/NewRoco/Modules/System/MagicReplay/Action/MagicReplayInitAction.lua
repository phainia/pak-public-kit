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
local MagicReplayInitAction = Base:Extend("MagicReplayInitAction")
FsmUtils.MergeMembers(Base, MagicReplayInitAction, {
  {name = "OpType", type = "var"},
  {name = "CurrentOp", type = "var"}
})

function MagicReplayInitAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function MagicReplayInitAction:OnEnter()
  self:InjectProperties()
  local opType = self.fsm:GetProperty("OpType")
  if opType == MagicReplayModuleEnum.ModuleOpType.Record then
    _G.NRCModeManager:DoCmd(_G.MagicReplayModuleCmd.OnEnterRecordState)
  elseif opType == MagicReplayModuleEnum.ModuleOpType.Preview then
    _G.NRCModeManager:DoCmd(_G.MagicReplayModuleCmd.OnEnterPreviewState)
  elseif opType == MagicReplayModuleEnum.ModuleOpType.Replay then
    _G.NRCModeManager:DoCmd(_G.MagicReplayModuleCmd.OnEnterReplayState)
  end
  self.fsm:SetProperty("CurrentOp", MagicReplayModuleEnum.ModuleOpType.Other)
end

function MagicReplayInitAction:OnExit()
end

return MagicReplayInitAction
