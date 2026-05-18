local Base = require("NewRoco.AI.BehaviorTree.Actions.LuaActionPlaySkill")
local LuaActionPlayPerceptionEffect = Base:Extend("LuaActionPlayChargeSkill")
local HIDDEN_FLAG = 4

function LuaActionPlayPerceptionEffect:OnStart(AIController, ...)
  local owner = AIController
  self.owner = owner
  self.interrupted = false
  self.isPassive = true
  local npc = owner.Npc
  local otherHiddenFlags = npc.hiddenFlag & ~(1 << HIDDEN_FLAG)
  if otherHiddenFlags > 0 then
    return self:Finish(true)
  end
  local skillPath = _G.UEPath.NPC_PERCEPT_EFFECT[self.Effect:GetValue(owner)]
  if not skillPath then
    self.owner = nil
    return self:Finish(false)
  end
  self:PlaySkillByPath(npc, skillPath, false, _G.PriorityEnum.Passive_World_AI_HeadEffect)
end

function LuaActionPlayPerceptionEffect:CleanUp(stopMontage)
  if self.owner then
    if stopMontage and self.owner.Npc then
      self.owner.Npc:StopAllMontage(0.1)
    end
    self.owner = nil
  end
  self.skillObj = nil
  self._npc = nil
  self._interruptSkill = nil
end

return LuaActionPlayPerceptionEffect
