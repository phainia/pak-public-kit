local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local ActorComponent = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local Base = ActorComponent
local LogicStatusComponent = Base:Extend("LogicStatusComponent")
LogicStatusComponent.Debug = false

function LogicStatusComponent:Attach(owner)
  Base.Attach(self, owner)
  local ServerData = owner.serverData
  if ServerData then
    self:UpdateStatusInfo(ServerData.status_info)
  end
end

function LogicStatusComponent:GetStatus(StatusEnum)
  if not self.StatusInfo then
    return false
  end
  for _, Status in ipairs(self.StatusInfo) do
    if Status.status == StatusEnum then
      return true, Status.variant, Status.extra_data
    end
  end
  return false, nil, nil
end

function LogicStatusComponent:UpdateData(ServerData, isReconnect)
  self:UpdateStatusInfo(ServerData.status_info)
end

function LogicStatusComponent:UpdateStatusInfo(Info)
  local Changed = self.StatusInfo ~= Info
  self.StatusInfo = Info
  if Changed then
    self:DispatchUpdateEvents()
  end
end

function LogicStatusComponent:UpdateWithAction(Action)
  if not Action then
    return
  end
  if not Action.change_info then
    return
  end
  for _, Info in ipairs(Action.change_info) do
    self:UpdateByChangeInfo(Info)
  end
end

function LogicStatusComponent:UpdateByChangeInfo(ChangeInfo)
  if LogicStatusComponent.Debug then
    local Stat = ChangeInfo.changed_status
    if Stat then
      local Name = "Unknown"
      local owner = self.owner
      local serverData = owner and owner.serverData
      local BaseInfo = serverData and serverData.base
      if BaseInfo then
        Name = string.format("[%s] %s %u", owner.name, BaseInfo.name, BaseInfo.actor_id)
      end
      Log.Error(Name, table.getKeyName(Enum.LogicStatusOpType, ChangeInfo.op_type), table.getKeyName(Enum.SpaceActorLogicStatus, ChangeInfo.changed_status.status))
    end
  end
  if ChangeInfo.op_type == ProtoEnum.LogicStatusOpType.LSOT_ADD then
    if not self.StatusInfo then
      self.StatusInfo = {}
    end
    table.insert(self.StatusInfo, ChangeInfo.changed_status)
  elseif ChangeInfo.op_type == ProtoEnum.LogicStatusOpType.LSOT_UPDATE then
    local ID = ChangeInfo.changed_status.status
    for _, Status in ipairs(self.StatusInfo) do
      if ID == Status.status then
        Status.varaint = ChangeInfo.changed_status.varaint
        Status.extra_data = ChangeInfo.changed_status.extra_data
        break
      end
    end
  elseif ChangeInfo.op_type == ProtoEnum.LogicStatusOpType.LSOT_REMOVE then
    if not self.StatusInfo then
      return
    end
    for i = #self.StatusInfo, 1, -1 do
      local Status = self.StatusInfo[i]
      if Status.status == ChangeInfo.changed_status.status then
        table.remove(self.StatusInfo, i)
        break
      end
    end
  end
  self:DispatchUpdateEvents(ChangeInfo)
end

function LogicStatusComponent:DispatchUpdateEvents(ChangeInfo)
  if not self.owner then
    return
  end
  self.owner:SendEvent(NPCModuleEvent.OnLogicStatusUpdated, self.owner, ChangeInfo)
  local LuaObj = self.owner.luaObj
  if LuaObj then
    LuaObj:OnLogicStatusChange(ChangeInfo)
  end
  if self.owner.statusComponent then
    self.owner.statusComponent:OnLogicStatusChange(ChangeInfo)
  end
end

function LogicStatusComponent:GetSummary()
  local Payload = {}
  for _, Info in pairs(self.StatusInfo) do
    Payload[table.getKeyName(ProtoEnum.SpaceActorLogicStatus, Info.status)] = Info
  end
  return Payload
end

function LogicStatusComponent:DeAttach()
  self.StatusInfo = nil
  Base.DeAttach(self)
end

function LogicStatusComponent:Destroy()
  self.StatusInfo = nil
  Base.Destroy(self)
end

return LogicStatusComponent
