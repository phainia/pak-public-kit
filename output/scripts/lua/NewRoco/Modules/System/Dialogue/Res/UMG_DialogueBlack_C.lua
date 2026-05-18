local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local DialoguePanelBase = require("NewRoco.Modules.System.Dialogue.Res.DialoguePanelBase")
local DialogueUtils = require("NewRoco.Modules.System.Dialogue.DialogueUtils")
local UMG_DialogueBlack_C = DialoguePanelBase:Extend("UMG_DialogueBlack_C")

function UMG_DialogueBlack_C:OnConstruct()
  DialoguePanelBase.OnConstruct(self)
  self.TriggerEndAnimOnPageEnd = false
  _G.NRCEventCenter:RegisterEvent("UMG_DialogueBlack_C", self, DialogueModuleEvent.OnHideDialogueBlackChange, self.OnHideDialogueBlackChange)
end

function UMG_DialogueBlack_C:OnDestruct()
  DialoguePanelBase.OnDestruct(self)
  _G.NRCEventCenter:UnRegisterEvent(self, DialogueModuleEvent.OnHideDialogueBlackChange, self.OnHideDialogueBlackChange)
end

function UMG_DialogueBlack_C:OnEnable()
  self:BindInputAction()
  DialoguePanelBase.OnEnable(self)
  self:OnHideDialogueBlackChange()
end

function UMG_DialogueBlack_C:OnDisable()
  self:UnBindInputAction()
  DialoguePanelBase.OnDisable(self)
end

function UMG_DialogueBlack_C:BindInputAction()
  local mappingContext = self:AddInputMappingContext("IMC_DialogueBlack")
  if mappingContext then
    mappingContext:BindAction("IA_NextDialogueBlack", self, "NextDialogue")
  end
end

function UMG_DialogueBlack_C:UnBindInputAction()
  self:ClearAllEnhancedInput()
end

function UMG_DialogueBlack_C:NextDialogue()
  self:OnDialogueClick()
end

function UMG_DialogueBlack_C:PlayEnterAnimation()
  if self.extraConf and self.extraConf.fade_in_speed then
    if self.extraConf.fade_in_speed >= 99 then
      self:PlayAnimation(self.FadeIn, 0, 1, 0, 999)
    else
      self:PlayAnimation(self.FadeIn, 0, 1, 0, self.extraConf.fade_in_speed)
    end
  else
    self:PlayAnimation(self.FadeIn)
  end
end

function UMG_DialogueBlack_C:RefreshView(DialogueConf, ContextOption, bBlockEnterAnimation, ExtraConf, EnterCallback, EnterCaller)
  self.TriggerEndAnimOnPageEnd = false
  self.isClosing = false
  self.done = false
  self.fadingOut = false
  self.HasFadeOut = false
  self.Timeout = DialogueConf and DialogueConf.timeout or 0
  if DialogueConf.ui_source_type == Enum.UIsourceType.UIT_BLACK_EXIT then
    return
  end
  self.extraConf = ExtraConf
  self.DialogueConf = DialogueConf
  DialoguePanelBase.RefreshView(self, DialogueConf, ContextOption, bBlockEnterAnimation, ExtraConf, EnterCallback, EnterCaller)
end

function UMG_DialogueBlack_C:OnTypeFinished()
  self:Log("OnTypeFinished", self.isClosing)
  if not self.extraConf then
    return
  end
  if self.extraConf and self.extraConf.autoCloseOff then
    return
  end
  local show_time = 2.0
  if self.extraConf and self.extraConf.show_time then
    show_time = self.extraConf.show_time
  end
  if self.isClosing then
    self:LogWarning("\233\135\141\229\164\141Closing OnTypeFinished")
    return
  end
  self.isClosing = true
  self.done = true
end

function UMG_DialogueBlack_C:PlayEndAnimation()
  if not self:GetIsVisible() then
    Log.Debug("Not visible, skip")
    return
  end
  self.done = true
  self.fadingOut = true
  if self.extraConf and self.extraConf.fade_out_speed then
    self:StopAllAnimations()
    self:PlayAnimation(self.FadeOut, 0, 1, 0, self.extraConf.fade_out_speed)
  else
    self:PlayAnimation(self.FadeOut)
    if self.Timeout > 0 then
      Log.Debug("start global black", self.DialogueConf.id, self.Timeout)
      _G.NRCEventCenter:DispatchEvent(NRCGlobalEvent.OPEN_BLACK_SCREEN, false)
      _G.DelayManager:DelaySeconds(self.Timeout / 1000, function()
        NRCModuleManager:DoCmd(BlackScreenModuleCmd.TryCloseGlobalBlackScreenIfAny, {}, true)
      end)
    end
  end
end

