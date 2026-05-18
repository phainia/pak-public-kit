local NPCActionModelBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local Base = NPCActionModelBase
local NPCActionRetractionCompass = Base:Extend("NPCActionRetractionCompass")

function NPCActionRetractionCompass:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionRetractionCompass:ExecuteWithModel()
  local localPlayerObj = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  localPlayerObj:PlayAnim("Yes", 1, 0, 0.1, 0.1, 1)
  self:Finish()
end

function NPCActionRetractionCompass:OnCameraStartEnd()
end

return NPCActionRetractionCompass
