local PerfDogExtension = {}
local PerfCatCmd = require("Profiler.PerfCat.PerfCatCmd")

function PerfDogExtension:Enable()
  UE.UPerfDogFunctionLibrary.EnablePerfDogExtension()
end

function PerfDogExtension:Disable()
  UE.UPerfDogFunctionLibrary.DisablePerfDogExtension()
end

function PerfDogExtension:EnablePostEngineStats()
  local cmd = "PerfDog.PostEngineStats 1"
  PerfCatCmd.ExecCmdCurrentWorld(cmd)
end

function PerfDogExtension:DisablePostEngineStats()
  local cmd = "PerfDog.PostEngineStats 0"
  PerfCatCmd.ExecCmdCurrentWorld(cmd)
end

function PerfDogExtension:EnableNRCStats()
  PerfCatCmd.EnableNRCStats()
end

function PerfDogExtension:DisableNRCStats()
  PerfCatCmd.DisableNRCStats()
end

function PerfDogExtension:EnablePostShaderComplexity()
  local cmd = "PerfDog.PostShaderComplexity 1"
  PerfCatCmd.ExecCmdCurrentWorld(cmd)
end

function PerfDogExtension:EnablePostPSOStats()
  PerfCatCmd.ExecCmdCurrentWorld("PerfDog.PostPSOStats 1")
end

function PerfDogExtension:DisablePostPSOStats()
  PerfCatCmd.ExecCmdCurrentWorld("PerfDog.PostPSOStats 0")
end

function PerfDogExtension:DisablePostShaderComplexity()
  local cmd = "PerfDog.PostShaderComplexity 0"
  PerfCatCmd.ExecCmdCurrentWorld(cmd)
end

function PerfDogExtension:Disable()
  UE.UPerfDogFunctionLibrary.DisablePerfDogExtension()
end

function PerfDogExtension:PostValue(Category, Key, Value)
  local valueType = type(Value)
  if "number" == valueType then
    if Value == math.floor(Value) then
      UE.UPerfDogFunctionLibrary.PostValueFloat(Category, Key, Value)
    else
      local value_int = math.floor(Value)
      UE.UPerfDogFunctionLibrary.PostValueInt(Category, Key, value_int)
    end
  elseif "string" == valueType then
    UE.UPerfDogFunctionLibrary.PostValueString(Category, Key, Value)
  else
    Log.Error("Unknown value type")
  end
end

function PerfDogExtension:RegisterCategory(Category, AggregationType, TimeInterval, EnableInShipping)
  UE.UPerfDogFunctionLibrary.RegisterCategory(Category, AggregationType, TimeInterval, EnableInShipping)
end

function PerfDogExtension:PostValueInt(Category, Key, Value)
  UE.UPerfDogFunctionLibrary.PostIntValue(Category, Key, Value)
end

function PerfDogExtension:PostValueFloat(Category, Key, Value)
  UE.UPerfDogFunctionLibrary.PostFloatValue(Category, Key, Value)
end

function PerfDogExtension:AddNote(NoteName)
  UE.UPerfDogFunctionLibrary.AddNote(NoteName)
end

function PerfDogExtension:SetLabel(LabelName)
  UE.UPerfDogFunctionLibrary.SetLabel(LabelName)
end

return PerfDogExtension
