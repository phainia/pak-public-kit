local UMG_PetEvolutionSelectTemple_C = _G.NRCViewBase:Extend("UMG_PetEvolutionSelectTemple_C")

function UMG_PetEvolutionSelectTemple_C:OnConstruct()
end

function UMG_PetEvolutionSelectTemple_C:OnDestruct()
  self.uiData = nil
end

function UMG_PetEvolutionSelectTemple_C:SetData(_data)
  self.uiData = _data
end

function UMG_PetEvolutionSelectTemple_C:SetSelectState(_flag)
  if self.isSelect ~= _flag then
    self.isSelect = _flag
    self:setActive(self.imgSelect, self.isSelect)
    self:setActive(self.imgNormal, not self.isSelect)
  end
end

function UMG_PetEvolutionSelectTemple_C:OnTouchEnded(_myGeometry, _inTouchEvent)
  local data = self.uiData
  if data then
    if data.callbackCaller and data.callbackFunc then
      tcall(data.callbackCaller, data.callbackFunc, data.index or -1, true)
    end
    if data.soundId then
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(data.soundId, "UMG_PetEvolutionSelectTemple_C:OnTouchEnded")
    end
  end
  return UE.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_PetEvolutionSelectTemple_C:setActive(_uiItem, _isShow)
  if _uiItem then
    if _isShow then
      _uiItem:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      _uiItem:SetVisibility(UE4.ESlateVisibility.Hidden)
    end
  end
end

return UMG_PetEvolutionSelectTemple_C
