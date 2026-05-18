local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_ItemBase_C")
local UMG_Activity_StageAwardItem_Icon_C = Base:Extend("UMG_Activity_StageAwardItem_Icon_C")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")

function UMG_Activity_StageAwardItem_Icon_C:OnConstruct()
  Base.OnConstruct(self)
  self.Btn.OnClicked:Add(self, self.OnBtnSelect)
end

function UMG_Activity_StageAwardItem_Icon_C:OnDestruct()
  Base.OnDestruct(self)
  self.Btn.OnClicked:Clear()
end

function UMG_Activity_StageAwardItem_Icon_C:OnItemUpdate(_data, datalist, index)
  Base.OnItemUpdate(self, _data, datalist, index)
  self.Btn.OnClicked:Clear()
  self:SetData(_data)
end

function UMG_Activity_StageAwardItem_Icon_C:OnItemSelected(_bSelected)
  Base.OnItemSelected(self, _bSelected)
  self:SetSelect(_bSelected)
  if _bSelected then
    self:ShowTips()
  end
end

function UMG_Activity_StageAwardItem_Icon_C:SetData(itemData)
  self.itemData = itemData
  self:SetIcon()
  self.Num:SetText("x" .. itemData.itemNum)
  self:SetSelect(false)
  ActivityUtils.SetRewardItemQuality(self.Quality, itemData.itemQuality)
end

function UMG_Activity_StageAwardItem_Icon_C:SetSelect(_select)
  self.xuanzhong:SetVisibility(_select and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  if _select then
  else
    self:TryPlayAnimation(self.normal, false, 0)
  end
end

function UMG_Activity_StageAwardItem_Icon_C:OnBtnSelect()
  self:ShowTips()
  local itemData = self.itemData
  if itemData and itemData.callbackWhenSelect then
    itemData.callbackWhenSelect(self)
  end
end

function UMG_Activity_StageAwardItem_Icon_C:ShowTips()
  local itemData = self.itemData
  if itemData then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Tips_OpenItemTips, itemData.itemId, itemData.itemType)
  end
end

function UMG_Activity_StageAwardItem_Icon_C:SetIcon()
  local isEgg
  if self.itemData and self.itemData.itemType == _G.Enum.GoodsType.GT_BAGITEM then
    local bagItemConf = _G.DataConfigManager:GetBagItemConf(self.itemData.itemId)
    if bagItemConf and bagItemConf.type == _G.Enum.BagItemType.BI_PET_EGG and bagItemConf.item_behavior and bagItemConf.item_behavior[1] and bagItemConf.item_behavior[1].ratio2 and bagItemConf.item_behavior[1].ratio2[1] then
      local eggInfo = {}
      eggInfo.random_egg_conf = bagItemConf.item_behavior[1].ratio2[1]
      self.IconSwitcher:SetActiveWidgetIndex(1)
      self.PetEggIcon:SetEggIcon(eggInfo, self.itemData.showIcon)
      isEgg = true
    end
  end
  if not isEgg then
    if self.IconSwitcher then
      self.IconSwitcher:SetActiveWidgetIndex(0)
    end
    self.Icon:SetPath(self.itemData.showIcon)
  end
end

return UMG_Activity_StageAwardItem_Icon_C
