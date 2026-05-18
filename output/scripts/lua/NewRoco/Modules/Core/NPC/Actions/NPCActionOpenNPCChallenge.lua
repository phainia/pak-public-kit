local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local Base = NPCActionBase
local NPCActionOpenNPCChallenge = Base:Extend("NPCActionOpenNPCChallenge")

function NPCActionOpenNPCChallenge:ExecuteWithModel()
  local View = self:GetOwnerNPCView()
  if not View then
    return true
  end
  _G.NRCModuleManager:DoCmd(LevelSelectionModuleCmd.OpenLeveBattleSilhouette, self)
end

function NPCActionOpenNPCChallenge:Finish(success, data, param)
  Base.Finish(self, success, data, param)
end

return NPCActionOpenNPCChallenge
