local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local NPCActionFactory = require("NewRoco.Modules.Core.NPC.Actions.NPCActionFactory")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local DialogueActionBase = require("NewRoco.Modules.System.Dialogue.Action.DialogueActionBase")
local Base = DialogueActionBase
local DialoguePreloadClientActionAction = Base:Extend("DialoguePreloadClientActionAction")
FsmUtils.MergeMembers(Base, DialoguePreloadClientActionAction, {
  {
    name = "ParentModule",
    type = "var"
  },
  {
    name = "DialogueConf",
    type = "var"
  },
  {name = "Option", type = "var"},
  {
    name = "ServerAction",
    type = "var"
  },
  {
    name = "ClientAction",
    type = "var"
  }
})

function DialoguePreloadClientActionAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function DialoguePreloadClientActionAction:OnEnter()
  self:InjectProperties()
  local Action = NPCActionFactory:Get(self.Option, self.DialogueConf.action, self.ServerAction, true)
  if Action then
    Action:Preload()
    self:SetProperty("ClientAction", Action)
  end
  self:Finish()
end

return DialoguePreloadClientActionAction
