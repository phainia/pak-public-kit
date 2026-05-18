local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local AppearanceUtils = require("NewRoco.Modules.System.Appearance.AppearanceUtils")
local UIUtils = require("NewRoco.Utils.UIUtils")
local UMG_UpgradeSuccPanel_Item_C = Base:Extend("UMG_UpgradeSuccPanel_Item_C")

function UMG_UpgradeSuccPanel_Item_C:OnConstruct()
end

function UMG_UpgradeSuccPanel_Item_C:OnDestruct()
  _G.UpdateManager:UnRegister(self)
end

function UMG_UpgradeSuccPanel_Item_C:OnItemUpdate(_data, datalist, index)
  _G.UpdateManager:Register(self)
  self.uiData = _data
  self.index = index
  self.marqueeSpeed = 0.05
  self:UpdatePanelInfo()
end

function UMG_UpgradeSuccPanel_Item_C:OnItemSelected(_bSelected)
end

function UMG_UpgradeSuccPanel_Item_C:OnDeactive()
  _G.UpdateManager:UnRegister(self)
end

function UMG_UpgradeSuccPanel_Item_C:UpdatePanelInfo()
  self.Closet1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Lock_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.HorizontalBox_91:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local suitConf = _G.DataConfigManager:GetFashionSuitsConf(self.uiData.suitId)
  if not suitConf then
    return
  end
  local currentItem = suitConf.lv_up_closet[self.uiData.index]
  self.SuitName:SetText(currentItem.goods_ui_text)
  local quality, privilege_effect
  if currentItem.lv_item_type == _G.Enum.GoodsType.GT_SALON then
    local salonItemConf = _G.DataConfigManager:GetSalonItemConf(currentItem.lv_item_id)
    self.Icon:SetPath(salonItemConf.icon)
    quality = salonItemConf.item_quality
  elseif currentItem.lv_item_type == _G.Enum.GoodsType.GT_FASHION then
    local fashionItemConf = _G.DataConfigManager:GetFashionItemConf(currentItem.lv_item_id)
    self.Icon:SetPath(fashionItemConf.icon)
    quality = fashionItemConf.item_quality
    if fashionItemConf and fashionItemConf.type == _G.Enum.FashionLabelType.FLT_PENDANTA then
      local pendantaConf = _G.DataConfigManager:GetFashionBagcharmConf(currentItem.lv_item_id)
      if pendantaConf and pendantaConf.charm_kind == _G.Enum.BagCharm.BGC_PETCHARM and 0 ~= pendantaConf.privilege_effect then
        privilege_effect = true
        self.TagImage:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Appearance/Raw/Frames/img_name_tiequan_png.img_name_tiequan_png'")
      end
    end
  elseif currentItem.lv_item_type == _G.Enum.GoodsType.GT_FASHION_SUITS then
    local fashionSuitsConf = _G.DataConfigManager:GetFashionSuitsConf(currentItem.lv_item_id)
    self.Icon:SetPath(fashionSuitsConf.suits_icon)
    quality = fashionSuitsConf.suit_grade
  elseif currentItem.lv_item_type == _G.Enum.GoodsType.GT_FASHION_BOND then
    local bondConf = _G.DataConfigManager:GetFashionBondConf(currentItem.lv_item_id)
    if bondConf then
      self.TagImage:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Appearance/Raw/Frames/img_name_xuancai_png.img_name_xuancai_png'")
      self.Icon:SetPath(bondConf.fashion_bond_big_icon)
      local grade = _G.DataConfigManager:GetFashionSuitsConf(bondConf.suits_id[1]).suit_grade
      quality = 4
      if grade and grade == Enum.SuitGrade.SG_BOND then
        quality = 5
      end
    end
  end
  if quality then
    UIUtils.SetIconQualityColor(self.QualityColor, quality)
    if 5 == quality then
      if privilege_effect then
        self.Selected:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Appearance/Raw/Frames/img_jiesuo_baogua_png.img_jiesuo_baogua_png'")
      else
        self.Selected:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Appearance/Raw/Frames/img_jiesuo_cheng_png.img_jiesuo_cheng_png'")
      end
    elseif 4 == quality then
      self.Selected:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Appearance/Raw/Frames/img_jiesuo_zi_png.img_jiesuo_zi_png'")
    end
  end
end

return UMG_UpgradeSuccPanel_Item_C
