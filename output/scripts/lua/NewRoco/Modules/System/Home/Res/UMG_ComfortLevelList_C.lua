local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ComfortLevelList_C = Base:Extend("UMG_ComfortLevelList_C")

function UMG_ComfortLevelList_C:OnConstruct()
end

function UMG_ComfortLevelList_C:OnDestruct()
end

function UMG_ComfortLevelList_C:OnItemUpdate(_data, datalist, index)
  self.NRCText_4:SetText(_data.coordinate)
  local p = math.floor((_data.furniture_coin_ratio or 0) / 100)
  if 0 ~= p and 100 ~= p then
    self.NRCText:SetText(LuaText.comfort_tips_furniture_coin_add)
    self.NRCText_1:SetText(string.format("%d%%", p))
    self.NRCText:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.NRCText_1:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.NRCText:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.NRCText_1:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  local p2 = math.floor((_data.home_exp_ratio or 0) / 100)
  if 0 ~= p2 and 100 ~= p2 then
    self.NRCText_2:SetText(LuaText.comfort_tips_home_exp_add)
    self.NRCText_3:SetText(string.format("%d%%", p2))
    self.NRCText_2:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.NRCText_3:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.NRCText_2:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.NRCText_3:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  if index == #datalist and self.NRCImage_212 then
    self.NRCImage_212:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

function UMG_ComfortLevelList_C:OnItemSelected(_bSelected)
end

function UMG_ComfortLevelList_C:OnDeactive()
end

return UMG_ComfortLevelList_C
