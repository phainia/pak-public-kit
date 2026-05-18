local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Base = DebugTabBase
local DebugTabProfiler = Base:Extend("DebugTabProfiler")
local PerfCatCmd = require("Profiler.PerfCat.PerfCatCmd")
local ActorShowroomAutomator

function DebugTabProfiler:Ctor()
  Base.Ctor(self)
end

function DebugTabProfiler:SetupTabs()
  self:Add("Log OK", self.OK, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "")
  self:Add("Set ViewMode", self.SetViewMode, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "")
  self:Add("\229\155\158\229\144\136\230\136\152\230\150\151\232\135\170\229\138\168\229\140\150", self.StartSkillAutoTest, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "")
  self:Add("\229\141\149\231\178\146\229\173\144\231\137\185\230\149\136\232\135\170\229\138\168\229\140\150", self.StartGeneralVfx, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "")
  self:Add("\228\184\187\232\167\146\233\173\148\230\179\149\232\135\170\229\138\168\229\140\150", self.StartMagicSkill, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "")
  self:Add("NPC Profiling", self.StartNPCShowroomProfiling, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "")
  self:Add("NPC Profiling ForceStop", self.StopNPCShowroomProfiling, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "")
end

function DebugTabProfiler:OK()
  Log.Info("OK")
end

function DebugTabProfiler:SetViewMode(Name, Panel)
  local inputText = Panel:GetInputString()
  PerfCatCmd.SetViewMode(inputText)
end

function DebugTabProfiler:StartSkillAutoTest()
  local Automator = require("Profiler.PerfCat.SkillCombat.SkillCombatAutomation")
  Automator:StartTest()
  NRCModeManager:DoCmd(DebugModuleCmd.OpenOrClosePanel, false)
end

function DebugTabProfiler:StartGeneralVfx()
  local Automator = require("Profiler.PerfCat.GeneralVfx.GeneralVfxAutomation")
  Automator:StartAutomationWithSavedConfig()
  NRCModeManager:DoCmd(DebugModuleCmd.OpenOrClosePanel, false)
end

function DebugTabProfiler:StartMagicSkill()
  local Automator = require("Profiler.PerfCat.MagicSkill.MagicSkillAutomation")
  Automator:StartAutomationWithSavedConfig()
  NRCModeManager:DoCmd(DebugModuleCmd.OpenOrClosePanel, false)
end

function DebugTabProfiler:StartNPCShowroomProfiling()
  if not ActorShowroomAutomator then
    ActorShowroomAutomator = require("Profiler.PerfCat.ActorShowroom.ActorShowroomAutomation")
  end
  ActorShowroomAutomator:StartAutomationWithSavedConfig()
  NRCModeManager:DoCmd(DebugModuleCmd.OpenOrClosePanel, false)
end

function DebugTabProfiler:StopNPCShowroomProfiling()
  ActorShowroomAutomator:ForceStop()
end

return DebugTabProfiler
