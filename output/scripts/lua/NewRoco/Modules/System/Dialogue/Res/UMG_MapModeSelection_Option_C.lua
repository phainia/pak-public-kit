local UMG_MapModeSelection_Option_C = _G.NRCViewBase:Extend("UMG_MapModeSelection_Option_C")

function UMG_MapModeSelection_Option_C:OnActive()
end

function UMG_MapModeSelection_Option_C:OnDeactive()
end

function UMG_MapModeSelection_Option_C:SetInfo(Mode, curSelectMode)
  self.mode = Mode
  if Mode == ProtoEnum.NavigationModeType.NMT_MINIMAP then
    self.Picture:SetPath("Texture2D'/Game/NewRoco/Modules/System/Dialogue/Raw/Textures/img_MapModeSelection_Bg1.img_MapModeSelection_Bg1'")
    self.Explain:SetText(LuaText.navigation_mode_map_function_des)
    self.Name:SetText(LuaText.navigation_mode_map_name)
  elseif Mode == ProtoEnum.NavigationModeType.NMT_COMPASS then
    self.Picture:SetPath("Texture2D'/Game/NewRoco/Modules/System/Dialogue/Raw/Textures/img_MapModeSelection_Bg2.img_MapModeSelection_Bg2'")
    self.Explain:SetText(LuaText.navigation_mode_compass_function_des)
    self.Name:SetText(LuaText.navigation_mode_compass_name)
  end
  if curSelectMode == self.mode then
    self:PlayAnimation(self.Selected)
  end
end

function UMG_MapModeSelection_Option_C:PlayUnSelectAnimation(curSelectMode)
  if self.mode ~= curSelectMode then
    self:StopAllAnimations()
    self:PlayAnimation(self.Cancel)
  end
end

function UMG_MapModeSelection_Option_C:OnTouchEnded(MyGeometry, InTouchEvent)
  if self.mode then
    self.panel:SetSelectMode(self.mode)
  end
  _G.NRCAudioManager:PlaySound2DAuto(40003001, "UMG_MapModeSelection_Option_C:OnTouchEnded")
  self:PlayAnimation(self.Selected)
  return UE.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_MapModeSelection_Option_C:OnAnimationFinished(Anim)
  if self.Selected == Anim then
    self:PlayAnimation(self.Selected_Loop, 0, 0)
  end
end

function UMG_MapModeSelection_Option_C:OnAddEventListener()
end

return UMG_MapModeSelection_Option_C
