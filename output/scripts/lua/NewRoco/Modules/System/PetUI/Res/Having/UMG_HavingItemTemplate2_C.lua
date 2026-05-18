local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_HavingItemTemplate2_C = Base:Extend("UMG_HavingItemTemplate2_C")

function UMG_HavingItemTemplate2_C:OnConstruct()
end

function UMG_HavingItemTemplate2_C:OnDestruct()
end

function UMG_HavingItemTemplate2_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self:SetInfo()
end

function UMG_HavingItemTemplate2_C:SetInfo()
  local data = self.data
  local BagItemConf = _G.DataConfigManager:GetBagItemConf(data.cost_item)
  self.ItemIcon:SetPath(BagItemConf.icon)
  self:SetQuality(BagItemConf.item_quality)
  local BagItemNum = self:getItemCount(data.cost_item)
  if BagItemNum >= data.cost_num then
    self.NumText:SetText(string.format("%d/%d", data.cost_num, BagItemNum))
  else
    self.NumText:SetText(string.format("<span color=\"#FF494BFF\" size=\"14\" font=\"/Game/NewRoco/Font/huakanglangman_Font\">%d</>/%d", BagItemNum, data.cost_num))
  end
end

function UMG_HavingItemTemplate2_C:getItemCount(_itemId)
  local itemData = _G.NRCModeManager:DoCmd(BagModuleCmd.GetBagItemByID, _itemId)
  if itemData then
    return itemData.num or 0
  end
  return 0
end

function UMG_HavingItemTemplate2_C:SetQuality(quality)
  if 0 == quality then
    self.BGColor:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Common/Raw/Frames/img_daojukuangkong_png.img_daojukuangkong_png'")
  elseif 1 == quality then
    self.BGColor:SetPath(UEPath.PROP_QUALITY_1)
  elseif 2 == quality then
    self.BGColor:SetPath(UEPath.PROP_QUALITY_2)
  elseif 3 == quality then
    self.BGColor:SetPath(UEPath.PROP_QUALITY_3)
  elseif 4 == quality then
    self.BGColor:SetPath(UEPath.PROP_QUALITY_4)
  elseif 5 == quality then
    self.BGColor:SetPath(UEPath.PROP_QUALITY_5)
  end
end

function UMG_HavingItemTemplate2_C:OnItemSelected(_bSelected)
  if _bSelected then
    _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.Tips_OpenItemTips, self.data.cost_item, _G.Enum.GoodsType.GT_BAGITEM)
  end
end

function UMG_HavingItemTemplate2_C:OnDeactive()
end

return UMG_HavingItemTemplate2_C
