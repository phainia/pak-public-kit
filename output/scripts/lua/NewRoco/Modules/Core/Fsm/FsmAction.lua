local FsmEnum = require("NewRoco.Modules.Core.Fsm.FsmEnum")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local FsmTimelineState = require("NewRoco.Modules.Core.Fsm.FsmTimelineState")
local Base = require("NewRoco.Modules.Core.Fsm.FsmBaseObject")
local FsmAction = Base:Extend("FsmAction")
FsmAction:SetMemberCount(12)
FsmUtils.MergeMembers(nil, FsmAction, {
  {name = "StartTime", type = "number"},
  {name = "EndTime", type = "number"}
})

function FsmAction:PreCtor()
  self.index = 0
  self.active = true
  self.entered = false
  self.finished = false
  self.timeout = 30.0
  self.execTime = 0.0
  self.execRealTime = 0
end

function FsmAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function FsmAction:OnPreload()
end

function FsmAction:OnEnter()
  self:Finish()
end

function FsmAction:OnTick(DeltaTime)
end

function FsmAction:OnExit()
end

function FsmAction:OnPause()
end

function FsmAction:OnResume()
end

function FsmAction:OnEvent(event)
end

function FsmAction:Finish()
  if self.finished then
    return
  end
  self.finished = true
  Log.DebugFormat("[Fsm]\231\138\182\230\128\129\230\156\186%s,\231\138\182\230\128\129:%s,\231\187\147\230\157\159Action:%s", self.fsm and self.fsm.GetName and self.fsm:GetName() or "nil", self.state and self.state.GetName and self.state:GetName() or "nil", self:GetName() or "nil")
  self:OnFinish()
  if self.fsm and self.fsm ~= FsmUtils.Dummy then
    self.fsm:TriggerEvent(FsmEnum.Events.FinishAction, self)
  end
end

function FsmAction:OnFinish()
end

function FsmAction:OnTimeout()
  Log.ErrorFormat("[Fsm]\231\138\182\230\128\129\230\156\186%s\229\143\145\231\148\159\232\182\133\230\151\182,\231\138\182\230\128\129:%s,\230\137\167\232\161\140Action:%s", self.fsm:GetName() or "nil", self.state:GetName() or "nil", self:GetName() or "nil")
  _G.BattleAutoTest:AddFailNumber()
end

function FsmAction:OnFinalize()
end

function FsmAction:DoPreload(state)
  self.fsm = state.fsm
  self.state = state
  self:OnPreload()
end

function FsmAction:DoEnter()
  if self.entered then
    return
  end
  if self.fsm and self.fsm ~= FsmUtils.Dummy then
    self.fsm:TriggerEvent(FsmEnum.Events.EnterAction, self)
  end
  Log.DebugFormat("[Fsm]\231\138\182\230\128\129\230\156\186%s,\231\138\182\230\128\129:%s,\230\137\167\232\161\140Action:%s", self.fsm.GetName and self.fsm:GetName() or "nil", self.state.GetName and self.state:GetName() or "nil", self:GetName() or "nil")
  self.active = true
  self.entered = true
  self.finished = false
  self.execTime = 0
  self.execRealTime = 0
  self.startGameTime = _G.UE4Helper.GetCurrentWorld():GetTimeSeconds()
  local Duration = self:GetDuration()
  self.timeout = math.max(Duration, self.timeout)
  self:OnEnter()
  if self.fsm and self.fsm ~= FsmUtils.Dummy then
    self.fsm:TriggerEvent(FsmEnum.Events.PostEnterAction, self)
  end
end

function FsmAction:CheckTimeout()
  if self.execRealTime < self.timeout + 0.5 then
    return
  else
    local GameTime = _G.UE4Helper.GetCurrentWorld():GetTimeSeconds()
    local GameDelta = GameTime - self.startGameTime or 0
    if GameDelta < self.timeout + 0.5 then
      self.execRealTime = GameDelta
      return
    end
  end
  self:OnTimeout()
  self:Finish()
end

function FsmAction:DoTick(DeltaTime)
  self.execRealTime = self.execRealTime + DeltaTime
  self.execTime = self.execTime + DeltaTime
  self:OnTick(DeltaTime)
  self:CheckTimeout()
end

function FsmAction:DoExit()
  if not self.active then
    return
  end
  self:OnExit()
  self.active = false
  self.entered = false
  self.finished = false
  if self.fsm and self.fsm ~= FsmUtils.Dummy then
    self.fsm:TriggerEvent(FsmEnum.Events.ExitAction, self)
  else
    Log.Error("Fsm is finalized, fsm ", self.fsm)
  end
end

function FsmAction:DoFinalize()
  self.fsm = FsmUtils.Dummy
  self.state = FsmUtils.Dummy
end

function FsmAction:IsValid()
  return self.fsm and self.state and self.fsm ~= FsmUtils.Dummy and self.state ~= FsmUtils.Dummy
end

function FsmAction:GetPrevState()
  if not self.fsm then
    return nil
  end
  if self.fsm == FsmUtils.Dummy then
    return nil
  end
  return self.fsm.prevState
end

function FsmAction:GetNextState()
  if not self.fsm then
    return nil
  end
  if self.fsm == FsmUtils.Dummy then
    return nil
  end
  return self.fsm.nextState
end

function FsmAction:InjectProperties()
  local KlassMembers = self.class and self.class.__members__
  if not KlassMembers then
    Log.Warning("Klass member is nil")
    return
  end
  for _, members in ipairs(KlassMembers) do
    local name = members.name
    if not string.IsNilOrEmpty(name) then
      self[name] = self:GetProperty(name)
      if nil == self[name] and nil ~= members.default then
        self[name] = members.default
      end
    end
  end
end

function FsmAction:GetStartTime()
  if self.StartTime ~= nil then
    return self.StartTime
  end
  return self:GetProperty("StartTime", -1)
end

function FsmAction:GetEndTime()
  if self.EndTime ~= nil then
    return self.EndTime
  end
  return self:GetProperty("EndTime", -1)
end

function FsmAction:GetDuration()
  return self:GetEndTime() - self:GetStartTime()
end

function FsmAction:GetRunningPercent()
  local Duration = self:GetDuration()
  if 0 == Duration then
    return 1
  end
  return math.clamp(self.execTime / Duration, 0, 1)
end

function FsmAction:GetTimeoutPercent()
  return math.clamp(self.execTime / self.timeout, 0, 1)
end

function FsmAction:InTimeline()
  if self.state and self.state ~= FsmUtils.Dummy then
    return self.state:InstanceOf(FsmTimelineState)
  else
    return false
  end
end

return FsmAction
