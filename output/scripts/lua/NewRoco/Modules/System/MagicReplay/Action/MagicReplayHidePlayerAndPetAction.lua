local MagicReplayModuleEvent = require("NewRoco.Modules.System.MagicReplay.MagicReplayModuleEvent")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local MagicReplayUtils = require("NewRoco.Modules.System.MagicReplay.MagicReplayUtils")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local MagicReplayActionBase = require("NewRoco.Modules.System.MagicReplay.Action.MagicReplayActionBase")
local FunctionBanModuleCmd = require("NewRoco.Modules.System.FunctionBan.FunctionBanModuleCmd")
local NPCModuleEnum = require("NewRoco.Modules.Core.NPC.NPCModuleEnum")
local Base = MagicReplayActionBase
local MagicReplayHidePlayerAndPetAction = Base:Extend("MagicReplayHidePlayerAndPetAction")
FsmUtils.MergeMembers(Base, MagicReplayHidePlayerAndPetAction, {})

function MagicReplayHidePlayerAndPetAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function MagicReplayHidePlayerAndPetAction:OnEnter()
  self:InjectProperties()
  self.localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  self.localPlayerId = self.localPlayer.serverData.base.actor_id
  _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.ShowOwnPetByPlayerId, self.localPlayerId, false, NPCModuleEnum.NpcReasonFlags.MAGIC_REPLAY)
  _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.HideOrShowTypingBubbleInfo, true, self.localPlayer.serverData.base.logic_id)
  _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.OnCmdSwitchChatBubbles, self.localPlayer.viewObj, false)
  _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.HIDE_LOCAL_PLAYER, true, UE4.EPlayerForceHiddenType.MagicReplay)
  _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.HIDE_OTHER_PLAYER, true, UE4.EPlayerForceHiddenType.MagicReplay)
  self:Finish()
end

return MagicReplayHidePlayerAndPetAction
