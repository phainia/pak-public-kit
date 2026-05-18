require("UnLuaEx")
local TextReplaceContext = require("NewRoco.Modules.System.TextReplaceContext")
local DialogueTextReplacer = require("NewRoco.Modules.System.Dialogue.DialogueTextReplacer")
local DialogueModuleEvent = reload("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local DialogueMainPanelBase = require("NewRoco.Modules.System.Dialogue.Res.DialogueMainPanelBase")
local UMG_DialogueCommonBlack_C = DialogueMainPanelBase:Extend("UMG_DialogueCommonBlack_C")

function UMG_DialogueCommonBlack_C:OnConstruct()
  DialogueMainPanelBase.OnConstruct(self)
  self:BindInputAction()
end

function UMG_DialogueCommonBlack_C:OnDestruct()
  DialogueMainPanelBase.OnDestruct(self)
end

function UMG_DialogueCommonBlack_C:BindInputAction()
  local mappingContext = self:AddInputMappingContext("IMC_Dialogue")
  if mappingContext then
    mappingContext:BindAction("IA_NextDialogue", self, "NextDialogue")
  end
end

function UMG_DialogueCommonBlack_C:NextDialogue()
  self:OnDialogueClick()
end

return UMG_DialogueCommonBlack_C
