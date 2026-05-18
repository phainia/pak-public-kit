require("UnLuaEx")
local TextReplaceContext = require("NewRoco.Modules.System.TextReplaceContext")
local DialogueTextReplacer = require("NewRoco.Modules.System.Dialogue.DialogueTextReplacer")
local DialogueModuleEvent = reload("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local DialogueMainPanelBase = require("NewRoco.Modules.System.Dialogue.Res.DialogueMainPanelBase")
local UMG_DialogueAncient_C = DialogueMainPanelBase:Extend("UMG_DialogueAncient_C")

function UMG_DialogueAncient_C:OnConstruct()
  DialogueMainPanelBase.OnConstruct(self)
  self:BindInputAction()
end

function UMG_DialogueAncient_C:OnDestruct()
  DialogueMainPanelBase.OnDestruct(self)
end

function UMG_DialogueAncient_C:BindInputAction()
  local mappingContext = self:AddInputMappingContext("IMC_Dialogue")
  if mappingContext then
    mappingContext:BindAction("IA_NextDialogue", self, "NextDialogue")
  end
end

function UMG_DialogueAncient_C:NextDialogue()
  self:OnDialogueClick()
end

function UMG_DialogueAncient_C:RefreshView(DialogueConf, ContextOption, bBlockEnterAnimation, ExtraConf, ...)
  self.bTranslate = ExtraConf.Translate
  self:GetTypeWritter():SetTextStyles()
  DialogueMainPanelBase.RefreshView(self, DialogueConf, ContextOption, bBlockEnterAnimation, ExtraConf, ...)
end

return UMG_DialogueAncient_C
