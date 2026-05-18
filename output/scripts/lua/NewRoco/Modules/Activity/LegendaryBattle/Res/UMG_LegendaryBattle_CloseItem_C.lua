local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_LegendaryBattle_CloseItem_C = Base:Extend("UMG_LegendaryBattle_CloseItem_C")

function UMG_LegendaryBattle_CloseItem_C:OnConstruct()
end

function UMG_LegendaryBattle_CloseItem_C:OnDestruct()
end

function UMG_LegendaryBattle_CloseItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self:SetInfo()
end

function UMG_LegendaryBattle_CloseItem_C:SetInfo()
  if self.data.textCescribe then
    self.TextCescribe:SetText(self.data.textCescribe)
  end
  if self.data.baseBallNum then
    self.TextQuantity:SetText(" \195\151 " .. self.data.baseBallNum)
    self.BallIcon:SetVisibility(UE4.ESlateVisibility.Visible)
    self.BallIcon:SetPath(self.data.iconPath)
  else
    self.TextQuantity:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.BallIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.data.coinNum then
    self.TextQuantity_1:SetText(" \195\151 " .. self.data.coinNum)
    self.CoinIcon:SetVisibility(UE4.ESlateVisibility.Visible)
    self.CoinIcon:SetPath(self.data.rewardIconPath)
  else
    self.TextQuantity_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.CoinIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.data.Rewards and #self.data.Rewards > 0 then
    self.List:InitGridView(self.data.Rewards)
    self.List:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.List:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_LegendaryBattle_CloseItem_C:OnItemSelected(_bSelected)
end

function UMG_LegendaryBattle_CloseItem_C:OnDeactive()
end

return UMG_LegendaryBattle_CloseItem_C
