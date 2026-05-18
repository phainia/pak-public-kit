local Base = require("NewRoco.Modules.Core.Scene.Component.RidePet.PassiveSkill_Base")
local PassiveSkill_Temperature = Base:Extend("PassiveSkill_Temperature")

function PassiveSkill_Temperature:Start()
  Log.Debug("PassiveSkill_Temperature:Start")
end

function PassiveSkill_Temperature:Stop()
  Log.Debug("PassiveSkill_Temperature:Stop")
end

return PassiveSkill_Temperature
