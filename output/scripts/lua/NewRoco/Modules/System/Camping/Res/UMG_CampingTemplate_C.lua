local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_CampingTemplate_C = Base:Extend("UMG_CampingTemplate_C")

function UMG_CampingTemplate_C:OnConstruct()
end

function UMG_CampingTemplate_C:OnDestruct()
end

function UMG_CampingTemplate_C:OnItemUpdate(_data, datalist, index)
  self.itemId = _data.itemId
  self.itemType = _data.itemType
  if not _data.itemType or _data.itemType == _G.Enum.GoodsType.GT_BAGITEM then
    local bagItemConf = _G.DataConfigManager:GetBagItemConf(_data.itemId)
    if bagItemConf then
      self:SetQuality(bagItemConf.item_quality)
      self.ItemIcon:SetPath(bagItemConf.icon)
    end
  elseif not _data.itemType or _data.itemType == _G.Enum.GoodsType.GT_VITEM then
    local vItemConf = _G.DataConfigManager:GetVisualItemConf(_G.Enum.VisualItem.VI_STAR)
    if nil ~= vItemConf then
      self:SetQuality(vItemConf.item_quality)
      self.ItemIcon:SetPath(vItemConf.bigIcon)
    end
  end
  self.ItemNumText:SetText(self:GetFormatNumText(_data.itemNum, _data.itemNeedNum))
end

function UMG_CampingTemplate_C:GetFormatNumText(itemNum, itemNeedNum)
  local itemText = ""
  if itemNeedNum then
    local redStr = "color=\"#ff696b\""
    local whiteStr = "color=\"#ffffff\""
    local fontStr = "font=\"/Game/NewRoco/Font/huakanglangman_Font\""
    local fmtStr = "<span size=\"12\" %s %s>%d</><span size=\"12\" %s %s>/%d</>"
    if itemNum < itemNeedNum then
      itemText = string.format(fmtStr, redStr, fontStr, itemNum, whiteStr, fontStr, itemNeedNum)
    else
      itemText = string.format(fmtStr, whiteStr, fontStr, itemNum, whiteStr, fontStr, itemNeedNum)
    end
  else
    itemText = tostring(itemNum)
  end
  return itemText
end

function UMG_CampingTemplate_C:SetQuality(quality)
  if 0 == quality then
  elseif 1 == quality then
    self.ItemIconBG:SetPath(UEPath.PROP_QUALITY_1)
  elseif 2 == quality then
    self.ItemIconBG:SetPath(UEPath.PROP_QUALITY_2)
  elseif 3 == quality then
    self.ItemIconBG:SetPath(UEPath.PROP_QUALITY_3)
  elseif 4 == quality then
    self.ItemIconBG:SetPath(UEPath.PROP_QUALITY_4)
  elseif 5 == quality then
    self.ItemIconBG:SetPath(UEPath.PROP_QUALITY_5)
  end
end

function UMG_CampingTemplate_C:OnItemSelected(_bSelected)
  if _bSelected then
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1004, "UMG_CampingTemplate_C:OnItemSelected")
    _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, self.itemId, self.itemType, false)
  end
end

function UMG_CampingTemplate_C:OnDeactive()
end

return UMG_CampingTemplate_C
