local Base = require("NewRoco.Modules.Core.Scene.Component.Buff.ScenePlayerBuff")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local ScenePlayerVitalityRecoverBuff = Base:Extend("ScenePlayerVitalityRecoverBuff")
local BuffStatus = {NONE = 0, ACTIVE = 1}

function ScenePlayerVitalityRecoverBuff:OnBegin(owner, vitalityID)
  Log.Debug("[SocialComponent] ScenePlayerVitalityRecoverBuff OnBegin")
  self.vitalityComp = self.owner.vitalityComponent
  local config = DataConfigManager:GetVitalityConf(vitalityID or 8)
  self.vitality_recover_percent = 0
  self.vitality_recover = 0
  if config then
    self.vitality_recover_percent = config.vitality_recover_percent
    self.vitality_recover = config.vitality_recover
  else
    Log.Error("ScenePlayerVitalityRecoverBuff OnBegin vitalityID = %d not found", vitalityID)
  end
  self.vitalityComp:AddRecoverBuff(self.vitality_recover_percent, self.vitality_recover)
  self.owner:SendEvent(PlayerModuleEvent.ON_VITALITY_BUFF_UPDATE, true)
  self.loopEffectID = 0
  self.curStatus = BuffStatus.NONE
end

function ScenePlayerVitalityRecoverBuff:OnUpdate(deltaTime)
  local maxVitality = self.vitalityComp:GetMaxVitality()
  local curVitality = self.vitalityComp:GetCurVitality()
  if maxVitality > curVitality then
    self:RecoverVitality(maxVitality, deltaTime)
  else
    local hasCost = self.vitalityComp:HasCostVitality()
    if hasCost then
      self:RecoverVitality(maxVitality, deltaTime)
    else
      self:StopRecover()
    end
  end
end

function ScenePlayerVitalityRecoverBuff:StopRecover()
  if self.curStatus == BuffStatus.ACTIVE then
    self:StopVitalityRecoverEffect()
    self.curStatus = BuffStatus.NONE
    self.delayTime = 1
  end
end

function ScenePlayerVitalityRecoverBuff:RecoverVitality(maxVitality, deltaTime)
  if self.curStatus == BuffStatus.NONE then
    self.curStatus = BuffStatus.ACTIVE
    self.delayTime = nil
    self:PlayVitalityRecoverEffect()
  end
end

function ScenePlayerVitalityRecoverBuff:PlayVitalityRecoverEffect()
end

function ScenePlayerVitalityRecoverBuff:StopVitalityRecoverEffect()
end

function ScenePlayerVitalityRecoverBuff:OnFinish()
  Log.Debug("[SocialComponent] ScenePlayerVitalityRecoverBuff OnFinish")
  self.owner:SendEvent(PlayerModuleEvent.ON_VITALITY_BUFF_UPDATE, false)
  self.vitalityComp:RemoveRecoverBuff()
  self:StopVitalityRecoverEffect()
end

return ScenePlayerVitalityRecoverBuff