function UMG_DialogueBlack_C:PlayEndAnimationDirect()
  if not self:GetIsVisible() then
    Log.Debug("Not visible, skip")
    return
  end
  self.done = true
  self.fadingOut = true
  self:StopAllAnimations()
  if self.extraConf and self.extraConf.fade_out_speed then
    self:PlayAnimation(self.FadeOut, 0, 1, 0, self.extraConf.fade_out_speed)
  else
    self.Inited = true
    self:PlayAnimation(self.FadeOut)
    local Time = self.FadeOut:GetEndTime() - self.FadeOut:GetStartTime()
    self:DelaySeconds(Time, self.DoClose, self)
    if self.Timeout > 0 then
      if self.DialogueConf then
        Log.Debug("start global black", self.DialogueConf.id, self.Timeout)
      end
      _G.NRCEventCenter:DispatchEvent(NRCGlobalEvent.OPEN_BLACK_SCREEN, false)
      _G.DelayManager:DelaySeconds(self.Timeout / 1000, function()
        NRCModuleManager:DoCmd(BlackScreenModuleCmd.TryCloseGlobalBlackScreenIfAny, {}, true)
      end)
    end
  end
end

function UMG_DialogueBlack_C:OnShown()
  if not UE.UObject.IsValid(self.Object) then
    Log.Debug("DialogueBlack\229\183\178\231\187\143\232\162\171\233\148\128\230\175\129")
    return
  end
  if self.extraConf and self.extraConf.autoCloseOff then
    return
  end
  self:Log("UMG_DialogueBlack_C:OnShown", self.DialogueConf.id, self.fadingOut, self.noFadeOut)
  if self.noFadeOut then
    self:FadeOutDone()
  elseif not self.fadingOut then
    self:PlayEndAnimation()
  end
end

function UMG_DialogueBlack_C:OnDialogueClick(...)
  if self.extraConf and self.extraConf.autoCloseOff then
    return
  end
  DialoguePanelBase.OnDialogueClick(self, ...)
end

function UMG_DialogueBlack_C:FadeInDone()
  self:Log("FadeInDone")
  self.module:DispatchEvent(DialogueModuleEvent.DialogueBlackFadeInDone)
  if self.extraConf and self.extraConf.show_time and not self.extraConf.autoCloseOff then
    self.isClosing = true
    self:DelaySeconds(self.extraConf.show_time, self.OnShown, self)
  end
end

function UMG_DialogueBlack_C:FadeOutDone()
  if self.module and self.module._currentMainPanel == self.panelName then
    self.module:DispatchEvent(DialogueModuleEvent.DialogueTalkFinished, self.DialogueConf)
  end
  self:SetVisibility(UE4.ESlateVisibility.Hidden)
end

function UMG_DialogueBlack_C:OnAnimationFinished(Animation)
  if not self.Inited then
    return
  end
  self:Log("OnAnimationFinished", Animation, self.FadeIn, self.Fast_in, self.FadeOut)
  if Animation == self.FadeIn or Animation == self.Fast_in then
    self:Log("OnAnimationFinished FadeIn")
    self:FadeInDone()
  elseif Animation == self.FadeOut then
    self:Log("OnAnimationFinished FadeOut")
    self.fadingOut = false
    self.HasFadeOut = true
    self:FadeOutDone()
  end
  DialoguePanelBase.OnAnimationFinished(self, Animation)
end

function UMG_DialogueBlack_C:Show(DialogueConf)
  Log.Debug("UMG_DialogueBlack_C:Show", DialogueConf.id)
  DialoguePanelBase.Show(self, DialogueConf)
end

function UMG_DialogueBlack_C:StopAllAnimations(...)
  if self:IsAnimationPlaying(self.FadeIn) then
    Log.Debug("Is Playing FadeIn")
  end
  if self:IsAnimationPlaying(self.FadeOut) then
    Log.Debug("Is Playing FadeOut")
  end
  if self:IsAnimationPlaying(self.Fast_in) then
    Log.Debug("Is Playing Fast_in")
  end
  self.Overridden.StopAllAnimations(self, ...)
end

function UMG_DialogueBlack_C:HasFadeOutDone()
  if not UE.UObject.IsValid(self) then
    return false
  end
  if self.HasFadeOut then
    return true
  end
  if self:IsAnimationPlaying(self.FadeOut) then
    return true
  end
  return false
end

function UMG_DialogueBlack_C:OnDeactive()
  self.Timeout = 0
  DialoguePanelBase.OnDeactive(self)
end

function UMG_DialogueBlack_C:OnHideDialogueBlackChange()
  self.Image_Background:SetRenderOpacity(DialogueUtils.HideDialogueBlack and 0.0 or 1.0)
end

return UMG_DialogueBlack_C
