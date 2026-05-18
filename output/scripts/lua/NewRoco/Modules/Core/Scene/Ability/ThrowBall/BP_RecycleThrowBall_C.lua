require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityBase")
local AbilityHelperManager = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityHelperManager")
local AbilityID = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityID")
local BP_RecycleThrowBall_C = Base:Extend("BP_RecycleThrowBall_C")

function BP_RecycleThrowBall_C:Start(OnFinished, Session, ...)
  Base.Start(self, OnFinished)
  local gid = NRCModuleManager:DoCmd(MainUIModuleCmd.GetSelectedPetGid)
  local pet = self.caster:GetPetByGid(gid)
  if pet and pet:GetStatus() == ProtoEnum.WorldPlayerPetStatusType.WPPST_IN_RIDE then
    local helper = AbilityHelperManager.GetHelper(AbilityID.RIDE_ALL_OFF)
    if helper then
      helper:HandleStatus(self.caster, false, true)
    end
  elseif Session then
    if Session.RecycleFromAbility then
      Session:RecycleFromAbility()
    else
      Log.Error("\229\135\186\231\142\176\228\184\165\233\135\141\230\138\165\233\148\153\239\188\140RecycleFromAbility is nil")
    end
  end
  self:Finish()
end

function BP_RecycleThrowBall_C:Finish()
  Base.Finish(self)
end

return BP_RecycleThrowBall_C
