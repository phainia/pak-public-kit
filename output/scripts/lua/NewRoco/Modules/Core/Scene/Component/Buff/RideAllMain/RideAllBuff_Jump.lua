local Base = require("NewRoco.Modules.Core.Scene.Component.Buff.RideAllMain.RideAllBuff_SkillBase")
local StatType = require("NewRoco.Modules.Core.Scene.Component.Stat.StatType")
local AbilityEvent = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityEvent")
local RideAllBuff_Jump = Base:Extend("RideAllBuff_Jump")

function RideAllBuff_Jump:OnBuffBegin(Owner, SkillConf)
  Base.OnBuffBegin(self, Owner, SkillConf, false)
  local RidePet = self.owner.viewObj.RidePet
  if RidePet.CharacterMovement:CanJump() then
    self:StartCostVitality()
  end
  self:StartFail()
end

function RideAllBuff_Jump:OnStartCostVitalityFinish(StartCostSuccess)
  if StartCostSuccess then
    local RidePet = self.owner.viewObj.RidePet
    local FxPlayer = RidePet.RocoMoveFx.CurrentPlayer
    if FxPlayer and FxPlayer.PlayWaterJumpFx then
      FxPlayer:PlayWaterJumpFx()
    end
    local SkillConf = self.SkillConf
    self:AnalyPropertyModify(SkillConf)
    local JumpZSpeed = tonumber(SkillConf.move_param_5)
    local SkillJumpZSpeed = self.owner.statComponent:GetValue(StatType.SKILL_JUMP_Z_SPEED)
    if self.propertyModify[5] then
      if 0 == self.modifyMode then
        JumpZSpeed = JumpZSpeed * SkillJumpZSpeed + self.modifyValue
      elseif 1 == self.modifyMode then
        JumpZSpeed = JumpZSpeed * SkillJumpZSpeed + JumpZSpeed * self.modifyValue / 10000
      else
        JumpZSpeed = JumpZSpeed * SkillJumpZSpeed
      end
    else
      JumpZSpeed = JumpZSpeed * SkillJumpZSpeed
    end
    local JumpXYSpeed = tonumber(SkillConf.move_param_6)
    local AllJumpXYSpeed = JumpXYSpeed
    local SkillJumpXSpeed = self.owner.statComponent:GetValue(StatType.SKILL_JUMP_X_SPEED)
    if self.propertyModify[6] then
      if 0 == self.modifyMode then
        AllJumpXYSpeed = AllJumpXYSpeed * SkillJumpXSpeed + self.modifyValue
      elseif 1 == self.modifyMode then
        AllJumpXYSpeed = AllJumpXYSpeed * SkillJumpXSpeed + AllJumpXYSpeed * self.modifyValue / 10000
      else
        AllJumpXYSpeed = AllJumpXYSpeed * SkillJumpXSpeed
      end
    else
      AllJumpXYSpeed = AllJumpXYSpeed * SkillJumpXSpeed
    end
    RidePet.CharacterMovement:Jump(tonumber(SkillConf.move_param_7), tonumber(SkillConf.move_param_8), JumpZSpeed, JumpXYSpeed, AllJumpXYSpeed - JumpXYSpeed)
    RidePet.BP_RidePetRoleHpComponent:ResetFalling()
    RidePet.BP_RidePetRoleHpComponent.lastMovementMode = UE.EMovementMode.MOVE_Falling
  else
    self:StartFail()
  end
end

function RideAllBuff_Jump:OnRemotePlayerBuffBegin(Owner, SkillConf)
  Base.OnRemotePlayerBuffBegin(self, Owner, SkillConf)
  _G.NRCAudioManager:PlaySound3DWithActorAuto(1220003273, self.owner.viewObj, "RideAllBuff_Jump")
  local RidePet = self.owner.viewObj.RidePet
  if RidePet and RidePet.RocoMoveFx.PlayWaterJumpFx then
    RidePet.RocoMoveFx:PlayWaterJumpFx()
  end
end

return RideAllBuff_Jump
