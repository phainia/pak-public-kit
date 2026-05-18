local WorldCombatBuffBase = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatBuffBase")
local WeakPointRevealComponent = require("NewRoco.Modules.Core.Scene.Component.Boss.WeakPointRevealComponent")
local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local Base = WorldCombatBuffBase
local WorldCombatBuffWeaknessExpose = Base:Extend("WorldCombatBuffWeaknessExpose")

function WorldCombatBuffWeaknessExpose:Ctor(Parent, Buff, Conf)
  Base.Ctor(self, Parent, Buff, Conf)
end

function WorldCombatBuffWeaknessExpose:OnInit()
  Base.OnInit(self)
  local ownerView = self:GetBuffOwnerView()
  self:ShowWeakness(true)
end

function WorldCombatBuffWeaknessExpose:OnAdd()
  local ownerView = self:GetBuffOwnerView()
  self:ShowWeakness(false)
end

function WorldCombatBuffWeaknessExpose:OnRemove()
  self:OnInvisible()
end

function WorldCombatBuffWeaknessExpose:ShowWeakness(is_restore)
  local OwnerShieldComponent = self.Parent.owner:EnsureComponent(WeakPointRevealComponent)
  Log.Debug("\229\177\149\231\164\186\229\188\177\231\130\185", table.tostring(self.Info))
  OwnerShieldComponent:ShowWeakness(self.Info.str_params_list, self.Info.int_params_list, is_restore)
end

function WorldCombatBuffWeaknessExpose:OnInvisible()
  local parentOwner = self.Parent and self.Parent.owner
  local OwnerShieldComponent = parentOwner and parentOwner:GetComponent(WeakPointRevealComponent)
  if OwnerShieldComponent then
    OwnerShieldComponent:RemoveWeakness()
    parentOwner:RemoveComponent(OwnerShieldComponent)
  end
end

return WorldCombatBuffWeaknessExpose
