local PerfCatCmd = {}
local Enabled = true

local function HandleCmdWithArgs(cmd, args)
  if not Enabled then
    return
  end
  if args then
    cmd = string.format("%s %s", cmd, args)
  end
  PerfCatCmd.ExecCmdCurrentWorld(cmd)
end

PerfCatCmd.Sequence = {
  Start = function(args)
    HandleCmdWithArgs("PerfCat.Sequence.Start", args)
  end,
  Pause = function()
    HandleCmdWithArgs("PerfCat.Sequence.Pause")
  end,
  Stop = function()
    HandleCmdWithArgs("PerfCat.Sequence.Stop")
  end
}
PerfCatCmd.Channel = {
  Start = function(args)
    HandleCmdWithArgs("PerfCat.Channel.Start", args)
  end,
  Begin = function(args)
    HandleCmdWithArgs("PerfCat.Channel.Begin", args)
  end,
  Pause = function(args)
    HandleCmdWithArgs("PerfCat.Channel.Pause", args)
  end,
  Stop = function()
    HandleCmdWithArgs("PerfCat.Channel.Stop")
  end
}
PerfCatCmd.EnvSystem = {
  Start = function(args)
    HandleCmdWithArgs("PerfCat.EnvSystem.Start", args)
  end,
  Pause = function()
    HandleCmdWithArgs("PerfCat.EnvSystem.Pause")
  end,
  Stop = function()
    HandleCmdWithArgs("PerfCat.EnvSystem.Stop")
  end
}
PerfCatCmd.SkillCombat = {
  Start = function(args)
    HandleCmdWithArgs("PerfCat.SkillCombat.Start", args)
  end,
  Stop = function()
    HandleCmdWithArgs("PerfCat.SkillCombat.Stop")
  end,
  Play = function(args)
    HandleCmdWithArgs("PerfCat.SkillCombat.Play", args)
  end,
  Pause = function(args)
    HandleCmdWithArgs("PerfCat.SkillCombat.Pause", args)
  end,
  Crash = function(args)
    HandleCmdWithArgs("PerfCat.SkillCombat.Crash", args)
  end
}

function PerfCatCmd.ExecCmdCurrentWorld(cmd)
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(UE4Helper.GetCurrentWorld(), cmd)
end

function PerfCatCmd.EnableShaderComplexityPostProcess()
  PerfCatCmd.ExecCmdCurrentWorld("r.ShaderComplexity.PostProcess.Enable 1")
end

function PerfCatCmd.DisableShaderComplexityPostProcess()
  PerfCatCmd.ExecCmdCurrentWorld("r.ShaderComplexity.PostProcess.Enable 0")
end

function PerfCatCmd.DisableScreenMsg()
  PerfCatCmd.ExecCmdCurrentWorld("DisableAllScreenMessages")
end

function PerfCatCmd.EnableScreenMsg()
  PerfCatCmd.ExecCmdCurrentWorld("EnableAllScreenMessages")
end

function PerfCatCmd.EnableNRCStats()
  PerfCatCmd.ExecCmdCurrentWorld("r.EnableNRCStats 1")
end

function PerfCatCmd.DisableNRCStats()
  PerfCatCmd.ExecCmdCurrentWorld("r.EnableNRCStats 0")
end

function PerfCatCmd.SetViewMode(viewmode)
  UE4.UPerfCatFunctionLibrary.SetViewMode(string.format("%s", viewmode))
end

return PerfCatCmd
