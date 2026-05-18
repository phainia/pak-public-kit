local NPCActionModelBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local Base = NPCActionModelBase
local NPCActionTurnAround = Base:Extend("NPCActionTurnAround")

function NPCActionTurnAround:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionTurnAround:ExecuteWithModel()
  NRCModeManager:GetCurMode():DisablePanelByLayer(Enum.UILayerType.UI_LAYER_MAIN)
  local CampFire = self:GetOwnerNPCView()
  self:Finish()
end

function NPCActionTurnAround:OnCameraStartEnd()
end

return NPCActionTurnAround
