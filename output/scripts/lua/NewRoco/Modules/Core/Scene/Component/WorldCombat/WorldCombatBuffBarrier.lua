local WorldCombatBuffBase = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatBuffBase")
local ShieldComponent = require("NewRoco.Modules.Core.Scene.Component.Boss.ShieldComponent")
local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local WeakPointRevealComponent = require("NewRoco.Modules.Core.Scene.Component.Boss.WeakPointRevealComponent")
local Base = WorldCombatBuffBase
local WorldCombatBuffBarrier = Base:Extend("WorldCombatBuffBarrier")

function WorldCombatBuffBarrier:Ctor(Parent, Buff, Conf)
  Base.Ctor(self, Parent, Buff, Conf)
end

function WorldCombatBuffBarrier:OnInit()
  Base.OnInit(self)
  Log.Debug("\229\136\157\229\167\139\229\140\150\233\154\156\229\163\129Buff", self.Info.buff_val, self.Config.params[1])
  self:ShowShield()
  self:UpdateBarrierState(true)
end

function WorldCombatBuffBarrier:OnAdd(Reason)
  Log.Debug("\230\183\187\229\138\160\233\154\156\229\163\129Buff", self.Info.buff_val, self.Config.params[1])
  self:ShowShield()
  self:UpdateBarrierState(true)
end

function WorldCombatBuffBarrier:OnRemove(Reason)
  Log.Debug("\231\167\187\233\153\164\233\154\156\229\163\129buff")
  local BuffOwner = self:GetBuffOwner()
  if BuffOwner then
    local OwnerShieldComponent = BuffOwner:EnsureComponent(ShieldComponent)
    if Reason == Enum.WorldBuffChangeReason.WBCT_NORMAL or Reason == _G.Enum.WorldBuffChangeReason.WBCT_BARRIER_BUFF_HIT_WEAK then
      OwnerShieldComponent:BreakShield()
    else
      OwnerShieldComponent:ClearShield()
    end
    BuffOwner:SendEvent(MainUIModuleEvent.OnBarrierBroken, self.Info.buff_val)
  end
  self:UpdateBarrierState(false)
  Base.OnRemove(self, Reason)
end

function WorldCombatBuffBarrier:OnUpdate(NewValue, OldValue, Reason)
  local BuffOwner = self:GetBuffOwner()
  if BuffOwner then
    local isCrit = Reason == Enum.WorldBuffChangeReason.WBCT_BARRIER_BUFF_HIT_WEAK
    BuffOwner:SendEvent(MainUIModuleEvent.OnBarrierChange, OldValue.buff_val, NewValue.buff_val, isCrit)
  end
  self:UpdateAIParam()
end

function WorldCombatBuffBarrier:ShowShield()
  if self.Info.buff_val == nil then
    self.Info.buff_val = self.Config.params[1]
  end
  local maxShield = self.Info.buff_val
  if self.Info.int_params_list and #self.Info.int_params_list > 0 then
    maxShield = self.Info.int_params_list[1]
  end
  local BuffOwner = self:GetBuffOwner()
  if BuffOwner then
    local OwnerShieldComponent = BuffOwner:EnsureComponent(ShieldComponent)
    OwnerShieldComponent:InitWeakPoint(self.Info.str_params_list)
    OwnerShieldComponent:ShowShield()
    BuffOwner:SendEvent(MainUIModuleEvent.OnBarrierShow, maxShield, self.Info.buff_val)
  end
end

function WorldCombatBuffBarrier:UpdateAIParam()
  local BuffOwner = self:GetBuffOwner()
  local AIComp = BuffOwner and BuffOwner.AIComponent
  if AIComp then
    AIComp:UpdateBarrier(self.Info.buff_val or 0, self.Config.params[1])
  end
end

function WorldCombatBuffBarrier:UpdateBarrierState(Exist)
  local barrier_owner_id = self:GetBuffOwner().serverData.base.actor_id
  local boss_id = _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.GetBossID)
  if barrier_owner_id == boss_id then
    if Exist then
      _G.NRCAudioManager:SetStateByName("Combat_Battle_Stage", "Shield_Stage")
    else
      _G.NRCAudioManager:SetStateByName("Combat_Battle_Stage", "Expose_Stage")
    end
  end
end

return WorldCombatBuffBarrier
