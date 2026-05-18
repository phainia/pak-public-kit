local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local DialogueUtils = require("NewRoco.Modules.System.Dialogue.DialogueUtils")
local DialogueActionBase = require("NewRoco.Modules.System.Dialogue.Action.DialogueActionBase")
local Base = DialogueActionBase
local CameraBlackScreenOutAction = Base:Extend("CameraBlackScreenAction")
FsmUtils.MergeMembers(Base, CameraBlackScreenOutAction, {
  {
    name = "CameraSetting",
    type = "var"
  }
})

function CameraBlackScreenOutAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function CameraBlackScreenOutAction:OnEnter()
  self:InjectProperties()
  if DialogueUtils.SkipDialogue then
    self:Finish()
    return
  end
  local bInBattle = self:GetProperty("bInBattle")
  if bInBattle then
    self:Finish()
  elseif self.CameraSetting.camera_switch_type == Enum.CameraSwitchType.CAMST_BLACK then
    _G.NRCEventCenter:DispatchEvent(_G.NRCGlobalEvent.CLOSE_BLACK_SCREEN)
    NRCModuleManager:DoCmd(DialogueModuleCmd.FadeOutDialogueCameraBlack)
    DelayManager:DelaySeconds(0.5, self.Finish, self)
  else
    self:Finish()
  end
end

function CameraBlackScreenOutAction:CloseIt()
end

function CameraBlackScreenOutAction:OnExit()
end

return CameraBlackScreenOutAction
