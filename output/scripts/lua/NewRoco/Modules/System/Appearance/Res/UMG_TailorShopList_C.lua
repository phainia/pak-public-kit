local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local AppearanceUtils = require("NewRoco.Modules.System.Appearance.AppearanceUtils")
local NPCShopUtils = require("NewRoco.Modules.System.NPCShopUI.NPCShopUtils")
local UMG_TailorShopList_C = Base:Extend("UMG_TailorShopList_C")

function UMG_TailorShopList_C:OnConstruct()
end

function UMG_TailorShopList_C:OnDestruct()
  self.uiData = nil
  _G.UpdateManager:UnRegister(self)
end

function UMG_TailorShopList_C:Construct()
  Base.Construct(self)
  self.uiData = {}
  self.SoldOut = false
end

function UMG_TailorShopList_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.uiData = _data
  self:UpdateInfo()
end

function UMG_TailorShopList_C:UpdateInfo()
  local mySuitId = self.uiData.itemId
  local suitConf = _G.DataConfigManager:GetFashionSuitsConf(mySuitId)
  if nil == suitConf then
    return
  end
  local goodsConf = _G.DataConfigManager:GetNormalShopConf(self.uiData.shopItemId)
  if nil == goodsConf then
    return
  end
  local fashionOwned, fashionNotOwned = _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.GetFashionOwnedBySuitId, mySuitId)
  self.bHasOwned = 0 == #fashionNotOwned
  if self.bHasOwned then
    self.Image_zhegai:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.AlreadyOwned:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.Image_zhegai:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.AlreadyOwned:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  local price = goodsConf.origin_price
  local costGoodType = goodsConf.price_goods_type
  local costGoodId = goodsConf.price_goods_id
  local goodsSevData = _G.NRCModuleManager:DoCmd(NPCShopUIModuleCmd.OnCmdGetGoodsSeverData, self.uiData.npcShopId, self.uiData.shopItemId)
  if goodsSevData then
    price = goodsSevData.real_price.num
    costGoodType = goodsSevData.real_price.goods_type
    costGoodId = goodsSevData.real_price.goods_id
  end
  self.CostNum:SetText(tostring(price))
  local fashionSuitConf = _G.DataConfigManager:GetFashionSuitsConf(mySuitId)
  if fashionSuitConf.suits_icon then
    self.Icon:SetPath(fashionSuitConf.suits_icon)
  else
    self.Icon:SetPath("")
  end
  local suitGradeColor, qualityGrade = AppearanceUtils:GetSuitGradeColor(fashionSuitConf.suit_grade)
  self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(suitGradeColor))
  self.Frame_Selected:SetPath(UEPath.TAILOR_SHOP_ITEM_SELECT_BG[qualityGrade])
  local iconPath = NPCShopUtils:GetGoodsCurrencyIconByType(costGoodType, costGoodId)
  self.CostIcon:SetPath(iconPath)
end

function UMG_TailorShopList_C:OnItemSelected(_bSelected)
  if _bSelected then
    if self.uiData.callbackCaller and self.uiData.callbackFunc then
      tcall(self.uiData.callbackCaller, self.uiData.callbackFunc, self, self.index, self.bHasOwned)
    end
    self:StopAllAnimations()
    self:PlayAnimation(self.change1)
  else
    self:StopAllAnimations()
    self:PlayAnimation(self.change1_unselect)
  end
end

function UMG_TailorShopList_C:OnDeactive()
  self:StopAllAnimations()
end

function UMG_TailorShopList_C:OnAnimationFinished(anim)
  if anim == self.change1 then
    self:PlayAnimation(self.change1_Loop, 0.0, 9999)
  end
end

function UMG_TailorShopList_C:GetItemCurrentPrice()
  local goodsConf = _G.DataConfigManager:GetNormalShopConf(self.uiData.shopItemId)
  if nil == goodsConf then
    return nil
  end
  local fashionOwned, fashionNotOwned = _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.GetFashionOwnedBySuitId, self.uiData.itemId)
  local price = goodsConf.origin_price
  if fashionOwned and #fashionOwned > 0 then
    for k, v in ipairs(fashionOwned) do
    end
  end
  return price
end

return UMG_TailorShopList_C
