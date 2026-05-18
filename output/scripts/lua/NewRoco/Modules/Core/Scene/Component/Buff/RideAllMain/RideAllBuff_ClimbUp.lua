local Base = require("NewRoco.Modules.Core.Scene.Component.Buff.RideAllMain.RideAllBuff_SkillBase")
local StatType = require("NewRoco.Modules.Core.Scene.Component.Stat.StatType")
local AbilityEvent = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityEvent")
local RideAllBuff_ClimbUp = Base:Extend("RideAllBuff_ClimbJump")
local Stat = require("NewRoco.Modules.Core.Scene.Component.Stat.Stat")

function RideAllBuff_ClimbUp:OnBuffBegin(Owner, SkillConf)
  Base.OnBuffBegin(self, Owner, SkillConf, false)
  self.ClimbMovement = self.RidePet.CharacterClimbMovement
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

function RideAllBuff_ClimbUp:OnStartCostVitalityFinish(StartCostSuccess)
  if StartCostSuccess then
    self.ClimbMovement:TryClimbDashing()
    if self.owner.isLocal then
      _G.NRCAudioManager:PlaySound2DAuto(1220003273, "RideAllBuff_ClimbUp")
    else
      _G.NRCAudioManager:PlaySound3DWithActorAuto(1220003273, self.owner.viewObj, "RideAllBuff_ClimbUp")
    end
  end
end

function RideAllBuff_ClimbUp:OnRemotePlayerBuffBegin(Owner, SkillConf)
  Base.OnRemotePlayerBuffBegin(self, Owner, SkillConf, false)
  _G.NRCAudioManager:PlaySound3DWithActorAuto(1220003273, self.owner.viewObj, "RideAllBuff_ClimbUp")
end

function RideAllBuff_ClimbUp:OnBuffUpdate(deltaTime)
  if self.ClimbMovement and self.ClimbMovement:IsClimbDashing() then
    return
  end
  if self.propertyModify[1] then
    if 0 == self.modifyMode then
      Log.Error("\230\148\128\231\136\172\232\183\179\232\183\131\230\154\130\228\184\141\230\148\175\230\140\129\229\138\160\230\179\149\232\191\144\231\174\151\239\188\140\232\175\183\233\128\154\231\159\165\231\173\150\229\136\146\230\172\167\233\152\179\231\137\185\229\142\187\230\155\180\230\148\185")
    elseif 1 == self.modifyMode then
      self.owner.statComponent:ApplyStat(StatType.CLIMB_SPEED_PROPERTY_RATIO, -1 * self.modifyValue / 10000, Stat.StatApplyType.Percent, self.ClimbMovement)
    end
  end
  self:StopActiveSKill()
end

return RideAllBuff_ClimbUp
