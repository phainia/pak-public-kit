local DialogueModuleCmd = require("NewRoco.Modules.System.Dialogue.DialogueModuleCmd")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local DialogueActionBase = require("NewRoco.Modules.System.Dialogue.Action.DialogueActionBase")
local Base = DialogueActionBase
local DialogueShowOptionsAction = Base:Extend("DialogueShowOptionsAction")
FsmUtils.MergeMembers(Base, DialogueShowOptionsAction, {
  {
    name = "ParentModule",
    type = "var"
  },
  {
    name = "DialogueConf",
    type = "var"
  },
  {name = "NPCOption", type = "var"}
})

function DialogueShowOptionsAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.bStarted = false
  self.bCanOpen = false
end

function DialogueShowOptionsAction:OnEnter()
  self:InjectProperties()
  self.timeout = 5
  self.bStarted = true
  self.bCanOpen = false
  self:OnTick(0)
end

function DialogueShowOptionsAction:OnFinish()
  Log.Debug("DialogueShowOptionsAction:OnFinish")
  if not self.bStarted then
    Log.Warning("DialogueShowOptionsAction:OnFinish \230\151\182\229\186\143\233\148\153\232\175\175")
    return
  end
  if not self.bCanOpen then
    Log.Error("\230\137\147\229\188\128\229\175\185\232\175\157\233\128\137\233\161\185\232\191\135\231\168\139\228\184\173\232\191\152\230\178\161\231\173\137\229\136\176\229\175\185\232\175\157\233\157\162\230\157\191\230\137\147\229\188\128\229\176\177\232\182\133\230\151\182\231\187\147\230\157\159\230\136\150\232\128\133\230\149\180\228\184\170\229\175\185\232\175\157\231\138\182\230\128\129\230\156\186\228\184\173\230\150\173")
    return
  end
  _G.NRCModuleManager:DoCmd(DialogueModuleCmd.ShowOptions)
  self.bStarted = false
  if self.ParentModule and self.NPCOption and self.NPCOption.config and not self.NPCOption.config.dialogue_transmission_2P then
    self.ParentModule:SyncProgress(self.DialogueConf and self.DialogueConf.id or 0, 0)
  end
end

function DialogueShowOptionsAction:OnTick(DeltaTime)
  if self:CheckPanel() then
    self.bCanOpen = true
    self:Finish()
  end
end

function DialogueShowOptionsAction:CheckPanel()
  local DialogueModule = _G.NRCModuleManager:GetModule("DialogueModule")
  if not DialogueModule then
    Log.Error("DialogueShowOptionsAction\228\184\165\233\135\141\233\148\153\232\175\175\239\188\140\229\175\185\232\175\157\230\168\161\229\157\151\228\184\141\229\173\152\229\156\168...")
    return false
  end
  local PanelName = DialogueModule._currentMainPanel
  if string.IsNilOrEmpty(PanelName) then
    return true
  end
  local HasPanel = DialogueModule:HasPanel(PanelName)
  if not HasPanel then
    Log.Debug("DialogueShowOptionsAction\230\151\160\230\179\149\232\142\183\229\143\150\229\175\185\232\175\157\233\157\162\230\157\191...\231\173\137\228\184\128\228\184\139\229\134\141\232\175\149", PanelName)
    return false
  end
  local Panel = DialogueModule:GetPanel(PanelName)
  if not Panel then
    Log.Debug("DialogueShowOptionsAction\230\151\160\230\179\149\232\142\183\229\143\150\229\175\185\232\175\157\233\157\162\230\157\191...\231\173\137\228\184\128\228\184\139\229\134\141\232\175\149", PanelName)
    return false
  end
  if not Panel.enableView then
    Log.Debug("DialogueShowOptionsAction\229\175\185\232\175\157\233\157\162\230\157\191\232\191\152\230\178\161\229\135\134\229\164\135\229\165\189...\231\173\137\228\184\128\228\184\139\229\134\141\232\175\149", PanelName)
    return false
  end
  if not Panel.ShowOptions then
    Log.Error("DialogueShowOptionsAction\229\175\185\232\175\157\233\157\162\230\157\191\230\178\161\230\156\137\230\152\190\231\164\186\233\128\137\233\161\185\231\154\132\229\138\159\232\131\189", PanelName)
    return false
  end
  return true
end

function DialogueShowOptionsAction:OnExit()
  Log.Debug("DialogueShowOptionsAction:OnExit")
  self.bStarted = false
  self.bCanOpen = false
end

return DialogueShowOptionsAction
