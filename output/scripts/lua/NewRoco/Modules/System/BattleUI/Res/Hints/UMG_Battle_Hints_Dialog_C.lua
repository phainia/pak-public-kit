local UMG_Battle_Hints_Dialog_C = _G.NRCPanelBase:Extend("UMG_Battle_Hints_Dialog_C")

function UMG_Battle_Hints_Dialog_C:OnAnimationFinished(anim)
  if anim == self.Open and not self.isHide then
    self:PlayAnimation(self.Loop)
  elseif anim == self.Close and self.isHide then
    self:SetVisibility(UE.ESlateVisibility.Collapsed)
    self:SetRenderOpacity(0)
  end
end

function UMG_Battle_Hints_Dialog_C:Show()
  self.isHide = false
  self:SetRenderOpacity(1)
  self:StopAllAnimations()
  self:PlayAnimation(self.Open)
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_Battle_Hints_Dialog_C:Hide()
  self.isHide = true
  self:StopAllAnimations()
  self:PlayAnimation(self.Close)
end

function UMG_Battle_Hints_Dialog_C:SetData(text, type)
  self.Type = type
  local lenInByte = #text
  local characterCount = 0
  local endLinePos, endLinePosInit
  local i = 1
  while lenInByte >= i do
    local modifyCount = false
    local curByte = string.byte(text, i)
    local byteCount = 1
    if curByte > 0 and curByte <= 127 then
      byteCount = 1
    elseif curByte >= 192 and curByte < 223 then
      byteCount = 2
    elseif curByte >= 224 and curByte < 239 then
      characterCount = characterCount + 1
      modifyCount = true
      byteCount = 3
    elseif curByte >= 240 and curByte <= 247 then
      byteCount = 4
    end
    if modifyCount then
      if 5 == characterCount then
        endLinePosInit = i - 1
      elseif 7 == characterCount then
        endLinePos = i - 1
      end
    end
    i = byteCount - 1 > 0 and i + byteCount - 1 or i + 1
  end
  if characterCount <= 4 then
    self.Switcher_Bg:SetActiveWidgetIndex(0)
    self.RichText:SetText(text)
    return
  else
    self.Switcher_Bg:SetActiveWidgetIndex(1)
    if characterCount > 7 and endLinePos then
      text = text:sub(1, endLinePos) .. "\n" .. text:sub(endLinePos + 1)
    elseif 7 == characterCount and endLinePosInit then
      text = text:sub(1, endLinePosInit) .. "\n" .. text:sub(endLinePosInit + 1)
    end
    self.RichText_1:SetText(text)
    return
  end
end

function UMG_Battle_Hints_Dialog_C:GetType()
  return self.Type
end

function UMG_Battle_Hints_Dialog_C:CheckIsChineseCharacter(curByte)
  return curByte >= 224 and curByte < 239
end

function UMG_Battle_Hints_Dialog_C:IsHide()
  return self.Visibility == UE4.ESlateVisibility.Collapsed or self.Visibility == UE4.ESlateVisibility.Hidden or 0 == self:GetRenderOpacity() or self:IsAnimationPlaying(self.Close)
end

return UMG_Battle_Hints_Dialog_C
