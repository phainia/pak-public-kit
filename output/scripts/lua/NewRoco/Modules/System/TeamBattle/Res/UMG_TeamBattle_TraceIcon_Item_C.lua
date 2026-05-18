local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UIUtils = require("NewRoco.Utils.UIUtils")
local UMG_TeamBattle_TraceIcon_Item_C = Base:Extend("UMG_TeamBattle_TraceIcon_Item_C")

function UMG_TeamBattle_TraceIcon_Item_C:OnConstruct()
end

function UMG_TeamBattle_TraceIcon_Item_C:OnDestruct()
end

function UMG_TeamBattle_TraceIcon_Item_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  if _data.Type == _G.Enum.GoodsType.GT_BAGITEM then
    local bagItemConf = _G.DataConfigManager:GetBagItemConf(_data.Id)
    self.Icon:SetPath(bagItemConf.icon)
    UIUtils.SetIconQualityColor(self.BGColor, bagItemConf.item_quality)
  elseif _data.Type == _G.Enum.GoodsType.GT_VITEM then
    local vItemConf = _G.DataConfigManager:GetVisualItemConf(_data.Id)
    self.Icon:SetPath(vItemConf.bigIcon)
    UIUtils.SetIconQualityColor(self.BGColor, vItemConf.item_quality)
  end
  self.Text_Quantity:SetText(_data.Count)
  if _data.Count > 0 then
    self.Quantity:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Quantity:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_TeamBattle_TraceIcon_Item_C:OnItemSelected(_bSelected)
  if _bSelected then
    _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.Tips_OpenItemTips, self.uiData.Id, self.uiData.Type, false, self.uiData.Count)
  end
end

function UMG_TeamBattle_TraceIcon_Item_C:OnDeactive()
end

return UMG_TeamBattle_TraceIcon_Item_C
