local DialogueMainPanelBase = require("NewRoco.Modules.System.Dialogue.Res.DialogueMainPanelBase")
local UMG_DialogueNightmare_C = DialogueMainPanelBase:Extend("UMG_DialogueNightmare_C")

function UMG_DialogueNightmare_C:OnConstruct()
  DialogueMainPanelBase.OnConstruct(self)
  self.bHasPlayedIn = false
  self.bHasPlayedLoop = false
  self:BindInputAction()
end

function UMG_DialogueNightmare_C:OnDestruct()
  DialogueMainPanelBase.OnDestruct(self)
end

function UMG_DialogueNightmare_C:BindInputAction()
  local mappingContext = self:AddInputMappingContext("IMC_Dialogue")
  if mappingContext then
    mappingContext:BindAction("IA_NextDialogue", self, "NextDialogue")
  end
end

function UMG_DialogueNightmare_C:NextDialogue()
  self:OnDialogueClick()
end

function UMG_DialogueNightmare_C:RefreshView(DialogueConf, ContextOption, bBlockEnterAnimation, ExtraConf, ...)
  self.bIsGlow = ExtraConf.Glow
  DialogueMainPanelBase.RefreshView(self, DialogueConf, ContextOption, bBlockEnterAnimation, ExtraConf, ...)
end

function UMG_DialogueNightmare_C:GetDialogueTextAnimationEnter(bIsSkip)
  if self.bHasPlayedIn then
    return nil
  end
  local rate = 1
  self.bHasPlayedIn = true
  if true == self.bIsGlow then
    return self.UMG_DialogueText.In_Glow, rate
  end
  return self.UMG_DialogueText.In, rate
end

function UMG_DialogueNightmare_C:GetDialogueTextAnimationLoop(bIsSkip)
  if self.bHasPlayedLoop then
    return nil
  end
  self.bHasPlayedLoop = true
  if true == self.bIsGlow then
    return self.UMG_DialogueText.Loop_Glow
  end
  return DialogueMainPanelBase.GetDialogueTextAnimationLoop(self)
end

function UMG_DialogueNightmare_C:GetDialogueTextAnimationEnd(bIsOnDisable)
  if bIsOnDisable then
    self.bHasPlayedIn = false
    self.bHasPlayedLoop = false
    return DialogueMainPanelBase.GetDialogueTextAnimationEnd(self)
  end
  return nil
end

function UMG_DialogueNightmare_C:ShouldStopDialogueTextAnimationDuringRefreshView()
  return false
end

return UMG_DialogueNightmare_C
