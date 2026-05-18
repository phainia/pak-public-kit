local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_SeasonIntegrationPopUp_Item_C = Base:Extend("UMG_SeasonIntegrationPopUp_Item_C")

function UMG_SeasonIntegrationPopUp_Item_C:OnConstruct()
end

function UMG_SeasonIntegrationPopUp_Item_C:OnDestruct()
end

function UMG_SeasonIntegrationPopUp_Item_C:OnItemUpdate(_data, datalist, index)
  if _data.type == Enum.SeaseonTipsShowType.SEASON_TIPS_IMG then
    self.NRCImage_BannerImg:SetPath(_data.param)
    self.NRCSwitcher_65:SetActiveWidgetIndex(0)
  elseif _data.type == Enum.SeaseonTipsShowType.SEASON_TIPS_TXT then
    self.NRCTextContent:SetText(_data.param)
    self.NRCSwitcher_65:SetActiveWidgetIndex(1)
  elseif _data.type == Enum.SeaseonTipsShowType.SEASON_TIPS_REWARD then
    local rewardConf = _G.DataConfigManager:GetRewardConf(tonumber(_data.param))
    if rewardConf then
      local itemList = {}
      local rewards = rewardConf.RewardItem
      for j = 1, #rewards do
        if rewards[j].Type == Enum.GoodsType.GT_BAGITEM then
          table.insert(itemList, {
            itemType = _G.Enum.GoodsType.GT_BAGITEM,
            itemId = rewards[j].Id,
            itemNum = rewards[j].Count,
            bShowNum = true
          })
        end
        if rewards[j].Type == Enum.GoodsType.GT_VITEM then
          table.insert(itemList, {
            itemType = _G.Enum.GoodsType.GT_VITEM,
            itemId = rewards[j].Id,
            itemNum = rewards[j].Count,
            bShowNum = true
          })
        end
        if rewards[j].Type == Enum.GoodsType.GT_CARD_LABEL then
          table.insert(itemList, {
            itemType = _G.Enum.GoodsType.GT_CARD_LABEL,
            itemId = rewards[j].Id,
            itemNum = rewards[j].Count,
            bShowNum = true
          })
        end
      end
      self.RewardList:InitGridView(itemList)
    end
    self.NRCSwitcher_65:SetActiveWidgetIndex(2)
  elseif _data.type == Enum.SeaseonTipsShowType.SEASON_TIPS_PETS_SHOW then
    if _data.param then
      local itemDataArray = {}
      local allPetBaseId = string.split(_data.param, ";")
      for idx, petBaseId in ipairs(allPetBaseId) do
        table.insert(itemDataArray, {
          id = tonumber(petBaseId)
        })
      end
      self.List_NewPet:InitGridView(itemDataArray)
    end
    self.NRCSwitcher_65:SetActiveWidgetIndex(3)
  end
end

function UMG_SeasonIntegrationPopUp_Item_C:OnItemSelected(_bSelected)
end

function UMG_SeasonIntegrationPopUp_Item_C:OnDeactive()
end

return UMG_SeasonIntegrationPopUp_Item_C
