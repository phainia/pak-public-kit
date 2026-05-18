local DialogueUtils = require("NewRoco.Modules.System.Dialogue.DialogueUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = require("NewRoco.Modules.System.Dialogue.Action.DialogueActionBase")
local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local DialogueWaitNextSyncAction = Base:Extend("DialogueWaitNextSyncAction")
FsmUtils.MergeMembers(Base, DialogueWaitNextSyncAction, {
  {
    name = "ParentModule",
    type = "var"
  },
  {name = "NextConfID", type = "var"},
  {
    name = "NextSelectIDs",
    type = "var"
  },
  {
    name = "PendingSyncList",
    type = "var"
  }
})

function DialogueWaitNextSyncAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function DialogueWaitNextSyncAction:OnEnter()
  self:InjectProperties()
  if self:ResolveNextConf() then
    self:Finish()
    return
  end
  self.fsm:Pause()
  if self.ParentModule then
    self.ParentModule:RegisterEvent(self, DialogueModuleEvent.SyncNextDialogue, self.OnSyncNextDialogue)
  else
    Log.Error("DialogueWaitNextSyncAction:OnEnter\239\188\140\229\175\185\232\175\157\230\168\161\229\157\151\228\184\141\229\173\152\229\156\168...")
    self:Finish()
  end
end

function DialogueWaitNextSyncAction:ResolveNextConf()
  if #self.PendingSyncList > 0 then
    Log.InfoFormat("DialogueWaitNextSyncAction:ResolveNextConf\239\188\140Find Next Conf with %d pending sync notify", #self.PendingSyncList)
    local NextSync = self.PendingSyncList[1]
    table.remove(self.PendingSyncList, 1)
    self:SetProperty("PendingSyncList", self.PendingSyncList)
    self:SetProperty("NextConfID", NextSync.DialogueID)
    self:SetProperty("NextSelectIDs", NextSync.SelectIDs)
    self.fsm:SetProperty("Progress", #self.PendingSyncList > 0 and 0 or NextSync.Progress)
    return true
  end
  return false
end

function DialogueWaitNextSyncAction:OnSyncNextDialogue(NextDialogueID)
  if self:ResolveNextConf() then
    self:Finish()
  else
    Log.Error("DialogueWaitNextSyncAction:OnSyncNextDialogue\239\188\140Fail to resolve next sync dialogue id when receive sync notify!")
    self.fsm:SendEvent(DialogueModuleEvent.EnterEndState, self)
  end
end

function DialogueWaitNextSyncAction:OnFinish()
  if self.ParentModule then
    self.ParentModule:UnRegisterEvent(self, DialogueModuleEvent.SyncNextDialogue)
  end
  self.fsm:Resume()
end

function DialogueWaitNextSyncAction:OnExit()
  if self.ParentModule then
    self.ParentModule:UnRegisterEvent(self, DialogueModuleEvent.SyncNextDialogue)
  end
end

function DialogueWaitNextSyncAction:OnTimeout()
  Base.OnTimeout(self)
  self.fsm:SendEvent(DialogueModuleEvent.EnterEndState, self)
end

return DialogueWaitNextSyncAction
