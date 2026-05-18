local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Base = DebugTabBase
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local DebugTabMemory = Base:Extend("DebugTabMemory")

function DebugTabMemory:Ctor()
  Base.Ctor(self)
end

function DebugTabMemory:SetupTabs()
end

function DebugTabMemory:TrySpawnBlackHole()
  local world = _G.UE4Helper.GetCurrentWorld()
  return UE4.UPerfCatFunctionLibrary.SpawnBlackHole(world)
end

function DebugTabMemory:Malloc(name, panel, InputText)
  self:TrySpawnBlackHole()
  local value
  if panel then
    value = panel.InputBox:GetText()
  else
    value = InputText
  end
  if nil == value or "" == value then
    value = "100"
  end
  local MemorySizeInMB = tonumber(value)
  Log.Debug(string.format("Try to Malloc: %d MB", MemorySizeInMB))
  UE4.UPerfCatFunctionLibrary.AllocateMemory(MemorySizeInMB)
end

function DebugTabMemory:Free(name, panel)
  Log.Debug("Try to Empty Memory BlackHole")
  UE4.UPerfCatFunctionLibrary.FreeAllocatedMemory()
end

function DebugTabMemory:MallocEverySecond(name, panel, InputText)
  self:TrySpawnBlackHole()
  local value
  if panel then
    value = panel.InputBox:GetText()
  else
    value = InputText
  end
  if nil == value or "" == value then
    value = "100"
  end
  local MemorySizeInMB = tonumber(value)
  Log.Debug(string.format("Try to Malloc: %d MB every second", MemorySizeInMB))
  UE4.UPerfCatFunctionLibrary.GraduallyAllocateMemory(MemorySizeInMB, 1)
end

function DebugTabMemory:CancelMalloc(name, panel)
  Log.Debug("Try to Cancel Gradual Allocation of Memory BlackHole")
  UE4.UPerfCatFunctionLibrary.CancelGradualAllocation()
end

function DebugTabMemory:DestroyBlackHole(name, panel)
  Log.Debug("Try to Destroy BlackHole")
  UE4.UPerfCatFunctionLibrary.DestroyBlackHole()
end

return DebugTabMemory
