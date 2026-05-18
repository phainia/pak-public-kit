require("UnLuaEx")
local DialogueMainPanelBase = require("NewRoco.Modules.System.Dialogue.Res.DialogueMainPanelBase")
local UMG_DialogueCommon_C = DialogueMainPanelBase:Extend("UMG_DialogueCommon_C")

function UMG_DialogueCommon_C:OnConstruct()
  DialogueMainPanelBase.OnConstruct(self)
  self:BindInputAction()
end

function UMG_DialogueCommon_C:OnDestruct()
  DialogueMainPanelBase.OnDestruct(self)
end

function UMG_DialogueCommon_C:BindInputAction()
  local mappingContext = self:AddInputMappingContext("IMC_Dialogue")
  if mappingContext then
    mappingContext:BindAction("IA_NextDialogue", self, "NextDialogue")
  end
end

function UMG_DialogueCommon_C:NextDialogue()
  self:OnDialogueClick()
end

return UMG_DialogueCommon_C
