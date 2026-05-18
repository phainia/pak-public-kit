local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local DialogueUtils = require("NewRoco.Modules.System.Dialogue.DialogueUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local DialogueActionBase = require("NewRoco.Modules.System.Dialogue.Action.DialogueActionBase")
local Base = DialogueActionBase
local DialogueWaitUserAction = Base:Extend("DialogueWaitUserAction")
FsmUtils.MergeMembers(Base, DialogueWaitUserAction, {
  {
    name = "DialogueConf",
    type = "var"
  },
  {
    name = "ParentModule",
    type = "var"
  },
  {name = "Options", type = "var"},
  {name = "Option", type = "var"},
  {name = "ConfID", type = "var"},
  {name = "bInBattle", type = "var"}
})

function DialogueWaitUserAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function DialogueWaitUserAction:OnEnter()
  self:InjectProperties()
  self.fsm:SetProperty("LastSelection", nil)
  self:AddEventListener()
  self.fsm:Pause()
  self.Finished = false
end

function DialogueWaitUserAction:OnSelectFinish(conf)
  Log.Debug("DialogueWaitUserAction:OnSelectFinish, Skip", self.Finished, conf and conf.id or "no conf")
  if self.Finished then
    return
  end
  self.fsm:SetProperty("CurrentSelection", conf)
  self.fsm:SetProperty("LastSelection", conf)
  self.Finished = true
  self:Finish()
end

function DialogueWaitUserAction:AddEventListener()
  if self.ParentModule then
    self.ParentModule:RegisterEvent(self, DialogueModuleEvent.DialogueSelectFinished, self.OnSelectFinish)
  else
    Log.Error("\230\137\190\228\184\141\229\136\176ParentModule")
  end
end

function DialogueWaitUserAction:RemoveEventListener()
  if self.ParentModule then
    self.ParentModule:UnRegisterEvent(self, DialogueModuleEvent.DialogueSelectFinished)
  else
    Log.Error("\230\137\190\228\184\141\229\136\176ParentModule")
  end
end

function DialogueWaitUserAction:OnFinish()
  self:RemoveEventListener()
  self.fsm:Resume()
end

function DialogueWaitUserAction:OnExit()
  self:RemoveEventListener()
end

return DialogueWaitUserAction
