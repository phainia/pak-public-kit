local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local WorldCombatBuffRes = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatBuffRes")
local WorldCombatBuffBase = Class("WorldCombatBuffBase")

function WorldCombatBuffBase:Ctor(Parent, Buff, Conf)
  self.Parent = Parent
  self.Caster = _G.NPCModuleCmd and _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, Buff.add_buff_caster_id) or self.Parent.owner
  self.ID = Buff.id
  self.Info = Buff
  self.Config = Conf
  self.ManagedRes = {}
end

function WorldCombatBuffBase:OnInit()
  self:CreateOptions(false)
  local Owner = self:GetBuffOwner()
  if Owner then
    if WorldCombatBuffBase.OnVisible ~= self.OnVisible then
      Owner:AddEventListener(self, NPCModuleEvent.OnViewVisible, self.OnVisible)
    end
    if WorldCombatBuffBase.OnInvisible ~= self.OnInvisible then
      Owner:AddEventListener(self, NPCModuleEvent.OnViewInvisible, self.OnInvisible)
    end
  end
end

function WorldCombatBuffBase:OnAdd(Reason)
  self:CreateOptions(true)
end

function WorldCombatBuffBase:InternalUpdate(Value, Reason)
  local New = Value
  local Old = self.Info
  self.Info = New
  self:OnUpdate(New, Old, Reason)
end

function WorldCombatBuffBase:OnUpdate(NewValue, OldValue, Reason)
  self:UpdateOptions(NewValue, OldValue, Reason)
end

function WorldCombatBuffBase:OnRemove(Reason)
  self:ClearOptions()
  local Owner = self:GetBuffOwner()
  if Owner then
    if WorldCombatBuffBase.OnVisible ~= self.OnVisible then
      Owner:RemoveEventListener(self, NPCModuleEvent.OnViewVisible, self.OnVisible)
    end
    if WorldCombatBuffBase.OnInvisible ~= self.OnInvisible then
      Owner:RemoveEventListener(self, NPCModuleEvent.OnViewInvisible, self.OnInvisible)
    end
  end
end

function WorldCombatBuffBase:GetBuffOwner()
  return self.Parent and self.Parent.owner
end

function WorldCombatBuffBase:GetBuffOwnerView()
  local Owner = self:GetBuffOwner()
  return Owner and Owner.viewObj
end

function WorldCombatBuffBase:OnVisible()
end

function WorldCombatBuffBase:OnInvisible()
end

function WorldCombatBuffBase:CreateOptions(JustAttached)
  local Options = self.Config.option
  if not Options then
    return
  end
  if 0 == #Options then
    return
  end
  for Index, Option in ipairs(Options) do
    local Res = self.ManagedRes[Index]
    if not Res then
      Res = WorldCombatBuffRes(self, Index, Option)
      self.ManagedRes[Index] = Res
    end
  end
  if JustAttached then
    for _, Res in pairs(self.ManagedRes) do
      Res:OnAdd()
    end
  else
    for _, Res in pairs(self.ManagedRes) do
      Res:OnInit()
    end
  end
end

function WorldCombatBuffBase:UpdateOptions(NewValue, OldValue)
  for _, Res in pairs(self.ManagedRes) do
    Res:OnUpdate(NewValue, OldValue)
  end
end

function WorldCombatBuffBase:ClearOptions()
  for _, Res in pairs(self.ManagedRes) do
    Res:OnRemove()
  end
  table.clear(self.ManagedRes)
end

function WorldCombatBuffBase:ToString()
  return string.format("[%s] %d %d %s %s", table.getKeyName(Enum.WorldBuffType, self.Config.buff_type or Enum.WorldBuffType.WBT_Normal), self.ID, self.Config.id, self.Config.buff_name or "None", table.getKeyName(Enum.WorldBuffEffect, self.Config.buff_effect_type))
end

return WorldCombatBuffBase
