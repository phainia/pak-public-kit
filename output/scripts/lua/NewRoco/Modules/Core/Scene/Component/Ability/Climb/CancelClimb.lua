local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityBase")
local CancelClimb = Base:Extend("CancelClimb")

function CancelClimb:Start(onFinished)
  local movement = self.caster.viewObj.CharacterMovement
  movement:CancelClimbing()
end

function CancelClimb:Recover(owner)
  local movement = owner.viewObj.CharacterMovement
  movement:CancelClimbing()
end

return CancelClimb
