local DialogueUtils = require("NewRoco.Modules.System.Dialogue.DialogueUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local HiddenComponent = require("NewRoco.Modules.Core.Scene.Component.Hidden.HiddenComponent")
local DialogueActionBase = require("NewRoco.Modules.System.Dialogue.Action.DialogueActionBase")
local Base = DialogueActionBase
local DialogueNPCAnimAction = Base:Extend("DialogueNPCAnimAction")
FsmUtils.MergeMembers(Base, DialogueNPCAnimAction, {
  {name = "bInBattle", type = "var"},
  {name = "TargetNPC", type = "var"},
  {
    name = "TargetNpcBp",
    type = "var"
  },
  {
    name = "DialogueConf",
    type = "var"
  },
  {name = "NpcIDs", type = "var"}
})

function DialogueNPCAnimAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function DialogueNPCAnimAction:OnEnter()
  self:InjectProperties()
  if DialogueUtils.SkipDialogue then
    self:Finish()
    return
  end
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

function DialogueNPCAnimAction:ConsumeActorPerform(Perform)
  if not Perform then
    return
  end
  local Actor = self:GetActor(Perform.actor)
  if not Actor then
    return
  end
  DialogueUtils.ToggleAI(Actor, false)
  if Actor.serverData then
    local ID = Actor.serverData.base.actor_id
    if not table.contains(self.NpcIDs, ID) then
      table.insert(self.NpcIDs, ID)
    end
  end
  if string.IsNilOrEmpty(Perform.action) then
  else
    local bHasLoopAnimation = DialogueUtils.PlayAnim(Actor, Perform.action)
    self:SetProperty("HasLoopAnimation", bHasLoopAnimation)
  end
  if Perform.shakehead then
    Actor = self:GetActor(Perform.actor)
    if Actor and Actor.DoHeadMotion then
      Actor:DoHeadMotion(Perform.shakehead or Enum.HeadMotion.Shake)
    end
  end
  if Perform.hidden_switch and 0 ~= Perform.hidden_switch then
    Actor = Actor or self:GetActor(Perform.actor)
    if Actor then
      local HidComp = Actor:GetComponent(HiddenComponent)
      if HidComp and HidComp:CanHide() then
        if 2 == Perform.hidden_switch then
          HidComp:BeginHide()
        else
          HidComp:EndHide(self, function()
          end)
        end
        if Actor.AIComponent then
          Actor.AIComponent:OnHiddenStatusChangedInDialogue(2 == Perform.hidden_switch, self.DialogueConf and self.DialogueConf.id or 0)
        end
      end
    end
  end
  if Perform.reveal_switch and 0 ~= Perform.reveal_switch then
    Actor = Actor or self:GetActor(Perform.actor)
    if Actor then
      local Hidden = 2 == Perform.reveal_switch
      if Actor.SetHidden then
        Actor:SetHidden(Hidden, 2)
      else
        Actor:SetVisible(not Hidden)
      end
    end
  end
end

function DialogueNPCAnimAction:OnExit()
end

function DialogueNPCAnimAction:OnFinish()
end

return DialogueNPCAnimAction
