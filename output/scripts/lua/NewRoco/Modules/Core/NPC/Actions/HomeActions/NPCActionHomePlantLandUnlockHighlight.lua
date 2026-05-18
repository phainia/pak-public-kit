local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local Base = NPCActionBase
local NPCActionHomePlantLandUnlockHighlight = Base:Extend("NPCActionHomePlantLandUnlockHighlight")

function NPCActionHomePlantLandUnlockHighlight:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionHomePlantLandUnlockHighlight:Execute()
  Base.Execute(self)
  if self.Config.action_param1 == "1" then
    _G.NRCModeManager:DoCmd(_G.FarmModuleCmd.ShowLandUnlockHighlight)
  elseif self.Config.action_param1 == "0" then
    _G.NRCModeManager:DoCmd(_G.FarmModuleCmd.HideLandUnlockHighlight)
  end
  self:Finish(true)
end

function NPCActionHomePlantLandUnlockHighlight:OnDialogueAction()
  self:Execute()
  Base.OnDialogueAction(self)
end

return NPCActionHomePlantLandUnlockHighlight
