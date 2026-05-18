local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local Base = NPCActionBase
local NPCActionPetSubmitFree = Base:Extend("NPCActionPetSubmitFree")

function NPCActionPetSubmitFree:ExecuteWithModel()
  local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
  local Context = string.format(LuaText.star_buytext_diamond_confirm, self.CostItemCount)
  local Title = "\231\178\190\231\129\181\228\187\147\229\186\147\229\174\185\233\135\143\228\184\141\232\182\179"
  local content = _G.DataConfigManager:GetPetGlobalConfig("pet_depot_max_hint").str
  local Ctx = DialogContext()
  Ctx:SetTitle(Title)
  Ctx:SetContent(content)
  Ctx:SetMode(DialogContext.Mode.OK_CANCEL)
  Ctx:SetCallback(self, self.NeedOpenFreePanel)
  Ctx:SetCloseOnCancel(true)
  Ctx:SetButtonText(LuaText.pet_remove_free, LuaText.umg_dialog_1)
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Ctx)
end

function NPCActionPetSubmitFree:NeedOpenFreePanel(NeedOpen)
  if NeedOpen then
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenPetFreeMainPanel, self)
  else
    self:Finish()
  end
end

function NPCActionPetSubmitFree:EndAction()
  self:Finish()
end

function NPCActionPetSubmitFree:IsNeedCloseDialogueUI()
  return false
end

return NPCActionPetSubmitFree
