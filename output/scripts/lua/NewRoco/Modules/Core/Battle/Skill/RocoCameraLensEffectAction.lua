local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local RocoSkillAction = require("NewRoco.Modules.Core.Battle.Skill.RocoSkillAction")
local RocoCameraLensEffectAction = RocoSkillAction:Extend("RocoCameraLensEffectAction")

function RocoCameraLensEffectAction:OnActionInitialized()
  if self:IsSkillEditor() then
    return
  end
  local skill = self:GetSkill()
  if skill and skill._playInBigworld then
    self:RegisterEvent()
  end
end

function RocoCameraLensEffectAction:OnActionDestruct()
  if self:IsSkillEditor() then
    return
  end
  self:UnRegisterEvent()
end

function RocoCameraLensEffectAction:OnBattleStartEvent()
  if self and UE.UObject.IsValid(self) and self.ClearEffect then
    self:ClearEffect()
  end
end

function RocoCameraLensEffectAction:RegisterEvent()
  if self._reg_event then
    return
  end
  self._reg_event = true
  _G.NRCEventCenter:RegisterEvent("RocoCameraLensEffectAction", self, BattleEvent.BattleStartFocus, self.OnBattleStartEvent)
end

function RocoCameraLensEffectAction:UnRegisterEvent()
  if not self._reg_event then
    return
  end
  self._reg_event = false
  _G.NRCEventCenter:UnRegisterEvent(self, BattleEvent.BattleStartFocus, self.OnBattleStartEvent)
end

function RocoCameraLensEffectAction:GetNpcCaster()
  local caster = self:GetCasterActor()
  local npc = caster and caster.sceneCharacter
  if npc and npc.config then
    return npc
  end
end

return RocoCameraLensEffectAction
