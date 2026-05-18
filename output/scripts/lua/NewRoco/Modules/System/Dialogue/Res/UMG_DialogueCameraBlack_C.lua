local DialogueModuleEvent = reload("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local UMG_DialogueCameraBlack_C = _G.NRCPanelBase:Extend("UMG_DialogueCameraBlack_C")

function UMG_DialogueCameraBlack_C:OnConstruct()
  self.isClosing = false
  self.doClosing = false
  self.fadingOut = false
end

function UMG_DialogueCameraBlack_C:OnDestruct()
end

function UMG_DialogueCameraBlack_C:OnActive()
  self.isClosing = false
  self.doClosing = false
  self:DoFadeIn()
end

function UMG_DialogueCameraBlack_C:OnDeactive()
end

function UMG_DialogueCameraBlack_C:OnEnable()
  self.isClosing = false
  self.doClosing = false
end

function UMG_DialogueCameraBlack_C:OnDisable()
end

function UMG_DialogueCameraBlack_C:TryClose()
  self:Log("TryClose", self.isClosing)
  self.doClosing = true
  if self.isClosing then
    self:LogWarning("\233\135\141\229\164\141Closing TryClose")
    return
  end
  self.isClosing = true
  self:StopAllAnimations()
  self:DoClose()
end

function UMG_DialogueCameraBlack_C:FadeInDone()
  self:Log("FadeInDone")
  self.module:DispatchEvent(DialogueModuleEvent.DialogueCameraBlackFadeInDone)
end

function UMG_DialogueCameraBlack_C:DoClose()
  self:Log("I'm closed!!!")
  _G.NRCPanelBase.DoClose(self)
end

function UMG_DialogueCameraBlack_C:FadeOutDone()
  self:Log("FadeOutDone", self.noFadeOut, self.doClosing)
  if self.noFadeOut and not self.doClosing then
    self.isClosing = false
    return
  end
  self:DoClose()
end

function UMG_DialogueCameraBlack_C:OnAnimationFinished(Animation)
  self:Log("OnAnimationFinished", Animation, self.FadeIn, self.FadeOut)
  if Animation == self.FadeIn then
    self:Log("OnAnimationFinished FadeIn")
    self:FadeInDone()
  elseif Animation == self.FadeOut then
    self:Log("OnAnimationFinished FadeOut")
    self.fadingOut = false
    self:FadeOutDone()
  end
end

function UMG_DialogueCameraBlack_C:DoFadeOut()
  self:Log("DoFadeOut", self.isClosing)
  if self.isClosing then
    self:LogWarning("\233\135\141\229\164\141Closing DoFadeOut")
    return
  end
  self.isClosing = true
  self:StopAllAnimations()
  self:PlayAnimation(self.FadeOut)
end

function UMG_DialogueCameraBlack_C:DoFadeIn()
  self:Log("DoFadeIn", self.isClosing)
  if self.isClosing then
    self:LogWarning("Closing")
    return
  end
  self:StopAllAnimations()
  self:PlayAnimation(self.FadeIn)
end

return UMG_DialogueCameraBlack_C
