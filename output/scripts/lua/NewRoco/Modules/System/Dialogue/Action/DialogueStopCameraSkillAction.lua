local DialogueUtils = require("NewRoco.Modules.System.Dialogue.DialogueUtils")
local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local DialogueActionBase = require("NewRoco.Modules.System.Dialogue.Action.DialogueActionBase")
local Base = DialogueActionBase
local DialogueStopCameraSkillAction = Base:Extend("DialogueStopCameraSkillAction")
FsmUtils.MergeMembers(Base, DialogueStopCameraSkillAction, {})

function DialogueStopCameraSkillAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function DialogueStopCameraSkillAction:OnEnter()
  self:InjectProperties()
  _G.NRCModuleManager:DoCmd(CameraModuleCmd.StopCameraSkillPlaying)
  self:Finish()
end

return DialogueStopCameraSkillAction
