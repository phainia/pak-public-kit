local DialoguePanelBase = require("NewRoco.Modules.System.Dialogue.Res.DialoguePanelBase")
local UMG_Specialdialogue_C = DialoguePanelBase:Extend("UMG_Specialdialogue_C")

function UMG_Specialdialogue_C:OnConstruct()
  if self.DialogueSelector then
    self:SetChildViews(self.DialogueSelector)
  end
  DialoguePanelBase.OnConstruct(self)
  self.TriggerEndAnimOnPageEnd = false
  self:BindInputAction()
end

function UMG_Specialdialogue_C:OnDestruct()
  DialoguePanelBase.OnDestruct(self)
end

function UMG_Specialdialogue_C:BindInputAction()
  local mappingContext = self:AddInputMappingContext("IMC_Dialogue")
  if mappingContext then
    mappingContext:BindAction("IA_NextDialogue", self, "NextDialogue")
  end
end

function UMG_Specialdialogue_C:NextDialogue()
  self:OnDialogueClick()
end

function UMG_Specialdialogue_C:RefreshView(DialogueConf, ContextOption, bBlockEnterAnimation, ExtraConf, EnterCallback, EnterCaller)
  self.TriggerEndAnimOnPageEnd = true
  if self.DialogueSelector then
    self.DialogueSelector:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  DialoguePanelBase.RefreshView(self, DialogueConf, ContextOption, bBlockEnterAnimation, ExtraConf, EnterCallback, EnterCaller)
end

function UMG_Specialdialogue_C:ShowExtraImage(DialogueConf)
  local Pic = (DialogueConf.ui_source_type == Enum.UIsourceType.UIT_PIC or DialogueConf.ui_source_type == Enum.UIsourceType.UIT_PIC2) and DialogueConf.source_param
  if Pic then
    self.ExtraImage:SetPath(Pic)
  else
    self.ExtraImage:SetPath("Texture2D'/Game/NewRoco/Modules/System/NpcDialog/Raw/Textures/img_npcdialogbook.img_npcdialogbook'")
  end
  self.ExtraImage:SetVisibility(UE4.ESlateVisibility.Visible)
end

function UMG_Specialdialogue_C:OnPlayEnterAnimation()
  self.CameraCapture:StartCapture()
  DialoguePanelBase.OnPlayEnterAnimation(self)
end

return UMG_Specialdialogue_C
