local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Base = DebugTabBase
local PerfCatCmd = require("Profiler.PerfCat.PerfCatCmd")
local PerfDogExt = require("Profiler.PerfDogExtension")
local DelayTaskQueue = require("Profiler.Utils.DelayTaskQueue")
local DebugTabPerfDogExtension = Base:Extend("DebugTabPerfDogExtension")

function DebugTabPerfDogExtension:Ctor()
  Base.Ctor(self)
  self.post_value_int = 1
  self.post_value_float = 1.11
  self.pressure_test_queue = DelayTaskQueue()
end

function DebugTabPerfDogExtension:SetupTabs()
  self:Add("\230\137\147\229\188\128 PerfDogExt", self.EnablePerfDogExtension, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "")
  self:Add("\229\133\179\233\151\173 PerfDogExt", self.DisablePerfDogExtension, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "")
  self:Add("\230\137\147\229\188\128\229\188\149\230\147\142\230\149\176\230\141\174\228\184\138\228\188\160", self.EnablePostEngineStats, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "")
  self:Add("\229\133\179\233\151\173\229\188\149\230\147\142\230\149\176\230\141\174\228\184\138\228\188\160", self.DisablePostEngineStats, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "")
  self:Add("\230\137\147\229\188\128 NRCStats", self.EnableNRCStats, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "")
  self:Add("\229\133\179\233\151\173 NRCStats", self.DisableNRCStats, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "")
  self:Add("\230\137\147\229\188\128 PSOStats", function()
    PerfDogExt.EnablePostPSOStats()
  end, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "")
  self:Add("\229\133\179\233\151\173 PSOStats", function()
    PerfDogExt.DisablePostPSOStats()
  end, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "")
  self:Add("\230\137\147\229\188\128\231\137\185\230\149\136\231\178\146\229\173\144\231\155\145\230\142\167", self.EnableProfileParticleCount, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "")
  self:Add("\229\133\179\233\151\173\231\137\185\230\149\136\231\178\146\229\173\144\231\155\145\230\142\167", self.DisableProfileParticleCount, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "")
  self:Add("\230\137\147\229\188\128 ShaderComplexity \230\149\176\230\141\174\228\184\138\228\188\160", self.EnablePostShaderComplexity, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "")
  self:Add("\229\133\179\233\151\173 ShaderComplexity \230\149\176\230\141\174\228\184\138\228\188\160", self.DisablePostShaderComplexity, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "")
  self:Add("PostValue Determined Test", self.PostValueDeterminedTest, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "")
  self:Add("PostValue Type-deducted Test", self.PostValueTypeDeductedTest, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "")
  self:Add("PostValue PressureTest", self.PostValuePressureTest, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "")
end

function DebugTabPerfDogExtension:EnablePerfDogExtension()
  local cmd = "Enable PerfDog Extension"
  self:ShowTips(cmd)
  PerfDogExt.Enable()
end

function DebugTabPerfDogExtension:DisablePerfDogExtension()
  local cmd = "Disable PerfDog Extension"
  self:ShowTips(cmd)
  PerfDogExt.Disable()
end

function DebugTabPerfDogExtension:EnablePostEngineStats()
  local cmd = "EnablePostEngineStats"
  self:ShowTips(cmd)
  PerfDogExt.EnablePostEngineStats()
end

function DebugTabPerfDogExtension:DisablePostEngineStats()
  local cmd = "DisablePostEngineStats"
  self:ShowTips(cmd)
  PerfDogExt.DisablePostEngineStats()
end

function DebugTabPerfDogExtension:EnableNRCStats()
  self:ShowTips("Enable NRC Stats")
  PerfDogExt.EnableNRCStats()
end

function DebugTabPerfDogExtension:DisableNRCStats()
  self:ShowTips("Disable NRC Stats")
  PerfDogExt.DisableNRCStats()
end

function DebugTabPerfDogExtension:EnableProfileParticleCount()
  self:ShowTips("\231\137\185\230\149\136\231\178\146\229\173\144\231\155\145\230\142\167: \230\137\147\229\188\128")
  PerfCatCmd.ExecCmdCurrentWorld("fx.Niagara.ProfileParticleCount 1")
end

function DebugTabPerfDogExtension:DisableProfileParticleCount()
  self:ShowTips("\231\137\185\230\149\136\231\178\146\229\173\144\231\155\145\230\142\167: \229\133\179\233\151\173")
  PerfCatCmd.ExecCmdCurrentWorld("fx.Niagara.ProfileParticleCount 0")
end

function DebugTabPerfDogExtension:EnablePostShaderComplexity()
  self:ShowTips("EnablePostShaderComplexity")
  PerfDogExt.EnablePostShaderComplexity()
end

function DebugTabPerfDogExtension:DisablePostShaderComplexity()
  self:ShowTips("DisableShaderComplexity")
  PerfDogExt.DisablePostShaderComplexity()
end

function DebugTabPerfDogExtension:PostValueDeterminedTest(Name, Panel)
  PerfDogExt:PostValueInt("UE Lua Test", "int", self.post_value_int + 1)
  PerfDogExt:PostValueFloat("UE Lua Test", "float", self.post_value_float + 0.1)
  self.post_value_int = self.post_value_int + 1
  self.post_value_float = self.post_value_float + 1
end

function DebugTabPerfDogExtension:PostValueTypeDeductedTest(Name, Panel)
  PerfDogExt:PostValue("UE Lua Test", "int_auto", self.post_value_int)
  PerfDogExt:PostValue("UE Lua Test", "float_auto", self.post_value_float)
  self.post_value_int = self.post_value_int + 1
  self.post_value_float = self.post_value_float + 1
end

function DebugTabPerfDogExtension:PostValuePressureTest(Name, Panel)
  local send_count = Panel:GetInputNumber() or 50
  
  local function massive_sender(callback, counter)
    self:PostValueDeterminedTest()
    counter = counter - 1
    if counter > 0 then
      DelayManager:DelayFrames(1, callback, callback, counter)
    end
  end
  
  self.pressure_test_queue:Add(1, self, function()
    massive_sender(massive_sender, send_count)
  end)
  self.pressure_test_queue:ProcessTaskQueue()
end

return DebugTabPerfDogExtension
