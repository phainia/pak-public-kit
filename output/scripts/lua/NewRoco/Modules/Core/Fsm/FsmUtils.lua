local ActorClass = UE4.AActor
local FsmUtils = {}
FsmUtils.Dummy = {}
setmetatable(FsmUtils.Dummy, {
  __newindex = function()
  end,
  __call = function()
  end,
  __tostring = function()
    return "<DummyTable>"
  end
})

function FsmUtils.GetTransition(transitions, event)
  if not transitions then
    return nil
  end
  if not event then
    return nil
  end
  for _, transition in ipairs(transitions) do
    local evt = type(transition) == "table" and transition.event or nil
    if evt == event.name then
      return transition
    end
  end
end

function FsmUtils.Contains(stateNames, state)
  if not stateNames then
    return false
  end
  if not state then
    return false
  end
  return table.contains(stateNames, state:GetName())
end

function FsmUtils.Iterate(list, funcName, arg1, arg2, arg3, arg4, arg5)
  for _, v in ipairs(list) do
    local func = v[funcName]
    if func then
      func(v, arg1, arg2, arg3, arg4, arg5)
    end
  end
end

function FsmUtils.GetProperty(obj, name, defaultValue)
  local properties = obj and obj.properties
  local property = properties and properties[name]
  if nil == property then
    return defaultValue
  else
    return property
  end
end

function FsmUtils.SetProperty(obj, name, value)
  if not obj then
    return
  end
  local properties = obj and obj.properties
  if nil == properties or properties == FsmUtils.Dummy then
    obj.properties = {}
    properties = obj.properties
  end
  properties[name] = value
end

function FsmUtils.MakeSlateColor(r, g, b, a)
  local Color = UE4.FSlateColor()
  Color.SpecifiedColor = UE4.FColor(r or 255, g or 255, b or 255, a or 255):ToLinearColor()
  return Color
end

local Colors, Fsm, FsmState, FsmAction

function FsmUtils.GetColor(fsmObject)
  if not Fsm then
    Fsm = require("NewRoco.Modules.Core.Fsm.Fsm")
  end
  if not FsmState then
    FsmState = require("NewRoco.Modules.Core.Fsm.FsmState")
  end
  if not FsmAction then
    FsmAction = require("NewRoco.Modules.Core.Fsm.FsmAction")
  end
  if not Colors then
    Colors = {
      Yellow = FsmUtils.MakeSlateColor(255, 248, 38),
      Red = FsmUtils.MakeSlateColor(255, 56, 38),
      White = FsmUtils.MakeSlateColor(255, 255, 255),
      Blue = FsmUtils.MakeSlateColor(0, 162, 255),
      Gray = FsmUtils.MakeSlateColor(133, 133, 133),
      Green = FsmUtils.MakeSlateColor(0, 255, 21)
    }
  end
  if fsmObject:InstanceOf(Fsm) then
    local fsm = fsmObject
    if fsm.active then
      if fsm.paused then
        return Colors.Gray
      else
        return Colors.Green
      end
    elseif fsm:IsSwitchingState() then
      return Colors.Yellow
    end
  elseif fsmObject:InstanceOf(FsmState) then
    local state = fsmObject
    if state.active then
      if state:IsWaitPreload() then
        return Colors.Yellow
      else
        return Colors.Green
      end
    elseif state.finished then
      return Colors.Gray
    else
      return Colors.White
    end
  elseif fsmObject:InstanceOf(FsmAction) then
    local action = fsmObject
    if action.finished then
      return Colors.Gray
    elseif action.active and action.entered then
      return Colors.Green
    else
      return Colors.White
    end
  end
  return Colors.White
end

local ipairs = _ENV.ipairs
local TempTable = table.new(0, 16)

function FsmUtils.MergeMembers(BaseKlass, Klass, members)
  if not members then
    return
  end
  local Parent = BaseKlass and BaseKlass.__members__ or FsmUtils.Dummy
  local Child = table.new(#Parent + #members, 0)
  for Index, Member in ipairs(Parent) do
    TempTable[Member.name] = Index
    Child[Index] = Member
  end
  for _, n in ipairs(members) do
    if TempTable[n.name] then
      Child[TempTable[n.name]] = n
    else
      table.insert(Child, n)
    end
  end
  table.reset(TempTable)
  Klass.__members__ = Child
end

function FsmUtils.SaveAsProperty(FsmObject, Blackboard, Name)
  if string.IsNilOrEmpty(Name) then
    return
  end
  if not FsmObject then
    return
  end
  if FsmObject == FsmUtils.Dummy then
    return
  end
  if not Blackboard then
    return
  end
  local Item = Blackboard:GetValueAsObject(Name)
  if not Item then
    return
  end
  Blackboard:RemoveObjectValue(Name)
  local Cached = FsmObject:GetProperty(Name)
  if Cached then
    FsmUtils.ClearProperty(FsmObject, Name)
    Log.Warning(FsmObject:GetName(), Name, "Cleared to prevent memory leak")
  end
  FsmObject:SetProperty(Name, Item)
  return Item
end

function FsmUtils.ClearProperty(FsmObject, Name)
  if string.IsNilOrEmpty(Name) then
    return
  end
  if not FsmObject then
    return
  end
  if FsmObject == FsmUtils.Dummy then
    return
  end
  local Actor = FsmObject:GetProperty(Name, nil)
  if Actor and Actor:IsValid() and Actor:IsA(ActorClass) then
    Actor:K2_DestroyActor()
  end
  Actor = nil
  FsmObject:SetProperty(Name, nil)
end

function FsmUtils.ClearAllProperties(FsmObject)
  if not FsmObject then
    return
  end
  if FsmObject == FsmUtils.Dummy then
    return
  end
  local Properties = FsmObject:GetProperties()
  if not Properties then
    return
  end
  if Properties == FsmUtils.Dummy then
    return
  end
  for k, v in pairs(Properties) do
    if type(v) == "userdata" or type(v) == "table" then
      if UE.UObject.IsValid(v) and v.IsA and v:IsA(ActorClass) then
        if v:IsValid() then
          v:K2_DestroyActor()
        end
      elseif type(v) == "table" and #v > 0 and v[1] then
        local actor = v[1]
        if UE.UObject.IsValid(actor) and actor.IsA and actor:IsA(ActorClass) and actor:IsValid() then
          actor:K2_DestroyActor()
        end
      end
      Properties[k] = nil
    end
  end
end

return FsmUtils
