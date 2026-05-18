local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_LegendaryBattle_CloseItem2_C = Base:Extend("UMG_LegendaryBattle_CloseItem2_C")

function UMG_LegendaryBattle_CloseItem2_C:OnConstruct()
end

function UMG_LegendaryBattle_CloseItem2_C:OnDestruct()
end

function UMG_LegendaryBattle_CloseItem2_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self:SetInfo()
end

function UMG_LegendaryBattle_CloseItem2_C:SetInfo()
  local data = self.data
  local itemType = data.type
  if itemType == _G.Enum.GoodsType.GT_VITEM then
    local vItemsConf = _G.DataConfigManager:GetVisualItemConf(data.id)
    if vItemsConf then
      self.CoinIcon:SetPath(NRCUtils:FormatConfIconPath(vItemsConf.bigIcon, _G.UIIconPath.BagItemPath))
      self.TextQuantity_1:SetText(string.format(" \195\151 %d", data.num))
    else
      self:LogError("VisualItemConf\228\184\173\228\184\141\229\173\152\229\156\168ID" .. data.id .. "\232\175\183\230\163\128\230\159\165\233\133\141\231\189\174")
      self.TextQuantity_1:SetText("")
    end
  elseif itemType == _G.Enum.GoodsType.GT_BAGITEM then
    local bagItemConf = _G.DataConfigManager:GetBagItemConf(data.id)
    self.CoinIcon:SetPath(NRCUtils:FormatConfIconPath(bagItemConf.icon, _G.UIIconPath.BagItemPath))
    self.TextQuantity_1:SetText(string.format(" \195\151 %d", data.num))
  end
end

function UMG_LegendaryBattle_CloseItem2_C:SetColor()
  self.TextQuantity_1:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#D56C1FFF"))
end

function UMG_LegendaryBattle_CloseItem2_C:OnItemSelected(_bSelected)
end

function UMG_LegendaryBattle_CloseItem2_C:OnDeactive()
end

return UMG_LegendaryBattle_CloseItem2_C
