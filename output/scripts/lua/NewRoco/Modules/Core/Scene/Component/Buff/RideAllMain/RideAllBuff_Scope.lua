local Base = require("NewRoco.Modules.Core.Scene.Component.Buff.RideAllMain.RideAllBuff_SkillBase")
local StatType = require("NewRoco.Modules.Core.Scene.Component.Stat.StatType")
local AbilityEvent = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityEvent")
local UILayerEvent = require("Core.NRCPanelLayer.UILayerEvent")
local RideAllBuff_Scope = Base:Extend("RideAllBuff_Scope")

function RideAllBuff_Scope:OnBuffBegin(Owner, SkillConf)
  Base.OnBuffBegin(self, Owner, SkillConf)
  self.CameraABP = self.owner:GetUEController().PlayerCameraManager:GetCameraAnimInstance()
  self._cachedMoveType = self.RideComp.RideMoveType
end

function RideAllBuff_Scope:OnStartCostVitalityFinish(StartCostSuccess)
  if StartCostSuccess then
    self.CameraABP.RideScope = true
    self.CameraABP.ScopeFOV = tonumber(self.SkillConf.move_param_1)
    self.CameraABP.ScopeOffsetZ = tonumber(self.SkillConf.move_param_2)
    self.owner.abilityComponent:SendEvent(AbilityEvent.ON_BUFF_LOOP_BEGIN, self._abilityID)
    if self.owner.inputComponent then
      self.owner.inputComponent:SetIgnoreMoveInput(self, true)
    end
    self.RidePet.RotationToCtrl = true
    if self.owner.isLocal then
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(1874, "RideAllBuff_Scope:Start")
    end
  else
    self:StartFail()
  end
end

function RideAllBuff_Scope:OnBuffUpdate(deltaTime)
  if not self:CanScope() then
    self:StopActiveSKill()
    return
  end
end

function RideAllBuff_Scope:CanScope()
  if self.RideComp.RideMoveType == ProtoEnum.SceneRideAllType.SRAT_FLY then
    return false
  end
  if self.owner.vitalityComponent:GetCurVitality() <= self.SkillConf.vitality_cost.min_start then
    return false
  end
  return true
end

function RideAllBuff_Scope:OnFullScreenOpened()
  self:StopActiveSKill()
end

function RideAllBuff_Scope:OnBuffFinish(param)
  Base.OnBuffFinish(self, param)
  self.CameraABP.RideScope = false
  if self.owner.isLocal then
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1875, "RideAllBuff_Scope:Start")
  end
  if self.RidePet then
    self.RidePet.RotationToCtrl = false
  end
  self.owner.abilityComponent:SendEvent(AbilityEvent.ON_BUFF_LOOP_END, self._abilityID)
  if self.owner.inputComponent then
    self.owner.inputComponent:SetIgnoreMoveInput(self, false)
  end
end

function RideAllBuff_Scope:OnRidePetChangeMoveType()
  if self.RideComp.RideMoveComp.MovementMode == UE.EMovementMode.MOVE_Falling then
    return
  end
  if self._cachedMoveType == self.RideComp.RideMoveType then
    return
  end
  self:StopActiveSKill()
end

return RideAllBuff_Scope
