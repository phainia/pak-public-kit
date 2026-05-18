local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local Base = NPCActionBase
local NPCActionMiracleExchangeAnime = Base:Extend("NPCActionMiracleExchangeAnime")

function NPCActionMiracleExchangeAnime:ExecuteWithModel()
  _G.NRCModuleManager:DoCmd(_G.MiracleExchangeModuleCmd.PlayFinishSkill, self)
end

return NPCActionMiracleExchangeAnime
