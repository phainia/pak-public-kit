local Base = require("NewRoco.Modules.Core.NPC.Actions.NPCActionDialogue")
local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local NPCActionDialogueLocal = Base:Extend("NPCActionDialogueLocal")

function NPCActionDialogueLocal:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionDialogueLocal:Execute(playerId, needSendReq)
  needSendReq = false
  Base.Execute(self, playerId, needSendReq)
end

function NPCActionDialogueLocal:OnSubmit(rsp)
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  localPlayer.inputComponent:SetInputEnable(self, true, "PreDialogue")
  if 0 == rsp.ret_info.ret_code then
    if self:NeedsValidation() then
      _G.NRCEventCenter:RegisterEvent("NPCActionDialogue", self, DialogueModuleEvent.DialogueEnded, self.RefreshData)
    end
    local FirstDialogue = self.Owner.optionInfo.first_dialog_id
    if FirstDialogue and FirstDialogue > 0 then
      _G.NRCModeManager:DoCmd(_G.DialogueModuleCmd.StartDialogueLocal, self.Owner, self, self.Owner.optionInfo.first_dialog_id)
    else
      _G.NRCModeManager:DoCmd(_G.DialogueModuleCmd.StartDialogueLocal, self.Owner, self, tonumber(self.Config.action_param1))
    end
    _G.NRCSDKManager:SetEnterDialogue()
  else
    _G.NRCModuleManager:DoCmd(_G.DialogueModuleCmd.UnregisterOption, self.Owner)
  end
  NPCActionBase.OnSubmit(self, rsp)
end

return NPCActionDialogueLocal
