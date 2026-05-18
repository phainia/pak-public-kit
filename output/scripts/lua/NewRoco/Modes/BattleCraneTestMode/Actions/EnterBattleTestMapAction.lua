local NRCModeAction = require("Core.NRCMode.NRCModeAction")
local EnterBattleTestMapAction = NRCModeAction:Extend("EnterBattleTestMapAction")

function EnterBattleTestMapAction:Ctor(name, properties)
  NRCModeAction.Ctor(self, name, properties)
end

function EnterBattleTestMapAction:OnEnter()
  Log.Debug("yukaheTestMap \230\181\139\232\175\149action.OnEnter")
  self:Finish()
end

function EnterBattleTestMapAction:OnExit()
end

return EnterBattleTestMapAction
