local CinematicModuleEvent = reload("NewRoco.Modules.Core.Cinematic.CinematicModuleEvent")
local UMG_CinematicBlackScreen_C = _G.NRCPanelBase:Extend("UMG_CinematicBlackScreen_C")

function UMG_CinematicBlackScreen_C:OnConstruct()
  self.Module = _G.NRCModuleManager:GetModule("CinematicModule")
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
    end
  })
  self:BindToAnimationStarted(self.FadeOut, {
    self,
    function(caller)
      self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    end
  })
  self:BindToAnimationFinished(self.FadeOut, {
    self,
    function(caller)
      self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  })
end

function UMG_CinematicBlackScreen_C:OnDestruct()
end

function UMG_CinematicBlackScreen_C:OnActive(caller, callback)
  if not self.Module then
    self.Module = _G.NRCModuleManager:GetModule("CinematicModule")
  end
  if self.Module then
    self.Module:RegisterEvent(self, CinematicModuleEvent.CloseBlackScreen, self.CloseBlackScreen)
    self.Module:RegisterEvent(self, CinematicModuleEvent.OpenBlackScreen, self.OpenBlackScreen)
  else
    Log.Error("\230\151\160\230\179\149\230\137\190\229\136\176CinematicModule")
  end
  self:RefreshView(caller, callback)
end

function UMG_CinematicBlackScreen_C:RefreshView(Caller, Callback)
  if Callback then
    Callback(Caller)
    self:SetVisibility(UE.ESlateVisibility.Visible)
  else
    self:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

function UMG_CinematicBlackScreen_C:OnAnimationFinished(Animation)
  Log.Debug("UMG_CinematicBlackScreen_C:OnAnimationFinished", UE.UObject.GetName(Animation))
  if Animation == self.FadeIn then
    self.Module:DispatchEvent(CinematicModuleEvent.BlackScreenIn)
  elseif Animation == self.FadeOut then
    self:SetInputEnable(true)
    self.Module:DispatchEvent(CinematicModuleEvent.BlackScreenOut)
  end
end

function UMG_CinematicBlackScreen_C:CloseBlackScreen(bFadeIn)
  Log.Debug("UMG_CinematicBlackScreen_C:CloseBlackScreen", bFadeIn and "true" or "false")
  self:StopAllAnimations()
  self:PlayAnimation(self.FadeOut, 0, 1, 0, bFadeIn and 2 or 999)
  self:SetInputEnable(true)
end

function UMG_CinematicBlackScreen_C:OnDisable()
  self:SetInputEnable(true)
end

function UMG_CinematicBlackScreen_C:OpenBlackScreen(bFadeIn)
  Log.Debug("UMG_CinematicBlackScreen_C:OpenBlackScreen", bFadeIn and "true" or "false")
  self:StopAllAnimations()
  self:PlayAnimation(self.FadeIn, 0, 1, 0, bFadeIn and 2 or 999)
  self:SetInputEnable(false)
end

function UMG_CinematicBlackScreen_C:SetInputEnable(enabled)
  _G.UE4Helper.ToggleInput(self, enabled, "CinematicBlackScreen")
end

function UMG_CinematicBlackScreen_C:OnDeactive()
  if self.Module then
    self.Module:UnRegisterEvent(self, CinematicModuleEvent.CloseBlackScreen)
    self.Module:UnRegisterEvent(self, CinematicModuleEvent.OpenBlackScreen)
    self.Module = nil
  end
  self:SetInputEnable(true)
end

return UMG_CinematicBlackScreen_C
