local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local AttacheeComponent = require("NewRoco.Modules.Core.Scene.Component.Pendant.AttacheeComponent")
local ActorComponent = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local Base = ActorComponent
local PendantComponent = Base:Extend("PendantComponent")

function PendantComponent:Attach(owner)
  Base.Attach(self, owner)
  self.pendantGroups = {}
  self:InitPendant(owner.serverData)
end

local PendantGroup

function PendantComponent.newPendantGroup()
  return {
    enabled = false,
    cfg = nil,
    pendantItems = setmetatable({}, {__mode = "v"}),
    pendantStates = {}
  }
end

function PendantComponent:UpdateData(ServerData, isReconnect)
  Base.UpdateData(self, ServerData, isReconnect)
  if isReconnect then
    self:ReleaseAllPendants()
    self:InitPendant(ServerData)
  end
end

function PendantComponent:InitPendant(serverData)
  if not serverData then
    return
  end
  self.pendantInfo = serverData.pendant_info
  if not self.pendantInfo then
    return
  end
  for _, pendantGroupInfo in ipairs(self.pendantInfo) do
    local group = PendantComponent.newPendantGroup()
    group.enabled = pendantGroupInfo.enabled
    group.cfg = _G.DataConfigManager:GetNpcPendantConf(pendantGroupInfo.pendant_cfg_id)
    group.info = pendantGroupInfo
    for _, pendantItemInfo in ipairs(pendantGroupInfo.pendant_item_infos) do
      group.pendantStates[pendantItemInfo.id] = pendantItemInfo.status
    end
    table.insert(self.pendantGroups, group)
    if group.enabled then
      self.d_ApplyState = _G.DelayManager:DelayFrames(1, self.PrepareChangeListAndApply, self)
    end
  end
  self.owner:SendEvent(NPCModuleEvent.PendantGroupStateChanged, self)
end

function PendantComponent:PrepareChangeListAndApply()
  if not self.owner or self.owner.isDestroy then
    return
  end
  local init_change_list = {}
  for _, group in ipairs(self.pendantGroups) do
    if group.enabled then
      for _, pendantItemInfo in ipairs(group.info.pendant_item_infos) do
        table.insert(init_change_list, {
          id = pendantItemInfo.id,
          status = pendantItemInfo.status
        })
      end
      self:ApplyGroupChange(group, true, init_change_list)
    end
  end
end

function PendantComponent:UpdateGroupInfo(changeInfo)
  local pendant_group
  local pendant_group_idx = 1
  for idx, group in ipairs(self.pendantGroups) do
    if group.cfg.id == changeInfo.pendant_cfg_id then
      pendant_group = group
      pendant_group_idx = idx
      break
    end
  end
  if pendant_group then
    self:ApplyGroupChange(pendant_group, changeInfo.enable, changeInfo.changed_pendant_item_infos or {})
  end
  self.owner:SendEvent(NPCModuleEvent.PendantGroupStateChanged, self)
end

function PendantComponent:ApplyGroupChange(group, enable, changedItems, debug)
  group.enabled = enable
  for _, changed_item in ipairs(changedItems) do
    group.pendantStates[changed_item.id] = changed_item.status
  end
  if group.enabled then
    for id, state in ipairs(group.pendantStates) do
      local pendant_npc = group.pendantItems[id]
      if not pendant_npc or pendant_npc.isDestroy then
        local create_point = group.info.pendant_item_infos[id].point
        local ActorInfo = _G.ProtoMessage:newActorInfo_Npc()
        if ActorInfo.base then
          ActorInfo.base.actor_id = NRCModuleManager:DoCmd(NPCModuleCmd.AcquireFakeID)
          ActorInfo.base.logic_id = ActorInfo.base.actor_id
          ActorInfo.base.lv = 0
          if create_point and create_point.pos then
            ActorInfo.base.pt.pos = create_point.pos
          else
            ActorInfo.base.pt.pos.x = 0
            ActorInfo.base.pt.pos.y = 0
            ActorInfo.base.pt.pos.z = 0
          end
          if create_point and create_point.dir then
            ActorInfo.base.pt.dir.z = create_point.dir.z
          else
            ActorInfo.base.pt.dir.z = 0
            ActorInfo.base.pt.dir.x = 0
            ActorInfo.base.pt.dir.y = 0
          end
        end
        if ActorInfo.npc_base then
          ActorInfo.npc_base.npc_cfg_id = group.cfg.npc_id
          ActorInfo.npc_base.src_npc_ref_cfg_id = self.owner:GetContentId()
        end
        pendant_npc = NRCModuleManager:DoCmd(NPCModuleCmd.CreateLocalNPCWithActorInfo, ActorInfo, PriorityEnum.Active_Player_Action)
        if debug then
          UE.UKismetSystemLibrary.Abs_DrawDebugSphere(self:GetOwnerView(), UE.FVector(create_point.pos.x, create_point.pos.y, create_point.pos.z), group.cfg.distance, 8, UE.FLinearColor(1, 0, 0, 1), 60, 2)
        end
        local comp = pendant_npc:EnsureComponent(AttacheeComponent)
        comp:InitByAttacher(self.owner, group, id, state)
        group.pendantItems[id] = pendant_npc
      end
      local Comp = group.pendantItems[id]:EnsureComponent(AttacheeComponent)
      Comp:SetState(state)
    end
  else
    if group.pendantStates then
      for id, state in pairs(group.pendantStates) do
        local Attachee = group.pendantItems[id]
        local Comp = Attachee and Attachee:EnsureComponent(AttacheeComponent)
        if Comp then
          Comp:SetState(state)
        else
          Log.Error("Component is gone", id)
        end
      end
    end
    for id, item in pairs(group.pendantItems) do
      local attacheeComp = item:GetComponent(AttacheeComponent)
      if attacheeComp then
        attacheeComp:Disappear()
      else
        Log.Error("Component is gone", id)
      end
    end
    group.pendantItems = {}
  end
end

function PendantComponent:DeAttach()
  self:ReleaseAllPendants()
end

function PendantComponent:ReleaseAllPendants()
  for _, pendantGroup in ipairs(self.pendantGroups) do
    for id, pendant_item in pairs(pendantGroup.pendantItems) do
      pendant_item:Disappear(true)
    end
  end
  self.pendantGroups = {}
  if self.d_ApplyState then
    _G.DelayManager:CancelDelayById(self.d_ApplyState)
    self.d_ApplyState = nil
  end
end

function PendantComponent:HasGroupEnabled()
  local Enabled = false
  for _, Group in ipairs(self.pendantGroups) do
    if Group.enabled then
      Enabled = true
      break
    end
  end
  return Enabled
end

function PendantComponent:IsAllCollected()
  for _, Group in ipairs(self.pendantGroups) do
    local States = Group.pendantStates
    for _, State in pairs(States) do
      if State ~= ProtoEnum.PendantItemStatus.PIS_DISABLE and State ~= ProtoEnum.PendantItemStatus.PIS_TRANSPARENT then
        return false
      end
    end
  end
  return true
end

return PendantComponent
