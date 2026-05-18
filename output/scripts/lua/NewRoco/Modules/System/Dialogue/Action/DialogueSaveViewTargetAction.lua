local DialogueUtils = require("NewRoco.Modules.System.Dialogue.DialogueUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local DialogueActionBase = require("NewRoco.Modules.System.Dialogue.Action.DialogueActionBase")
local Base = DialogueActionBase
local DialogueSaveViewTargetAction = Base:Extend("DialogueSaveViewTarget")
FsmUtils.MergeMembers(Base, DialogueSaveViewTargetAction, {
  {name = "Transform", type = "table"}
})

function DialogueSaveViewTargetAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function DialogueSaveViewTargetAction:OnEnter()
  self:Finish()
end

function DialogueSaveViewTargetAction:OnFinish()
  local Player = DialogueUtils.GetPlayer()
  local Controller = DialogueUtils.GetController(Player)
  local CameraActor = Controller.CameraActor
  if CameraActor then
    self:SetProperty("Transform", CameraActor:GetTransform())
  else
    Log.Warning("\230\151\160\230\179\149\232\142\183\229\143\150CameraActor!!!")
  end
end

function DialogueSaveViewTargetAction:OnExit()
end

return DialogueSaveViewTargetAction
