require("UnLuaEx")
local DialoguePanelBase = require("NewRoco.Modules.System.Dialogue.Res.DialoguePanelBase")
local UMG_DialogueSolo_C = DialoguePanelBase:Extend("UMG_DialogueSolo_C")

function UMG_DialogueSolo_C:OnConstruct()
  DialoguePanelBase.OnConstruct(self)
  self:BindInputAction()
end

function UMG_DialogueSolo_C:OnDestruct()
  DialoguePanelBase.OnDestruct(self)
end

function UMG_DialogueSolo_C:BindInputAction()
  local mappingContext = self:AddInputMappingContext("IMC_Dialogue")
  if mappingContext then
    mappingContext:BindAction("IA_NextDialogue", self, "NextDialogue")
  end
end

function UMG_DialogueSolo_C:NextDialogue()
  self:OnDialogueClick()
end

return UMG_DialogueSolo_C
