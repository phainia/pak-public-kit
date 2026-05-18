local MissileEvent = require("NewRoco.Modules.Core.Missile.MissileEvent")
local WorldCombatSkillContext = Class()

function WorldCombatSkillContext:Ctor(skillId, caster, target, targetPos, interrupt)
  self.skillId = skillId
  self.caster = caster
  self.target = target
  self.targetPos = targetPos
  self.dynamicData = {}
  self.bbCache = {}
  self.actionIdx = 0
  self.SkillStage = Enum.WorldSkillStage.WKS_NONE
  self.canInterrupt = interrupt or false
end

function WorldCombatSkillContext:UpdateDynamicData(key, value)
  self.dynamicData[key] = value
end

function WorldCombatSkillContext:GetDynamicData(key)
  return self.dynamicData[key]
end

function WorldCombatSkillContext:RemoveDynamicData(key)
  table.removeKey(key)
end

function WorldCombatSkillContext:GetActionIdx()
  local idx = self.actionIdx
  self.actionIdx = self.actionIdx + 1
  return idx
end

function WorldCombatSkillContext:CleanUp()
  if self.caster then
    self.caster:RemoveListeners(MissileEvent.ON_MISSILE_CREATE)
  else
    Log.Error("===amonsu====WorldCombatSkillContext====CleanUp==", "self.caster is nil")
  end
  self.skillId = nil
  self.caster = nil
  self.target = nil
  self.targetPos = nil
  self.dynamicData = {}
  self.actionIdx = 0
  self.completeCallback = nil
  self.bbCache = {}
  self.skillInfo = nil
  self.SkillStage = Enum.WorldSkillStage.WKS_NONE
  if not NRCEnv:IsLocalMode() then
    local missileModule = NRCModuleManager:GetModule("MissileModule")
    missileModule:ClearUnlaunchedRes()
  end
end

return WorldCombatSkillContext
