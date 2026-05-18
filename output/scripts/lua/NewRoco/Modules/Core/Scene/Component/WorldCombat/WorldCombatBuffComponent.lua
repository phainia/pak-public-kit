local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local WorldCombatBuffFactory = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatBuffFactory")
local ActorComponent = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local Base = ActorComponent
local WorldCombatBuffComponent = Base:Extend("WorldCombatBuffComponent")
WorldCombatBuffComponent.Debug = false

function WorldCombatBuffComponent:Attach(owner)
  Base.Attach(self, owner)
  self.Buffs = {}
  self:InitBuffs(self:GetRawBuffData())
  self.owner:SendEvent(NPCModuleEvent.OnBuffUpdated)
end

function WorldCombatBuffComponent:InitBuffs(BuffInfo)
  if not BuffInfo then
    return
  end
  local RawBuffs = BuffInfo.buff_infos
  if not RawBuffs then
    return
  end
  if 0 == #RawBuffs then
    return
  end
  for _, Buff in ipairs(RawBuffs) do
    self:Insert(Buff)
  end
  for _, Buff in pairs(self.Buffs) do
    Buff:OnInit()
  end
  local Owner = self:GetOwner()
  local serverData = Owner and Owner.serverData
  local actor_id = serverData and serverData.base.actor_id
  _G.NRCModuleManager:DoCmd(_G.SceneModuleCmd.ConsumeCachedActorTag, actor_id)
end

function WorldCombatBuffComponent:UpdateData(ServerData, isReconnect)
  Base.UpdateData(self, ServerData, isReconnect)
  local BuffInfo = ServerData.buff_info
  local BuffInfos = BuffInfo and BuffInfo.buff_infos
  local BuffChanged = false
  if not BuffInfos or 0 == #BuffInfos then
    for _, Buff in pairs(self.Buffs) do
      Buff:OnRemove()
      BuffChanged = true
    end
    table.clear(self.Buffs)
  else
    for _, Buff in pairs(self.Buffs) do
      Buff.BuffDeleteFlag = true
    end
    for _, Info in ipairs(BuffInfos) do
      local Buff = self.Buffs[Info.id]
      if not Buff then
        Buff = self:Insert(Info)
        if Buff then
          Buff:OnAdd()
          Buff.BuffDeleteFlag = false
          BuffChanged = true
        else
          Log.Error("\230\183\187\229\138\160Buff\229\164\177\232\180\165", Info.id, Info.buff_cfg_id, Info.add_buff_caster_id, self.owner:DebugNPCNameAndID())
        end
      else
        Buff:InternalUpdate(Info)
        Buff.BuffDeleteFlag = false
      end
    end
    local BuffToDelete = {}
    for _, Buff in pairs(self.Buffs) do
      if Buff.BuffDeleteFlag then
        table.insert(BuffToDelete, Buff)
      end
    end
    for _, Buff in ipairs(BuffToDelete) do
      Buff:OnRemove()
      self.Buffs[Buff.ID] = nil
      BuffChanged = true
    end
  end
  if BuffChanged then
    self.owner:SendEvent(NPCModuleEvent.OnBuffUpdated)
  end
end

function WorldCombatBuffComponent:Insert(Info)
  local NewBuff = WorldCombatBuffFactory.TryCreateBuff(self, Info)
  if NewBuff then
    self.Buffs[Info.id] = NewBuff
  end
  return NewBuff
end

function WorldCombatBuffComponent:OnBuffChanges(Change)
  if not Change then
    return
  end
  local AddOrRemoved = false
  local ChangeInfo = Change and Change.changed_buff_info
  if not ChangeInfo and Change and Change.buff_info and #Change.buff_info > 0 then
    ChangeInfo = Change.buff_info[1]
  end
  if ChangeInfo then
    local Current = self.Buffs[ChangeInfo.id]
    if Current then
      Current:InternalUpdate(ChangeInfo, Change.buff_changed_reason)
      self:DumpDebug("\230\155\180\230\150\176Buff", Current)
    else
      local Buff = self:Insert(ChangeInfo)
      if Buff then
        Buff:OnAdd(Change.buff_changed_reason)
        AddOrRemoved = true
        self:DumpDebug("\230\183\187\229\138\160Buff", Buff)
      else
        Log.Error("\230\183\187\229\138\160Buff\229\164\177\232\180\165", ChangeInfo.id, ChangeInfo.buff_cfg_id)
      end
    end
  end
  local RemoveID = Change and Change.removed_buff_id
  local RemoveBuff = RemoveID and self.Buffs[RemoveID]
  if RemoveBuff then
    self.Buffs[RemoveID] = nil
    RemoveBuff:OnRemove(Change.buff_changed_reason)
    AddOrRemoved = true
    self:DumpDebug("\231\167\187\233\153\164Buff", RemoveBuff)
  end
  if AddOrRemoved then
    self.owner:SendEvent(NPCModuleEvent.OnBuffUpdated)
  end
end

function WorldCombatBuffComponent:DeAttach()
  Base.DeAttach(self)
  for _, Buff in pairs(self.Buffs) do
    Buff:OnRemove()
  end
  table.clear(self.Buffs)
end

function WorldCombatBuffComponent:Destroy()
  Base.Destroy(self)
end

function WorldCombatBuffComponent:HasBuff(ID)
  if not ID or 0 == ID then
    return false
  end
  return self.Buffs[ID] ~= nil
end

function WorldCombatBuffComponent:HasBuffOfType(type)
  if self.Buffs then
    for _, buff in pairs(self.Buffs) do
      local confId = buff.Info.buff_cfg_id
      if confId and 0 ~= confId then
        local Conf = _G.DataConfigManager:GetWorldBuffConf(confId)
        if Conf then
          local EffectType = Conf and Conf.buff_effect_type
          if EffectType == type then
            return true
          end
        end
      end
    end
  end
  return false
end

function WorldCombatBuffComponent:GetRawBuffData()
  local owner = self.owner
  local serverData = owner and owner.serverData
  return serverData and serverData.buff_info
end

function WorldCombatBuffComponent:DumpDebug(Operation, Buff)
  if not WorldCombatBuffComponent.Debug then
    return
  end
  local Name = "Unknown"
  local owner = self.owner
  local serverData = owner and owner.serverData
  local BaseInfo = serverData and serverData.base
  if BaseInfo then
    Name = string.format("[%s] %s %u", owner.name, BaseInfo.name, BaseInfo.actor_id)
  end
  Log.Error(Name, Operation, Buff:ToString())
end

return WorldCombatBuffComponent
