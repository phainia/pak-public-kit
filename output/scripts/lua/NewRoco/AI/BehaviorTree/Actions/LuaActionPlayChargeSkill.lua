local Base = require("NewRoco.AI.BehaviorTree.Actions.LuaActionPlaySkill")
local LuaActionPlayChargeSkill = Base:Extend("LuaActionPlayChargeSkill")
local errorCooldown = 0

function LuaActionPlayChargeSkill:OnStart(AIController, ...)
  local owner = AIController
  self.owner = owner
  self.interrupted = false
  local npc = owner.Npc
  local skillPath = npc.AIComponent:GetChargeSkillPath()
  if string.IsNilOrEmpty(skillPath) then
    errorCooldown = errorCooldown - 1
    if errorCooldown <= 0 then
      Log.ErrorFunc(function()
        return "PlayChargeSkill: \230\156\170\230\137\190\229\136\176\232\147\132\229\138\155\230\138\128\232\131\189\239\188\140\230\159\165\228\184\128\230\159\165\233\133\141\231\189\174\239\188\129 " .. owner.Npc:DebugNPCNameAndID()
      end)
      errorCooldown = 100
    end
    self.owner = nil
    return self:Finish(false)
  end
  self:PlaySkillByPath(npc, skillPath, true)
end

return LuaActionPlayChargeSkill
