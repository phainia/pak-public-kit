local MagicReplayModuleEvent = require("NewRoco.Modules.System.MagicReplay.MagicReplayModuleEvent")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local MagicReplayUtils = require("NewRoco.Modules.System.MagicReplay.MagicReplayUtils")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local MagicReplayActionBase = require("NewRoco.Modules.System.MagicReplay.Action.MagicReplayActionBase")
local FunctionBanModuleCmd = require("NewRoco.Modules.System.FunctionBan.FunctionBanModuleCmd")
local CreatePlayerModuleCmd = require("NewRoco.Modules.System.CreatePlayerModule.CreatePlayerModuleCmd")
local NPCModuleEnum = require("NewRoco.Modules.Core.NPC.NPCModuleEnum")
local Base = MagicReplayActionBase
local MagicReplayPreviewMainAction = Base:Extend("MagicReplayPreviewMainAction")
FsmUtils.MergeMembers(Base, MagicReplayPreviewMainAction, {
  {
    name = "NeedWhiteScreen",
    type = "boolean"
  }
})

function MagicReplayPreviewMainAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function MagicReplayPreviewMainAction:OnEnter()
  self:InjectProperties()
  self.fsm:SetProperty("NeedWhiteScreen", false)
  self.switchCam = false
  self.isLoopEnd = false
  self.localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  _G.NRCEventCenter:RegisterEvent("MagicReplayPreviewMainAction", self, MagicReplayModuleEvent.OnMagicSeqPlayerSpawned, self.OnMagicSeqPlayerSpawned)
  _G.NRCEventCenter:RegisterEvent("MagicReplayPreviewMainAction", self, MagicReplayModuleEvent.OnMagicSeqPreviewEnd, self.OnMagicSeqPreviewEnd)
  _G.NRCEventCenter:RegisterEvent("MagicReplayPreviewMainAction", self, MagicReplayModuleEvent.OnManualStopPreview, self.OnManualStopPreview)
  _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.OnCmdUseUMGChatBubblesParent, self, true)
  _G.NRCModuleManager:DoCmd(_G.MagicReplayModuleCmd.StartPreview)
  self.fsm:Pause()
end

function MagicReplayPreviewMainAction:OnMagicSeqPlayerSpawned()
  if self.switchCam then
    return
  end
  self.playerCameraManager = self.localPlayer:GetUEController().PlayerCameraManager
  if self.playerCameraManager then
    local main_actor_id = _G.NRCModuleManager:DoCmd(_G.MagicReplayModuleCmd.GetMainMagicActorId)
    if main_actor_id then
      local main_player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GetPlayerByServerID, main_actor_id)
      if main_player and main_player.viewObj then
        self.playerCameraManager:BeginFilming(main_player.viewObj, true)
        self.switchCam = true
      end
    end
  end
end

function MagicReplayPreviewMainAction:OnMagicSeqPreviewEnd()
  self.fsm:SetProperty("NeedWhiteScreen", false)
  self.isLoopEnd = true
  _G.NRCModeManager:DoCmd(_G.MagicReplayModuleCmd.OnEnterPreviewState)
end

function MagicReplayPreviewMainAction:OnManualStopPreview()
  _G.NRCModeManager:DoCmd(_G.MagicReplayModuleCmd.CloseRecordPanel)
  _G.NRCModeManager:DoCmd(_G.MagicReplayModuleCmd.CloseToolExitButtonPopup)
  _G.NRCModeManager:DoCmd(_G.MagicReplayModuleCmd.CloseToolRestartButtonPopup)
  self.fsm:SetProperty("NeedWhiteScreen", true)
  self.fsm:Resume()
  self:Finish()
end

function MagicReplayPreviewMainAction:OnFinish()
  self:Clear()
end

function MagicReplayPreviewMainAction:OnExit()
  if not self.isLoopEnd then
    self.fsm:SetProperty("NeedWhiteScreen", true)
  end
  if self.finished then
    return
  end
  self:Clear()
end

function MagicReplayPreviewMainAction:Clear()
  _G.NRCEventCenter:UnRegisterEvent(self, MagicReplayModuleEvent.OnMagicSeqPlayerSpawned, self.OnMagicSeqPlayerSpawned)
  _G.NRCEventCenter:UnRegisterEvent(self, MagicReplayModuleEvent.OnMagicSeqPreviewEnd, self.OnMagicSeqPreviewEnd)
  _G.NRCEventCenter:UnRegisterEvent(self, MagicReplayModuleEvent.OnManualStopPreview, self.OnManualStopPreview)
  self.switchCam = false
  _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.OnCmdUseUMGChatBubblesParent, self, false)
  _G.NRCModuleManager:DoCmd(_G.MagicReplayModuleCmd.StopPreview)
end

return MagicReplayPreviewMainAction
