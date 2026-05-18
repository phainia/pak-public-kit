local function WeakTable(table, mode)
  return setmetatable(table or {}, {
    __mode = mode or "kv"
  })
end

local NRCClass = Class()

function NRCClass:Ctor()
end

function NRCClass:__Ctor()
end

function NRCClass:__Dctor()
  local Dctor = rawget(self, "Dctor")
  if Dctor then
    Dctor(self)
  end
end

function NRCClass:DumpUProperty()
  local UPropertyCache = rawget(self, "__UPropertyCache__")
  if not UPropertyCache then
    return
  end
  self:Log("NRCUmgClass DumpUProperty")
  for k, v in pairs(UPropertyCache) do
    self:Log("show me __UPropertyCache__:", k)
  end
end

function NRCClass:UnBindProperty()
  local t = getmetatable(self)
  local UPropertyCache = rawget(self, "__UPropertyCache__")
  if UPropertyCache then
    for k, v in pairs(UPropertyCache) do
      if v and type(v) == "table" then
        if v.ClassType == "NRCViewBase" and self:CheckFuncIsValid(v, "Destruct") then
          v:Destruct()
        end
        if UE4.UObject.IsValid(v) and not v:IsA(UE4.UNRCUserWidget) and v.ReleaseClass then
          v:ReleaseClass()
        end
      else
        if v and type(v) == "userdata" and self:CheckFuncIsValid(v, "ReleaseClass") then
          v:ReleaseClass()
        else
        end
      end
    end
    rawset(self, "__UPropertyCache__", nil)
  end
end

function NRCClass:UnbindSelfRef()
  for k, v in pairs(self) do
    local value_type = type(v)
    if "userdata" ~= value_type then
      self[k] = nil
    end
  end
end

function NRCClass:CheckFuncIsValid(t, n)
  local mt = getmetatable(t)
  return rawget(mt, n) ~= nil
end

function NRCClass:Log(...)
  local name = rawget(self, "name")
  name = name or "Nameless"
  local out = string.format("[%s]", name)
  Log.Debug(out, ...)
end

return NRCClass
