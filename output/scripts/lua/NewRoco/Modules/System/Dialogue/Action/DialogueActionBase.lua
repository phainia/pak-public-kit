local DialogueUtils = require("NewRoco.Modules.System.Dialogue.DialogueUtils")
local FsmAction = require("NewRoco.Modules.Core.Fsm.FsmAction")
local Base = FsmAction
local DialogueActionBase = Base:Extend("DialogueActionBase")

function DialogueActionBase:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function DialogueActionBase:GetActor(ActorID)
  return DialogueUtils.GrabActor(ActorID, self.fsm)
end

function DialogueActionBase:GetActorView(ActorID)
  return DialogueUtils.GrabActorView(ActorID, self.fsm)
end

function DialogueActionBase:GetActorTransform(ActorID)
  return DialogueUtils.GrabActorTransform(ActorID, self.fsm)
end

return DialogueActionBase
