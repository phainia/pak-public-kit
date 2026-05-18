local EnhancedInputModuleEvent = require("NewRoco.Modules.Core.EnhancedInput.EnhancedInputModuleEvent")
local UMG_Button_Skip_C = _G.NRCPanelBase:Extend("UMG_Button_Skip_C")

function UMG_Button_Skip_C:OnConstruct()
  self.Button.OnPressed:Add(self, self.OnButtonPressed)
  self.Button.OnReleased:Add(self, self.OnButtonReleased)
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
  self:BindToAnimationStarted(self.FadeIn, {
    self,
    function(caller)
      self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    end
  })
  self:BindToAnimationFinished(self.FadeIn, {
    self,
    function(caller)
      self:SetVisibility(UE4.ESlateVisibility.Visible)
      self:BindInputAction()
    end
  })
  self:BindToAnimationStarted(self.LightOut, {
    self,
    function(caller)
      self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      self:UnBindInputAction()
    end
  })
  self:BindToAnimationFinished(self.LightOut, {
    self,
    function(caller)
      self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  })
  self:BindToAnimationStarted(self.Down, {
    self,
    function(caller)
      self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    end
  })
  self:BindToAnimationFinished(self.Up, {
    self,
    function(caller)
      if not self:IsAnimationPlaying(self.Out) and not self:IsAnimationPlaying(self.In) and not self:GetVisibility() == UE4.ESlateVisibility.Collapsed then
        self:SetVisibility(UE4.ESlateVisibility.Visible)
      end
    end
  })
  _G.NRCEventCenter:RegisterEvent(self.name, self, EnhancedInputModuleEvent.KeyMappingsChanged, self.PCKeySetting)
  self:PCKeySetting()
end

function UMG_Button_Skip_C:OnDestruct()
  _G.NRCEventCenter:UnRegisterEvent(self, EnhancedInputModuleEvent.KeyMappingsChanged, self.PCKeySetting)
end

function UMG_Button_Skip_C:BindInputAction()
  local mappingContext = self:AddInputMappingContext("IMC_Common_Skip", 90000)
  if mappingContext then
    mappingContext:BindAction("IA_Common_Skip", self, "OnPCKey")
  end
end

function UMG_Button_Skip_C:UnBindInputAction()
  local mappingContext = self:RemoveInputMappingContext("IMC_Common_Skip")
end

function UMG_Button_Skip_C:PCKeySetting()
  if UE4Helper.IsPCMode() and _G.SystemSettingModuleCmd then
    local text, image = _G.NRCModuleManager:DoCmd(SystemSettingModuleCmd.GetMappingKeyUIName, "IA_Common_Skip")
    if "" ~= image then
      self.PCKey:SetImageMode(image)
    else
      self.PCKey:SetText(text)
    end
    self.PCKey:SetKeyVisibility(true)
  end
end

function UMG_Button_Skip_C:OnButtonPressed()
  self:PlayAnimation(self.Down)
end

function UMG_Button_Skip_C:OnButtonReleased()
  self:PlayAnimation(self.Up)
end

function UMG_Button_Skip_C:OnPCKey()
  self.Button.OnClicked:Broadcast()
end

return UMG_Button_Skip_C
