local ActorComponent = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local PlayerAddHpComponent = ActorComponent:Extend("PlayerAddHpComponent")

function PlayerAddHpComponent:Ctor()
  ActorComponent.Ctor(self)
  self.registeredHealer = {}
  self.healerCount = 0
  self.healingState = false
  self.delayCancelHandle = nil
end

function PlayerAddHpComponent:Attach(owner)
  ActorComponent.Attach(self, owner)
end

function PlayerAddHpComponent:DeAttach()
  if self.delayCancelHandle then
    self:CancelHealing()
    self.delayCancelHandle = nil
  end
  self.registeredHealer = {}
  self.healerCount = 0
  self.healingState = false
  ActorComponent.DeAttach(self)
end

local npc_healing_cooldown = _G.DataConfigManager:GetNpcGlobalConfig("npc_behavior_close_recover_CD")

function PlayerAddHpComponent:RegisterHealer(npc)
  local id = npc:GetServerId()
  if self.registeredHealer[id] then
    return
  end
  self.registeredHealer[id] = true
  self.healerCount = self.healerCount + 1
  if self.delayCancelHandle then
    _G.DelayManager:CancelDelayById(self.delayCancelHandle)
    self.delayCancelHandle = nil
  end
  self:BeginHealing()
end

function PlayerAddHpComponent:UnregisterHealer(npc)
  local id = npc:GetServerId()
  if self.registeredHealer[id] then
    self.registeredHealer[id] = nil
    self.healerCount = self.healerCount - 1
    if 0 == self.healerCount then
      self:DelayCancelHealing()
    end
  end
end

function PlayerAddHpComponent:BeginHealing()
  if self.healingState then
    return
  end
  local player = self.owner
  local info = _G.ProtoMessage:newClientAiCommandInfo()
  info.actor_id = player:GetServerId()
  info.action_id = _G.ProtoEnum.NpcSceneCommandType.NSC_REQ_ADD_PLAYER_HP
  _G.SceneAIUtils.GetSceneAIManager():EnqueueMessage_SceneCommand(info)
  self.healingState = true
end

function PlayerAddHpComponent:CancelHealing()
  if not self.healingState then
    return
  end
  local player = self.owner
  local info = _G.ProtoMessage:newClientAiCommandInfo()
  info.actor_id = player:GetServerId()
  info.action_id = _G.ProtoEnum.NpcSceneCommandType.NSC_CANCEL_ADD_PLAYER_HP
  _G.SceneAIUtils.GetSceneAIManager():EnqueueMessage_SceneCommand(info)
  self.healingState = false
end

function PlayerAddHpComponent:DelayCancelHealing()
  if self.delayCancelHandle == nil then
    self.delayCancelHandle = _G.DelayManager:DelaySeconds(1, self.CancelHealing, self)
  end
end

return PlayerAddHpComponent
