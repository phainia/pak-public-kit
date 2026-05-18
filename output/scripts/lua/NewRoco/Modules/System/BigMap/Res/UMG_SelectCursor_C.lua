local UMG_SelectCursor_C = NRCClass()

function UMG_SelectCursor_C:showAni(_pos)
  if _pos then
    self.Slot:SetPosition(_pos)
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:PlayCursorAnim(self.Nomarl)
    self.isPlayOpenAni = true
    self.isShow = true
    self.waitPlayOutAni = false
  end
end

function UMG_SelectCursor_C:setShowPosition(_pos)
  if _pos then
    self.Slot:SetPosition(_pos)
  end
end

function UMG_SelectCursor_C:showEndAni()
  if self.isPlayOpenAni then
    self.waitPlayOutAni = true
  else
    self:PlayCursorAnim(self.Select_Out)
  end
end

function UMG_SelectCursor_C:PlayCursorAnim(_animation)
  if self.curPlayAnim == _animation then
    return
  end
  if self.curPlayAnim then
    self.nextAnim = _animation
    return
  end
  self.curPlayAnim = _animation
  self:PlayAnimation(_animation)
end

function UMG_SelectCursor_C:OnAnimationFinished(_animation)
  self.curPlayAnim = nil
  if _animation == self.Select_In then
    self.isPlayOpenAni = false
    if self.waitPlayOutAni then
      self.waitPlayOutAni = false
      self:PlayCursorAnim(self.Select_Out)
    end
  elseif _animation == self.ChangeInfo_Out then
    self:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.isShow = false
  elseif _animation == self.Nomarl then
    self.Select:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:PlayCursorAnim(self.Select_In)
  elseif _animation == self.Select_Out then
    self.isShow = false
    if self.nextAnim == self.Nomarl then
      self:PlayCursorAnim(self.Nomarl)
      self.isPlayOpenAni = true
      self.isShow = true
      self.waitPlayOutAni = false
      self.nextAnim = nil
    end
  end
end

return UMG_SelectCursor_C
