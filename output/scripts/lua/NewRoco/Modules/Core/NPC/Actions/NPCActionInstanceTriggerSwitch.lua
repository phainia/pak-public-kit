local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local Base = NPCActionBase
local NPCActionInstanceTriggerSwitch = Base:Extend("NPCActionBattle")

function NPCActionInstanceTriggerSwitch:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
  self.DelayHandler = -1
end

function NPCActionInstanceTriggerSwitch:OnNpcAction()
  local Owner = self:GetOwnerNPC()
  if not Owner then
    Log.Debug("\228\184\186\228\187\128\228\185\136\232\184\143\230\157\191\228\184\162\228\186\134\232\191\152\232\131\189\232\167\166\229\143\145\228\186\164\228\186\146?")
    return false
  end
  if Owner:IsLogicStatus(ProtoEnum.SpaceActorLogicStatus.SALS_TRIGGER_ON) then
    Log.Debug("\232\184\143\230\157\191\229\183\178\231\187\143\230\191\128\230\180\187\239\188\140\228\184\141\232\166\129\233\135\141\229\164\141\230\191\128\230\180\187", Owner:DebugNPCNameAndID())
    return false
  end
  if Owner:IsLogicStatus(ProtoEnum.SpaceActorLogicStatus.SALS_INTERACTING) then
    Log.Debug("\232\184\143\230\157\191\229\183\178\231\187\143\230\191\128\230\180\187\239\188\140\228\184\141\232\166\129\233\135\141\229\164\141\230\191\128\230\180\187", Owner:DebugNPCNameAndID())
    return false
  end
  local OwnerView = Owner and Owner.viewObj
  if OwnerView and not OwnerView.PlayerStanding then
    Log.Debug("\232\184\143\230\157\191\229\183\178\231\187\143\230\191\128\230\180\187\239\188\140\228\184\141\232\166\129\233\135\141\229\164\141\230\191\128\230\180\187", Owner:DebugNPCNameAndID())
    return false
  end
  return Base.OnNpcAction(self)
end

function NPCActionInstanceTriggerSwitch:Execute()
  Base.Execute(self)
  if self.SkipSubmit then
    if self.DelayHandler > 0 then
      _G.DelayManager:CancelDelayById(self.DelayHandler)
      self.DelayHandler = -1
    end
    self.DelayHandler = _G.DelayManager:DelaySeconds(0.1, self.Finish, self)
  end
end

function NPCActionInstanceTriggerSwitch:OnSubmit(rsp)
  Base.OnSubmit(self, rsp)
  if self.SkipSubmit then
    return
  end
  self:Finish(true)
end

function NPCActionInstanceTriggerSwitch:Finish(success, data, param)
  self.DelayHandler = -1
  Base.Finish(self, success, data, param)
end

function NPCActionInstanceTriggerSwitch:Destroy()
  if self.DelayHandler > 0 then
    _G.DelayManager:CancelDelayById(self.DelayHandler)
    self.DelayHandler = -1
  end
  Base.Destroy(self)
end

return NPCActionInstanceTriggerSwitch
