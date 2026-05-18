local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local Base = NPCActionBase
local NPCActionMiracleExchange = Base:Extend("NPCActionMiracleExchange")

function NPCActionMiracleExchange:ExecuteWithModel()
  _G.NRCModuleManager:DoCmd(MiracleExchangeModuleCmd.OpenMiracleExchangeMain, self)
end

return NPCActionMiracleExchange
