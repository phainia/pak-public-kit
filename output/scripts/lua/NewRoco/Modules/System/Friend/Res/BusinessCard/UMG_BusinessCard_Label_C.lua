local UMG_BusinessCard_Label_C = _G.NRCViewBase:Extend("UMG_BusinessCard_Label_C")

function UMG_BusinessCard_Label_C:OnActive()
end

function UMG_BusinessCard_Label_C:OnDeactive()
end

function UMG_BusinessCard_Label_C:SetLabelText(LabelText)
  self.BriefIntroduction:SetText(LabelText)
end

function UMG_BusinessCard_Label_C:OnModifyLabelText(_FirstId, _LastId)
  if nil == _FirstId and nil == _LastId then
    return false
  end
  local FirstIndex = _FirstId
  local LeftInfo = _G.DataConfigManager:GetCardLabelConf(FirstIndex)
  if LeftInfo.label_type == Enum.LabelType.LT_FIRST then
    self.LT_FIRST = LeftInfo.label_text
  end
  local index = _LastId
  local RightInfo = _G.DataConfigManager:GetCardLabelConf(index)
  if RightInfo.label_type == Enum.LabelType.LT_LAST then
    self.LT_LAST = RightInfo.label_text
  end
  local LabelText = string.format("%s%s", self.LT_FIRST, self.LT_LAST)
  self.BriefIntroduction:SetText(LabelText)
end

function UMG_BusinessCard_Label_C:OnAddEventListener()
end

return UMG_BusinessCard_Label_C
