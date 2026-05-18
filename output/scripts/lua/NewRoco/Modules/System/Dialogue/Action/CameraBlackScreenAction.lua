local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local DialogueUtils = require("NewRoco.Modules.System.Dialogue.DialogueUtils")
local DialogueActionBase = require("NewRoco.Modules.System.Dialogue.Action.DialogueActionBase")
local Base = DialogueActionBase
local CameraBlackScreenAction = Base:Extend("CameraBlackScreenAction")
FsmUtils.MergeMembers(Base, CameraBlackScreenAction, {
  {
    name = "DialogueConf",
    type = "var"
  },
  {
    name = "CameraSetting",
    type = "var"
  },
  {
    name = "ParentModule",
    type = "var"
  }
})

function CameraBlackScreenAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.Handler = -1
end

function CameraBlackScreenAction:OnEnter()
  if DialogueUtils.SkipDialogue then
    self:Finish()
    return
  end
  self:InjectProperties()
  local bInBattle = self:GetProperty("bInBattle")
  local bUseBattleCamera = self:GetProperty("bUseBattleCamera")
  if bInBattle and bUseBattleCamera then
    self:Finish()
  elseif bInBattle then
  elseif self.CameraSetting.camera_switch_type == Enum.CameraSwitchType.CAMST_BLACK then
    self:AddListener()
    NRCModuleManager:DoCmd(DialogueModuleCmd.FadeInDialogueCameraBlack)
  else
    self:Finish()
  end
end

function CameraBlackScreenAction:OnExit()
  self:RemoveListener()
  self:ClearDelayHandler()
end

function CameraBlackScreenAction:ClearDelayHandler()
  if self.Handler <= 0 then
    return
  end
  _G.DelayManager:CancelDelayById(self.Handler)
  self.Handler = -1
end

function CameraBlackScreenAction:BlackFinish()
  self.Handler = _G.DelayManager:DelaySeconds(0.5, self.Finish, self)
end

function CameraBlackScreenAction:OnFinish()
end

function CameraBlackScreenAction:AddListener()
  local ParentModule = self:GetProperty("ParentModule")
  if ParentModule then
    ParentModule:RegisterEvent(self, DialogueModuleEvent.DialogueCameraBlackFadeInDone, self.BlackFinish)
  end
end

function CameraBlackScreenAction:RemoveListener()
  local ParentModule = self:GetProperty("ParentModule")
  if ParentModule then
    ParentModule:UnRegisterEvent(self, DialogueModuleEvent.DialogueCameraBlackFadeInDone)
  end
end

return CameraBlackScreenAction
