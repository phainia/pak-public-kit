local UMG_GeneralReward_C = _G.NRCViewBase:Extend("UMG_GeneralReward_C")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")

function UMG_GeneralReward_C:OnConstruct()
end

function UMG_GeneralReward_C:OnDestruct()
end

function UMG_GeneralReward_C:SetData(data)
  if not string.IsNilOrEmpty(data.title) then
    self.title:SetText(data.title)
  else
    self.title:SetText(_G.LuaText.activity_reward_preview_text_prompt)
  end
  local itemList = data.itemList or {}
  local maxItemCnt = #itemList
  local itemTypesData = table.new(0, maxItemCnt)
  do
    local function AddItemData(itemType, itemId, itemNum)
      local typeItems = itemTypesData[itemType]
      
      if not typeItems then
        typeItems = table.new(0, maxItemCnt)
        itemTypesData[itemType] = typeItems
      end
      local curNum = typeItems[itemId] or 0
      typeItems[itemId] = curNum + itemNum
    end
    
    for _, item in ipairs(itemList) do
      if item.itemType == _G.Enum.GoodsType.GT_REWARD then
        local rewardData = _G.DataConfigManager:GetRewardConf(item.itemId, true)
        if rewardData and rewardData.RewardItem then
          for _, rewardItem in ipairs(rewardData.RewardItem) do
            AddItemData(rewardItem.Type, rewardItem.Id, rewardItem.Count)
          end
        end
      else
        AddItemData(item.itemType, item.itemId, item.itemNum)
      end
    end
  end
  local rewardsTable = table.new(maxItemCnt, 0)
  for itemType, itemInTypes in pairs(itemTypesData) do
    for itemId, itemNum in pairs(itemInTypes) do
      local _, itemQuality = ActivityUtils.GetItemIconAndQuality(itemType, itemId)
      local itemData = table.copy(data.itemDataTemplate)
      itemData.itemType = itemType
      itemData.itemId = itemId
      itemData.itemNum = itemNum
      itemData.iconSortId = itemQuality
      table.insert(rewardsTable, itemData)
    end
  end
  table.sort(rewardsTable, function(a, b)
    if a.itemType == _G.Enum.GoodsType.GT_VITEM and b.itemType ~= _G.Enum.GoodsType.GT_VITEM then
      return true
    elseif a.itemType ~= _G.Enum.GoodsType.GT_VITEM and b.itemType == _G.Enum.GoodsType.GT_VITEM then
      return false
    elseif a.iconSortId == b.iconSortId then
      return a.itemId < b.itemId
    else
      return a.iconSortId > b.iconSortId
    end
  end)
  ActivityUtils.AdjustCtrlAutoSize(self.AwardList, #rewardsTable <= 4)
  ActivityUtils.AdjustCtrlSize(self.BG, {
    175,
    326,
    477,
    627
  }, #rewardsTable)
  self.AwardList:InitList(rewardsTable)
end

return UMG_GeneralReward_C
