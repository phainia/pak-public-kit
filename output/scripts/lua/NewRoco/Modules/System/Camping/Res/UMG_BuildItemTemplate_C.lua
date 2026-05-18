local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_BuildItemTemplate_C = Base:Extend("UMG_BuildItemTemplate_C")

function UMG_BuildItemTemplate_C:OnConstruct()
end

function UMG_BuildItemTemplate_C:OnDestruct()
end

function UMG_BuildItemTemplate_C:OnDeactive()
end

function UMG_BuildItemTemplate_C:OnItemUpdate(_data, datalist, index)
  local bagItemId = _data.itemId
  local bagItemConf = _G.DataConfigManager:GetBagItemConf(bagItemId) or nil
  if bagItemConf then
    self.NumText:SetText(bagItemConf.name)
    self:SetQuality(bagItemConf.item_quality)
    self.NRCText_167:SetText(string.format("x%s", _data.itemText))
    self.Icon:SetPath(bagItemConf.big_icon)
  end
end

function UMG_BuildItemTemplate_C:SetQuality(quality)
  local color = UE4.UNRCStatics.HexToSlateColor("#ffffff")
  if 1 == quality then
    color = UE4.UNRCStatics.HexToSlateColor("#ffffff")
  elseif 2 == quality then
    color = UE4.UNRCStatics.HexToSlateColor("#96db71")
  elseif 3 == quality then
    color = UE4.UNRCStatics.HexToSlateColor("#43adef")
  elseif 4 == quality then
    color = UE4.UNRCStatics.HexToSlateColor("#c67fcc")
  elseif 5 == quality then
    color = UE4.UNRCStatics.HexToSlateColor("#e6c142")
  end
  self.NumText:SetColorAndOpacity(color)
end

return UMG_BuildItemTemplate_C
