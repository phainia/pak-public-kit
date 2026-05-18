local DialogueModuleCmd = require("NewRoco.Modules.System.Dialogue.DialogueModuleCmd")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local DialogueActionBase = require("NewRoco.Modules.System.Dialogue.Action.DialogueActionBase")
local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local Base = DialogueActionBase
local DialogueWaitSyncShowOptionsAction = Base:Extend("DialogueWaitSyncShowOptionsAction")
FsmUtils.MergeMembers(Base, DialogueWaitSyncShowOptionsAction, {
  {
    name = "ParentModule",
    type = "var"
  },
  {name = "Progress", type = "var"}
})

function DialogueWaitSyncShowOptionsAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function DialogueWaitSyncShowOptionsAction:OnEnter()
  self:InjectProperties()
  if not self:CheckOptionUI() then
    self:Finish()
    return
  end
  if self:CheckShouldShowOptions() then
    self:Finish()
    return
  end
  if self.ParentModule then
    self.ParentModule:RegisterEvent(self, DialogueModuleEvent.SyncShowOptions, self.OnSyncShowOptions)
    self.fsm:Pause()
  else
    Log.Error("DialogueWaitSyncShowOptionsAction:OnEnter\239\188\140\229\175\185\232\175\157\230\168\161\229\157\151\228\184\141\229\173\152\229\156\168...")
    self:Finish()
  end
end

function DialogueWaitSyncShowOptionsAction:CheckShouldShowOptions()
  if self.Progress and 0 == self.Progress then
    return true
  end
  return false
end

function DialogueWaitSyncShowOptionsAction:OnSyncShowOptions()
  if self:CheckShouldShowOptions() then
    self:Finish()
  end
end

function DialogueWaitSyncShowOptionsAction:CheckOptionUI()
  local DialogueModule = self.ParentModule
  if not DialogueModule then
    Log.Error("DialogueWaitSyncShowOptionsAction\228\184\165\233\135\141\233\148\153\232\175\175\239\188\140\229\175\185\232\175\157\230\168\161\229\157\151\228\184\141\229\173\152\229\156\168...")
    return false
  end
  local PanelName = DialogueModule._currentMainPanel
  if string.IsNilOrEmpty(PanelName) then
    return false
  end
  local HasPanel = DialogueModule:HasPanel(PanelName)
  if not HasPanel then
    Log.Debug("DialogueWaitSyncShowOptionsAction\230\151\160\230\179\149\232\142\183\229\143\150\229\175\185\232\175\157\233\157\162\230\157\191...\231\173\137\228\184\128\228\184\139\229\134\141\232\175\149", PanelName)
    return false
  end
  local Panel = DialogueModule:GetPanel(PanelName)
  if not Panel then
    Log.Debug("DialogueWaitSyncShowOptionsAction\230\151\160\230\179\149\232\142\183\229\143\150\229\175\185\232\175\157\233\157\162\230\157\191...\231\173\137\228\184\128\228\184\139\229\134\141\232\175\149", PanelName)
    return false
  end
  if not Panel.enableView then
    Log.Debug("DialogueWaitSyncShowOptionsAction\229\175\185\232\175\157\233\157\162\230\157\191\232\191\152\230\178\161\229\135\134\229\164\135\229\165\189...\231\173\137\228\184\128\228\184\139\229\134\141\232\175\149", PanelName)
    return false
  end
  if not Panel.ShowOptions then
    Log.Error("DialogueWaitSyncShowOptionsAction\229\175\185\232\175\157\233\157\162\230\157\191\230\178\161\230\156\137\230\152\190\231\164\186\233\128\137\233\161\185\231\154\132\229\138\159\232\131\189", PanelName)
    return false
  end
  return true
end

function DialogueWaitSyncShowOptionsAction:OnFinish()
  if self.ParentModule then
    self.ParentModule:UnRegisterEvent(self, DialogueModuleEvent.SyncShowOptions)
  end
  self.fsm:Resume()
end

function DialogueWaitSyncShowOptionsAction:OnExit()
  self:OnFinish()
end

function DialogueWaitSyncShowOptionsAction:OnTimeout()
  Base.OnTimeout(self)
  self.fsm:SendEvent(DialogueModuleEvent.EnterEndState, self)
end

return DialogueWaitSyncShowOptionsAction
