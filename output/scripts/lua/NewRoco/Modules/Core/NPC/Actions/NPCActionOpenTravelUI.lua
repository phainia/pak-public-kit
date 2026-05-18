local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local BigMapModuleCmd = require("NewRoco.Modules.System.BigMap.BigMapModuleCmd")
local Base = NPCActionBase
local NPCActionOpenTravelUI = Base:Extend("NPCActionOpenTravelUI")

function NPCActionOpenTravelUI:ExecuteWithModel()
  _G.NRCModuleManager:DoCmd(BigMapModuleCmd.OpenTravelMainMap, self)
end

function NPCActionOpenTravelUI:EndAction()
  self:Finish()
end

return NPCActionOpenTravelUI
