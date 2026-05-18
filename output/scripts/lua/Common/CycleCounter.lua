local CycleCounter = Singleton:Extend("CycleCounter")
local CounterPool = {}
local Dummy = setmetatable({}, {
  Start = function()
  end,
  __call = function(t)
    return t
  end,
  __close = function()
  end
})
local Metatable = {
  __call = function(t)
    return t:Start()
  end,
  __close = function(t, key)
    t.Closed = true
    UE.FCycleCounter.Stop()
  end,
  __gc = function(t)
    if not t.Closed then
      Log.Warning("[CC] counter not closed", t.Name)
      t.Closed = true
    end
  end
}

local function MakeNewCounter(Name)
  local Counter = {
    Name = Name,
    Closed = false,
    Start = function(t)
      t.Closed = false
      UE.FCycleCounter.Start(t.Name)
      return t
    end
  }
  UE.FCycleCounter.Create(Name)
  Counter = setmetatable(Counter, Metatable)
  return Counter
end

function CycleCounter:Ctor(name)
  self.name = name or "CycleCounter"
  Singleton.Ctor(self, self.name)
end

function CycleCounter.Start(Name, SubName)
  if RocoEnv.IS_SHIPPING then
    return Dummy
  end
  if not Name then
    return Dummy
  end
  if not string.IsNilOrEmpty(SubName) then
    Name = string.format("%s.%s", Name, SubName)
  end
  local Counter = CounterPool[Name]
  if not Counter then
    Counter = MakeNewCounter(Name)
    CounterPool[Name] = Counter
  end
  return Counter()
end

function CycleCounter.Create(Name)
  if RocoEnv.IS_SHIPPING then
    return Dummy
  end
  return MakeNewCounter(Name)
end

return CycleCounter
