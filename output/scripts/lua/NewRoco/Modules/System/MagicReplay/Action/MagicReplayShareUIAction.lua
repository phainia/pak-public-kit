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
local MagicReplayShareUIAction = Base:Extend("MagicReplayShareUIAction")
FsmUtils.MergeMembers(Base, MagicReplayShareUIAction, {
  {name = "CurrentOp", type = "var"},
  {
    name = "NeedWhiteScreen",
    type = "boolean"
  }
})

function MagicReplayShareUIAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function MagicReplayShareUIAction:OnEnter()
  self:InjectProperties()
  _G.NRCModeManager:DoCmd(_G.MagicReplayModuleCmd.CloseRecordPanel)
  _G.NRCModeManager:DoCmd(_G.MagicReplayModuleCmd.CloseToolExitButtonPopup)
  _G.NRCModeManager:DoCmd(_G.MagicReplayModuleCmd.CloseToolRestartButtonPopup)
  self.fsm:SetProperty("CurrentOp", MagicReplayModuleEnum.ModuleOpType.Share)
  self.fsm:SetProperty("NeedWhiteScreen", true)
  local initFeedInfo = _G.NRCModeManager:DoCmd(_G.MagicReplayModuleCmd.GetRecordFeedInitInfo)
  _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.OpenCreateMagicMessage, initFeedInfo)
  self.fsm:Pause()
end

function MagicReplayShareUIAction:OnExit()
end

return MagicReplayShareUIAction
