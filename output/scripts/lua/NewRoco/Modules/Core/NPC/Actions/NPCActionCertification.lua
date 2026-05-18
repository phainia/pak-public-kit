local NPCActionModelBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local Base = NPCActionModelBase
local NPCActionCertification = Base:Extend("NPCActionCertification")

function NPCActionCertification:ExecuteWithModel()
  _G.NRCModeManager:DoCmd(_G.ActivityModuleCmd.OnCmdOpenCertificationBlessingMain, self)
end

function NPCActionCertification:GetActivityId()
  return tonumber(self.Config.action_param1)
end

return NPCActionCertification
