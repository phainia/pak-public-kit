local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityBase")
local ABEnum = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityEnum")
local VitalityUtil = require("NewRoco.Modules.Core.Scene.Component.Vitality.VitalityUtil")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local ClimbDash = Base:Extend("ClimbDash")

function ClimbDash:Start(onFinished)
  Log.Debug("ClimbDash Start")
  local movement = self.caster.viewObj.CharacterMovement
  if not movement:IsClimbDashing() then
    movement:TryClimbDashing()
    self.caster:SendEvent(PlayerModuleEvent.ON_UPDATE_VITALITY_COST, ProtoEnum.WorldPlayerStatusType.WPST_DASHING, self.helper.basic_movement_conf.id)
    self:EnterState(ABEnum.AbilityState.Casting)
  end
end

function ClimbDash:Update(deltaTime)
  if self:IsCasting() then
    local movement = self.caster.viewObj.CharacterMovement
    if not movement:IsClimbDashing() then
      self:Finish()
    end
  end
end

function ClimbDash:Finish(Force)
  Log.Debug("ClimbDash Finish")
  self.caster.statusComponent:RemoveStatus(ProtoEnum.WorldPlayerStatusType.WPST_CLIMB_DASH)
  Base.Finish(self, Force)
end

return ClimbDash
