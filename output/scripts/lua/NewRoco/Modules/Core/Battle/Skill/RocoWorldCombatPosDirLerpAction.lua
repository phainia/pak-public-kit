local RocoSkillAction = require("NewRoco.Modules.Core.Battle.Skill.RocoSkillAction")
local Base = RocoSkillAction
local RocoWorldCombatPosDirLerpAction = Base:Extend("RocoWorldCombatPosDirLerpAction")

function RocoWorldCombatPosDirLerpAction:OnActionStart()
  if not self:IsSkillEditor() and _G.WorldCombatModuleCmd and not _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.IsInOfflineMode) then
    return
  end
  Log.Debug("RocoWorldCombatPosDirLerpAction:OnActionStart")
end

function RocoWorldCombatPosDirLerpAction:OnActionEnd()
  if not self:IsSkillEditor() and _G.WorldCombatModuleCmd and not _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.IsInOfflineMode) then
    return
  end
  Log.Debug("RocoWorldCombatPosDirLerpAction:OnActionEnd")
end

return RocoWorldCombatPosDirLerpAction
