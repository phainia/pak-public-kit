local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local Base = NPCActionBase
local NPCActionOpenBossChallenge = Base:Extend("NPCActionOpenBossChallenge")

function NPCActionOpenBossChallenge:ExecuteWithModel()
  local View = self:GetOwnerNPCView()
  if not View then
    return true
  end
  _G.NRCModuleManager:DoCmd(LevelSelectionModuleCmd.OpenLeveSelect, self)
end

function NPCActionOpenBossChallenge:Finish(success, data, param)
  Base.Finish(self, success, data, param)
end

return NPCActionOpenBossChallenge
