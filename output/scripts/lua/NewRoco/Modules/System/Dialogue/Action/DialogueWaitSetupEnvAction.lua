local DialogueUtils = require("NewRoco.Modules.System.Dialogue.DialogueUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local DialogueActionBase = require("NewRoco.Modules.System.Dialogue.Action.DialogueActionBase")
local Base = DialogueActionBase
local DialogueWaitSetupEnvAction = Base:Extend("DialogueWaitSetupEnvAction")
FsmUtils.MergeMembers(Base, DialogueWaitSetupEnvAction, {
  {name = "TargetNPC", type = "var"},
  {
    name = "DialogueConf",
    type = "var"
  },
  {
    name = "ParentModule",
    type = "var"
  }
})

function DialogueWaitSetupEnvAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function DialogueWaitSetupEnvAction:OnEnter()
  if DialogueUtils.SkipDialogue then
    self:Finish()
    return
  end
  Log.Debug("DialogueWaitSetupEnvAction:OnEnter")
  self:InjectProperties()
  local bInBattle = self:GetProperty("bInBattle")
  if bInBattle then
    self:Finish()
  else
    self:StatusCheck()
    self.timeout = 3
  end
end

function DialogueWaitSetupEnvAction:AddLoadingListener()
  self.TargetNPC:AddEventListener(self, NPCModuleEvent.VIEW_LOADED, self.FinishLoading)
end

function DialogueWaitSetupEnvAction:RemoveLoadingListener()
  self.TargetNPC:RemoveEventListener(self, NPCModuleEvent.VIEW_LOADED, self.FinishLoading)
end

function DialogueWaitSetupEnvAction:AddTurningListener()
  self.TargetNPC:AddEventListener(self, NPCModuleEvent.TURN_END, self.FinishTurning)
end

function DialogueWaitSetupEnvAction:RemoveTurningListener()
  self.TargetNPC:RemoveEventListener(self, NPCModuleEvent.TURN_END, self.FinishTurning)
end

function DialogueWaitSetupEnvAction:FinishLoading()
  self:RemoveLoadingListener()
  Log.Warning("DialogueWaitSetupEnvAction:view obj loaded")
  self:StatusCheck()
end

function DialogueWaitSetupEnvAction:FinishTurning()
  self:RemoveTurningListener()
  Log.Warning("DialogueWaitSetupEnvAction: Turning finish")
  self:StatusCheck()
end

function DialogueWaitSetupEnvAction:StatusCheck()
  if not self.TargetNPC or self.TargetNPC.isDestroy then
    self:Finish()
    return
  end
  if not self.TargetNPC.viewObj then
    Log.Warning("DialogueWaitSetupEnvAction:view obj not loaded")
    self:AddLoadingListener()
    return
  end
  if self.TargetNPC.TurnComponent:IsTurning() and self.DialogueConf.interact_camera_type == Enum.NpcInteractCameraType.NPC_INTERACT_CAMERA_UI then
    Log.Warning("DialogueWaitSetupEnvAction: Turning not finish")
    self:AddTurningListener()
    return
  end
  self:Finish()
end

function DialogueWaitSetupEnvAction:OnFinish()
end

function DialogueWaitSetupEnvAction:OnExit()
end

return DialogueWaitSetupEnvAction
