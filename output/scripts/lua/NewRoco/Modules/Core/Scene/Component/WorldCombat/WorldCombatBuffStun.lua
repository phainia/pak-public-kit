local WorldCombatBuffBase = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatBuffBase")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local NPCModuleEnum = require("NewRoco.Modules.Core.NPC.NPCModuleEnum")
local StunComponent = require("NewRoco.Modules.Core.Scene.Component.Boss.StunComponent")
local Base = WorldCombatBuffBase
local WorldCombatBuffStun = Base:Extend("WorldCombatBuffStun")

function WorldCombatBuffStun:Ctor(Parent, Buff, Conf)
  Base.Ctor(self, Parent, Buff, Conf)
  self.d_StunTimeOut = nil
  self.d_StunTimeOut_keptFrame = nil
  self.d_RepeatTimeOut = nil
end

function WorldCombatBuffStun:OnInit()
  Base.OnInit(self)
  self:OnStun()
end

function WorldCombatBuffStun:OnAdd()
  self:OnStun()
end

local WorldCombatSkillComponent

function WorldCombatBuffStun:OnStun()
  local OwnerStunComp = self.Parent.owner:EnsureComponent(StunComponent)
  OwnerStunComp:SetAILocker(true)
  if not self.Parent.owner.viewObj then
    self.Parent.owner:AddEventListener(self, NPCModuleEvent.VIEW_SHELL_LOADED, self.LaterOnStun)
    return
  end
  if not WorldCombatSkillComponent then
    WorldCombatSkillComponent = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatSkillComponent")
  end
  local OwnerWorldSkillComp = self.Parent.owner:EnsureComponent(WorldCombatSkillComponent)
  OwnerWorldSkillComp:ForceStopCurrentSkill()
  local rocoSkill = self.Parent.owner.viewObj.RocoSkill
  if rocoSkill then
    rocoSkill:StopAllPassiveSkill()
  end
  local moveComp = self.Parent.owner.viewObj.GetMovementComponent and self.Parent.owner.viewObj:GetMovementComponent() or nil
  if moveComp then
    if moveComp:IsHovering() or moveComp:IsFlying() then
      moveComp:SetMovementMode(UE4.EMovementMode.MOVE_Falling)
    else
      self.Parent.owner.viewObj:ForceLockOnGround()
    end
  end
  self.Caster:SetCollisionDisable(false, NPCModuleEnum.NpcReasonFlags.AI)
  if self.Caster.HiddenComponent and self.Caster.HiddenComponent:IsHidden() then
    self.Caster.HiddenComponent:ResetHide(true)
  end
  if self.Info.create_time + 5000 < _G.ZoneServer:GetServerTime() then
    Log.Debug("[WorldCombatBuffStun] time exceeded (5s), stun immediately")
    self:OnStunTimeOut()
  else
    self.Parent.owner:AddEventListener(self, _G.WorldCombatModuleEvent.OnBossShieldBreak, self.OnShieldBroke)
    if self.d_StunTimeOut == nil and nil == self.d_StunTimeOut_keptFrame then
      self.d_StunTimeOut = DelayManager:DelaySeconds(3, self.OnStunTimeOut, self)
    end
  end
end

function WorldCombatBuffStun:LaterOnStun(ownerNpc)
  local BuffComp = ownerNpc.WorldCombatBuffComponent
  if BuffComp and BuffComp:HasBuffOfType(Enum.WorldBuffEffect.WBE_STUN) then
    self:OnStun()
  end
end

function WorldCombatBuffStun:OnStunTimeOut()
  self.d_StunTimeOut = nil
  self.Parent.owner:RemoveEventListener(self, _G.WorldCombatModuleEvent.OnBossShieldBreak, self.OnShieldBroke)
  self.d_StunTimeOut_keptFrame = DelayManager:DelayFrames(1, self.OnStunTimeOut_KeptFrame, self)
end

function WorldCombatBuffStun:OnStunTimeOut_KeptFrame()
  self.d_StunTimeOut_keptFrame = nil
  self:EnterStun()
end

function WorldCombatBuffStun:OnShieldBroke()
  self:CleanDelayHandle()
  self.Parent.owner:RemoveEventListener(self, _G.WorldCombatModuleEvent.OnBossShieldBreak, self.OnShieldBroke)
  self:EnterStun()
end

function WorldCombatBuffStun:EnterStun()
  local OwnerStunComp = self.Parent.owner:EnsureComponent(StunComponent)
  if OwnerStunComp then
    OwnerStunComp:SetStunLevel(2):SetSkipHit(false)
    Log.PrintScreenMsg("[WorldCombatStun] StartStun buffId:%d, timeout:%d", self.Config.id, self.Config.time_out_duration)
    local timePassed = _G.ZoneServer:GetServerTime() - self.Info.create_time
    local stunTime = math.max((self.Config.time_out_duration - timePassed) / 1000, 0.1)
    OwnerStunComp:Stun(stunTime, self, self.StunEnd)
  end
end

function WorldCombatBuffStun:CleanDelayHandle()
  if self.d_StunTimeOut then
    DelayManager:CancelDelayById(self.d_StunTimeOut)
    self.d_StunTimeOut = nil
  end
  if self.d_StunTimeOut_keptFrame then
    DelayManager:CancelDelayById(self.d_StunTimeOut_keptFrame)
    self.d_StunTimeOut_keptFrame = nil
  end
end

function WorldCombatBuffStun:CleanRepeatHandle()
  if self.d_RepeatTimeOut then
    DelayManager:CancelDelayById(self.d_RepeatTimeOut)
    self.d_RepeatTimeOut = nil
  end
end

function WorldCombatBuffStun:OnRemove(Reason)
  self:CleanDelayHandle()
  self:CleanRepeatHandle()
  self.Parent.owner:RemoveEventListener(self, _G.WorldCombatModuleEvent.OnBossShieldBreak, self.OnShieldBroke)
  local OwnerStunComp = self.Parent.owner:GetComponent(StunComponent)
  if OwnerStunComp then
    OwnerStunComp:GetDelegate():Remove(self, self.StunEnd)
    OwnerStunComp:StopStun(Reason == Enum.WorldBuffChangeReason.WBCT_INTERNAL_BATTLE_BEGIN)
  end
  Base.OnRemove(self, Reason)
end

function WorldCombatBuffStun:StunEnd(comp)
  Log.PrintScreenMsg("[WorldCombatBuffStun] \231\156\169\230\153\149\232\161\168\230\188\148\231\187\147\230\157\159\228\186\134\239\188\140\228\189\134\230\152\175Buff\229\165\189\229\131\143\232\191\152\230\178\161\230\156\137\231\167\187\233\153\164\239\188\159\229\134\141\230\146\173\228\184\128\228\188\154\229\132\191 %s", self.Parent.owner.config.name)
  self:CleanRepeatHandle()
  self.d_RepeatTimeOut = _G.DelayManager:DelayFrames(1, self.StunAgain, self)
end

function WorldCombatBuffStun:StunAgain()
  self.d_RepeatTimeOut = nil
  local OwnerStunComp = self.Parent.owner:GetComponent(StunComponent)
  if OwnerStunComp then
    OwnerStunComp:SetSkipHit(true)
    OwnerStunComp:Stun(10, self, self.StunEnd)
  end
end

return WorldCombatBuffStun
