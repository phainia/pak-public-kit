local Class = _G.MakeSimpleClass
local EventDispatcher = require("Common.EventDispatcher")
local ThrowSessionBase = Class("ThrowSessionBase")
ThrowSessionBase.CurrentID = 0
ThrowSessionBase:SetMemberCount(4)
EventDispatcher.BindClass(ThrowSessionBase)

function ThrowSessionBase:Ctor()
  EventDispatcher():Attach(self)
  self:SetSeqID(self:GetNewSessionId())
end

function ThrowSessionBase:SetSeqID(SeqID)
  self.SeqID = SeqID
end

function ThrowSessionBase:GetNewSessionId()
  ThrowSessionBase.CurrentID = ThrowSessionBase.CurrentID + 1
  return ThrowSessionBase.CurrentID
end

function ThrowSessionBase:SetOwnerId(owner_id)
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local localPlayerId = localPlayer.serverData.base.actor_id
  if owner_id then
    self.owner_id = owner_id
  else
    self.owner_id = localPlayerId
  end
  if self.owner_id == localPlayerId then
    self.is_local = true
  else
    self.is_local = false
  end
end

return ThrowSessionBase
