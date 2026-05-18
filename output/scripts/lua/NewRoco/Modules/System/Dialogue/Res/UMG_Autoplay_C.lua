local EnhancedInputModuleEvent = require("NewRoco.Modules.Core.EnhancedInput.EnhancedInputModuleEvent")
local UMG_Autoplay_C = _G.NRCPanelBase:Extend("UMG_Autoplay_C")

function UMG_Autoplay_C:OnConstruct()
  if not self.CallbackID or not (self.CallbackID > 0) then
    self.CallbackID = _G.UserSettingManager:RegisterDialogueAutoPlayChangedCallback(self, self.UpdateUI)
  end
  self.ButtonAAA.OnClicked:Add(self, self.OnButtonClick)
  self:BindToAnimationStarted(self.In, {
    self,
    function(caller)
      self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    end
  })
  self:BindToAnimationFinished(self.In, {
    self,
    function(caller)
      self:SetVisibility(UE4.ESlateVisibility.Visible)
      self:BindInputAction()
    end
  })
  self:BindToAnimationStarted(self.Out, {
    self,
    function(caller)
      self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      self:UnBindInputAction()
    end
  })
  self:BindToAnimationFinished(self.Out, {
    self,
    function(caller)
      self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  })
  self:BindToAnimationStarted(self.Play, {
    self,
    self.OnSwitchAnimationStart
  })
  self:BindToAnimationFinished(self.Play, {
    self,
    self.OnSwitchOnAnimationEnd
  })
  self:BindToAnimationStarted(self.Stop, {
    self,
    self.OnSwitchAnimationStart
  })
  self:BindToAnimationFinished(self.Stop, {
    self,
    self.OnSwitchOffAnimationEnd
  })
  _G.NRCEventCenter:RegisterEvent(self.name, self, EnhancedInputModuleEvent.KeyMappingsChanged, self.PCKeySetting)
  self:PCKeySetting()
  self:UpdateUI(true)
end

function UMG_Autoplay_C:OnDestruct()
  _G.NRCEventCenter:UnRegisterEvent(self, EnhancedInputModuleEvent.KeyMappingsChanged, self.PCKeySetting)
  _G.UserSettingManager:UnregisterDialogueAutoPlayChangedCallback(self.CallbackID)
  self.CallbackID = 0
end

function UMG_Autoplay_C:BindInputAction()
  local mappingContext = self:AddInputMappingContext("IMC_Dialogue_Autoplay", 25000)
  if mappingContext then
    mappingContext:BindAction("IA_ToggleDialogueAutoplay", self, "OnPCKey")
  end
end

function UMG_Autoplay_C:UnBindInputAction()
  local mappingContext = self:RemoveInputMappingContext("IMC_Dialogue_Autoplay")
end

function UMG_Autoplay_C:OnPCKey()
  local Visible = self:GetVisibility()
  if Visible == UE.ESlateVisibility.Visible then
    self:OnButtonClick()
  end
end

function UMG_Autoplay_C:PCKeySetting()
  if UE4Helper.IsPCMode() and _G.SystemSettingModuleCmd then
    local text, image = _G.NRCModuleManager:DoCmd(SystemSettingModuleCmd.GetMappingKeyUIName, "IA_ToggleDialogueAutoplay")
    if "" ~= image then
      self.PCKey:SetImageMode(image)
    else
      self.PCKey:SetText(text)
    end
    self.PCKey:SetKeyVisibility(true)
  end
end

function UMG_Autoplay_C:UpdateUI(bFastForward)
  local Value = _G.UserSettingManager:IsDialogueAutoPlayOn()
  if self.CurValue ~= Value then
    if Value then
      self:PlayAnimation(self.Play, 0.0, 1, UE4.EUMGSequencePlayMode.Forward, bFastForward and 9999 or 1.0)
    else
      self:PlayAnimation(self.Stop, 0.0, 1, UE4.EUMGSequencePlayMode.Forward, bFastForward and 9999 or 1.0)
    end
    self.CurValue = Value
  end
end

function UMG_Autoplay_C:OnButtonClick()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1003, "DialoguePanel:OnAutoPlayClick")
  _G.UserSettingManager:SetDialogueAutoPlay(not self.CurValue)
end

function UMG_Autoplay_C:OnSwitchAnimationStart()
  self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self:StopAnimation(self.Loop)
end

function UMG_Autoplay_C:OnSwitchOnAnimationEnd()
  self:SetVisibility(UE.ESlateVisibility.Visible)
  self:PlayAnimation(self.Loop, 0.0, 0)
end

function UMG_Autoplay_C:OnSwitchOffAnimationEnd()
  self:SetVisibility(UE4.ESlateVisibility.Visible)
end

return UMG_Autoplay_C
