local DialogueModuleCmd = require("NewRoco.Modules.System.Dialogue.DialogueModuleCmd")
local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local StatusCheckerBase = require("NewRoco.Modules.Core.Task.StatusCheckers.StatusCheckerBase")
local Base = StatusCheckerBase
local DialogueStatusChecker = Base:Extend("DialogueStatusChecker")

function DialogueStatusChecker:Ctor()
  Base.Ctor(self)
end

function DialogueStatusChecker:CheckPass()
  local HasDialogue = DialogueModuleCmd and _G.NRCModuleManager:DoCmd(DialogueModuleCmd.HasDialogue)
  if HasDialogue then
    self:Log("\229\189\147\229\137\141\230\156\137\230\173\163\229\156\168\230\137\167\232\161\140\231\154\132\229\175\185\232\175\157")
    return false
  else
    return true
  end
end

function DialogueStatusChecker:StartCheck()
  self:RegisterGlobalEvent(DialogueModuleEvent.DialogueEnded, self.OnDialogueEnded)
end

function DialogueStatusChecker:OnDialogueEnded()
  self:FireCallback()
end

function DialogueStatusChecker:EndCheck()
  self:UnregisterGlobalEvent(DialogueModuleEvent.DialogueEnded, self.OnDialogueEnded)
end

return DialogueStatusChecker
