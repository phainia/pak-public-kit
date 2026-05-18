local RocoSkillAction = require("NewRoco.Modules.Core.Battle.Skill.RocoSkillAction")
local RocoTimeChangeAction = RocoSkillAction:Extend("RocoTimeChangeAction")
local NRCModuleManager = _G.NRCModuleManager

function RocoTimeChangeAction:ChangeTime(time)
  if self.timeCallback then
    self.timeCallback:UpdateTime(time)
  end
end

function RocoTimeChangeAction:GetGameTime()
  return NRCModuleManager:DoCmd(EnvSystemModuleCmd.GetCurrentTime) / 3600
end

function RocoTimeChangeAction:RequestTime()
  self.timeCallback = NRCModuleManager:DoCmd(EnvSystemModuleCmd.RegisterTime, 0)
end

function RocoTimeChangeAction:ReleaseTime()
  NRCModuleManager:DoCmd(EnvSystemModuleCmd.ReleaseTime, self.timeCallback)
  self.timeCallback = nil
end

return RocoTimeChangeAction
