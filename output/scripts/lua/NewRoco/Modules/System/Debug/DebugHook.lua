local DebugHook = {}
local Hooks = {}

local function NormalizeName(Name)
  return Name:gsub("%.", "/") .. ".lua"
end

function DebugHook.Add(Name, Line)
  if not Name then
    return
  end
  if not Line then
    return
  end
  local Norm = NormalizeName(Name)
  local Sub = Hooks[Norm]
  if not Sub then
    Sub = {}
    Hooks[Norm] = Sub
  end
  Sub[Line] = true
  Log.Error("Add", Norm, Line, "OK!")
  DebugHook.UpdateHook()
end

function DebugHook.Remove(Name, Line)
  if not Name then
    return
  end
  if not Line then
    return
  end
  local Norm = NormalizeName(Name)
  local Sub = Hooks[Norm]
  if Sub then
    Sub[Line] = nil
    Log.Error("Remove", Norm, Line, "OK!")
    if nil == next(Sub) then
      Hooks[Norm] = nil
    end
  end
  DebugHook.UpdateHook()
end

function DebugHook.InternalHook()
  local Info = debug.getinfo(2, "S")
  if not Info then
    return
  end
  if Info.what ~= "Lua" then
    return
  end
  local Source = Info.source
  local Point1 = Hooks[Source]
  if not Point1 then
    return
  end
  local Line = Info.linedefined
  local Point2 = Point1[Line]
  if not Point2 then
    return
  end
  _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.ShowTable, Log.Inspect(3), Line)
end

function DebugHook.UpdateHook()
  if next(Hooks) == nil then
    debug.sethook()
    Log.Error("remove debug hook")
  else
    debug.sethook(DebugHook.InternalHook, "c")
    Log.Error("add debug hook")
  end
end

return DebugHook
