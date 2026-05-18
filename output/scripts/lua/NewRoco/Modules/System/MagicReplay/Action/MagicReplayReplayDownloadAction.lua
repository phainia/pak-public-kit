local MagicReplayModuleEnum = require("NewRoco.Modules.System.MagicReplay.MagicReplayModuleEnum")
local MagicReplayModuleEvent = require("NewRoco.Modules.System.MagicReplay.MagicReplayModuleEvent")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local MagicReplayUtils = require("NewRoco.Modules.System.MagicReplay.MagicReplayUtils")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local MagicReplayActionBase = require("NewRoco.Modules.System.MagicReplay.Action.MagicReplayActionBase")
local FunctionBanModuleCmd = require("NewRoco.Modules.System.FunctionBan.FunctionBanModuleCmd")
local CreatePlayerModuleCmd = require("NewRoco.Modules.System.CreatePlayerModule.CreatePlayerModuleCmd")
local MagicReplayModuleCmd = require("NewRoco.Modules.System.MagicReplay.MagicReplayModuleCmd")
local Base = MagicReplayActionBase
local MagicReplayReplayDownloadAction = Base:Extend("MagicReplayReplayDownloadAction")
FsmUtils.MergeMembers(Base, MagicReplayReplayDownloadAction, {
  {
    name = "ParentModule",
    type = "var"
  },
  {name = "CurrentOp", type = "var"},
  {
    name = "ReplayFileName",
    type = "var"
  }
})

function MagicReplayReplayDownloadAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function MagicReplayReplayDownloadAction:OnEnter()
  self:InjectProperties()
  self.fileName = self.fsm:GetProperty("FileName")
  self.ParentModule = self.fsm:GetProperty("ParentModule")
  local feedDetail, npc_id = _G.NRCModeManager:DoCmd(MagicReplayModuleCmd.GetReplayFeedDetail)
  _G.NRCModeManager:DoCmd(_G.MagicReplayModuleCmd.OpenReplayPanel, feedDetail)
  self.fsm:SetProperty("CurrentOp", MagicReplayModuleEnum.ModuleOpType.Replay)
  self.fsm:Pause()
  local NPC = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, npc_id)
  if NPC and NPC.viewObj and NPC.viewObj.ActivateMagicReplayCheck then
    NPC.viewObj:ActivateMagicReplayCheck()
  end
  _G.NRCModeManager:DoCmd(MagicReplayModuleCmd.ReqDownloadReplay, feedDetail.feed_video_info, self, self.OnDownloadFinish)
end

function MagicReplayReplayDownloadAction:OnDownloadFinish(fileName, isSuccess)
  self.fsm:SetProperty("ReplayFileName", fileName)
  if isSuccess then
    self.fsm:Resume()
    self:Finish()
  else
    Log.Error("MagicReplayReplayDownloadAction:OnDownloadFinish failed", fileName)
    _G.NRCModeManager:DoCmd(MagicReplayModuleCmd.StopMagicReplay)
  end
end

function MagicReplayReplayDownloadAction:OnFinish()
  self.ParentModule:DispatchEvent(MagicReplayModuleEvent.OnFinishReplayDownload)
end

function MagicReplayReplayDownloadAction:OnExit()
end

return MagicReplayReplayDownloadAction
