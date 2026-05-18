local ActorComponent = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local Base = ActorComponent
local ChatBubbleComponent = Base:Extend("ChatBubbleComponent")

function ChatBubbleComponent:Ctor()
  Base.Ctor(self)
end

function ChatBubbleComponent:Attach(owner)
  Base.Attach(self, owner)
  self:AddEventListener()
end

function ChatBubbleComponent:DeAttach()
  self:RemoveEventListener()
  Base.DeAttach(self)
end

function ChatBubbleComponent:Destroy()
  self:RemoveEventListener()
  Base.Destroy(self)
end

function ChatBubbleComponent:AddEventListener()
  self.owner:AddEventListener(self, PlayerModuleEvent.ON_AVATAR_READY, self.OnLogicStatusUpdated)
  self.owner:AddEventListener(self, NPCModuleEvent.OnLogicStatusUpdated, self.OnLogicStatusUpdated)
end

function ChatBubbleComponent:RemoveEventListener()
  if self.owner then
    self.owner:RemoveEventListener(self, PlayerModuleEvent.ON_AVATAR_READY, self.OnLogicStatusUpdated)
    self.owner:RemoveEventListener(self, NPCModuleEvent.OnLogicStatusUpdated, self.OnLogicStatusUpdated)
  end
end

function ChatBubbleComponent:OnLogicStatusUpdated()
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if player and self.owner.serverData.base and self.owner.serverData.base.actor_id == player.serverData.base.actor_id then
    return
  end
  local IsBlack = _G.DataModelMgr.PlayerDataModel:CheckHasBlackByPlayerUin(self.owner.serverData.base.logic_id)
  if IsBlack then
    if self:ShouldShowBubble() then
      _G.NRCModuleManager:DoCmd(FriendModuleCmd.HideOrShowTypingBubbleInfo, true, self.owner.serverData.base.logic_id)
    end
    return
  end
  if self:ShouldShowBubble() then
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.HideOrShowTypingBubbleInfo, false, self.owner.serverData.base.logic_id)
  else
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.HideOrShowTypingBubbleInfo, true, self.owner.serverData.base.logic_id)
  end
end

function ChatBubbleComponent:ShouldShowBubble()
  if not self.owner:IsLogicStatus(_G.Enum.SpaceActorLogicStatus.SALS_MSG_INPUT) then
    return false
  end
  return true
end

return ChatBubbleComponent
