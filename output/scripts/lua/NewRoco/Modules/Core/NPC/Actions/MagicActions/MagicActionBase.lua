local Class = _G.MakeSimpleClass
local MagicActionEvent = require("NewRoco.Modules.Core.NPC.Actions.MagicActions.MagicActionEvent")
local OnlineModuleEvent = require("NewRoco.Modules.Core.Online.OnlineModuleEvent")
local EventDispatcher = require("Common.EventDispatcher")
local ThrowUtils = require("NewRoco.Modules.Core.NPC.ThrowUtils")
local MagicActionBase = Class("MagicActionBase")
MagicActionBase:SetMemberCount(4)
EventDispatcher.BindClass(MagicActionBase)

function MagicActionBase:Ctor(Owner, Config, Info)
  if type(self) == "table" then
    EventDispatcher():Attach(self)
  else
    Log.Error("Why MagicActionBase self is not table????", type(self))
  end
  self.Owner = Owner
  self.Config = Config
  self.Info = Info
  self.Runner = nil
end

function MagicActionBase:UpdateInfo(NewAction)
  self.Info = NewAction
end

function MagicActionBase:IsEnabled()
  return self.Owner:IsOptionEnable(true) and not self.Owner:IsDisableByOnlineModeMagicAction()
end

function MagicActionBase:CanExecute(Runner, ChargeLevel, MagicID, RelativeLocation)
  if self.Owner.optionInfo.enabled or self.Config.action_type == _G.Enum.ActionType.ACT_STAR_UNLOCK_SANCTUARY or self.Config.action_type == _G.Enum.ActionType.ACT_STAR_UNLOCK_OWL or self.Config.action_type == _G.Enum.ActionType.ACT_WIND_UNLOCK_OWL or self.Config.action_type == _G.Enum.ActionType.ACT_MAGIC_REVEAL or self.Config.action_type == _G.Enum.ActionType.ACT_MAGIC_REVEAL_FAILED then
  else
    return false
  end
  if 0 == self.Owner.optionInfo.executable_times then
    return false
  end
  if ChargeLevel < self.Config.magic_charge_level then
    return false
  end
  if MagicID ~= self.Config.magic_id then
    return false
  end
  if self.Owner:IsDisableByOnlineModeMagicAction() then
    return false
  end
  if self.Config.horizontal_effective_angle and #self.Config.horizontal_effective_angle >= 2 then
    local minAngle = self.Config.horizontal_effective_angle[1]
    local maxAngle = self.Config.horizontal_effective_angle[2]
    local angle, isAngleValid = ThrowUtils.CheckActionEffectInAnglesForward(Runner, RelativeLocation, minAngle, maxAngle)
    self.CurrHorizontalAngle = angle
    return isAngleValid
  end
  if self.Config.z_axis_effective_angle and 0 ~= self.Config.z_axis_effective_angle then
    local ZAngle = self.Config.z_axis_effective_angle
    local angle, isAngleValid = ThrowUtils.CheckActionEffectInAnglesVertical(Runner, RelativeLocation, ZAngle)
    self.CurrVerticalAngle = angle
    return isAngleValid
  end
  return true
end

function MagicActionBase:Execute(Runner, LightBallNPC)
  self.Runner = Runner
  self:OnExecute(LightBallNPC)
end

function MagicActionBase:OnExecute(LightBallNPC)
end

function MagicActionBase:Submit()
  self:OnSubmit()
end

function MagicActionBase:OnSubmit(rsp)
  self:Finish(true)
end

function MagicActionBase:Finish(Success)
  if not self.Runner then
    return
  end
  self:OnFinish()
  self.Runner = nil
end

function MagicActionBase:OnFinish()
  Log.Debug("MagicActionBase:OnFinish")
end

function MagicActionBase:GetRunnerView()
  if not self.Runner then
    return nil
  end
  return self.Runner.viewObj
end

function MagicActionBase:GetRunnerSkillComponent()
  local View = self:GetRunnerView()
  if not View then
    return nil
  end
  local Comp = View.RocoSkill
  return Comp
end

function MagicActionBase:GetOwnerNPC()
  if not self.Owner then
    return nil
  end
  return self.Owner.owner
end

function MagicActionBase:GetOwnerNPCView()
  local NPC = self:GetOwnerNPC()
  return NPC and NPC.viewObj
end

return MagicActionBase
