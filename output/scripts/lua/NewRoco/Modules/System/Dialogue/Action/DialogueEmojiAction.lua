local DialogueUtils = require("NewRoco.Modules.System.Dialogue.DialogueUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BubbleComponent = require("NewRoco.Modules.Core.Scene.Component.Bubble.BubbleComponent")
local DialogueActionBase = require("NewRoco.Modules.System.Dialogue.Action.DialogueActionBase")
local Base = DialogueActionBase
local DialogueEmojiAction = Base:Extend("DialogueEmojiAction")
FsmUtils.MergeMembers(Base, DialogueEmojiAction, {
  {name = "TargetNPC", type = "var"},
  {
    name = "DialogueConf",
    type = "var"
  },
  {name = "NpcIDs", type = "var"}
})

function DialogueEmojiAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function DialogueEmojiAction:OnEnter()
  self:InjectProperties()
  if DialogueUtils.SkipDialogue then
    self:Finish()
    return
  end
  Log.Debug("DialogueEmojiAction:OnEnter")
  if not self.DialogueConf then
    self:Finish()
    return
  end
  local Performs = self.DialogueConf.actor_perform
  if not Performs or 0 == #Performs then
    self:Finish()
    return
  end
  for _, Perform in ipairs(Performs) do
    self:ConsumeActorPerform(Perform)
  end
  self:Finish()
end

function DialogueEmojiAction:ConsumeActorPerform(Perform)
  if not Perform then
    return
  end
  local actor = self:GetActor(Perform.actor)
  if not actor then
    return
  end
  local emotion = Perform.emotion
  if not emotion then
    return
  end
  if 0 == emotion then
    return
  end
  local Comp = actor:EnsureComponent(BubbleComponent)
  Comp:Play(nil, emotion)
end

function DialogueEmojiAction:OnExit()
  Log.Debug("DialogueEmojiAction:OnExit")
end

return DialogueEmojiAction
