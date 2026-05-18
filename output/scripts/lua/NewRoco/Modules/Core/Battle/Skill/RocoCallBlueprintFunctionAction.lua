local RocoSkillAction = require("NewRoco.Modules.Core.Battle.Skill.RocoSkillAction")
local RocoCallBlueprintFunctionAction = RocoSkillAction:Extend("RocoCallBlueprintFunctionAction")
local NRCModuleManager = _G.NRCModuleManager

function RocoCallBlueprintFunctionAction:CallFunction(Target, FunctionName)
  if Target and Target[FunctionName] then
    Target[FunctionName](Target)
  end
end

return RocoCallBlueprintFunctionAction
