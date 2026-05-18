local MagicReplayModuleEvent = require("NewRoco.Modules.System.MagicReplay.MagicReplayModuleEvent")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local MagicReplayUtils = require("NewRoco.Modules.System.MagicReplay.MagicReplayUtils")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local MagicReplayActionBase = require("NewRoco.Modules.System.MagicReplay.Action.MagicReplayActionBase")
local FunctionBanModuleCmd = require("NewRoco.Modules.System.FunctionBan.FunctionBanModuleCmd")
local CreatePlayerModuleCmd = require("NewRoco.Modules.System.CreatePlayerModule.CreatePlayerModuleCmd")
local Base = MagicReplayActionBase
local MagicReplayStartPreviewCamAction = Base:Extend("MagicReplayStartPreviewCamAction")
FsmUtils.MergeMembers(Base, MagicReplayStartPreviewCamAction, {})

function MagicReplayStartPreviewCamAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function MagicReplayStartPreviewCamAction:OnEnter()
  self:InjectProperties()
  self.localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  self.playerCameraManager = self.localPlayer:GetUEController().PlayerCameraManager
  if self.playerCameraManager and self.localPlayer.viewObj then
    self.playerCameraManager:BeginFilming(self.localPlayer.viewObj)
  end
  self:Finish()
end

function MagicReplayStartPreviewCamAction:OnExit()
end

return MagicReplayStartPreviewCamAction
