require("UnLuaEx")
local TextReplaceContext = require("NewRoco.Modules.System.TextReplaceContext")
local DialogueTextReplacer = require("NewRoco.Modules.System.Dialogue.DialogueTextReplacer")
local DialogueModuleEvent = reload("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local DialogueMainPanelBase = require("NewRoco.Modules.System.Dialogue.Res.DialogueMainPanelBase")
local UMG_DialogueThinking_C = DialogueMainPanelBase:Extend("UMG_DialogueThinking_C")

function UMG_DialogueThinking_C:OnConstruct()
  DialogueMainPanelBase.OnConstruct(self)
  self:BindInputAction()
end

function UMG_DialogueThinking_C:OnDestruct()
  DialogueMainPanelBase.OnDestruct(self)
end

function UMG_DialogueThinking_C:BindInputAction()
  local mappingContext = self:AddInputMappingContext("IMC_Dialogue")
  if mappingContext then
    mappingContext:BindAction("IA_NextDialogue", self, "NextDialogue")
  end
end

function UMG_DialogueThinking_C:NextDialogue()
  self:OnDialogueClick()
end

function UMG_DialogueThinking_C:RefreshView(DialogueConf, ContextOption, bBlockEnterAnimation, ...)
  DialogueMainPanelBase.RefreshView(self, DialogueConf, ContextOption, bBlockEnterAnimation, ...)
end

return UMG_DialogueThinking_C
