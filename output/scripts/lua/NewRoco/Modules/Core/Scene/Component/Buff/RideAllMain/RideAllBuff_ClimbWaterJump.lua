local Base = require("NewRoco.Modules.Core.Scene.Component.Buff.RideAllMain.RideAllBuff_SkillBase")
local StatType = require("NewRoco.Modules.Core.Scene.Component.Stat.StatType")
local AbilityEvent = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityEvent")
local Stat = require("NewRoco.Modules.Core.Scene.Component.Stat.Stat")
local RideAllBuff_ClimbWaterJump = Base:Extend("RideAllBuff_ClimbWaterJump")

function RideAllBuff_ClimbWaterJump:OnBuffBegin(Owner, SkillConf)
  Base.OnBuffBegin(self, Owner, SkillConf, false)
  self.ClimbMovement = self.RidePet.CharacterClimbWaterFallMovement
  if SkillConf.move_param_1 then
    self.ClimbMovement.ClimbDashCurve = _G.PlayerResourceManager:GetStaticResource(SkillConf.move_param_1)
  end
  self:AnalyPropertyModify(SkillConf)
  if self.propertyModify[1] then
    if 0 == self.modifyMode then
      Log.Error("\230\148\128\231\136\172\232\183\179\232\183\131\230\154\130\228\184\141\230\148\175\230\140\129\229\138\160\230\179\149\232\191\144\231\174\151\239\188\140\232\175\183\233\128\154\231\159\165\231\173\150\229\136\146\230\172\167\233\152\179\231\137\185\229\142\187\230\155\180\230\148\185")
    elseif 1 == self.modifyMode then
      self.owner.statComponent:ApplyStat(StatType.CLIMB_SPEED_PROPERTY_RATIO, self.modifyValue / 10000, Stat.StatApplyType.Percent, self.ClimbMovement)
    end
  end
  if not self.ClimbMovement:IsClimbDashing() then
    self:StartCostVitality()
  end
end

function RideAllBuff_ClimbWaterJump:OnStartCostVitalityFinish(StartCostSuccess)
  if StartCostSuccess then
    self.ClimbMovement:TryClimbDashing()
    self.RidePet.RocoAudio:PlayAudioToSelf(3530063)
  end
end

function RideAllBuff_ClimbWaterJump:OnRemotePlayerBuffBegin(Owner, SkillConf)
  Base.OnRemotePlayerBuffBegin(self, Owner, SkillConf, false)
  self.RidePet.RocoAudio:PlayAudioToSelf(3530063)
end

function RideAllBuff_ClimbWaterJump:OnUpdate(deltaTime)
  if self.ClimbMovement and self.ClimbMovement:IsClimbDashing() then
    return
  end
  if self.propertyModify and self.propertyModify[1] then
    if 0 == self.modifyMode then
      Log.Error("\230\148\128\231\136\172\232\183\179\232\183\131\230\154\130\228\184\141\230\148\175\230\140\129\229\138\160\230\179\149\232\191\144\231\174\151\239\188\140\232\175\183\233\128\154\231\159\165\231\173\150\229\136\146\230\172\167\233\152\179\231\137\185\229\142\187\230\155\180\230\148\185")
    elseif 1 == self.modifyMode then
      self.owner.statComponent:ApplyStat(StatType.CLIMB_SPEED_PROPERTY_RATIO, -1 * self.modifyValue / 10000, Stat.StatApplyType.Percent, self.ClimbMovement)
    end
  end
  self:StopActiveSKill()
end

return RideAllBuff_ClimbWaterJump
