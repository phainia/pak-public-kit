local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Pet_TeamResonance_List1_C = Base:Extend("UMG_Pet_TeamResonance_List1_C")

function UMG_Pet_TeamResonance_List1_C:OnConstruct()
end

function UMG_Pet_TeamResonance_List1_C:OnDestruct()
end

function UMG_Pet_TeamResonance_List1_C:OnItemUpdate(_data, datalist, index)
  self.Number:SetText(string.format("x%d", _data.number))
  self.Text:SetText(_data.skillText)
  local attrText = string.format("%s%d%s", "+", _data.attrData / 100, "%")
  self.Text_2:SetText(attrText)
  self:SetActive(_data.isActive)
end

function UMG_Pet_TeamResonance_List1_C:OnItemSelected(_bSelected)
end

function UMG_Pet_TeamResonance_List1_C:OnDeactive()
end

function UMG_Pet_TeamResonance_List1_C:SetActive(bActive)
  local bgColor = bActive and "FFFFFFFF" or "929086FF"
  local numberColor = bActive and "E2DDD1FF" or "929086FF"
  local Text2Color = bActive and "FFC65FFF" or "929086FF"
  self.Bg:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(bgColor))
  self.Number:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(numberColor))
  self.Text:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(numberColor))
  self.Text_2:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(Text2Color))
  if bActive then
    self.Activated:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Activated:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

return UMG_Pet_TeamResonance_List1_C
