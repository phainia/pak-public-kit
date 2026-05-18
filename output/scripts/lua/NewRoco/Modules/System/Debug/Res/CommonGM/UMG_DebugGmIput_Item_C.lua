local UMG_DebugGmIput_Item_C = _G.NRCPanelBase:Extend("UMG_DebugGmIput_Item_C")

function UMG_DebugGmIput_Item_C:OnActive()
end

function UMG_DebugGmIput_Item_C:OnDeactive()
end

function UMG_DebugGmIput_Item_C:OnAddEventListener()
end

function UMG_DebugGmIput_Item_C:SetText(_Text, HintText, require)
  local Input
  if require then
    Input = string.format("%s%s", _Text, "*")
  else
    Input = _Text
  end
  self.Text:SetText(Input)
  self.InputBox:SetHintText(HintText)
end

function UMG_DebugGmIput_Item_C:GetInputBox()
  return self.InputBox:GetText()
end

function UMG_DebugGmIput_Item_C:SetColor(LinearColor)
  self.Text:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(LinearColor))
end

return UMG_DebugGmIput_Item_C
