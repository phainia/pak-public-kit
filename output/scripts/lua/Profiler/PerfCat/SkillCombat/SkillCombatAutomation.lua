local SkillCombatAutomation = NRCClass()
local SkillAutoTest = require("NewRoco.Modules.Core.Battle.AutoTest.SkillAutoTest")
local PerfCatCmd = require("Profiler.PerfCat.PerfCatCmd")
local JsonUtils = require("Common.JsonUtils")

function SkillCombatAutomation:StartTest()
  self.autoBattleParam = JsonUtils.LoadSaved("AutoBattle/AutoTestParam")
  PerfCatCmd.ExecCmdCurrentWorld("rhi.EnablePerfCustomCsvStat 1")
  if self.autoBattleParam.DisableScreenMsg then
    PerfCatCmd.DisableScreenMsg()
  end
  SkillAutoTest:StartAutoTest(function()
    self:OnFinished()
  end)
end

function SkillCombatAutomation:OnFinished()
  PerfCatCmd.ExecCmdCurrentWorld("rhi.EnablePerfCustomCsvStat 0")
  if self.autoBattleParam.DisableScreenMsg then
    PerfCatCmd.EnableScreenMsg()
  end
end

function SkillCombatAutomation:IsStarted()
  return SkillAutoTest.isStarted
end

function SkillCombatAutomation:IsFinished()
  return SkillAutoTest.isFinished
end

return SkillCombatAutomation
